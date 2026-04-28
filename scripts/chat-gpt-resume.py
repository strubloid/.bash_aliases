
import os
import sys
import re
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
)

if len(sys.argv) < 2:
    print("Usage: chat-gpt-resume.py <path-to-vtt-file>")
    sys.exit(1)

vtt_file = sys.argv[1]

if not os.path.isfile(vtt_file):
    print(f"Error: file not found: {vtt_file}")
    sys.exit(1)

# Detect language from the vtt filename (e.g. "video.pt.vtt" -> "pt", "video.en.vtt" -> "en")
lang_match = re.search(r"\.([a-z]{2}(?:-[A-Z]{2})?)\.vtt$", os.path.basename(vtt_file))
detected_lang = lang_match.group(1) if lang_match else None

## Names of the characters in the RPG session
CHARACTER_NAMES = ["Phendrachion", "Elandor", "Baskkol", "Root", "Baltazar"]

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

# Deduplicate consecutive identical lines (common in auto-subs)
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
You are processing part {idx} of {total_chunks} of an auto-generated transcription from a tabletop RPG session.

IMPORTANT: Write in {language_name}.

Your goal is NOT to simply summarize. Instead, extract structured story information that will later be used to build a full narrative recap.

From this segment, identify and describe clearly:

1. EVENTS (chronological)
- What happens step by step

2. CHARACTERS & ENTITIES
- Player characters
- NPCs
- Enemies/monsters
- Locations

3. DECISIONS
- Important player choices
- Moral decisions (e.g., spare vs kill)

4. COMBAT & ENCOUNTERS
- Who fights whom
- Outcomes (win/loss/escape/etc.)

5. IMPORTANT MOMENTS
- Dramatic, funny, or tense situations
- Unexpected outcomes or failures

6. CONTEXT FOR CONTINUITY
- Anything that connects to previous or future events

Rules:
- Be thorough, do not skip events
- Keep chronological order
- Do NOT invent information
- Do NOT write a story — keep it structured and factual

Transcription segment:
{chunk}
"""
    # Use gpt-3.5-turbo for chunk summaries to save tokens
    summary = ask([{"role": "user", "content": chunk_prompt}], model="gpt-3.5-turbo")
    chunk_summaries.append(f"[Part {idx}]\n{summary}")

combined_summaries = "\n\n".join(chunk_summaries)

print("Generating final narrative recap...")

# Compact, bullet-pointed prompt with restored key instructions
character_names_clause = f"The valid main character names are: {', '.join(CHARACTER_NAMES)}. Always use these exact names in the recap."

question = f"""The following are summaries of a tabletop RPG session, divided into {total_chunks} parts.

{character_names_clause}

IMPORTANT: Write in {language_name}. Do not skip any event or detail, even minor ones. Do not invent facts.

Your recap must:
- Cover ALL events and details from the summaries, in chronological order
- Include all key player decisions, especially moral choices
- Describe all combat encounters (with monster/enemy names and outcomes)
- Name all important characters, NPCs, monsters, and locations
- Include important dialogue, dramatic, tense, or funny moments
- Mention major successes, failures, and unexpected outcomes
- Clearly show the consequences of actions and decisions
- Write as a flowing, story-like narrative (not bullet points)
- Break into short paragraphs for each scene or moment
- At the end, add a short section: 'Where things left off' (current situation and next objective)

Session summaries:
{combined_summaries}
"""


# Get AI response using gpt-4-turbo for the final recap
ai_response = ask([{"role": "user", "content": question}], model="gpt-4-turbo")

output_file = "summary.txt"
with open(output_file, "w", encoding="utf-8") as f:
    f.write(ai_response)
print(f"\nSummary saved to {output_file}")
