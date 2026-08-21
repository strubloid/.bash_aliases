#!/bin/bash

# Strubloid::linux::DND
#
# dnd-video-cut-low-volume-spaces
#
# Removes background-only / silence sections from a video while preserving every
# intelligible human speech segment, even when the speaker is quiet.
#
# THIS IS NOT "find quiet audio and cut it".
# THIS IS "find sections without understandable human speech and remove them,
#           while protecting human speech even when it is whispered."
#
# Priority: HUMAN SPEECH > BACKGROUND AUDIO > VOLUME
# Low volume never implies silence.
#
# Strategy:
#   1. Extract audio (16 kHz mono).
#   2. Run WebRTC VAD  -> speech-like regions (fast, robust, local).
#   3. Run Whisper     -> word-level timestamps + confidence (definitive
#                         evidence of intelligible human speech).
#   4. Classify each audio region into:
#        - "speech"        -> keep (whisper transcribed a word here)
#        - "vad_only"      -> remove but flag for manual review
#        - "silence"       -> remove automatically (no review needed)
#   5. Render candidate-final.mp4 (obvious removals already applied).
#   6. Extract questionable leftovers so the user only listens to ambiguous
#      removals.
#   7. Interactive review restores anything that actually contains voice.
#   8. Render final.mp4 with all decisions applied at their original positions.
#
# Workflow / resume:
#   - The first run creates <input>.dnd-cut/ with analysis, candidate-final.mp4
#     and the leftover review bundle. Review decisions are persisted to
#     decisions.json. Re-running the command prompts for resume / rebuild /
#     re-analyze / fresh.
#
# Usage:
#   dnd-video-cut-low-volume-spaces <video-file>

# =============================================================================
# CONFIGURATION  --  tune these without touching the processing logic.
# =============================================================================

# Padding around detected speech, in seconds. Prevents clipped words.
PRE_ROLL="${DND_PRE_ROLL:-0.30}"
POST_ROLL="${DND_POST_ROLL:-0.40}"

# A non-speech gap shorter than this is left alone (avoids micro-cuts).
MIN_REMOVE_DURATION="${DND_MIN_REMOVE_DURATION:-0.80}"

# A speech region shorter than this is treated as noise/breath (not kept).
MIN_SPEECH_DURATION="${DND_MIN_SPEECH_DURATION:-0.25}"

# Whisper word probability above this counts as confirmed intelligible speech.
SPEECH_KEEP_THRESHOLD="${DND_SPEECH_KEEP_THRESHOLD:-0.40}"

# WebRTC VAD is binary (speech / not-speech). A vad_only region with no Whisper
# text is flagged for review regardless of confidence.
SPEECH_REVIEW_THRESHOLD="${DND_SPEECH_REVIEW_THRESHOLD:-0.50}"

# Whisper model.  small = good speed/accuracy trade-off on CPU.
WHISPER_MODEL="${DND_WHISPER_MODEL:-small}"
WHISPER_LANGUAGE="${DND_WHISPER_LANGUAGE:-en}"
WHISPER_DEVICE="${DND_WHISPER_DEVICE:-cpu}"

# Audio player used during manual review.
DND_AUDIO_PLAYER="${DND_AUDIO_PLAYER:-ffplay -hide_banner -loglevel error -autoexit -nodisp}"

# Whether to auto-resume when prior state is detected.
DND_AUTO_RESUME="${DND_AUTO_RESUME:-ask}"   # ask|yes|no

# Python virtualenv that ships whisper + webrtcvad.
BASH_ALIASES_VENV_BIN="${BASH_ALIASES_VENV_BIN:-$HOME/.bash_aliases_scripts/.venv/bin}"

# =============================================================================
# UTILITY
# =============================================================================

function dnd-log()  { printf '[dnd] %s\n' "$*"; }
function dnd-warn() { printf '[dnd][warn] %s\n' "$*" >&2; }
function dnd-err()  { printf '[dnd][error] %s\n' "$*" >&2; }

function dnd-format-ts() {
  # dnd-format-ts <seconds>  -> "HH:MM:SS.mmm"
  local s="${1}"
  awk -v s="$s" 'BEGIN {
    h = int(s / 3600); s -= h*3600
    m = int(s / 60);   s -= m*60
    printf "%02d:%02d:%06.3f\n", h, m, s
  }'
}

# =============================================================================
# DEPENDENCY CHECK
# =============================================================================

