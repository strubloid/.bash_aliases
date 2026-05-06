
#!/bin/bash

# Preset configs for gemma4:26b
OLLAMA_CONFIG_BALANCED="$(cat <<'EOF'
PARAMETER num_ctx 32768
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 64
PARAMETER repeat_penalty 1.08
PARAMETER num_predict 4096
EOF
)"
OLLAMA_CONFIG_CODER="$(cat <<'EOF'
PARAMETER num_ctx 32768
PARAMETER temperature 0.25
PARAMETER top_p 0.85
PARAMETER top_k 40
PARAMETER repeat_penalty 1.1
PARAMETER num_predict 4096
EOF
)"
OLLAMA_CONFIG_CREATIVE="$(cat <<'EOF'
PARAMETER num_ctx 32768
PARAMETER temperature 0.95
PARAMETER top_p 0.95
PARAMETER top_k 64
PARAMETER repeat_penalty 1.05
PARAMETER num_predict 4096
EOF
)"
OLLAMA_CONFIG_PRECISE="$(cat <<'EOF'
PARAMETER num_ctx 32768
PARAMETER temperature 0.1
PARAMETER top_p 0.75
PARAMETER top_k 30
PARAMETER repeat_penalty 1.12
PARAMETER num_predict 2048
EOF
)"
OLLAMA_CONFIG_LONG_CONTEXT="$(cat <<'EOF'
PARAMETER num_ctx 65536
PARAMETER temperature 0.45
PARAMETER top_p 0.9
PARAMETER top_k 50
PARAMETER repeat_penalty 1.08
PARAMETER num_predict 8192
EOF
)"


# JSON string for all config presets (for use with jq or external tools)
OLLAMA_CONFIG_JSON="$(jq -n \
  --arg balanced "$OLLAMA_CONFIG_BALANCED" \
  --arg coder "$OLLAMA_CONFIG_CODER" \
  --arg creative "$OLLAMA_CONFIG_CREATIVE" \
  --arg precise "$OLLAMA_CONFIG_PRECISE" \
  --arg long_context "$OLLAMA_CONFIG_LONG_CONTEXT" \
  '[
    {
      name: "Balanced",
      config: $balanced,
      system: "You are a balanced assistant. Provide clear, practical, and accurate answers. Be concise when the task is simple, but give enough detail when the problem requires it. State uncertainty when needed."
    },
    {
      name: "Coder",
      config: $coder,
      system: "You are a senior software engineer and coding agent. Prioritize correctness, maintainability, type safety, and minimal changes. Before editing files, inspect the target file. Use exact file paths. Never claim a file was changed unless the tool succeeded. After edits, verify by reading the file or running the relevant checks."
    },
    {
      name: "Creative",
      config: $creative,
      system: "You are a creative assistant. Generate original, vivid, and engaging ideas while still respecting the user'\''s constraints. Offer multiple directions when useful. Keep the output imaginative, polished, and practical."
    },
    {
      name: "Precise",
      config: $precise,
      system: "You are a precise assistant. Answer directly and avoid speculation. Check assumptions carefully. Prefer exact steps, exact commands, and clear verification. If information is missing, say what is missing instead of guessing."
    },
    {
      name: "Long Context",
      config: $long_context,
      system: "You are a long-context analysis assistant. Track details across large inputs carefully. Summarize structure before making changes. Preserve existing behavior unless asked otherwise. When working with long documents or codebases, identify dependencies, risks, and verification steps."
    }
  ]'
)"

# Strubloid::linux::ollama

# ollama-dangerous: Select a model from ollama ls and run launch with dangerous flag
ollama-dangerous() {
	local model_list model selected_model
	model_list=$(ollama ls | awk 'NR>1 {print $1}')
	if [ -z "$model_list" ]; then
		echo "No models found from 'ollama ls'."
		return 1
	fi
	echo "Available models:"
	select selected_model in $model_list; do
		if [ -n "$selected_model" ]; then
			echo "Launching: ollama launch claude --model $selected_model --yes -- --dangerously-skip-permissions"
			ollama launch claude --model "$selected_model" --yes -- --dangerously-skip-permissions
			break
		else
			echo "Invalid selection. Try again."
		fi
	done
}

