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