function dnd-dependencies-check() {
  local missing=()
  local have_whisper=1
  local have_vad=1

  command -v ffmpeg  >/dev/null 2>&1 || missing+=("ffmpeg")
  command -v ffprobe >/dev/null 2>&1 || missing+=("ffprobe")
  command -v jq      >/dev/null 2>&1 || missing+=("jq")
  command -v python3 >/dev/null 2>&1 || missing+=("python3")

  if [[ ! -x "${BASH_ALIASES_VENV_BIN}/whisper" ]]; then
    have_whisper=0
    missing+=("whisper (expected at ${BASH_ALIASES_VENV_BIN}/whisper)")
  fi

  if ! "${BASH_ALIASES_VENV_BIN}/python" -c "import webrtcvad, scipy.io.wavfile, numpy" 2>/dev/null; then
    have_vad=0
    missing+=("webrtcvad / scipy.io.wavfile / numpy in the bash_aliases venv")
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    dnd-err "Missing dependencies:"
    for dep in "${missing[@]}"; do
      dnd-err "  - $dep"
    done
    dnd-err "Install with: ${BASH_ALIASES_VENV_BIN}/pip install webrtcvad scipy numpy"
    return 1
  fi

  dnd-log "Dependencies OK  (whisper=$have_whisper vad=$have_vad)"
  return 0
}

# =============================================================================
# WORKSPACE / RESUME
# =============================================================================

function dnd-workspace-path() {
  # dnd-workspace-path <input> -> "<dirname>/<basename-noext>.dnd-cut"
  local input="$1"
  local dir
  local base
  dir="$(dirname "$input")"
  base="$(basename "${input%.*}")"
  printf '%s/%s.dnd-cut\n' "$dir" "$base"
}

function dnd-workspace-init() {
  local ws="$1"
  mkdir -p "$ws/analysis" "$ws/leftovers" "$ws/segments" "$ws/review"
  : > "$ws/review/review.log"
}

function dnd-has-state() {
  # dnd-has-state <workspace>  ->  returns 0 when an existing run is detected
  local ws="$1"
  [[ -f "$ws/analysis/audio.json" || -f "$ws/decisions.json" ]]
}

function dnd-valid-json() {
  # dnd-valid-json <path>  ->  returns 0 when file exists and parses as JSON
  local p="$1"
  [[ -f "$p" ]] || return 1
  jq empty "$p" >/dev/null 2>&1
}

function dnd-resume-prompt() {
  # Echoes one of: resume | rebuild-timeline | fresh | abort
  # Side effects: cleans up files according to the choice.
  local ws="$1"
  local choice

  if [[ "$DND_AUTO_RESUME" == "yes" ]]; then choice="r"; fi

  if [[ -z "${choice:-}" ]]; then
    dnd-log "Existing workspace detected: $ws"
    dnd-log "  [r] Resume (reuse analysis + decisions)"
    dnd-log "  [t] Rebuild timeline (keep audio/VAD/Whisper, rebuild cuts)"
    dnd-log "  [a] Re-analyze (keep workspace, redo audio/VAD/Whisper)"
    dnd-log "  [f] Fresh start (wipe workspace)"
    while true; do
      read -r -n 1 -p "[dnd] Choose [r/t/a/f]: " choice
      echo
      case "$choice" in
        r|t|a|f) break ;;
        *) dnd-warn "Please press r, t, a or f." ;;
      esac
    done
  fi

  case "$choice" in
    r) dnd-log "Resuming."; printf 'resume\n'; return 0 ;;
    t) rm -f "$ws/decisions.json" "$ws/candidate-final.mp4" "$ws/final.mp4" "$ws/analysis/timeline.json" "$ws/analysis/final-plan.json"
       rm -rf "$ws/leftovers" "$ws/segments"
       mkdir -p "$ws/leftovers" "$ws/segments"
       dnd-log "Rebuilding timeline from existing analysis."; printf 'rebuild-timeline\n'; return 0 ;;
    a) rm -f "$ws/decisions.json" "$ws/candidate-final.mp4" "$ws/final.mp4" \
          "$ws/analysis/timeline.json" "$ws/analysis/final-plan.json" \
          "$ws/analysis/audio.wav" "$ws/analysis/vad.json" "$ws/analysis/audio.json"
       rm -rf "$ws/leftovers" "$ws/segments"
       mkdir -p "$ws/leftovers" "$ws/segments"
       dnd-log "Re-running analysis."; printf 'reanalyze\n'; return 0 ;;
    f) dnd-log "Wiping workspace."; rm -rf "$ws"; dnd-workspace-init "$ws"
       printf 'fresh\n'; return 0 ;;
  esac
}

# =============================================================================
# METADATA
# =============================================================================

function dnd-extract-metadata() {
  # Writes JSON to <workspace>/analysis/metadata.json and prints duration.
  local input="$1"
  local ws="$2"
  local out="$ws/analysis/metadata.json"

  ffprobe -v error \
    -show_entries stream=index,codec_type,codec_name,width,height,r_frame_rate,sample_rate,channels,bit_rate \
    -show_entries format=duration,bit_rate,size,format_name \
    -of json "$input" > "$out"

  jq -r '.format.duration // empty' "$out"
}

# =============================================================================
# AUDIO EXTRACTION
# =============================================================================

function dnd-extract-audio() {
  # 16 kHz / mono / pcm_s16le -- Whisper + Silero-VAD's preferred format.
  local input="$1"
  local wav="$2"

  if [[ -f "$wav" ]]; then return 0; fi

  dnd-log "Extracting audio -> $wav"
  ffmpeg -y -nostdin -loglevel error -i "$input" \
    -vn -ac 1 -ar 16000 -c:a pcm_s16le "$wav"
}

