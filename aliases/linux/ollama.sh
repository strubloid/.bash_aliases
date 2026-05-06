#!/bin/bash

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
  read -p "num_ctx (default 32768): " num_ctx
  num_ctx=${num_ctx:-32768}
  read -p "temperature (default 1.0): " temperature
  temperature=${temperature:-1.0}
  read -p "top_p (default 0.95): " top_p
  top_p=${top_p:-0.95}
  read -p "top_k (default 64): " top_k
  top_k=${top_k:-64}

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

