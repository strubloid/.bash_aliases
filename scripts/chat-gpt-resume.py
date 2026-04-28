
import os
import sys
import re
import json
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
)

if len(sys.argv) < 2:
    print("Usage: chat-gpt-resume.py <path-to-vtt-file> [canonical-names.json]")
    sys.exit(1)

vtt_file = sys.argv[1]
canonical_names_file = sys.argv[2] if len(sys.argv) > 2 else None

if not os.path.isfile(vtt_file):
    print(f"Error: file not found: {vtt_file}")
    sys.exit(1)

# Load canonical names if provided
CANONICAL_NAMES = []
if canonical_names_file:
    if not os.path.isfile(canonical_names_file):
        print(f"Error: canonical names file not found: {canonical_names_file}")
        sys.exit(1)
    with open(canonical_names_file, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
            if isinstance(data, list):
                CANONICAL_NAMES = data
            elif isinstance(data, dict) and "names" in data:
                CANONICAL_NAMES = data["names"]
            else:
                print("Error: canonical names file must be a list or a dict with a 'names' key.")
                sys.exit(1)
        except Exception as e:
            print(f"Error parsing canonical names file: {e}")
            sys.exit(1)

# Detect language from the vtt filename (e.g. "video.pt.vtt" -> "pt", "video.en.vtt" -> "en")
lang_match = re.search(r"\.([a-z]{2}(?:-[A-Z]{2})?)\.vtt$", os.path.basename(vtt_file))
detected_lang = lang_match.group(1) if lang_match else None



# Map language codes to full language names for the prompt
LANG_NAMES = {
    "pt": "Portuguese",
    "pt-BR": "Brazilian Portuguese",
    "en": "English",
    "es": "Spanish",
    "fr": "French",
    "de": "German",
    "it": "Italian",
    "ja": "Japanese",
}
language_name = LANG_NAMES.get(detected_lang, detected_lang if detected_lang else "the same language as the transcription")

# Parse the .vtt file — strip header, timestamps and tags, keep only spoken text
with open(vtt_file, "r", encoding="utf-8") as f:
    raw = f.read()

lines = raw.splitlines()
text_lines = []
for line in lines:
    # Skip WEBVTT header, NOTE blocks, blank lines, and timestamp lines
    if line.startswith("WEBVTT") or line.startswith("NOTE") or line.strip() == "":
        continue
    if re.match(r"^\d{2}:\d{2}[\d:.]+\s*-->\s*", line):
        continue
    # Strip inline tags like <00:00:00.000><c> etc.
    cleaned = re.sub(r"<[^>]+>", "", line).strip()
    if cleaned:
        text_lines.append(cleaned)
deduped = []
for line in text_lines:
    if not deduped or line != deduped[-1]:
        deduped.append(line)

transcription = " ".join(deduped)

if not transcription:
    print("Error: no transcription text found in the vtt file.")
    sys.exit(1)



# Use fewer, larger chunks, no overlap
def ask(messages, model="gpt-3.5-turbo"):
    response = client.chat.completions.create(
        messages=messages,
        model=model,
    )
    return response.choices[0].message.content

num_parts = 4
part_length = len(transcription) // num_parts if len(transcription) >= num_parts else len(transcription)
chunks = [transcription[i*part_length:(i+1)*part_length] for i in range(num_parts)]
chunks = [c for c in chunks if c.strip()]
total_chunks = len(chunks)

print(f"Processing {total_chunks} chunk(s) from the transcription...")

chunk_summaries = []
for idx, chunk in enumerate(chunks, start=1):
    print(f"  Summarizing chunk {idx}/{total_chunks}...")
    chunk_prompt = f"""
WARNING: You must not add, invent, expand, synthesize, rename, or generalize any event, name, item, or action. Only use what is explicitly present in the input. If you are unsure, leave it out or say it is unclear.

IMPORTANT: Write in {language_name}.

{f'The valid main character and entity names are: {", ".join(CANONICAL_NAMES)}. You must use only these exact names. Never alter, abbreviate, or invent names. If a name is unclear, leave it out or mark as unclear.' if CANONICAL_NAMES else ''}

Your goal is NOT to write a story or enhance the narrative. Only compress and reorder for clarity, and preserve exact facts.

From this segment, identify and describe clearly:

1. EVENTS (chronological)
- What happens step by step, with all investigative and mechanical details (e.g., break-ins, clues, rival parties, item assignments, combat mechanics, relationships, time pressure/dungeon timer, and all party members present unless absent in the transcript).

2. CHARACTERS & ENTITIES
- Player characters (use only canonical names if provided, all present unless transcript says otherwise)
- NPCs
- Enemies/monsters
- Locations

3. DECISIONS
- Important player choices
- Moral dilemmas (e.g., spare vs kill, emotional pressure, lies, promises, family, honor, legacy)
- Item or artifact ownership: State clearly who receives any important item if present

4. COMBAT & ENCOUNTERS
- Who fights whom
- Outcomes (win/loss/escape/etc.)
- Mechanics (leeching, attachment, weaknesses, critical contributions, special items, shields, life drain, attachment, identifying weaknesses)

5. IMPORTANT MOMENTS
- Dramatic, funny, or tense situations
- Unexpected outcomes or failures
- Key clues, relationships, and lore (e.g., impersonation, body-switching, mercy kills, blessings, time pressure system, rival party, all clues and relationships)
- Dungeon time pressure mechanic if present

6. CONTEXT FOR CONTINUITY
- Anything that connects to previous or future events

Rules:
- Be thorough, do not skip events, clues, or high-impact moments
- Keep chronological order and cause-effect chains
- Do NOT invent, expand, synthesize, rename, generalize, or enhance information
- Do NOT write a story — keep it structured and factual
- Do NOT interpret, dramatize, or add meaning. Only state what is explicitly present in the transcription.
- Always attribute actions to specific characters when possible. Do not use vague group references.
- Keep language neutral and factual unless the transcript itself is dramatic or emotional.
- If the cause or nature of an event is uncertain or ambiguous in the transcript, preserve that uncertainty. Use phrases like 'it is unclear', 'possibly', 'raising the hypothesis', or 'the group speculated'. Never turn speculation or ambiguity into a definitive statement.
- Absolutely do NOT add any lore, names, or details that are not explicitly present in the transcript. If a detail is not present, do not mention it at all.
- Do NOT expand on minor events, side activities, or interactions unless they are described in detail in the input. Do not add new scenes, actions, or dialogue.
- Do NOT synthesize, combine, or infer connections between events unless they are explicitly stated.
- If you are unsure of a name, leave it blank or say 'unclear'. Never guess or invent a name. Never abbreviate or alter names.
- Do NOT add any lore, magic, or world details unless they are explicitly present in the input.
- Use plain, neutral language. Do not use dramatic, poetic, or stylized adjectives unless they are directly quoted from the transcript. Describe events and characters factually, without embellishment.
- Do NOT omit any key clues, mechanics, relationships, or high-impact narrative beats that are present in the input.
- Use "pergaminho" instead of "scroll" for consistency.
- If a statue animates, clarify it is the statue itself, not a separate golem.

Transcription segment:
{chunk}
"""
    summary = ask([{"role": "user", "content": chunk_prompt}], model="gpt-3.5-turbo")
    chunk_summaries.append(f"[Parte {idx}]\n{summary}")

combined_summaries = "\n\n".join(chunk_summaries)

print("Generating final narrative recap...")


character_names_clause = f"The valid main character and entity names are: {', '.join(CANONICAL_NAMES)}. You must use only these exact names. Never alter, abbreviate, or invent names. If a name is unclear, leave it out or mark as unclear." if CANONICAL_NAMES else ""

question = f"""
WARNING: You must not add, invent, expand, synthesize, rename, or generalize any event, name, item, or action. Only use what is explicitly present in the input. If you are unsure, leave it out or say it is unclear.

You are an expert RPG session chronicler. Your task is to assemble the following chunk summaries into a single, strictly factual recap.

{character_names_clause}

IMPORTANT: Write in {language_name}.

Your recap must:
- Cover ALL events and details from the summaries, in chronological order
- Include all key investigative and mechanical details (e.g., break-ins, clues, rival parties, item assignments, combat mechanics, relationships, time pressure/dungeon timer)
- Include all key player decisions, especially moral dilemmas, emotional pressure, lies, promises, and any important item/artifact ownership outcomes
- Describe all combat encounters (with monster/enemy names and outcomes, mechanics, weaknesses, and critical contributions: shields, life drain, attachment, identifying weaknesses, special items)
- Name all important characters, NPCs, monsters, and locations exactly as in the summaries{f' (use only canonical names: {', '.join(CANONICAL_NAMES)})' if CANONICAL_NAMES else ''}
- Clarify any impersonation, servant/master, or mercy kill relationships if present
- Include important dialogue, dramatic, tense, or funny moments, including family, moral arguments, and any pressure or deception tactics
- Mention major successes, failures, and unexpected outcomes
- Clearly show the consequences of actions and decisions
- Add any blessings or time pressure mechanics if present
- Write as a structured, factual recap (not a story, not a novel, not bullet points)
- Break into short paragraphs for each scene or moment
- Divide the recap into labeled sections: [Parte 1], [Parte 2], etc., one for each chunk
- For each part, write a focused, readable narrative paragraph or two, covering the main events, discoveries, and decisions from that chunk
- Use all details from the summaries
- Maintain continuity between parts, but do NOT merge, compress, or synthesize information across parts
- Do NOT invent, reinterpret, dramatize, add, expand, enhance, generalize, or embellish any facts, dialogue, or events that are not present in the summaries
- Do NOT interpret or add meaning. Only use what is explicitly present in the summaries.
- Always attribute actions to specific characters when possible. Do not use vague group references.
- Keep language neutral and factual unless the summaries themselves are dramatic or emotional.
- If the cause or nature of an event is uncertain or ambiguous in the summaries, preserve that uncertainty. Use phrases like 'it is unclear', 'possibly', 'raising the hypothesis', or 'the group speculated'. Never turn speculation or ambiguity into a definitive statement.
- Absolutely do NOT add any lore, names, or details that are not explicitly present in the summaries. If a detail is not present, do not mention it at all.
- Do NOT expand on minor events, side activities, or interactions unless they are described in detail in the input. Do not add new scenes, actions, or dialogue.
- Do NOT synthesize, combine, or infer connections between events unless they are explicitly stated.
- If you are unsure of a name, leave it blank or say 'unclear'. Never guess or invent a name. Never abbreviate or alter names.
- Do NOT add any lore, magic, or world details unless they are explicitly present in the input.
- Use plain, neutral language. Do not use dramatic, poetic, or stylized adjectives unless they are directly quoted from the summaries. Describe events and characters factually, without embellishment.
- Do NOT omit any key clues, mechanics, or relationships that are present in the input.
- If something is unclear or missing, leave it out or say it is unclear
- At the end, add a section labeled 'Onde As Coisas Pararam' summarizing the current situation and next objective
- Use "pergaminho" instead of "scroll" for consistency.
- If a statue animates, clarify it is the statue itself, not a separate golem.
- Remove any mention of selling items or following a rival plan if not present in the summaries.

Session summaries:
{combined_summaries}
"""

ai_response = ask([{"role": "user", "content": question}], model="gpt-4-turbo")

output_file = "summary.txt"
with open(output_file, "w", encoding="utf-8") as f:
    f.write(ai_response)
print(f"\nSummary saved to {output_file}")
