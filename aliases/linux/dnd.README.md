# dnd-video-cut-low-volume-spaces

Remove background-only / silence sections from a video while preserving every
intelligible human speech segment — even when whispered, quiet, or masked by
music or game audio.

> **Not** "find quiet audio and cut it".
> **Is** "find sections without understandable human speech and remove them,
> while protecting human speech even when it is quiet."

Priority: **HUMAN SPEECH > BACKGROUND AUDIO > VOLUME**

---

## What it does

1. Extracts the audio track from a video.
2. Runs two local analyzers:
   - **Whisper** (word-level timestamps + confidence) — definitive proof of
     intelligible human speech.
   - **WebRTC VAD** — flags voice-like audio Whisper did not transcribe.
3. Builds a timeline classifying every region into:
   - `speech` — Whisper transcribed a word → **KEEP**
   - `vad_only` — voice-like audio, no transcription → **REMOVE + manual review**
   - `silence` — no voice activity → **REMOVE automatically** (no review)
4. Renders `candidate-final.mp4` with obvious removals already applied.
5. Extracts only the **questionable** segments as `leftovers/segment-NNN.mp4`
   so you listen to the ambiguous ones — not the entire removed audio.
6. Interactive review (`r` restore / `k` keep removed / `p` replay / `s` skip /
   `q` quit) — only for the segments that actually might contain voice.
7. Restores chosen segments at their **original timeline positions** and
   renders `final.mp4`.

The original video is never modified. All artifacts live in a sibling
workspace directory.

---

## AI / privacy / cost

- **No cloud API.** Whisper is OpenAI's *open-source* model (MIT licensed),
  invoked through the local `whisper` CLI. The model weights are downloaded
  once to `~/.cache/whisper` and reused forever. Inference runs on your CPU
  (or GPU if available).
- **No API key. No account. No metering.**
- The only "AI" component besides Whisper is WebRTC VAD, which is classical
  digital signal processing, not a neural network.
- The audio never leaves your machine.

---

## Install

### 1. System packages (apt)

```bash
sudo apt install ffmpeg jq
```

### 2. Python packages (in the bash_aliases venv)

```bash
~/.bash_aliases_scripts/.venv/bin/pip install webrtcvad scipy numpy
```

Whisper is already installed in that venv (the project uses it for
`video-transcribe` and similar).

### 3. Reload the aliases

```bash
./upgrade.sh
```

---

## Usage

```bash
dnd-video-cut-low-volume-spaces video-25.mp4
dnd-video-cut-low-volume-spaces "/path/with spaces/recording.mkv"
```

If you re-run on the same file, you'll be prompted:

```
Existing workspace detected: ./video-25.dnd-cut
  [r] Resume (reuse analysis + decisions)
  [t] Rebuild timeline (keep audio/VAD/Whisper, rebuild cuts)
  [a] Re-analyze (keep workspace, redo audio/VAD/Whisper)
  [f] Fresh start (wipe workspace)
```

Set `DND_AUTO_RESUME=yes` to skip the prompt and auto-resume.

---

## Output structure

```
video-25.dnd-cut/
├── analysis/
│   ├── audio.wav          # 16 kHz mono PCM (Whisper + WebRTC input)
│   ├── audio.json         # Whisper word-level timestamps + confidence
│   ├── vad.json           # WebRTC VAD regions
│   ├── metadata.json      # ffprobe info
│   ├── segments.json      # classified regions (speech / vad_only / silence)
│   ├── timeline.json      # keep/remove plan + questionable list
│   └── final-plan.json    # timeline after user decisions
├── leftovers/
│   ├── segment-001.mp4    # per-questionable clip from the original video
│   ├── segment-002.mp4
│   ├── leftovers.mp4      # all clips concatenated for batch listening
│   └── index.json         # segment → timestamps / confidence / reason
├── review/
│   └── review.log         # append-only log of every decision
├── decisions.json         # persisted review decisions (resumable)
├── candidate-final.mp4    # obvious removals already applied
└── final.mp4              # final output
```

---

## Configuration

All thresholds live at the top of `aliases/linux/dnd.sh`. Every value can be
overridden via environment variable without editing the script.