# =============================================================================
# SILERO VAD
# =============================================================================

function dnd-run-vad() {
  # Writes JSON list of {start,end} regions to <out>.
  local wav="$1"
  local out="$2"

  if [[ -f "$out" ]]; then
    dnd-log "VAD already present, skipping."
    return 0
  fi

  dnd-log "Running WebRTC VAD..."

  local min_speech_ms
  min_speech_ms=$(awk -v d="$MIN_SPEECH_DURATION" 'BEGIN { printf "%d", d * 1000 }')
  [[ "$min_speech_ms" -lt 50 ]] && min_speech_ms=50

  local pybin="${BASH_ALIASES_VENV_BIN}/python"
  "$pybin" - "$wav" "$out" "$min_speech_ms" <<'PYEOF'
import sys, json, os
import numpy as np
from scipy.io import wavfile

wav_path, out_path, min_speech_ms = sys.argv[1], sys.argv[2], int(sys.argv[3])

sr, audio = wavfile.read(wav_path)
if sr != 16000:
    raise SystemExit(f"expected 16000 Hz wav, got {sr}")
if audio.ndim > 1:
    audio = audio.mean(axis=1).astype(np.int16)
audio = np.ascontiguousarray(audio)

# WebRTC VAD operates on 10/20/30 ms frames at 8/16/32 kHz.
# 16 kHz / 30 ms = 480 samples/frame.
import webrtcvad
vad = webrtcvad.Vad(2)  # 0=least aggressive .. 3=most aggressive

frame_ms = 30
frame_len = int(sr * frame_ms / 1000)  # 480
n = len(audio) // frame_len
regions = []
in_speech = False
seg_start = 0
for i in range(n):
    frame = audio[i * frame_len : (i + 1) * frame_len]
    if len(frame) < frame_len:
        break
    is_speech = vad.is_speech(frame.tobytes(), sr)
    t = i * frame_ms / 1000.0
    if is_speech and not in_speech:
        seg_start = t
        in_speech = True
    elif not is_speech and in_speech:
        regions.append({"start": round(seg_start, 3),
                        "end":   round(t, 3)})
        in_speech = False
if in_speech:
    regions.append({"start": round(seg_start, 3),
                    "end":   round(len(audio) / sr, 3)})

# Drop regions shorter than min_speech_ms.
min_dur = min_speech_ms / 1000.0
regions = [r for r in regions if (r["end"] - r["start"]) >= min_dur]

# Merge regions that are very close (within 200 ms) to avoid micro-fragments.
merged = []
for r in regions:
    if merged and (r["start"] - merged[-1]["end"]) < 0.2:
        merged[-1]["end"] = r["end"]
    else:
        merged.append(dict(r))

with open(out_path, "w") as f:
    json.dump(merged, f, indent=2)

print(f"[dnd-vad] {len(merged)} speech-like regions")
PYEOF
}

# =============================================================================
# WHISPER (word-level timestamps)
# =============================================================================

function dnd-run-whisper() {
  # Writes <out_dir>/<basename>.json with word timestamps.
  local wav="$1"
  local out_dir="$2"

  if [[ -f "$out_dir/$(basename "${wav%.*}").json" ]]; then
    dnd-log "Whisper output already present, skipping."
    return 0
  fi

  dnd-log "Running Whisper  (model=$WHISPER_MODEL  device=$WHISPER_DEVICE)..."

  "${BASH_ALIASES_VENV_BIN}/whisper" "$wav" \
    --model "$WHISPER_MODEL" \
    --language "$WHISPER_LANGUAGE" \
    --device "$WHISPER_DEVICE" \
    --output_format json \
    --word_timestamps True \
    --output_dir "$out_dir" \
    --verbose False \
    > /dev/null
}

# =============================================================================
# TIMELINE BUILDING (Python: combines VAD + Whisper into classified regions)
# =============================================================================

