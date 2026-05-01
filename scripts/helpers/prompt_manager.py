import os
import json

class PromptManager:

  @staticmethod
  def get_chunk_prompt(chunk, language_name, previous_chunk=""):
    if previous_chunk:
        previous_context = (
            "\nPREVIOUS CONTEXT (for consistency only, do not repeat; "
            "use the previous chunk as context to ensure consistency and correct any discrepancies in the current chunk):\n"
            f"{previous_chunk}\n"
        )
    else:
      previous_context = ""
    return f"""
      You are extracting structured data from an RPG session.

      IMPORTANT:
      - Write in {language_name}
      - DO NOT invent anything

      {previous_context}
      TASK:
      Extract structured information.

      OUTPUT FORMAT (JSON ONLY):

      {{
        "events": ["..."],
        "clues": ["..."],
        "decisions": ["..."],
        "interactions": ["..."],
        "combat": ["..."],
        "items": ["..."],
        "entities": ["list of names exactly as written"],
        "state": "current situation"
      }}

      RULES:
      - Keep chronological order
      - Keep exact names
      - No interpretation
      - No summarization

      TEXT:
      {chunk}
      """

  ## This will generate the final prompt for the narrative recap, combining all chunk summaries 
  # and providing clear instructions to the AI on how to structure the final output. 
  # It emphasizes the importance of using only the provided data and maintaining a clear sequence 
  # of events, cause and effect, and exact names. 
  # The final section also guides the AI to summarize the current situation, next steps, and active
  # risks based on the combined summaries.
  @staticmethod
  def get_final_prompt(merged_json, language_name):
    return f"""
      You are generating a final RPG recap.

      IMPORTANT:
      - Write in {language_name}
      - Use ONLY provided data
      - Do NOT invent anything

      TASK:
      Convert structured data into a recap.

      RULES:
      - Keep chronological order
      - Keep cause → effect
      - Keep names EXACT
      - If missing info, OMIT

      STRUCTURE:

      [Parte 1]
      Start and initial events

      [Parte 2]
      Investigation / development

      [Parte 3]
      Main event / decision

      [Parte 4]
      Final events / consequences

      Each part:
      - 2–3 paragraphs
      - Clear sequence
      - No filler

      DATA:
      {merged_json}
      """