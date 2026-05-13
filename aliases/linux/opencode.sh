#!/bin/bash

# Strubloid::linux::opencode

opencode-chrome() {
  local path="${1:-.}"
  local port="${2:-9999}"
  cd "$path" && opencode serve --hostname 0.0.0.0 --port "$port"
}

opencode-kill() {
  local port="${1:-9999}"
  echo "Killing process on port $port..."
  fuser -k "$port"/tcp 2>/dev/null || pkill -f "opencode serve.*$port" || echo "No process found on port $port"
}

## This function creates the global skill folders for both Copilot and Opencode if they don't exist
## it also creates the global config for both Copilot and Opencode if they don't exist
## 
opencode-create-global-skill-folder(){

  ## personal skill folder location
  local globalCopilotSkillFolder="$HOME/.copilot/skills"

  ## global config skill folder location
  local globalOpencodeSkillFolder="$HOME/.config/opencode/command"

  # creates the global skills folders if not exist
  mkdir -p "$globalCopilotSkillFolder"
  mkdir -p "$globalOpencodeSkillFolder"
}

## this will copy a skill to a current project folder
## and create the necessary folders if not exist and skills in opencode and vscode
opencode-local-skills(){

  ## we get the current project folder
  read -p "Tell me the project folder (press enter to use current folder): " project_folder

  ## checking if is empty we use the current folder
  if [ -z "$project_folder" ]; then
    project_folder=$(pwd)
  fi

  ## we get the skill name or use the current folder name
  read -p "Tell me the skill name (press enter to use current folder name): " skill_name

  ## if we cant find the skill name value we use the current folder name
  if [ -z "$skill_name" ]; then
    skill_name=$(basename "$project_folder")
  fi

  ## checking if the .github folder exist 
  if [ ! -d "$project_folder/.github/skills" ]; then
    
    ## creating the github skills folder
    mkdir -p "$project_folder/.github/skills"
    echo "✓ Created .github/skills folder in project"
  fi

  ## checking if the .opencode folder exist 
  if [ ! -d "$project_folder/.opencode/commands" ]; then
    
    ## creating the opencode skills folder
    mkdir -p "$project_folder/.opencode/commands"
    echo "✓ Created .opencode/commands folder in project"
  fi

  ## creating skill folder for github and opencode
  mkdir -p "$project_folder/.github/skills/$skill_name"
  echo "✓ Created .github/skills/$skill_name"

  mkdir -p "$project_folder/.opencode/commands/$skill_name"
  echo "✓ Created .opencode/commands/$skill_name"

  # copying the skill files to both folders
  cp -r ./*.md "$project_folder/.github/skills/$skill_name/"
  cp -r ./*.md "$project_folder/.opencode/commands/$skill_name/"

  echo "Opening skill '$skill_name' in VS Code from project folder: $project_folder"

}

## this will copy a skill to the global skills folder for both Copilot and Opencode
## and create the necessary folders if not exist and skills in opencode and vscode
## this will also open the skill in VS Code after copying to the global skills folder 
## for both Copilot and Opencode folder
opencode-add-current-skill-globally() {

  ## we get the first argument of the skill name or gets the current folder name
  local skill_name="${1:-$(basename "$(pwd)")}"

  ## personal skill folder location
  local global_copilot_skills_folder="$HOME/.copilot/skills/$skill_name"

  ## global config skill folder location
  local global_opencode_skills_folder="$HOME/.config/opencode/command/$skill_name"

  ## we check if not exist the personal skill folder in the destination folder
  if [ ! -d "$global_copilot_skills_folder" ]; then
    ## creating personal skill folder in the destination folder
    mkdir -p "$global_copilot_skills_folder"
  fi

  ## we check if not exist the global skill folder in the destination folder
  if [ ! -d "$global_opencode_skills_folder" ]; then
    ## creating global skill folder in the destination folder
    mkdir -p "$global_opencode_skills_folder"
  fi

  ## copy the current skill file to both destination folders
  cp -r ./* "$global_copilot_skills_folder/"
  cp -r ./* "$global_opencode_skills_folder/"

  echo "✓ Skill '$skill_name' registered at:"
  echo "  Personal: $global_copilot_skills_folder"
  echo "  Global:   $global_opencode_skills_folder"
}
