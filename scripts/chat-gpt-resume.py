
import sys
import os
import argparse
from helpers.config_loader import ConfigLoader
from helpers.language_detector import LanguageDetector
from helpers.vtt_processor import VTTProcessor
from helpers.text_chunker import TextChunker
from helpers.openai_service import OpenAIService
from helpers.prompt_manager import PromptManager
from helpers.time_extractor import TimeExtractor
from helpers.name_fixes import canonicalize_names

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("vtt_file")
    parser.add_argument("--from", dest="from_time", type=str, required=True)
    args = parser.parse_args()
    ## printing all arguments for debugging
    # print(f"Arguments: {args}")
    vtt_file = args.vtt_file
    from_time = args.from_time
    print(f"[VTT File]: {vtt_file}")
    print(f"[From Time]: {from_time}")

    # If you want to keep canonical_names, you can parse them from unknown or elsewhere as needed
    canonical_names = ["Baltazar", "Elandor", "Root", "Baskkol", "Phendrachion"]
    # canonical_names = []

    # 2. Detect Language
    language_name = LanguageDetector.detect(vtt_file)
    print(f"[Detected language]: {language_name}")

    try:
        transcription = VTTProcessor.get_trimmed_transcription(vtt_file, from_time)        
    except Exception as e:
        print(f"Error processing VTT: {e}")
        sys.exit(1)
    

    # 4. Chunk the transcription
    chunks = TextChunker.chunk_text(transcription, num_parts=4)
    total_chunks = len(chunks)
    print(f"[Processing] [{total_chunks}] chunk(s) from the transcription...")

    # 5. Initialize AI Service
    try:
        openai_service = OpenAIService()
    except Exception as e:
        print(f"Error initializing OpenAI service: {e}")
        sys.exit(1)

    # 6. Summarize each chunk
    chunk_summaries = []
    for idx, chunk in enumerate(chunks, start=1):
        print(f"  Summarizing chunk {idx}/{total_chunks}...")
        prompt = PromptManager.get_chunk_prompt(chunk, language_name, canonical_names)
        
        summary = openai_service.ask([{"role": "user", "content": prompt}],  model="gpt-3.5-turbo")
        # summary = openai_service.ask([{"role": "user", "content": prompt}],  model="gpt-4o")
        chunk_summaries.append(f"[Parte {idx}]\n{summary}")

    # 7. Generate Final Narrative Recap
    print("[Generating]: Final narrative recap...")
    combined_summaries = "\n\n".join(chunk_summaries)
    final_prompt = PromptManager.get_final_prompt(combined_summaries, language_name, canonical_names)

    ## cleaning up names after chunking
    # name_map = {
    #     "Fendrachion": "Phendrachion",
    #     "Fendren": "Phendrachion",
    #     "Oneal": "Phendrachion",
    #     "Dudu": "Elandor",
    #     "Rafael": "Baltazar",
    #     "Igor": "Root",
    #     "Cassio": "Baskkol",
    #     "Basco": "Baskkol",
    #     "Karma": "Carman",
    # }
    # final_prompt = canonicalize_names(final_prompt, name_map)
    
    ai_response = openai_service.ask([{"role": "user", "content": final_prompt}], model="gpt-4-turbo")
    # ai_response = openai_service.ask([{"role": "user", "content": final_prompt}], model="gpt-4o")
    

    # 8. Save Output
    output_file = "summary.txt"
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(ai_response)
    
    print(f"\n[V3]Summary saved to {output_file}")

if __name__ == "__main__":
    main()