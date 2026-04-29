import os
from openai import OpenAI

class OpenAIService:
    """Encapsulates interaction with OpenAI API."""

    def __init__(self):
        api_key = os.environ.get("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY environment variable is not set.")
        self.client = OpenAI(api_key=api_key)

    def ask(self, messages, model="gpt-3.5-turbo"):
        response = self.client.chat.completions.create(
            messages=messages,
            model=model,
        )
        return response.choices[0].message.content