function dnd-build-timeline() {
  # Writes <ws>/analysis/segments.json (raw classified regions) and
  # <ws>/analysis/timeline.json (merged + padded keep/remove plan).
  local ws="$1"
  local duration="$2"
  local vad_json="$ws/analysis/vad.json"
  local whisper_json="$ws/analysis/audio.json"
  local segments_json="$ws/analysis/segments.json"
  local timeline_json="$ws/analysis/timeline.json"

  dnd-log "Building classified timeline..."

  local pybin="${BASH_ALIASES_VENV_BIN}/python"
  "$pybin" - "$vad_json" "$whisper_json" "$segments_json" "$timeline_json" \
           "$duration" "$MIN_SPEECH_DURATION" "$MIN_REMOVE_DURATION" \
           "$SPEECH_KEEP_THRESHOLD" "$SPEECH_REVIEW_THRESHOLD" \
           "$PRE_ROLL" "$POST_ROLL" <<'PYEOF'
import sys, json

(vad_p, wh_p, seg_p, tl_p, dur,
 min_speech, min_remove,
 keep_thr, review_thr,
 pre_roll, post_roll) = sys.argv[1:12]

duration      = float(dur)
min_speech    = float(min_speech)
min_remove    = float(min_remove)
keep_thr      = float(keep_thr)
review_thr    = float(review_thr)
pre_roll      = float(pre_roll)
post_roll     = float(post_roll)

with open(vad_p) as f:
    vad = json.load(f)
with open(wh_p) as f:
    wh  = json.load(f)

words = []
for seg in wh.get("segments", []):
    no_speech_prob = float(seg.get("no_speech_prob", 0.0) or 0.0)
    if no_speech_prob > 0.6:
        continue
    for w in seg.get("words", []) or []:
        if "start" not in w or "end" not in w:
            continue
        prob = float(w.get("probability", 0.0) or 0.0)
        txt  = (w.get("word") or "").strip()
        if not txt:
            continue
        words.append({
            "start": float(w["start"]),
            "end":   float(w["end"]),
            "probability": prob,
            "word":  txt,
        })

RES = 0.05
n = int(duration / RES) + 2
labels = ["silence"] * n
vad_p_arr = [0.0] * n

for w in words:
    if w["probability"] < keep_thr:
        continue
    s = max(0, int(w["start"] / RES))
    e = min(n - 1, int(w["end"]   / RES))
    for i in range(s, e + 1):
        labels[i] = "speech"

for r in vad:
    s = max(0, int(r["start"] / RES))
    e = min(n - 1, int(r["end"]   / RES))
    for i in range(s, e + 1):
        if labels[i] == "silence":
            labels[i] = "vad_only"

regions = []
cur = labels[0]; cs = 0
for i in range(1, n):
    if labels[i] != cur:
        regions.append((cur, cs * RES, i * RES))
        cur = labels[i]; cs = i
regions.append((cur, cs * RES, n * RES))

classified = []
idx = 0
for state, s, e in regions:
    d = e - s
    rec = {
        "id": idx,
        "start": round(s, 3),
        "end":   round(e, 3),
        "duration": round(d, 3),
        "classification": state,
        "speech_confidence": 0.0,
        "action": "keep",
        "review_required": False,
        "reason": "",
    }
    if state == "speech":
        rec["action"] = "keep"
        rec["reason"] = "Whisper transcribed words in this range"
        rec["speech_confidence"] = 1.0
    elif state == "vad_only":
        rec["action"] = "remove"
        rec["review_required"] = True
        rec["reason"] = "Speech-like audio without transcribed text"
        rec["speech_confidence"] = round(review_thr, 3)
    else:
        if d < min_remove:
            rec["action"] = "keep"
            rec["reason"] = f"Silence shorter than MIN_REMOVE_DURATION ({min_remove}s)"
            rec["speech_confidence"] = 0.0
        else:
            rec["action"] = "remove"
            rec["review_required"] = False
            rec["reason"] = "No speech-like audio detected"
            rec["speech_confidence"] = 0.0
    classified.append(rec)
    idx += 1

# Filter out very short speech regions (likely false positives / breaths).
classified = [
    r for r in classified
    if not (r["classification"] == "speech" and r["duration"] < min_speech)
]

# Apply PRE_ROLL / POST_ROLL to speech regions, then re-merge overlapping
# keep regions, then re-classify the resulting gaps.
def expand_speech(seg):
    return {
        "start":  max(0.0, seg["start"]  - pre_roll),
        "end":    min(duration, seg["end"] + post_roll),
        "classification": "speech",
    }

expanded = [expand_speech(r) for r in classified if r["classification"] == "speech"]
expanded.sort(key=lambda x: x["start"])

merged = []
for r in expanded:
    if merged and r["start"] <= merged[-1]["end"]:
        merged[-1]["end"] = max(merged[-1]["end"], r["end"])
    else:
        merged.append(dict(r))

# Build KEEP ranges; everything in between is REMOVE.
timeline = []
seg_id = 0
cursor = 0.0
for m in merged:
    if m["start"] > cursor:
        gap_d = m["start"] - cursor
        if gap_d >= min_remove:
            timeline.append({
                "id": seg_id,
                "start":  round(cursor, 3),
                "end":    round(m["start"], 3),
                "duration": round(gap_d, 3),
                "classification": "gap",
                "speech_confidence": 0.0,
                "action": "remove",
                "review_required": False,
                "reason": "Non-speech gap between kept speech regions",
            })
            seg_id += 1
    timeline.append({
        "id": seg_id,
        "start":  round(m["start"], 3),
        "end":    round(m["end"], 3),
        "duration": round(m["end"] - m["start"], 3),
        "classification": "speech",
        "speech_confidence": 1.0,
        "action": "keep",
        "review_required": False,
        "reason": "Confirmed speech (Whisper) with padding",
    })
    seg_id += 1
    cursor = m["end"]

if cursor < duration - 0.01:
    gap_d = duration - cursor
    if gap_d >= min_remove:
        timeline.append({
            "id": seg_id,
            "start":  round(cursor, 3),
            "end":    round(duration, 3),
            "duration": round(gap_d, 3),
            "classification": "gap",
            "speech_confidence": 0.0,
            "action": "remove",
            "review_required": False,
            "reason": "Trailing non-speech section",
        })
        seg_id += 1

# Mark "vad_only" regions that still fall inside a REMOVE gap for review.
keep_ranges = [(t["start"], t["end"]) for t in timeline if t["action"] == "keep"]
def inside_keep(s, e):
    for ks, ke in keep_ranges:
        if s >= ks and e <= ke:
            return True
    return False

# Build a flat list of "questionable" regions from the original classified
# regions (not merged gaps), so the user can review them.
questionable = []
for r in classified:
    if r["classification"] != "vad_only":
        continue
    if r["duration"] < min_speech:
        continue
    if inside_keep(r["start"], r["end"]):
        continue
    questionable.append({
        "id":              r["id"],
        "start":           r["start"],
        "end":             r["end"],
        "duration":        r["duration"],
        "classification":  "possible_speech",
        "speech_confidence": r["speech_confidence"],
        "action":          "remove",
        "review_required": True,
        "reason":          r["reason"],
    })

with open(seg_p, "w") as f:
    json.dump(classified, f, indent=2)

with open(tl_p, "w") as f:
    json.dump({
        "duration":    round(duration, 3),
        "timeline":    timeline,
        "questionable": questionable,
        "summary": {
            "keep_seconds":      round(sum(t["duration"] for t in timeline if t["action"] == "keep"), 3),
            "remove_seconds":    round(sum(t["duration"] for t in timeline if t["action"] == "remove"), 3),
            "review_segments":   len(questionable),
            "remove_segments":   sum(1 for t in timeline if t["action"] == "remove"),
            "keep_segments":     sum(1 for t in timeline if t["action"] == "keep"),
        },
    }, f, indent=2)
PYEOF
}

