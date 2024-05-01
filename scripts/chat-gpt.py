import os
import sys
from openai import OpenAI

client = OpenAI(
    # This is the default and can be omitted
    api_key=os.environ.get("OPENAI_API_KEY"),
)

# Check if there are command line arguments
if len(sys.argv) < 2:
    print("You must provide a message")
    sys.exit(1)

client = OpenAI(
    # This is the default and can be omitted
    api_key=os.environ.get("OPENAI_API_KEY"),
)

# Loading the line to search on chat gpt
Question = sys.argv[1]
# print(Question)

# Creating the query
response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": Question,
        }
    ],
    model="gpt-3.5-turbo",
)

# model="gpt-3.5-turbo",
ai_response = response.choices[0].message.content

# This will print out, so a bash script can get this response
print(ai_response)



