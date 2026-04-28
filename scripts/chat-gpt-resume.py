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

question = (
    "The following is an auto-generated transcription from a YouTube video of a tabletop RPG game session. "
    "Please provide:\n"
    "1. A concise summary of what happened in the session.\n"
    "2. Key events, encounters, or decisions made by the players.\n"
    "3. Any notable moments or story developments.\n\n"
    f"Transcription:\n{transcription}"
)

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
print(ai_response)
