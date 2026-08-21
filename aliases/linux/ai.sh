#!/bin/bash

# Strubloid::linux::ai

## function to start the open web ui

## installing the chat cuda version
chat-install-cuda(){
  if [ -d "$HOME/.bash_aliases_docker/" ]; then
      docker compose -f $HOME/.bash_aliases_docker/openwebui/cuda/docker-compose.yml up -d
  else
      echo " [ERROR]: Docker-compose  file not found."
  fi  
}

## installing the chat main version
chat-install-main(){

    if [ -d "$HOME/.bash_aliases_docker/" ]; then
        docker compose -f $HOME/.bash_aliases_docker/openwebui/main/docker-compose.yml up -d
    else
        echo " [ERROR]: Docker-compose  file not found."
    fi
}

# command to update the repo
pull-main-repo(){
  docker pull ghcr.io/open-webui/open-webui:main
}

# command to update the repo
pull-cuda-repo(){
  docker pull ghcr.io/open-webui/open-webui:cuda
}

# Function to start the chatGPT GUI locally with GPU support
chat_start() {
  read -r -p "Do you want to start with CUDA? (y/n): " choice
  if [[ "$choice" =~ ^(yes|y|Y|Yes|YES)$ ]]
  then
    docker compose -f "$HOME/.bash_aliases_docker/openwebui/cuda/docker-compose.yml" up -d open-webui-cuda
  else 
    docker compose -f "$HOME/.bash_aliases_docker/openwebui/main/docker-compose.yml" up -d open-webui-main
  fi 
}


# Function to update the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local(){

  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui
  
  # 2. Pull the latest image
  pull-cuda-repo

  # 3. Recreate the container
  chat-install-cuda
}

# Function to start the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local-cpu(){
  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui

  # 2. Pull the latest image
  pull-main-repo

  # 3. Recreate the container
  chat-install-main
}

## --------------------------------------------------------------------------
## ai-create-tasks
##
## Takes an existing timestamped Whisper transcript (e.g. produced by
## video-transcribe) and uses OpenCode with the MiniMax M3 model to extract
## and organize the actual tasks discussed in the video.
##
## Two-pass AI strategy:
##   Pass 1 - chunked candidate extraction (per transcript segment).
##   Pass 2 - global reconciliation against the full transcript.
##
## Produces structured JSON from the model, then deterministically renders
## task1.md, task2.md, ... via Bash + jq.
##
## Usage:
##   ai-create-tasks <transcript-file> [output-dir] [model]
##
## Arguments:
##   transcript-file : Path to a VTT transcript (preserves timestamps) or a
##                     plain text transcript. VTT is preferred.
##   output-dir      : Where task1.md, task2.md, ... are written.
##                     Default: ./tasks (relative to current directory)
##   model           : OpenCode model identifier to use.
##                     Default: opencode-go/minimax-m3
##
## Requirements:
##   - opencode (CLI) on PATH
##   - jq, awk, sed on PATH
##
## Example:
##   video-transcribe meeting.mp4
##   ai-create-tasks ./meeting.mp4-transcribed.vtt ./meeting-tasks
## --------------------------------------------------------------------------

## Strip ANSI escape sequences from a stream on stdin.
ai-strip-ansi() {
  sed -E 's/\x1b\[[0-9;?]*[a-zA-Z]//g'
}

