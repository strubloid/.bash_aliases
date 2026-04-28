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

# Split transcription into chunks so the full video is processed
def ask(messages):
    response = client.chat.completions.create(
        messages=messages,
        model="gpt-5.5",
    )
    return response.choices[0].message.content

# Divide into exactly 3 equal parts (or fewer if very short)
num_parts = 3
part_length = len(transcription) // num_parts if len(transcription) >= num_parts else len(transcription)
chunks = [transcription[i*part_length:(i+1)*part_length] for i in range(num_parts)]
# Remove empty chunks (if transcription is short)
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
    summary = ask([{"role": "user", "content": chunk_prompt}])
    chunk_summaries.append(f"[Part {idx}]\n{summary}")

combined_summaries = "\n\n".join(chunk_summaries)

print("Generating final narrative recap...")

question = f"""The following are sequential summaries covering the full content of a tabletop RPG session video, broken into {total_chunks} parts.

IMPORTANT: Your entire response must be written in {language_name}. Do not respond in English unless the transcription is in English.

Your task is to create a human-friendly, story-like recap similar to a "Previously on..." segment from a TV series or anime.

Requirements:

1. NARRATIVE RECAP (MAIN OUTPUT)
- Write a chronological, flowing story covering ALL parts from beginning to end.
- Break it into short paragraphs (like scenes or moments).
- Use natural storytelling language, not bullet points.
- Do NOT skip any part — all {total_chunks} parts must be reflected in the story.

2. IMPORTANT MOMENTS (EMBEDDED IN STORY)
While writing the recap, clearly include:
- Key player decisions (especially moral choices, like sparing or killing)
- Combat encounters (include monster/enemy names when possible)
- Major successes, failures, or unexpected outcomes
- Important dialogue or interactions (summarized)
- Any tension, funny moments, or dramatic turns

3. NAMING & CLARITY
- Identify and name important characters, NPCs, locations, and enemies.
- If names are unclear, infer carefully but do not invent major facts.

4. ENDING SUMMARY (SHORT)
At the end, add a brief "Where things left off" section:
- Current situation
- Immediate next objective or likely direction

5. STYLE GUIDELINES
- Write like a narrator telling the story to players before the next session
- Keep it engaging but concise
- Avoid rigid structure or technical formatting
- Do NOT output bullet points except for the final short section
- Respond entirely in {language_name}

Session summaries:
{combined_summaries}
"""

ai_response = ask([{"role": "user", "content": question}])
print(ai_response)

output_file = "summary.txt"
with open(output_file, "w", encoding="utf-8") as f:
    f.write(ai_response)
print(f"\nSummary saved to {output_file}")
