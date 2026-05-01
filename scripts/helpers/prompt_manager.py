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
You are converting rough RPG transcript notes into a clean session recap.

MAIN GOAL:
Create a factual recap of what happened in the session, in chronological order, for players to hear before the next session.

DO NOT:
- Do not invent events, names, motives, places, or outcomes.
- Do not guess corrupted names or unclear phrases.
- Do not include dice rolls, levels, rules, damage numbers, checks, abilities, or table jokes unless they directly changed the story.
- Do not list every small action.
- Do not repeat the same fact more than once.
- Do not use vague filler like “situação”, “problema”, “dilema”, or “coisas aconteceram”.
- Do not keep corrupted transcription phrases such as unclear names, broken sentences, or impossible actions.

NAME HANDLING:
- Preserve names exactly when they are clear.
- If a name appears in multiple forms, use the most consistent version from the session context.
- If uncertain, avoid the name and write “o grupo”, “um personagem”, or omit the detail.
- Never create new names.

CONTENT TO KEEP:
- Main events in chronological order.
- Important discoveries and clues.
- Important NPC interactions.
- Important group decisions.
- Moral choices and their outcomes.
- Combat only as threat → key action → result.
- Important items found, lost, recovered, or used.
- The final state of the group.

CONTENT TO REMOVE:
- Repeated facts.
- Table talk.
- Jokes.
- Mechanical details.
- Dice rolls.
- Damage numbers.
- Level requirements.
- Minor movement details.
- Unclear transcription noise.
- Overly specific micro-actions that do not affect the story.

PROCESS:
1. First, identify the clean timeline.
2. Merge repeated facts.
3. Correct obvious duplicate references without inventing.
4. Remove uncertain or corrupted details.
5. Write the recap in four parts.
6. Keep each part focused on one stage of the session.

OUTPUT FORMAT (JSON ONLY):
{{
    "facts": [
        "WHO did WHAT",
        "WHO did WHAT",
        "..."
    ]
}}

TEXT:
{chunk}
"""

    @staticmethod
    def get_final_prompt(merged_json, language_name):
        return f"""
You are converting structured RPG session facts into a clean final recap.

MAIN GOAL:
Create a clear, factual, chronological recap of what happened in the session, for players to hear before the next session.

ABSOLUTE RULES:
- Use ONLY the provided facts, they are sequential, please respect that.
- Do NOT invent events, names, motives, places, items, causes, risks, or outcomes, just read all the text and give real things from it.
- Do NOT guess corrupted names or unclear phrases, try to understand them to use as data for all the facts.
- Do NOT add explanations that are not explicitly present in the facts.
- Do NOT change who did what, just use the named provided, understand the context.
- Do NOT change who gave, found, used, stole, recovered, or received an item.
- Do NOT turn uncertain information into certainty.
- Do NOT include rules, dice, levels, damage numbers, checks, or mechanical terms.
- Do NOT include table jokes, side comments, or player chatter.
- Do NOT repeat the same fact, even if it appears multiple times in the data, but if multiple things happens to be at the same time, it is a part of the RPG game, understand this is how people play RPG.

NAME HANDLING:
- Preserve names when they are called 
- Never create a new name.
- Never modify names to make them sound better.

FACT CLEANUP BEFORE WRITING:
1. Build a clean chronological timeline from the facts.
2. Remove duplicated facts.
3. Merge small related actions into larger story beats.
4. Preserve important cause → effect links.
5. Keep only facts that affect the story.
6. Check that each sentence clearly states who acted and what changed.

CONTENT TO KEEP:
- Main events in chronological order.
- Important clues and discoveries.
- Important NPC interactions.
- Important group decisions.
- Moral choices and their outcomes.
- Combat only as threat → key development → result.
- Important items found, stolen, recovered, used, or discussed.
- The final state of the group.

CONTENT TO REMOVE:
- Repeated descriptions.
- Small movement details.
- Unclear transcription noise.
- Rules and mechanics.
- Dice rolls, damage, levels, checks, and ability names.
- Long lists of minor actions.
- Speculative explanations.
- Generic filler.

COMPRESSION RULE:
Do not list every action. Convert related facts into concise story beats.

Example:
Instead of listing every person arriving separately at a fire, write:
“O grupo ajudou guardas e civis a controlar o incêndio com magia e baldes de água.”

ITEM RULE:
When an item changes hands, be exact.
If the facts say Carman had the sword and returned it to the group, write that.
Do not say the group returned it, sold it, lost it, or gave it away unless explicitly stated.

MORAL DECISION RULE:
When a moral choice happens, include:
- What the dilemma was.
- What the group chose.
- The outcome.
Keep it short, give some data but still factual.

COMBAT RULE:
Summarize combat briefly:
- What enemy appeared.
- What danger it caused.
- How the group overcame it.
- What result or discovery followed.
Do not call a creature “morta-viva” unless the facts explicitly confirm that.

OUTPUT FORMAT:

OUTPUT FORMAT:

[Parte 1]
Cover the first major sequence of the session.

[Parte 2]
Cover the next major sequence of the session.

[Parte 3]
Cover the following major sequence of the session.

[Parte 4]
Cover the final major sequence of the session.

PART STRUCTURE RULES:
- Divide the recap by chronology, not by fixed story type.
- Do not force investigation, combat, travel, dungeon, or moral choices if they are not present.
- Each part should contain the most important events from that section of the session.
- Keep cause → effect clear when supported by the facts.
- If one section has more important events than another, balance the parts naturally.
- The structure must work for any RPG adventure, including social sessions, travel, mystery, combat, downtime, exploration, politics, or dungeon crawling.

STYLE:
- Easy to read out loud.
- Factual but engaging.
- No bullet points inside the four parts.
- 2 to 4 minutes when read.
- Keep each part focused and concise.
- Prefer clarity over completeness.

DATA:
{merged_json}
"""