## Extract the first balanced JSON object or array from stdin.
## Robust against ```json ... ``` code fences, leading prose, and trailing
## commentary. Returns empty if no JSON could be located.
ai-extract-json() {
  awk '
    {
      line = $0
      # Entering a JSON code fence (```json or ```jsonc)
      if (line ~ /^```[Jj][Ss][Oo][Nn][Cc]?[[:space:]]*$/) { fence = 1; next }
      # Closing fence (or non-JSON opening fence we ignore)
      if (line ~ /^```/) {
        if (fence) { fence = 0; started = 1; next }
        next
      }
      if (fence) { print line; next }
      # Locate the first JSON start character ("{" or "[") in the stream
      if (!started) {
        if (match(line, /[[{]/)) {
          started = 1
          printf "%s", substr(line, RSTART)
        }
        next
      }
      printf "\n%s", line
    }
  '
}

## Run an OpenCode prompt and return only the assistant text from the JSON
## event stream. Usage: ai-run-opencode <model> <prompt-file>
## The prompt content is passed inline so it works regardless of the
## current working directory (the opencode CLI restricts --file paths).
ai-run-opencode() {
  local model="$1"
  local prompt_file="$2"

  if [[ ! -f "$prompt_file" ]]; then
    echo "[ERROR] ai-run-opencode: prompt file not found: $prompt_file" >&2
    return 1
  fi

  local prompt_content
  prompt_content=$(cat "$prompt_file")

  local raw
  raw=$(opencode run --model "$model" --format json -- "$prompt_content" 2>/dev/null)

  if [[ -z "$raw" ]]; then
    echo "[ERROR] ai-run-opencode: empty response from opencode" >&2
    return 1
  fi

  printf '%s' "$raw" \
    | jq -r 'select(.type == "text") | .part.text' \
    | ai-strip-ansi
}

## Interactive model picker.
##
## Usage: ai-pick-model <default-model>
## Prints the chosen model id on stdout.
##
## Behaviour by context:
##   - Interactive TTY:  prompts "Use default? [Y/n]". 'y' / Enter uses
##                       the default. Anything other than 'n' / 'N' is
##                       taken as a direct model id. 'n' / 'N' shows the
##                       full opencode model list and asks for a pick.
##   - Piped input:      reads the first line of stdin as the response
##                       and processes it the same way (no prompt).
##   - No stdin at all:  falls back to the default (safe for scripts).
ai-pick-model() {
  local default="${1:-opencode-go/minimax-m3}"

  local response=""

  if [[ -t 0 ]]; then
    ## Interactive: prompt the user.
    echo ""
    echo "[ai-create-tasks] Default model: $default"
    if ! read -r -p "Use default model? [Y/n]: " response; then
      echo "$default"
      return 0
    fi
    response="${response:-Y}"
  else
    ## Non-interactive: try to consume one line from stdin if any.
    if ! read -r response; then
      echo "$default"
      return 0
    fi
  fi

  ## Accept the default.
  if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
    echo "$default"
    return 0
  fi

  ## Anything other than 'n' / 'N' is treated as a direct model id, so
  ## `ai-create-tasks transcript.vtt opencode-go/kimi-k3` works too.
  if [[ ! "$response" =~ ^[Nn]$ ]]; then
    echo "$response"
    return 0
  fi

  ## Fetch the live model list from opencode.
  local models=()
  while IFS= read -r m; do
    [[ -n "$m" ]] && models+=("$m")
  done < <(opencode models 2>/dev/null | sed -E 's/\x1b\[[0-9;]*m//g')

  if [[ ${#models[@]} -eq 0 ]]; then
    echo "[ERROR] Could not retrieve model list from opencode" >&2
    return 1
  fi

  echo ""
  echo "[ai-create-tasks] Available models (${#models[@]} total)."
  echo "[ai-create-tasks] Tip: paste a model id like 'opencode-go/minimax-m3' instead of a number."
  echo ""

  local n=1
  for m in "${models[@]}"; do
    local marker=""
    if [[ "$m" == "$default" ]]; then
      marker="  <-- default"
    fi
    printf "  %3d) %s%s\n" "$n" "$m" "$marker"
    n=$((n+1))
  done

  echo ""

  while true; do
    local pick=""

    if [[ -t 0 ]]; then
      read -r -p "Pick by number (1-${#models[@]}) or type a model id: " pick || true
    else
      read -r pick || true
    fi

    if [[ -z "$pick" ]]; then
      echo "[ai-create-tasks] Please enter a number or model id."
      continue
    fi

    if [[ "$pick" =~ ^[0-9]+$ ]]; then
      if (( pick >= 1 && pick <= ${#models[@]} )); then
        echo "${models[$((pick-1))]}"
        return 0
      fi
      echo "[ai-create-tasks] Invalid number: $pick (must be 1-${#models[@]})."
      continue
    fi

    echo "$pick"
    return 0
  done
}

## Preflight check for OpenCode.
##
## - If the `opencode` binary is not on PATH but is installed at the
##   default location ($HOME/.opencode/bin/opencode), adds it to PATH.
## - If opencode is missing entirely, runs the official installer
##   (curl -fsSL https://opencode.ai/install | bash).
## - Verifies the `opencode-go` provider is configured with an API key
##   by reading ~/.local/share/opencode/auth.json. If not, prints an
##   actionable message and returns non-zero.
##
## Returns 0 on success, 1 on failure.
ai-ensure-opencode() {
  local opencode_bin="$HOME/.opencode/bin/opencode"

  ## 1. Make sure the `opencode` binary is callable.
  if ! command -v opencode >/dev/null 2>&1; then
    if [[ -x "$opencode_bin" ]]; then
      export PATH="$HOME/.opencode/bin:$PATH"
      echo "[ai-create-tasks] opencode found at $opencode_bin; added to PATH for this session."
    else
      echo "[ai-create-tasks] opencode is not installed."
      echo "[ai-create-tasks] Installing now (requires curl and internet access)..."
      if ! command -v curl >/dev/null 2>&1; then
        echo "[ERROR] curl is required to install opencode."
        echo "[ERROR] Install curl first, or install opencode manually: https://opencode.ai/docs/"
        return 1
      fi
      if ! curl -fsSL https://opencode.ai/install | bash; then
        echo "[ERROR] Failed to install opencode via the official installer."
        echo "[ERROR] Install manually: https://opencode.ai/docs/"
        return 1
      fi
      export PATH="$HOME/.opencode/bin:$PATH"
      echo "[ai-create-tasks] opencode installed successfully."
    fi
  fi

  ## 2. Final sanity check: is `opencode` actually callable now?
  if ! command -v opencode >/dev/null 2>&1; then
    echo "[ERROR] opencode is still not available after the install attempt."
    echo "[ERROR] Add ~/.opencode/bin to your PATH, then retry."
    return 1
  fi

  ## 3. Make sure the opencode-go provider has an API key configured.
  ##    OpenCode stores credentials in ~/.local/share/opencode/auth.json.
  local auth_file="$HOME/.local/share/opencode/auth.json"
  if [[ ! -f "$auth_file" ]] \
     || ! jq -e '.["opencode-go"] and .["opencode-go"].type == "api" and (.["opencode-go"].key // "") != ""' \
        "$auth_file" >/dev/null 2>&1; then
    echo "[ERROR] opencode-go provider is not configured (no API key found)."
    echo "[ERROR] To fix this, run ONE of the following:"
    echo "[ERROR]   opencode auth login --provider opencode-go --method api"
    echo "[ERROR]   opencode auth login opencode-go"
    echo "[ERROR] Then paste your opencode-go API key when prompted."
    echo "[ERROR] Get a key at: https://opencode.ai/auth"
    return 1
  fi

  return 0
}

ai-create-tasks() {

  ## ---- input validation -------------------------------------------------
  local transcript_file="${1:-}"
  local output_dir="${2:-$(pwd)/tasks}"
  local model="$3"

  if [[ -z "$transcript_file" ]]; then
    echo "Usage: ai-create-tasks <transcript-file> [output-dir] [model]"
    echo "  transcript-file : path to VTT (or plain text) transcript"
    echo "  output-dir      : where task1.md, task2.md, ... are written (default: ./tasks)"
    echo "  model           : opencode model id. If omitted, you will be"
    echo "                    prompted: use default (opencode-go/minimax-m3)"
    echo "                    or pick from the live opencode model list."
    return 1
  fi

  if [[ ! -f "$transcript_file" ]]; then
    echo "[ERROR] Transcript file not found: $transcript_file"
    return 1
  fi

  ## ---- dependencies ----------------------------------------------------
  ## 1. Preflight: opencode installed + opencode-go API key configured.
  if ! ai-ensure-opencode; then
    return 1
  fi

  ## 2. Other required CLI tools.
  local missing=0
  for cmd in jq awk sed; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "[ERROR] Required command not found: $cmd"
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    return 1
  fi

  ## ---- model selection -------------------------------------------------
  ## If the user passed a model as the 3rd argument, use it. Otherwise
  ## prompt interactively (or fall back to the default in non-TTY).
  if [[ -z "$model" ]]; then
    if ! model=$(ai-pick-model "opencode-go/minimax-m3"); then
      return 1
    fi
  fi

  ## ---- work area -------------------------------------------------------
  local work_dir
  work_dir="$(mktemp -d -t ai-create-tasks.XXXXXX)"
  trap 'rm -rf "$work_dir"' RETURN

  mkdir -p "$output_dir"

  echo "[ai-create-tasks] Source : $transcript_file"
  echo "[ai-create-tasks] Output : $output_dir"
  echo "[ai-create-tasks] Model  : $model"

  ## ---- normalize transcript to a timestamped plain text form -----------
  ## Output format per line:
  ##   [hh:mm:ss.mmm - hh:mm:ss.mmm] spoken text
  local transcript_with_ts="$work_dir/transcript_ts.txt"
  local first_line
  first_line=$(head -n 1 "$transcript_file" 2>/dev/null)

  if [[ "$first_line" == "WEBVTT"* || "$first_line" == "WEBVTT" ]]; then
    awk '
      BEGIN { in_cue = 0; cue_text = "" }
      /^WEBVTT/ || /^NOTE/ || /^$/ { next }
      /^[0-9]+:[0-9]+:[0-9]+\.[0-9]+[ \t]+-->/ {
        # closing previous cue if any
        if (in_cue && cue_text != "") {
          print cue_text
          cue_text = ""
        }
        # parse timestamps (split on " --> ")
        ts = $0
        sub(/[ \t]+-->.*$/, "", ts)
        end = $0
        sub(/^.*-->[ \t]*/, "", end)
        sub(/[ \t].*$/, "", end)
        printf("[%s - %s] ", ts, end)
        in_cue = 1
        next
      }
      {
        # strip simple VTT tags like <c>, <00:00:01.000>
        gsub(/<[^>]*>/, "", $0)
        if (in_cue) {
          if (cue_text == "") cue_text = $0
          else cue_text = cue_text " " $0
        }
      }
      END {
        if (in_cue && cue_text != "") print cue_text
      }
    ' "$transcript_file" > "$transcript_with_ts"
  else
    ## Plain text transcript: pass through unchanged. The model is told the
    ## transcript has no timestamps so it should not invent any evidence.
    cp "$transcript_file" "$transcript_with_ts"
  fi

  if [[ ! -s "$transcript_with_ts" ]]; then
    echo "[ERROR] Transcript is empty after normalization"
    return 1
  fi

  local transcript_chars
  transcript_chars=$(wc -c < "$transcript_with_ts")
  echo "[ai-create-tasks] Transcript size: ${transcript_chars} chars"

  ## ---- chunk transcript for candidate extraction -----------------------
  ## Roughly 25k chars per chunk. Cap at 8 chunks to bound API cost.
  local chunk_chars=25000
  local num_chunks=1
  if (( transcript_chars > chunk_chars )); then
    num_chunks=$(( (transcript_chars + chunk_chars - 1) / chunk_chars ))
    if (( num_chunks > 8 )); then num_chunks=8; fi
  fi

  local total_lines
  total_lines=$(wc -l < "$transcript_with_ts")
  local lines_per_chunk=$(( (total_lines + num_chunks - 1) / num_chunks ))
  if (( lines_per_chunk < 1 )); then lines_per_chunk=1; fi

  echo "[ai-create-tasks] Pass 1 : extracting candidates ($num_chunks chunk(s))..."

  local candidates_combined="[]"
  local chunk_idx=0
  while (( chunk_idx < num_chunks )); do
    local chunk_start=$(( chunk_idx * lines_per_chunk + 1 ))
    local chunk_end=$(( (chunk_idx + 1) * lines_per_chunk ))
    if (( chunk_end > total_lines )); then chunk_end=$total_lines; fi

    local chunk_file="$work_dir/chunk_${chunk_idx}.txt"
    sed -n "${chunk_start},${chunk_end}p" "$transcript_with_ts" > "$chunk_file"

    echo "[ai-create-tasks]   chunk $((chunk_idx+1))/${num_chunks} (lines ${chunk_start}-${chunk_end})..."

    local prompt_file="$work_dir/prompt_extract_${chunk_idx}.txt"
    {
      printf '%s\n' "You are analyzing chunk $((chunk_idx+1)) of ${num_chunks} of a timestamped transcript."
      printf '%s\n' ""
      printf '%s\n' "Your job: extract CANDIDATE tasks. Be liberal - include anything that might"
      printf '%s\n' "be a real requested task. A later pass will reconcile duplicates, resolve"
      printf '%s\n' "references, and incorporate clarifications globally."
      printf '%s\n' ""
      printf '%s\n' "Strict rules:"
      printf '%s\n' "- Output JSON only. No Markdown, no prose, no code fences."
      printf '%s\n' "- For each candidate, preserve every timestamp where the task was mentioned,"
      printf '%s\n' "  exactly as they appear in the transcript: \"[hh:mm:ss.mmm - hh:mm:ss.mmm]\"."
      printf '%s\n' "- Distinguish actual requested tasks from general discussion, explanations,"
      printf '%s\n' "  questions, brainstorming, greetings, and unrelated conversation."
      printf '%s\n' "- Do NOT invent requirements. Preserve ambiguity in open_questions."
      printf '%s\n' "- If a chunk has nothing that looks like a real task, output:"
      printf '%s\n' "  {\"candidates\": []}"
      printf '%s\n' ""
      printf '%s\n' "JSON schema (output exactly this shape):"
      printf '%s\n' "{"
      printf '%s\n' "  \"candidates\": ["
      printf '%s\n' "    {"
      printf '%s\n' "      \"id\": \"cand-<short-kebab-slug>\","
      printf '%s\n' "      \"title\": \"Short descriptive title\","
      printf '%s\n' "      \"objective\": \"What the task aims to achieve\","
      printf '%s\n' "      \"description\": \"Concise description\","
      printf '%s\n' "      \"requirements\": [\"Requirement 1\", \"Requirement 2\"],"
      printf '%s\n' "      \"acceptance_criteria\": [\"Criterion 1\", \"Criterion 2\"],"
      printf '%s\n' "      \"technical_details\": [\"Detail 1\", \"Detail 2\"],"
      printf '%s\n' "      \"dependencies\": [\"Dependency 1\", \"Dependency 2\"],"
      printf '%s\n' "      \"edge_cases\": [\"Edge case 1\", \"Edge case 2\"],"
      printf '%s\n' "      \"open_questions\": [\"Question 1\", \"Question 2\"],"
      printf '%s\n' "      \"evidence\": [\"[hh:mm:ss.mmm - hh:mm:ss.mmm] quoted snippet\"]"
      printf '%s\n' "    }"
      printf '%s\n' "  ]"
      printf '%s\n' "}"
      printf '%s\n' ""
      printf '%s\n' "TRANSCRIPT CHUNK:"
      printf '%s\n' ""
      cat "$chunk_file"
    } > "$prompt_file"

    local raw_response
    if ! raw_response=$(ai-run-opencode "$model" "$prompt_file"); then
      echo "[WARN] Chunk $((chunk_idx+1)) failed; skipping"
      chunk_idx=$((chunk_idx+1))
      continue
    fi

    local chunk_json
    chunk_json=$(printf '%s' "$raw_response" | ai-extract-json)

    if ! printf '%s' "$chunk_json" | jq -e . >/dev/null 2>&1; then
      echo "[WARN] Chunk $((chunk_idx+1)) returned invalid JSON; skipping"
      chunk_idx=$((chunk_idx+1))
      continue
    fi

    local chunk_candidates
    chunk_candidates=$(printf '%s' "$chunk_json" | jq '.candidates // []')

    candidates_combined=$(jq -s 'add // []' \
      <(printf '%s' "$candidates_combined") \
      <(printf '%s' "$chunk_candidates"))

    chunk_idx=$((chunk_idx+1))
  done

  printf '%s' "$candidates_combined" | jq . > "$work_dir/candidates.json"
  local candidates_count
  candidates_count=$(printf '%s' "$candidates_combined" | jq 'length')
  echo "[ai-create-tasks]   -> ${candidates_count} candidate(s) collected"

  ## ---- pass 2: global reconciliation ----------------------------------
  echo "[ai-create-tasks] Pass 2 : reconciling against full transcript..."

  local reconcile_prompt="$work_dir/prompt_reconcile.txt"
  {
    printf '%s\n' "You are performing GLOBAL RECONCILIATION of candidate tasks extracted"
    printf '%s\n' "from a timestamped transcript."
    printf '%s\n' ""
    printf '%s\n' "Your job: produce the CANONICAL task list."
    printf '%s\n' ""
    printf '%s\n' "Strict rules:"
    printf '%s\n' "- Output JSON only. No Markdown, no prose, no code fences."
    printf '%s\n' "- Merge duplicates: the same task discussed across multiple chunks = ONE entry."
    printf '%s\n' "- Resolve references such as \"this\", \"that\", \"the previous task\","
    printf '%s\n' "  \"going back to...\" against the correct task."
    printf '%s\n' "- Incorporate later clarifications and corrections over earlier statements."
    printf '%s\n' "- Do NOT invent requirements. Preserve ambiguity as open_questions."
    printf '%s\n' "- Each task MUST include evidence: a list of timestamp strings preserved"
    printf '%s\n' "  exactly as they appear in the transcript:"
    printf '%s\n' "  \"[hh:mm:ss.mmm - hh:mm:ss.mmm]\"."
    printf '%s\n' "- Distinguish actual requested tasks from discussion, questions,"
    printf '%s\n' "  brainstorming, greetings, and unrelated conversation. Drop non-tasks."
    printf '%s\n' "- Avoid duplicate or overly fragmented tasks."
    printf '%s\n' "- Order tasks logically (chronological order of first mention is fine)."
    printf '%s\n' "- Use empty arrays (not null) for empty list fields."
    printf '%s\n' ""
    printf '%s\n' "JSON schema (output exactly this shape):"
    printf '%s\n' "{"
    printf '%s\n' "  \"tasks\": ["
    printf '%s\n' "    {"
    printf '%s\n' "      \"title\": \"...\","
    printf '%s\n' "      \"objective\": \"...\","
    printf '%s\n' "      \"description\": \"...\","
    printf '%s\n' "      \"requirements\": [\"...\"],"
    printf '%s\n' "      \"acceptance_criteria\": [\"...\"],"
    printf '%s\n' "      \"technical_details\": [\"...\"],"
    printf '%s\n' "      \"dependencies\": [\"...\"],"
    printf '%s\n' "      \"edge_cases\": [\"...\"],"
    printf '%s\n' "      \"open_questions\": [\"...\"],"
    printf '%s\n' "      \"evidence\": [\"[hh:mm:ss.mmm - hh:mm:ss.mmm] ...\"]"
    printf '%s\n' "    }"
    printf '%s\n' "  ]"
    printf '%s\n' "}"
    printf '%s\n' ""
    printf '%s\n' "CANDIDATE TASKS (from chunked extraction):"
    printf '%s\n' ""
    cat "$work_dir/candidates.json"
    printf '%s\n' ""
    printf '%s\n' "FULL TIMESTAMPED TRANSCRIPT:"
    printf '%s\n' ""
    cat "$transcript_with_ts"
  } > "$reconcile_prompt"

  local raw_final
  if ! raw_final=$(ai-run-opencode "$model" "$reconcile_prompt"); then
    echo "[ERROR] Final reconciliation call failed"
    return 1
  fi

  local final_json
  final_json=$(printf '%s' "$raw_final" | ai-extract-json)

  if ! printf '%s' "$final_json" | jq -e . >/dev/null 2>&1; then
    echo "[ERROR] Final reconciliation did not return valid JSON"
    echo "[ERROR] Raw response was:"
    printf '%s\n' "$raw_final" | head -n 20
    return 1
  fi

  printf '%s' "$final_json" | jq . > "$work_dir/final.json"

  ## ---- generate task markdown files via jq -----------------------------
  echo "[ai-create-tasks] Rendering task markdown files..."

  local task_count
  task_count=$(printf '%s' "$final_json" | jq '.tasks | length')

  if (( task_count == 0 )); then
    echo "[WARN] No tasks found in the transcript"
    return 0
  fi

  local i=0
  while (( i < task_count )); do
    local task_md="$output_dir/task$((i+1)).md"
    printf '%s' "$final_json" \
      | jq -r --argjson idx "$i" '
          def render_list:
            if (length // 0) > 0
            then (map("- " + .) | join("\n")) + "\n"
            else "None captured.\n"
            end;

          .tasks[$idx] |
          "# Task: " + (.title // "Untitled") + "\n\n" +
          (if ((.objective // "") | length) > 0
           then "## Objective\n" + .objective + "\n\n"
           else "" end) +
          (if ((.description // "") | length) > 0
           then "## Description\n" + .description + "\n\n"
           else "" end) +
          "## Requirements\n" + ((.requirements // []) | render_list) + "\n" +
          "## Acceptance Criteria\n" + ((.acceptance_criteria // []) | render_list) + "\n" +
          "## Technical Details\n" + ((.technical_details // []) | render_list) + "\n" +
          "## Dependencies\n" + ((.dependencies // []) | render_list) + "\n" +
          "## Edge Cases\n" + ((.edge_cases // []) | render_list) + "\n" +
          "## Open Questions\n" + ((.open_questions // []) | render_list) + "\n" +
          "## Evidence\n" + ((.evidence // []) | render_list)
        ' > "$task_md"
    echo "  -> $task_md"
    i=$((i+1))
  done

  echo "[ai-create-tasks] Done. ${task_count} task file(s) in ${output_dir}"
}