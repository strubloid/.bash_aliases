#!/bin/bash

# Strubloid::linux::Python

# # alias gpt-summarizer='/media/games/apps/gpt-summarizer/main_cli.py'

start-python-local(){

  python3 -m venv /media/games/apps/pyhtonEnvironment/myenv
  source /media/games/apps/pyhtonEnvironment/myenv/bin/activate  # Activate the virtual environment
}

#sum-gpt(){

#  ## getting the file to read
#  read -p "[Share the path to the file]: " CHECK_THIS_FILE_PATH
#
#  CHAT_GPT_FOLDER="/media/games/apps/gpt-summarizer/"
#
#
#  python3 gpt-summarizer  $CHECK_THIS_FILE_PATH $1 $2 $3 $4
#}

sum-gpt()
{
    # Define the endpoint URL
    ENDPOINT="https://api.openai.com/v1/chat/completions"

    # Loading the file to compress
    if [ -z "$1" ]
    then
        read -p "[file]: " USER_INPUT
    else
        USER_INPUT=$(cat $1)
    fi

    echo "[USER_INPUT]: OK"

    # Create a temporary file to store the user input
    TMP_INPUT_FILE=$(mktemp)

    # Read user input from the input file and write it to the temporary file
    cat $INPUT_FILE > $TMP_INPUT_FILE



    # Define the prompt
    PROMPT='{
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Tell me a joke."}
      ]
    }'

    # Make the API request using curl
    RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/engines/davinci/completions" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$PROMPT")

    # Extract the response from the JSON
    CHAT_RESPONSE=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

    # Print the chat response
    echo "ChatGPT says: $CHAT_RESPONSE"
    echo $CHAT_RESPONSE > "chat_gpt_reply.txt"


#    response=$(curl https://api.openai.com/v1/models \
#            -H "Authorization: Bearer $OPENAI_API_KEY" \
#            -H "OpenAI-Organization: $ORGANIZATION_ID" \
#            -H "OpenAI-Project: $PROJECT_ID")
    echo "[RESPONSE]: OK"

## Send the user input to ChatGPT
#response=$(curl -s -X POST \
#    -H "Content-Type: application/json" \
#    -H "Authorization: Bearer $API_KEY" \
#    --data-binary @$TMP_INPUT_FILE \
#    $ENDPOINT \
#    <<EOF
#{
#  "model": "text-davinci-003",
#  "max_tokens": 50
#}
#EOF
#)


#    # Clean up the temporary file
#    echo "[TMP_FILE]: REMOVED"
#    rm $TMP_INPUT_FILE

#    # Parse the response and extract ChatGPT's reply
#    reply=$(echo $response | jq -r '.choices[0].message.content')

#    # Print ChatGPT's reply
#    echo "[ChatGPT]: $reply"
#    echo $reply > "chat_gpt_reply.txt"
}