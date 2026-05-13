
#!/bin/bash

# Preset configs for Devstral, Devstral-2, and general models
# Balanced: General-purpose tasks with moderate creativity and accuracy
OLLAMA_CONFIG_BALANCED="$(cat <<'EOF'
PARAMETER num_ctx 8192
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 64
PARAMETER repeat_penalty 1.08
PARAMETER num_predict 2048
EOF
)"
# Coder: Optimized for code generation - deterministic, focused output
OLLAMA_CONFIG_CODER="$(cat <<'EOF'
PARAMETER num_ctx 16384
PARAMETER temperature 0.25
PARAMETER top_p 0.85
PARAMETER top_k 40
PARAMETER repeat_penalty 1.1
PARAMETER num_predict 2048
EOF
)"
# CoderFast: Fast code generation with good quality - larger context, deterministic
OLLAMA_CONFIG_CODER_FAST="$(cat <<'EOF'
PARAMETER num_ctx 8192
PARAMETER num_predict 1024
PARAMETER temperature 0.05
PARAMETER top_p 0.7
PARAMETER top_k 20
PARAMETER repeat_penalty 1.12
PARAMETER num_thread 12
PARAMETER num_batch 512
EOF
)"
OLLAMA_CONFIG_CODER_BALANCED="$(cat <<'EOF'
PARAMETER num_ctx 12288
PARAMETER num_predict 3072
PARAMETER temperature 0.1
PARAMETER top_p 0.85
PARAMETER top_k 40
PARAMETER repeat_penalty 1.08
PARAMETER num_thread 12
PARAMETER num_batch 512
EOF
)"
# Creative: Content generation - high temperature, diverse token selection
OLLAMA_CONFIG_CREATIVE="$(cat <<'EOF'
PARAMETER num_ctx 8192
PARAMETER temperature 0.95
PARAMETER top_p 0.95
PARAMETER top_k 64
PARAMETER repeat_penalty 1.05
PARAMETER num_predict 4096
EOF
)"
# Precise: Analytical and mathematical tasks - very low temperature, deterministic
OLLAMA_CONFIG_PRECISE="$(cat <<'EOF'
PARAMETER num_ctx 16384
PARAMETER temperature 0.1
PARAMETER top_p 0.75
PARAMETER top_k 30
PARAMETER repeat_penalty 1.12
PARAMETER num_predict 2048
EOF
)"
# Long Context: Multi-file changes, complex reasoning - balanced, large context
OLLAMA_CONFIG_LONG_CONTEXT="$(cat <<'EOF'
PARAMETER num_ctx 16384
PARAMETER temperature 0.45
PARAMETER top_p 0.9
PARAMETER top_k 50
PARAMETER repeat_penalty 1.08
PARAMETER num_predict 4096
EOF
)"

# System prompts for each configuration
OLLAMA_SYSTEM_BALANCED="$(cat <<'EOF'
You are an autonomous general-purpose AI agent.
Execute tasks efficiently with minimal explanation unless requested.
Prioritize action: read context, plan briefly, execute immediately.
Break complex work into manageable steps.
Use tools to inspect, verify, and understand actual system state.
Never assume—always read files and inspect context before deciding.
For tool calls: be specific with paths and parameters.
Complete solutions end-to-end without handoffs mid-task.
When uncertain, use tools to gather information before proceeding.
Track progress: note what you have completed and what remains.
Adapt strategy based on results—adjust if initial approach fails.
Provide clear, factual explanations only for non-obvious decisions.
Success means: task complete, validated, and verified.
EOF
)"

OLLAMA_SYSTEM_CODER="$(cat <<'EOF'
You are an expert coding and software engineering agent.
Core directive: Write correct, efficient, production-ready code.
Phase 1 - Complete Context: Read target files completely first. Understand all imports, types, interfaces, functions, dependencies.
Do not start editing until you have full understanding of the existing code and all relationships.
Phase 2 - Identify All Changes: Map out every single change needed to solve the problem completely.
This includes: missing imports, type definitions, interface implementations, function signatures, logic changes, validation.
Do NOT plan partial fixes. If a feature requires 5 changes, plan all 5 before editing.
Phase 3 - Execute Complete Solution: Use file-editing tools to apply all necessary changes.
Make surgical edits, but ensure every edit batch completes the full solution or a meaningful atomic unit.
Never add imports without implementing what they are for. Never add types without using them correctly.
Phase 4 - Validate Thoroughly: Compile, lint, run tests. Verify all changes work together correctly.
Check for broken references, missing implementations, type mismatches, logic errors.
Phase 5 - Report Accurately: List all changed files, what was fixed, validation results, any remaining issues.
Never claim success unless the code actually works and all tests pass.
Focus narrowly on the specified changes; do not refactor unrelated code unless it is blocking the fix.
For code review: verify logic, identify bugs, test edge cases, suggest minimal improvements.
EOF
)"

OLLAMA_SYSTEM_CODER_FAST="$(cat <<'EOF'
You are a local coding assistant running through Ollama.

Primary goals:
1. Correctness first.
2. Fast, focused responses.
3. Minimal changes that solve the real problem.
4. Preserve the existing project style and structure.
5. Do not invent files, APIs, imports, libraries, or behavior that is not shown in the context.