# =============================================================================
# RENDERING (concat demuxer, no re-encode when possible)
# =============================================================================

function dnd-render-from-plan() {
  # dnd-render-from-plan <input> <output> <plan_json>
  local input="$1"
  local output="$2"
  local plan_json="$3"

  local keep_count
  keep_count=$(jq '[.timeline[] | select(.action=="keep")] | length' "$plan_json")

  if [[ "$keep_count" -eq 0 ]]; then
    dnd-warn "Nothing to keep -- entire timeline marked remove. Copying original as fallback."
    dnd-warn "If this was unintended, edit $ws/decisions.json and re-run with [t]."
    cp -p "$input" "$output"
    return 0
  fi

  local tmpdir
  tmpdir="$(dirname "$output")/segments"
  rm -rf "$tmpdir"
  mkdir -p "$tmpdir"

  dnd-log "Extracting $keep_count keep-segments -> $tmpdir"

  local i=0
  local list="$tmpdir/_concat.txt"
  : > "$list"

  while IFS=$'\t' read -r start end; do
    local seg="seg-$(printf '%05d' "$i")"
    local out="$tmpdir/${seg}.mp4"
    local dur
    dur=$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }')
    # -ss AFTER -i gives frame-accurate cuts with -c copy.
    ffmpeg -y -nostdin -loglevel error \
      -i "$input" -ss "$start" -t "$dur" \
      -c copy -avoid_negative_ts make_zero "$out"
    printf "file '%s'\n" "$out" >> "$list"
    i=$((i + 1))
  done < <(jq -r '.timeline[] | select(.action=="keep") | "\(.start)\t\(.end)"' "$plan_json")

  if [[ "$i" -eq 0 ]]; then
    dnd-warn "Plan produced no segments."
    cp -p "$input" "$output"
    return 0
  fi

  dnd-log "Concatenating -> $output"
  if ! ffmpeg -y -nostdin -loglevel error \
      -f concat -safe 0 -i "$list" \
      -c copy -movflags +faststart \
      "$output"; then
    dnd-warn "Stream-copy concat failed; falling back to re-encode."
    ffmpeg -y -nostdin -loglevel error \
      -f concat -safe 0 -i "$list" \
      -c:v libx264 -preset veryfast -crf 18 \
      -c:a aac -b:a 192k \
      -movflags +faststart \
      "$output"
  fi

  rm -rf "$tmpdir"
}

# =============================================================================
# QUESTIONABLE LEFTOVERS
# =============================================================================

