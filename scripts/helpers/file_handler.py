import os
import sys
import json

class FileHandler:
    
    # This method saves the summary of each chunk to a specified output directory with a 
    # filename that includes the chunk index.
    @staticmethod
    def save_summary(summary, output_dir, chunk_idx):
        os.makedirs(output_dir, exist_ok=True)
        summary_filename = os.path.join(output_dir, f"chunk_{chunk_idx}_summary.txt")
        with open(summary_filename, "w", encoding="utf-8") as sf:
            sf.write(summary)
        print(f"  => [Saved Chunk {chunk_idx}]")
    
    # This method saves the final narrative recap to a specified output directory with a 
    # given filename.
    @staticmethod
    def save_final_recap(recap, output_dir, filename="final_recap.txt"):
        os.makedirs(output_dir, exist_ok=True)
        recap_filename = os.path.join(output_dir, filename)
        with open(recap_filename, "w", encoding="utf-8") as rf:
            rf.write(recap)
        print(f"  => [Saved Final Recap]")