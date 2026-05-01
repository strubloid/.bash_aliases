import os

class PromptManager:
    @staticmethod
    def get_chunk_prompt(chunk, language_name, canonical_names):
        return f"""
WARNING: Use ONLY what is explicitly present in the input. Do NOT invent, infer, or replace missing information.

IMPORTANT: Write in {language_name}.

{f'VALID NAMES: {", ".join(canonical_names)}. You MUST use only these exact names. If a name differs, keep it as-is (do NOT replace or guess).' if canonical_names else ''}

OBJECTIVE:
Summarize this segment into ONE clear, natural paragraph preserving ALL key events.

CRITICAL RULES:

- DO NOT invent any new information
- DO NOT introduce mechanics (no "advantage", "roll", etc.)
- DO NOT rename characters
- DO NOT remove key events (fire, investigation, clues, Carman, dungeon, necromancy, combat)
- DO NOT over-structure (no bullet points, no labels like "Eventos")
- DO NOT generalize important details

REQUIRED CONTENT (if present in the chunk):
- What happened
- Who was involved
- Key discoveries or clues
- Decisions made
- Outcomes

STYLE:
- Write as a natural session recap paragraph
- Clear and readable
- Neutral tone
- Maintain chronological order
- Keep cause → effect when present

Transcription:
{chunk}
"""

    @staticmethod
    def get_final_prompt(combined_summaries, language_name, canonical_names):
        return f"""
WARNING: Use ONLY the information in the summaries. Do NOT add, infer, or modify facts.

IMPORTANT: Write in {language_name}.

{f'VALID NAMES: {", ".join(canonical_names)}. Use these names exactly. Do NOT change or replace names.' if canonical_names else ''}

OBJECTIVE:
Produce a clean, natural RPG session recap similar to a narrated summary.

CRITICAL RULES:

- DO NOT invent events or details
- DO NOT add game mechanics not explicitly stated
- DO NOT rename characters
- DO NOT remove important events
- DO NOT restructure into lists or bullet points
- DO NOT over-simplify key scenes

REQUIRED STRUCTURE:

- Divide into:
  [Parte 1]
  [Parte 2]
  [Parte 3]
  [Parte 4]

- Each part must be ONE or TWO natural paragraphs
- Maintain chronological order
- Preserve narrative flow

REQUIRED CONTENT (if present in summaries):

- Fire and initial investigation
- Clues (break-in, witnesses, spider, etc.)
- Crook Snook and goblins
- Carman interaction and resolution
- Dungeon exploration
- Necromancy lab and goblin assistant
- Ethical decision (kill or spare)
- Combat and outcome
- Items discovered

STYLE:

- Natural storytelling recap (like a session narration)
- Clear, readable, engaging
- No bullet points
- No technical/system language
- No invented explanations
- Keep cause → effect relationships

FINAL SECTION:

Add:

Onde As Coisas Pararam:
- Current situation
- Immediate next step
- Active risks or unresolved elements

Summaries:
{combined_summaries}
"""