function dnd-extract-leftovers() {
  # Cuts each questionable region from the original video preserving its
  # original timeline position. Also builds leftovers.mp4 (concat) and
  # leftovers/index.json.
  local ws="$1"
  local input="$2"
  local plan_json="$ws/analysis/timeline.json"

  local leftovers_dir="$ws/leftovers"
  rm -rf "$leftovers_dir"
  mkdir -p "$leftovers_dir"

  local qcount
  qcount=$(jq '.questionable | length' "$plan_json")

  if [[ "$qcount" -eq 0 ]]; then
    dnd-log "No questionable segments to review."
    jq '{segments: [], generated: now|todate}' "$plan_json" > "$leftovers_dir/index.json"
    : > "$leftovers_dir/_concat.txt"
    return 0
  fi

  dnd-log "Extracting $qcount questionable leftovers..."

  local list="$leftovers_dir/_concat.txt"
  : > "$list"
  local idx_json="$leftovers_dir/index.json"
  local tmp_entries=()

  local i=0
  while IFS=$'\t' read -r s e conf reason; do
    local seg="segment-$(printf '%03d' "$((i + 1))")"
    local out="$leftovers_dir/${seg}.mp4"
    local dur
    dur=$(awk -v s="$s" -v e="$e" 'BEGIN { printf "%.3f", e - s }')
    ffmpeg -y -nostdin -loglevel error \
      -i "$input" -ss "$s" -t "$dur" \
      -c copy -avoid_negative_ts make_zero "$out"
    printf "file '%s'\n" "$out" >> "$list"

    tmp_entries+=("$(jq -n --argjson n "$((i + 1))" --argjson s "$s" --argjson e "$e" --argjson d "$dur" --argjson c "$conf" --arg r "$reason" \
      '{segment: $n, start: $s, end: $e, duration: $d, speech_confidence: $c, classification: "possible_speech", reason: $r, file: ("segment-" + (("000" + ($n|tostring)) | .[length-3:]) + ".mp4")}')")

    i=$((i + 1))
  done < <(jq -r '.questionable[] | "\(.start)\t\(.end)\t\(.speech_confidence)\t\(.reason)"' "$plan_json")

  printf '%s\n' "${tmp_entries[@]}" | jq -s '{generated: now|todate, segments: .}' > "$idx_json"

  if [[ -s "$list" ]]; then
    dnd-log "Building leftovers.mp4..."
    ffmpeg -y -nostdin -loglevel error \
      -f concat -safe 0 -i "$list" \
      -c copy "$leftovers_dir/leftovers.mp4" \
      || dnd-warn "leftovers.mp4 concat failed; individual files still available."
  fi
}

# =============================================================================
# DECISIONS
# =============================================================================

function dnd-decisions-load() {
  local ws="$1"
  if [[ -f "$ws/decisions.json" ]]; then
    cat "$ws/decisions.json"
  else
    echo '{"updated": "", "items": []}'
  fi
}

function dnd-decision-for() {
  # dnd-decision-for <decisions_json> <segment_id>  ->  remove|restore|pending
  local dec_json="$1"
  local sid="$2"
  jq -r --argjson id "$sid" '
    (.items[] | select(.segment == $id) | .decision) // "pending"
  ' "$dec_json"
}

function dnd-decisions-append() {
  local ws="$1"
  local sid="$2"
  local decision="$3"
  local decisions="$ws/decisions.json"

  if [[ ! -f "$decisions" ]]; then
    echo '{"updated": "", "items": []}' > "$decisions"
  fi

  local tmp
  tmp=$(mktemp)
  jq --arg ts "$(date -Iseconds)" --argjson id "$sid" --arg d "$decision" '
    .updated = $ts
    | .items = (
        (.items | map(select(.segment != $id)))
        + [{segment: $id, decision: $d, ts: $ts}]
      )
  ' "$decisions" > "$tmp" && mv "$tmp" "$decisions"
}

# =============================================================================
# INTERACTIVE REVIEW
# =============================================================================

function dnd-play-segment() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    dnd-warn "Cannot play: $file not found."
    return 1
  fi
  # shellcheck disable=SC2086
  $DND_AUDIO_PLAYER "$file" >/dev/null 2>&1 &
  local pid=$!
  wait "$pid" 2>/dev/null
}