| Variable | Default | Meaning |
|---|---:|---|
| `DND_PRE_ROLL` | `0.30` | Seconds of padding before each kept speech region |
| `DND_POST_ROLL` | `0.40` | Seconds of padding after each kept speech region |
| `DND_MIN_REMOVE_DURATION` | `0.80` | Gaps shorter than this are left in place (avoids micro-cuts) |
| `DND_MIN_SPEECH_DURATION` | `0.25` | Whisper regions shorter than this are treated as noise/breath |
| `DND_SPEECH_KEEP_THRESHOLD` | `0.40` | Whisper word probability above this counts as confirmed speech |
| `DND_SPEECH_REVIEW_THRESHOLD` | `0.50` | Reserved for VAD-only ambiguous regions |
| `DND_WHISPER_MODEL` | `small` | `tiny` / `base` / `small` / `medium` / `large-v3` |
| `DND_WHISPER_LANGUAGE` | `en` | ISO 639-1 code, or `auto` |
| `DND_WHISPER_DEVICE` | `cpu` | `cpu` or `cuda` |
| `DND_AUDIO_PLAYER` | `ffplay -hide_banner -loglevel error -autoexit -nodisp` | Used during review |
| `DND_AUTO_RESUME` | `ask` | `ask` / `yes` / `no` |

### Choosing a Whisper model

| Model | Relative speed | Accuracy | Notes |
|---|---|---|---|
| `tiny` | ~32× realtime | low | Only for very long videos or quick first pass |
| `base` | ~16× realtime | medium | Decent for clean English |
| `small` | ~6× realtime | good | **Default.** Solid CPU-only choice |
| `medium` | ~2× realtime | very good | Needs a real GPU for comfort |
| `large-v3` | ~1× realtime | best | GPU strongly recommended |

---

## Review semantics

The script is **conservative**: false-removal of speech is much worse than
leaving some background noise.

- **Clear speech** (Whisper transcribed words) — automatically kept.
- **Clear background** (no VAD, no Whisper text) — automatically removed, no
  review.
- **VAD-only** (voice-like audio with no Whisper text) — removed initially,
  then surfaced in the review so you only have to listen to segments that
  *might* be a person talking through noise.

You will only ever be asked to listen to a segment when the AI is genuinely
unsure whether it contains understandable speech.

### Review shortcuts

| Key | Action |
|---|---|
| `r` | **Restore** this segment to its original position in the timeline |
| `k` | **Keep removed** — confirms the segment should stay cut |
| `p` | **Play again** — re-plays the current segment |
| `s` | **Skip** — defer the decision (will be asked again next run) |
| `q` | **Quit** — resume later with the same command |

---

## Resumability

Everything is idempotent. If processing is interrupted:

- `audio.wav`, `vad.json`, `audio.json`, `timeline.json`, `candidate-final.mp4`
  and `decisions.json` are preserved.
- Re-running the command prompts you to **resume**, **rebuild the timeline**,
  **re-analyze**, or **wipe and start fresh**.
- Decisions already made (segments you already marked `restore` or `remove`)
  are kept and not asked again.

The expensive step (Whisper transcription) is never re-run unless you
explicitly choose **re-analyze**.

---

## Limitations

- Speaker diarization is **not** included (no per-speaker labels). The spec
  marks it as "useful but not required".
- The script does not adjust audio levels or normalize. It only cuts.
- Frame-accurate cuts use `-ss` after the input flag (slow seek) to avoid
  keyframe-snap artifacts; for very long videos this is slower than fast-seek
  but produces correct boundaries.
- A `c copy` concat is attempted first to avoid re-encoding; if the source
  has mismatched streams the script falls back to a libx264 / aac re-encode
  (CRF 18, AAC 192 kb/s).

---

## Example session

```
$ dnd-video-cut-low-volume-spaces dnd-recording-25.mp4
[dnd] Workspace: ./dnd-recording-25.dnd-cut
[dnd] Video duration: 1842.500s
[dnd] Extracting audio -> ./dnd-recording-25.dnd-cut/analysis/audio.wav
[dnd] Running WebRTC VAD...
[dnd-vad] 47 speech-like regions
[dnd] Running Whisper  (model=small  device=cpu)...
[dnd] Building classified timeline...
[dnd] Extracting 31 keep-segments -> ./dnd-recording-25.dnd-cut/segments
[dnd] Concatenating -> ./dnd-recording-25.dnd-cut/candidate-final.mp4
[dnd] Extracting 4 questionable leftovers...
[dnd] Building leftovers.mp4...
[dnd] Manual review starts: 4 segment(s) require attention.

[dnd] [1/4]  segment=12  00:12:31.400 -> 00:12:34.200  (2.80s, conf=0.41)
       reason: Speech-like audio without transcribed text
       file:   leftovers/segment-013.mp4
[dnd] [r]estore  [k]eep removed  [p]lay again  [s]kip  [q]uit? r
[dnd]   -> marked RESTORE
...

============================================================
  DND video cut summary
============================================================
  Original duration        : 1842.5s
  Automatically removed    : 421.7s
  Questionable segments    : 4
  Restored                 : 1
  Segments reviewed        : 4
  Final duration           : 1423.6s
  Final output             : ./dnd-recording-25.dnd-cut/final.mp4
============================================================
```
