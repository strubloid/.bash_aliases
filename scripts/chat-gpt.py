import os
import sys
from openai import OpenAI

client = OpenAI(
    # This is the default and can be omitted
    api_key=os.environ.get("OPENAI_API_KEY"),
)

UserMessage = "qual é a cor do céu?"

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": UserMessage,
        }
    ],
    model="gpt-3.5-turbo",
)

# model="gpt-3.5-turbo",
ai_response = response.choices[0].message.content
print(ai_response)