function dnd-interactive-review() {
  local ws="$1"
  local plan_json="$ws/analysis/timeline.json"
  local decisions="$ws/decisions.json"
  local review_log="$ws/review/review.log"

  if [[ ! -f "$decisions" ]]; then
    echo '{"updated": "", "items": []}' > "$decisions"
  fi

  local total
  total=$(jq '.questionable | length' "$plan_json")
  if [[ "$total" -eq 0 ]]; then
    dnd-log "No segments require manual review. Skipping."
    return 0
  fi

  dnd-log "Manual review starts: $total segment(s) require attention."

  local i=0
  while IFS=$'\t' read -r segid s e conf reason; do
    i=$((i + 1))
    local segfile
    segfile=$(printf 'segment-%03d.mp4' "$((segid + 1))")

    local current
    current=$(dnd-decision-for "$decisions" "$segid")
    if [[ "$current" == "restore" || "$current" == "remove" ]]; then
      dnd-log "  [$i/$total] decision already set: $current (skipping)"
      continue
    fi

    local ts_start ts_end
    ts_start=$(dnd-format-ts "$s")
    ts_end=$(dnd-format-ts "$e")

    printf '\n'
    dnd-log "[%d/%d]  segment=%d  %s -> %s  (%.2fs, conf=%.2f)" \
      "$i" "$total" "$segid" "$ts_start" "$ts_end" \
      "$(awk -v s="$s" -v e="$e" 'BEGIN{print e-s}')" "$conf"
    dnd-log "         reason: $reason"
    dnd-log "         file:   leftovers/$segfile"

    if [[ -f "$ws/leftovers/$segfile" ]]; then
      dnd-play-segment "$ws/leftovers/$segfile"
    else
      dnd-warn "Leftover file missing: leftovers/$segfile"
    fi

    while true; do
      read -r -n 1 -p "[dnd] [r]estore  [k]eep removed  [p]lay again  [s]kip  [q]uit? " choice
      echo
      case "$choice" in
        r) dnd-decisions-append "$ws" "$segid" "restore"
           printf '%s segment=%d decision=restore\n' "$(date -Iseconds)" "$segid" >> "$review_log"
           dnd-log "  -> marked RESTORE"; break ;;
        k) dnd-decisions-append "$ws" "$segid" "remove"
           printf '%s segment=%d decision=remove\n'  "$(date -Iseconds)" "$segid" >> "$review_log"
           dnd-log "  -> marked REMOVE";  break ;;
        p) dnd-play-segment "$ws/leftovers/$segfile"; continue ;;
        s) dnd-log "  -> deferred"; break ;;
        q) dnd-log "  -> quitting (resumable)"; return 0 ;;
        *) dnd-warn "Please press r, k, p, s or q." ;;
      esac
    done
  done < <(jq -r '.questionable[] | "\(.id)\t\(.start)\t\(.end)\t\(.speech_confidence)\t\(.reason)"' "$plan_json")

  dnd-log "Review complete. See $review_log"
}

# =============================================================================
# FINAL TIMELINE RECONSTRUCTION + RENDER
# =============================================================================

function dnd-reconstruct-plan() {
  # Rebuild the final keep ranges by unioning:
  #   - all speech keep segments from the original plan
  #   - all restored questionable segments
  # then split into a chronological timeline of keep/remove entries.
  local ws="$1"
  local plan_json="$ws/analysis/timeline.json"
  local decisions="$ws/decisions.json"
  local final_plan="$ws/analysis/final-plan.json"

  jq -s '
    .[0] as $plan | .[1] as $dec
    | ( $dec.items | map(select(.decision=="restore")) | map(.segment) ) as $restore_ids
    | ( $plan.timeline        | map(select(.action=="keep")) ) as $keeps
    | ( $plan.questionable
        | map(select((.id as $i | $restore_ids | index($i)) != null))
        | map({start: .start, end: .end, classification: "restored",
               speech_confidence: .speech_confidence,
               reason: "Restored after manual review"})
      ) as $restored
    | ([$keeps[], $restored[]] | sort_by(.start)) as $all
    | ( reduce $all[] as $r ([];
          if . == [] then
            [{start: $r.start, end: $r.end, classification: $r.classification,
              speech_confidence: $r.speech_confidence, reason: $r.reason}]
          elif $r.start <= .[-1].end then
            .[:-1] + [ .[-1] | .end = (if $r.end > .end then $r.end else .end end) ]
          else
            . + [{start: $r.start, end: $r.end, classification: $r.classification,
                  speech_confidence: $r.speech_confidence, reason: $r.reason}]
          end
        )
      ) as $merged
    | ( reduce ($merged | range(0; length), -1) as $i (
          {timeline: [], last_end: 0, next_id: 0};
          if $i == -1 then
            if .last_end < $plan.duration then
              .timeline += [{
                id: .next_id,
                start: .last_end,
                end:   $plan.duration,
                duration: ($plan.duration - .last_end),
                classification: "gap",
                speech_confidence: 0,
                action: (if ($plan.duration - .last_end) >= $MIN_REMOVE_DURATION | not then "keep" else "remove" end),
                reason: "Trailing gap"
              }]
            else . end
          else
            . as $st
            | (if $merged[$i].start > $st.last_end and ($merged[$i].start - $st.last_end) > 0 then
                [{id: $st.next_id,
                  start: $st.last_end,
                  end:   $merged[$i].start,
                  duration: ($merged[$i].start - $st.last_end),
                  classification: "gap",
                  speech_confidence: 0,
                  action: "remove",
                  reason: "Non-speech gap"}]
               else [] end) as $pre
            | ($pre | length) as $plen
            | {
                timeline: ($st.timeline + $pre + [{
                  id: ($st.next_id + $plen),
                  start: $merged[$i].start,
                  end:   $merged[$i].end,
                  duration: ($merged[$i].end - $merged[$i].start),
                  classification: $merged[$i].classification,
                  speech_confidence: $merged[$i].speech_confidence,
                  action: "keep",
                  reason: $merged[$i].reason
                }]),
                last_end: $merged[$i].end,
                next_id:  ($st.next_id + $plen + 1)
              }
          end
        )
        | .timeline
      ) as $timeline
    | {
        duration: $plan.duration,
        timeline: $timeline,
        summary: $plan.summary,
      }' --argjson MIN_REMOVE_DURATION "$MIN_REMOVE_DURATION" \
         "$plan_json" "$decisions" > "$final_plan"
}

