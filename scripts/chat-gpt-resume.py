
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
from helpers.file_handler import FileHandler
from helpers.name_fixes import  fix_names

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("vtt_file")
    parser.add_argument("--from", dest="from_time", type=str, required=True)
    args = parser.parse_args()
    # print(f"Arguments: {args}")
    
    vtt_file = args.vtt_file
    from_time = args.from_time if args.from_time else "00:00"
    print(f"[VTT File]: {vtt_file} \n[From Time]: {from_time}")

    # If you want to keep canonical_names, you can parse them from unknown or elsewhere as needed
    # canonical_names = ["Baltazar", "Elandor", "Root", "Baskkol", "Phendrachion"]

    # 2. Detect Language
    language_name = LanguageDetector.detect(vtt_file)

    try:
        ## we try to trim the transcription from the from_time provided by user
        transcription = VTTProcessor.get_trimmed_transcription(vtt_file, from_time)        
    except Exception as e:
        print(f"Error processing VTT: {e}")
        sys.exit(1)
    

    # 4. Chunk the transcription
    num_parts = 4
    chunks = TextChunker.chunk_text(transcription, num_parts)
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
    previous_chunk = None
    for idx, chunk in enumerate(chunks, start=1):
        
        print(f"  Summarizing chunk {idx}/{total_chunks}...")
        
        ## loading the correct prompt for the chunk summarization
        prompt = PromptManager.get_chunk_prompt(chunk, language_name, previous_chunk)
        
        ## getting the summary from the AI
        summary = openai_service.ask([{"role": "user", "content": prompt}], model="gpt-4o")
        
        ## appending the summary to the list with a header for the chunk
        chunk_summaries.append(f"[Parte {idx}]\n{summary}")

        # Update previous_chunk for the next iteration
        previous_chunk = summary

        # Save each chunk summary to a file
        FileHandler.save_summary(summary, ".", idx)

    # 7. Generate Final Narrative Recap
    print("[Generating]: Final narrative recap...")
    combined_summaries = "\n\n".join(chunk_summaries)
    final_prompt = PromptManager.get_final_prompt(combined_summaries, language_name)
    
    # ai_response = openai_service.ask([{"role": "user", "content": final_prompt}], model="gpt-4-turbo")
    ai_response = openai_service.ask([{"role": "user", "content": final_prompt}], model="gpt-5.4-mini")
    
    ## fixing the names in the final AI response using the fix_names function
    ai_response = fix_names(ai_response)
    
    # 8. Save Output
    output_file = "summary.txt"
    FileHandler.save_final_recap(ai_response, ".", filename=output_file)
    
if __name__ == "__main__":
    main()