# ollama-tweak: Select a base model from ollama ls, tweak parameters, and create a new model
ollama-tweak() {

  local model_list selected_model new_model_name num_ctx temperature top_p top_k tmp_modelfile
  model_list=$(ollama ls | awk 'NR>1 {print $1}')
  if [ -z "$model_list" ]; then
    echo "No models found from 'ollama ls'."
    return 1
  fi
  
  echo "Available base models:"
  select selected_model in $model_list; do
    if [ -n "$selected_model" ]; then
      break
    else
      echo "Invalid selection. Try again."
    fi
  done

  read -p "Enter new model name: " new_model_name

  # Set good defaults for parameters
  # num_ctx: 32768 is high and safe for most modern models; increase if your hardware and model support it
  read -p "num_ctx (default 32768, increase for max context): " num_ctx
  num_ctx=${num_ctx:-32768}

  # temperature: 0.7 is a common balanced value (lower = more deterministic, higher = more creative)
  read -p "temperature (default 0.7): " temperature
  temperature=${temperature:-0.7}

  # top_p: 0.9 is a common default for nucleus sampling
  read -p "top_p (default 0.9): " top_p
  top_p=${top_p:-0.9}

  # top_k: 40 is a common default (higher = more randomness)
  read -p "top_k (default 40): " top_k
  top_k=${top_k:-40}

  tmp_modelfile=$(mktemp)
  cat > "$tmp_modelfile" <<EOF
FROM $selected_model
PARAMETER num_ctx $num_ctx
PARAMETER temperature $temperature
PARAMETER top_p $top_p
PARAMETER top_k $top_k
EOF

  echo "Creating model $new_model_name from $selected_model with custom parameters..."
  ollama create "$new_model_name" -f "$tmp_modelfile"
  rm -f "$tmp_modelfile"

}

ollama-tweak-advanced() {

  local model_list selected_model new_model_name num_ctx temperature top_p top_k tmp_modelfile
  model_list=$(ollama ls | awk 'NR>1 {print $1}')
  if [ -z "$model_list" ]; then
    echo "No models found from 'ollama ls'."
    return 1
  fi
  
  echo "Available base models:"
  select selected_model in $model_list; do
    if [ -n "$selected_model" ]; then
      break
    else
      echo "Invalid selection. Try again."
    fi
  done

  echo "Selected model: $selected_model"
  read -p "Enter new model name: " new_model_name

  # Extract names from JSON for menu
  mapfile -t config_names < <(echo "$OLLAMA_CONFIG_JSON" | jq -r '.[].name')
  echo "Select a configuration preset:"
  select config_name in "${config_names[@]}"; do
    if [ -n "$config_name" ]; then
      config_index=$((REPLY-1))
      config_value=$(echo "$OLLAMA_CONFIG_JSON" | jq -r ".[$config_index].config")
      system_value=$(echo "$OLLAMA_CONFIG_JSON" | jq -r ".[$config_index].system")
      break
    else
      echo "Invalid selection. Try again."
    fi
  done

  ## creating a temp file
  tmp_modelfile=$(mktemp)

  ## loading the string
  modelfile_content="FROM $selected_model\n\n$config_value\n\nSYSTEM \"\"\"\n$system_value\n\"\"\""  
  
  ## writing to the temp file (no output to terminal)
  echo -e "$modelfile_content" > "$tmp_modelfile"

  echo -e "\nContent saved:"
  cat "$tmp_modelfile"

  # echo "Creating model $new_model_name from $selected_model with custom parameters..."
  ollama create "$new_model_name" -f "$tmp_modelfile"
  rm -f "$tmp_modelfile"

}