function dnd-render-final() {
  local ws="$1"
  local input="$2"
  local plan_json="$ws/analysis/final-plan.json"
  local output="$ws/final.mp4"
  dnd-render-from-plan "$input" "$output" "$plan_json"
}

# =============================================================================
# SUMMARY
# =============================================================================

function dnd-print-summary() {
  local ws="$1"
  local input="$2"
  local plan_json="$ws/analysis/timeline.json"
  local final_plan="$ws/analysis/final-plan.json"
  local decisions="$ws/decisions.json"

  local orig_dur final_dur auto_rm qseg restored reviewed
  orig_dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
  final_dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$ws/final.mp4" 2>/dev/null || echo "n/a")
  auto_rm=$(jq '[.timeline[] | select(.action=="remove")] | map(.duration) | add // 0' "$plan_json")
  qseg=$(jq '.questionable | length' "$plan_json")
  restored=$(jq '[.items[] | select(.decision=="restore")] | length' "$decisions")
  reviewed=$(jq '[.items[] | select(.decision!="pending")] | length' "$decisions")

  cat <<EOF
============================================================
  DND video cut summary
============================================================
  Original duration : ${orig_dur}s
  Automatically removed : ${auto_rm}s
  Questionable segments  : ${qseg}
  Restored              : ${restored}
  Segments reviewed     : ${reviewed}
  Final duration        : ${final_dur}s
  Final output          : $ws/final.mp4
============================================================
EOF
}

# =============================================================================
# MAIN ENTRY
# =============================================================================

function dnd-video-cut-low-volume-spaces() {

  set -euo pipefail
  trap 'dnd-err "Interrupted (line ${LINENO:-?}). Workspace preserved -- re-run to resume."; exit 130' INT TERM

  if [[ $# -lt 1 ]]; then
    dnd-err "Usage: dnd-video-cut-low-volume-spaces <video-file>"
    return 1
  fi

  local input="$1"
  if [[ ! -f "$input" ]]; then
    dnd-err "Input file not found: $input"
    return 1
  fi

  dnd-dependencies-check || return 1

  local ws
  ws=$(dnd-workspace-path "$input")
  dnd-workspace-init "$ws"

  dnd-log "Workspace: $ws"

  # ---- Resume handling ----
  local mode="fresh"
  if dnd-has-state "$ws"; then
    mode=$(dnd-resume-prompt "$ws")
  fi

  # ---- Metadata ----
  local duration
  duration=$(dnd-extract-metadata "$input" "$ws")
  dnd-log "Video duration: ${duration}s"

  # ---- Audio ----
  local wav="$ws/analysis/audio.wav"
  dnd-extract-audio "$input" "$wav"

  # ---- Analysis ----
  if [[ "$mode" == "fresh" || "$mode" == "reanalyze" ]]; then
    dnd-run-vad      "$wav" "$ws/analysis/vad.json"
    dnd-run-whisper  "$wav" "$ws/analysis"
  else
    # rebuild-timeline / resume: ensure analysis files exist; if not, run them.
    if ! dnd-valid-json "$ws/analysis/vad.json"; then
      rm -f "$ws/analysis/vad.json"
      dnd-run-vad "$wav" "$ws/analysis/vad.json"
    fi
    if ! dnd-valid-json "$ws/analysis/audio.json"; then
      rm -f "$ws/analysis/audio.json"
      dnd-run-whisper "$wav" "$ws/analysis"
    fi
  fi

  # ---- Timeline ----
  if [[ "$mode" != "resume" ]] || ! dnd-valid-json "$ws/analysis/timeline.json"; then
    dnd-build-timeline "$ws" "$duration"
  fi

  local plan_json="$ws/analysis/timeline.json"

  # ---- Candidate final (auto removals applied) ----
  if [[ ! -f "$ws/candidate-final.mp4" ]]; then
    dnd-render-from-plan "$input" "$ws/candidate-final.mp4" "$plan_json"
  fi

  # ---- Leftovers ----
  if [[ ! -d "$ws/leftovers" ]] || [[ -z "$(ls -A "$ws/leftovers" 2>/dev/null)" ]]; then
    dnd-extract-leftovers "$ws" "$input"
  fi

  # ---- Manual review ----
  dnd-interactive-review "$ws"

  # ---- Final plan + render ----
  dnd-reconstruct-plan "$ws"
  dnd-render-final "$ws" "$input"

  # ---- Summary ----
  dnd-print-summary "$ws" "$input"
}