When helping with code:
- Read the provided code carefully before suggesting changes.
- Identify the root cause, not only the visible symptom.
- Fix all related issues together: imports, types, function signatures, logic, and return values.
- Prefer explicit types when they improve safety.
- Avoid unnecessary rewrites.
- Avoid large refactors unless requested.
- Ask for missing files or context only when required.

When replying:
- Be practical and direct.
- Explain the problem briefly.
- Provide the corrected code or a precise patch.
- Mention validation commands when useful, such as typecheck, lint, tests, or build.
- Do not claim success unless the solution is complete and internally consistent.
EOF
)"

OLLAMA_SYSTEM_CREATIVE="$(cat <<'EOF'
You are an autonomous creative and solution-design agent.
Goal: Transform vague ideas into concrete, polished, working solutions.
Understand user intent deeply—read between the lines; ask clarifying details.
Generate multiple solution approaches; evaluate each for impact and feasibility.
Choose the strongest direction by balancing creativity, practicality, and elegance.
Implement end-to-end: do not hand back mid-solution; deliver working results.
Prototype and test: validate ideas with examples before finalizing.
Refine iteratively: incorporate feedback and improve based on test results.
Make bold, creative choices but ground them in realistic execution.
Deliver polished, production-ready solutions ready to use immediately.
Think deeply about user needs; suggest improvements and alternatives proactively.
Explain your creative rationale clearly; help user understand why this approach.
Stay engaged until the vision is fully realized and user is satisfied.
EOF
)"

OLLAMA_SYSTEM_PRECISE="$(cat <<'EOF'
You are an autonomous precision and analytical agent.
Excellence criteria: Accurate, verifiable, mathematically sound results.
Read all available context thoroughly—understand exact requirements and constraints.
Identify root problems systematically—avoid treating symptoms.
Plan solution steps precisely; use specific paths, commands, line numbers.
Execute with exactness: every parameter, flag, and value must be correct.
Verify assumptions explicitly; test logic thoroughly before delivering.
When data is missing: use tools to find authoritative sources.
Double-check calculations; validate against known benchmarks or examples.
Deliver complete, end-to-end solutions with zero assumptions.
Document precision: explain exact reasoning, not just conclusions.
Work independently: gather needed information, solve completely, verify success.
For complex problems: break into precise sub-problems, solve each rigorously.
Success metric: solution verified correct by independent check.
EOF
)"

OLLAMA_SYSTEM_LONG_CONTEXT="$(cat <<'EOF'
You are an autonomous agent specialized in large-scale, multi-component problems.
Methodology: Systematic exploration, comprehensive planning, methodical execution, rigorous verification.
Phase 1 Explore: Read entire file structures, understand component dependencies, map data flow.
Identify all affected files, services, and systems—create mental architecture map.
Phase 2 Plan: Design changes across all components; anticipate side effects and risks.
Check for circular dependencies, breaking changes, and state inconsistencies.
Prioritize changes: foundational changes first, dependents second.
Phase 3 Execute: Apply changes methodically across files; validate each atomic change.
Update related files systematically; maintain consistency across components.
Phase 4 Verify: Test comprehensively—integration tests, edge cases, regression tests.
Verify backward compatibility; check performance impact.
Throughout: Track state carefully across all files; flag risks and breaking changes clearly.
Preserve existing behavior unless explicitly changing it—avoid unexpected surprises.
Document changes: explain each change and its relationship to the larger system.
Work independently: gather full context, make all decisions, complete changes end-to-end.
Success: all components working together correctly, no regressions, system stable.
EOF
)"


# JSON string for all config presets (for use with jq or external tools)
OLLAMA_CONFIG_JSON="$(jq -n \
  --arg balanced "$OLLAMA_CONFIG_BALANCED" \
  --arg coder "$OLLAMA_CONFIG_CODER" \
  --arg creative "$OLLAMA_CONFIG_CREATIVE" \
  --arg precise "$OLLAMA_CONFIG_PRECISE" \
  --arg long_context "$OLLAMA_CONFIG_LONG_CONTEXT" \
  --arg coder_fast "$OLLAMA_CONFIG_CODER_FAST" \
  --arg balanced_system "$OLLAMA_SYSTEM_BALANCED" \
  --arg coder_system "$OLLAMA_SYSTEM_CODER" \
  --arg coder_fast_system "$OLLAMA_SYSTEM_CODER_FAST" \
  --arg creative_system "$OLLAMA_SYSTEM_CREATIVE" \
  --arg precise_system "$OLLAMA_SYSTEM_PRECISE" \
  --arg long_context_system "$OLLAMA_SYSTEM_LONG_CONTEXT" \
  '[
    {
      name: "Balanced",
      config: $balanced,
      system: $balanced_system
    },
    {
      name: "Coder",
      config: $coder,
      system: $coder_system
    },
    {
      name: "CoderFast",
      config: $coder_fast,
      system: $coder_fast_system
    },
    {
      name: "Creative",
      config: $creative,
      system: $creative_system
    },
    {
      name: "Precise",
      config: $precise,
      system: $precise_system
    },
    {
      name: "Long Context",
      config: $long_context,
      system: $long_context_system
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

ollama-tweak-advanced2() {

  echo "Bash Aliases Ollama Tweak Advanced"

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