class PromptManager:
    @staticmethod
    def get_chunk_prompt(chunk, language_name, previous_chunk=""):
        previous_context = ""
        if previous_chunk:
            previous_context = f"""
PREVIOUS CONTEXT:
Use this only to maintain continuity of names, places, items, unresolved events, and cause-effect.
Do NOT repeat previous events unless the current chunk directly continues them.
Do NOT use previous context to invent details missing from the current chunk.
If a name was stable in previous context and appears slightly corrupted here, use the stable name and record the corrupted form in "uncertain_names".
If the current chunk contradicts previous context, keep the current chunk factual and place the contradiction in "uncertain_facts".

{previous_chunk}
"""

        return f"""
You are extracting structured factual story data from one chunk of an RPG session transcript.

IMPORTANT:
- Write in {language_name}.
- Output JSON only.
- This is NOT the final recap.
- Do NOT write prose recap here.
- Your job is to preserve accurate story data so a later step can write a strong recap.
- Prefer keeping useful story data over compressing too much.

{previous_context}

MAIN GOAL:
Extract all story-relevant information from this chunk in chronological order, with enough detail for a final recap to be written without guessing.

ABSOLUTE RULES:
- Do NOT invent events, names, motives, places, items, causes, risks, or outcomes.
- Do NOT guess corrupted names or unclear phrases.
- Do NOT reinterpret events.
- Do NOT change who did what.
- Do NOT change who gave, found, stole, used, recovered, lost, or received an item.
- Do NOT turn uncertainty into fact.
- Do NOT state guilt, motive, or identity as fact unless clearly supported.
- Do NOT include dice rolls, levels, damage numbers, checks, rules, ability names, or table jokes unless they directly changed the story.
- Do NOT repeat the same fact more than once.
- Do NOT compress aggressively.
- Do NOT output a recap.
- Do NOT mix languages. Write all extracted content in {language_name}.

NAME HANDLING:
- Preserve names only when they are clear.
- Do NOT place clear repeated character names in "uncertain_names".
- Only place names in "uncertain_names" when the spelling is genuinely unstable, corrupted, or unclear.
- If a name appears in multiple forms, use the clearest version supported by the current chunk and previous context.
- If a name is uncertain, use a neutral phrase such as "o grupo", "um personagem", "o NPC", "o inimigo", "o ferreiro", "a criatura", or omit the name.
- Never create new names.
- Never modify names just to make them sound better.
- If a place/item/person is central and repeatedly referenced, keep it as an entity unless its name is truly unreadable.

FACT EXTRACTION RULES:
- Each timeline event must be a complete factual sentence.
- Each timeline event should include WHO did WHAT whenever possible.
- Keep events atomic enough to preserve meaning, but not so tiny that they become noise.
- Preserve cause → effect when explicit.
- Preserve exact outcomes of decisions.
- Preserve important emotional, social, or moral stakes when they affect a decision.
- Preserve important clues separately from actions.
- Preserve important item changes separately from general events.
- Preserve important NPC conversations as interaction records.
- Preserve combat as threat → key developments → outcome.
- Preserve important locations and what changed there.
- Preserve transitions between locations when they explain how the group reached the next important scene.
- Preserve the end state of the chunk.
- Include enough detail so the final recap does not need to guess.

CONTENT TO KEEP:
- Main events in chronological order.
- Important discoveries and clues.
- Important NPC interactions.
- Important group decisions.
- Moral choices and their outcomes.
- Combat threats, turning points, and results.
- Important items found, stolen, recovered, used, examined, changed, given, received, lost, or discussed.
- Important locations reached, revealed, searched, or left.
- Important factions, enemies, NPCs, creatures, witnesses, suspects, or rivals.
- Unresolved questions or threads that continue later.
- The state of the group at the end of this chunk.

CONTENT TO REMOVE:
- Repeated facts.
- Table talk.
- Jokes.
- Rules and mechanics.
- Dice rolls.
- Damage numbers.
- Level requirements.
- Minor movement details.
- Broken transcription noise.
- Unclear phrases that cannot be trusted.
- Micro-actions that do not affect the story.
- Speculative moral commentary not directly stated in the transcript.

OUTPUT FORMAT JSON ONLY:
{{
    "timeline_events": [
        {{
            "order": 1,
            "fact": "Specific chronological event.",
            "who": "Character, group, NPC, or UNKNOWN.",
            "what_changed": "What changed because of this event.",
            "importance": "high|medium|low"
        }}
    ],
    "scene_transitions": [
        {{
            "from": "Previous important place or situation.",
            "to": "Next important place or situation.",
            "reason": "Why the group moved or changed focus, if explicit.",
            "result": "What this transition led to."
        }}
    ],
    "clues_and_discoveries": [
        {{
            "clue": "Specific clue or discovery.",
            "source": "Who or what revealed it, if known.",
            "meaning": "What this clue suggests, only if explicit; otherwise UNKNOWN.",
            "importance": "high|medium|low"
        }}
    ],
    "decisions": [
        {{
            "decision": "Decision made by the group or character.",
            "who_decided": "Who made the decision, if clear.",
            "reason": "Reason if explicitly stated, otherwise UNKNOWN.",
            "outcome": "Immediate result of the decision, if known.",
            "importance": "high|medium|low"
        }}
    ],
    "npc_interactions": [
        {{
            "npc": "NPC name or neutral label.",
            "interaction": "What was discussed or done.",
            "information_given": "Important information revealed, if any.",
            "result": "What changed because of this interaction.",
            "importance": "high|medium|low"
        }}
    ],
    "combat_or_threats": [
        {{
            "enemy_or_threat": "Enemy, creature, hazard, or threat.",
            "type": "combat|hazard|social_threat|environmental_threat|unknown",
            "trigger": "What started the conflict or danger, if known.",
            "what_happened": "Important developments only.",
            "danger_caused": "Who or what was threatened, injured, trapped, or affected.",
            "outcome": "How it ended.",
            "items_or_clues_after": "Items, clues, or consequences discovered after it, if any."
        }}
    ],
    "items": [
        {{
            "item": "Item name or description.",
            "action": "found|lost|stolen|recovered|used|examined|given|received|discussed|changed|unknown",
            "holder_before": "Who had it before, if known; otherwise UNKNOWN.",
            "holder_after": "Who had it after, if known; otherwise UNKNOWN.",
            "details": "Exact factual details about the item.",
            "importance": "high|medium|low"
        }}
    ],
    "locations": [
        {{
            "location": "Location name or description.",
            "what_happened_there": "Important events that happened there.",
            "new_path_or_access": "Any new path, entrance, exit, route, or access discovered; otherwise UNKNOWN."
        }}
    ],
    "entities": [
        {{
            "name": "Clear character, NPC, faction, creature, place, or item name.",
            "type": "player_character|npc|faction|creature|place|item|unknown",
            "notes": "Short factual note about this entity from this chunk."
        }}
    ],
    "suspicions_or_theories": [
        {{
            "subject": "Person, faction, item, place, or event suspected.",
            "theory": "What the group suspects or believes.",
            "evidence": "What supports this suspicion, if explicit.",
            "certainty": "confirmed|suspected|uncertain"
        }}
    ],
    "moral_or_social_stakes": [
        {{
            "situation": "Moral, emotional, political, or social issue.",
            "choice": "What the group chose, if any.",
            "outcome": "What happened because of the choice."
        }}
    ],
    "uncertain_names": [
        "Only names that are genuinely corrupted, inconsistent, or unclear."
    ],
    "uncertain_facts": [
        "Important but unclear facts that should not be trusted yet."
    ],
    "unresolved_threads": [
        "Open questions, unfinished goals, active suspicions, future hooks, or unresolved dangers from this chunk."
    ],
    "chunk_state": {{
        "current_location": "Where the group is at the end of this chunk, if known.",
        "current_goal": "What the group is trying to do next, if known.",
        "active_risks": ["Known active risks, only if explicitly present."],
        "summary": "Short factual description of where things stand at the end of this chunk."
    }}
}}

TEXT:
{chunk}
"""

    @staticmethod
    def get_final_prompt(merged_json, language_name, num_parts=4):
        part_headers = "\n".join(
            [
                f"[Parte {part_number}]\nCover the next major chronological sequence of the session.\n"
                for part_number in range(1, num_parts + 1)
            ]
        )

        return f"""
You are converting structured RPG session data into a clean final recap.

IMPORTANT:
- Write in {language_name}.
- Use only the provided structured data.
- The data is sequential. Respect its order.
- The goal is a player-facing recap, not a data dump.

MAIN GOAL:
Create a clear, factual, chronological recap of what happened in the session, for players to hear before the next session.

ABSOLUTE RULES:
- Do NOT invent events, names, motives, places, items, causes, risks, or outcomes.
- Do NOT guess corrupted names or unclear phrases.
- Do NOT add explanations that are not explicitly present in the data.
- Do NOT change who did what.
- Do NOT change who gave, found, stole, used, recovered, lost, or received an item.
- Do NOT turn uncertain information into certainty.
- Do NOT include rules, dice, levels, damage numbers, checks, ability names, or mechanical terms.
- Do NOT include table jokes, side comments, or player chatter.
- Do NOT repeat the same fact, even if it appears multiple times.
- If a fact is unclear or contradicted, omit it unless it is essential.
- Do NOT call something confirmed if the data only says it was suspected.

NAME HANDLING:
- Preserve names only when they are clear and stable.
- If a name appears in multiple forms, use the clearest and most consistent version from the data.
- If uncertain, use a neutral phrase such as "o grupo", "um personagem", "o NPC", "o inimigo", "o comerciante", "o ferreiro", or "a criatura".
- Never create a new name.
- Never modify names just to make them sound better.
- Never merge two characters unless the data clearly shows they are the same person.
- Ignore "uncertain_names" entries if the same name is clearly stable elsewhere in the data.

FACT CLEANUP BEFORE WRITING:
1. Build a clean chronological timeline from "timeline_events".
2. Use "scene_transitions" to connect the major sequences naturally.
3. Add important context from "clues_and_discoveries", "decisions", "npc_interactions", "items", "locations", "combat_or_threats", "suspicions_or_theories", "moral_or_social_stakes", and "unresolved_threads".
4. Remove duplicated facts.
5. Remove corrupted or uncertain facts that are not essential.
6. Merge small related actions into larger story beats.
7. Preserve important cause → effect links.
8. Keep facts that affect the session story.
9. Make sure each sentence clearly states who acted and what changed.
10. Keep item ownership and item transfer exact.
11. Keep suspicions separate from confirmed facts.
12. Do not include a final “Onde As Coisas Pararam” section.

CONTENT TO KEEP:
- Main events in chronological order.
- Important clues and discoveries.
- Important NPC interactions.
- Important group decisions.
- Moral, emotional, social, or political choices and their outcomes.
- Combat or threats only as threat → key development → result.
- Important items found, stolen, recovered, used, examined, changed, given, received, lost, or discussed.
- Important locations reached, revealed, searched, or left.
- Important suspects, witnesses, factions, enemies, NPCs, creatures, or unresolved threads.

CONTENT TO REMOVE:
- Repeated descriptions.
- Small movement details.
- Unclear transcription noise.
- Rules and mechanics.
- Dice rolls, damage, levels, checks, and ability names.
- Long lists of minor actions.
- Speculative explanations.
- Generic filler.
- Any “current state” section unless explicitly requested.

COMPRESSION RULE:
Do not list every action. Convert related facts into concise story beats, but do not remove important cause-effect information.

Example:
Instead of listing every person arriving separately at a fire, write:
"O grupo ajudou guardas e civis a controlar o incêndio com magia e baldes de água."

ACCURACY RULES:
- When a cause is uncertain, keep it broad.
- Separate clues clearly instead of merging them into a false cause.
- Do not state guilt, motive, or identity as fact unless clearly supported.
- If the data says the group considered someone a suspect, do not state that person was guilty.
- If the data says someone had an item and handed it to the group, write that exactly.
- Do not say the group returned, sold, lost, or gave away an item unless explicitly stated.
- If a location, person, or item name is unstable, use a neutral description.

MORAL DECISION RULE:
When a moral choice happens, include:
- What the dilemma was.
- What the group chose.
- The outcome.
Keep it short and factual.

COMBAT OR THREAT RULE:
Summarize threats briefly:
- What enemy, hazard, or danger appeared.
- What danger it caused.
- How the group overcame it.
- What result or discovery followed.
Do not call a creature something specific unless the data explicitly confirms it.

PART STRUCTURE RULES:
- Divide the recap by chronology, not by fixed story type.
- Do not force investigation, combat, travel, dungeon, social scenes, or moral choices if they are not present.
- Each part should cover the next major sequence of the session.
- Keep cause → effect clear when supported by the data.
- If one section has more important events than another, balance the parts naturally.
- The structure must work for any RPG adventure, including social sessions, travel, mystery, combat, downtime, exploration, politics, or dungeon crawling.

OUTPUT FORMAT:

{part_headers}

STYLE:
- Easy to read out loud.
- Factual but natural.
- No bullet points inside the parts.
- 2 to 4 minutes when read.
- Keep each part focused and concise.
- Prefer clarity over completeness.

DATA:
{merged_json}
"""