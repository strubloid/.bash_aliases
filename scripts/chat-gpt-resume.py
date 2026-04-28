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

# Truncate to avoid token limits (~12000 chars ~ 3000 tokens, leaving room for response)
MAX_CHARS = 12000
if len(transcription) > MAX_CHARS:
    transcription = transcription[:MAX_CHARS] + "..."

question = f"""The following is an auto-generated transcription from a YouTube video of a tabletop RPG session (Pathfinder).

IMPORTANT: Your entire response must be written in {language_name}. Do not respond in English unless the transcription is in English.

Your goal is to generate a structured session recap that helps players quickly understand what happened and prepare for the next session.

Please provide:

1. SESSION SUMMARY
- A concise but clear overview (5-10 sentences max).

2. TIMELINE OF EVENTS
- Chronological bullet points of key events in order.

3. KEY ENCOUNTERS
- Combat, social, or exploration encounters.
- Include enemies, locations, and outcomes.

4. PLAYER DECISIONS & ACTIONS
- Important choices made by players.
- Consequences (immediate or implied).

5. NPCs INTRODUCED OR INTERACTED WITH
- Name + role + relevance.

6. LOOT, REWARDS, OR IMPORTANT ITEMS
- Items gained, used, or discussed.

7. STORY DEVELOPMENTS
- Plot progression, reveals, twists, or new objectives.

8. UNRESOLVED THREADS / CLIFFHANGERS
- Open questions, ongoing quests, mysteries.

9. NEXT SESSION HOOKS
- What is likely to happen next or what players should prepare for.

Important:
- Ignore transcription errors unless critical.
- Infer context when necessary, but do not invent major events.
- Keep it structured and easy to skim.
- Respond entirely in {language_name}.

Transcription:
{transcription}"""

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": question,
        }
    ],
    model="gpt-3.5-turbo",
)

ai_response = response.choices[0].message.content
# print(ai_response)

output_file = "summary.txt"
with open(output_file, "w", encoding="utf-8") as f:
    f.write(ai_response)
print(f"\nSummary saved to {output_file}")
