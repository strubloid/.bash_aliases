import os
import sys
import json

class ConfigLoader:
    """Handles CLI arguments and loading canonical names."""
    def __init__(self, args):
        self.args = args

    def parse_args(self):
        if len(self.args) < 2:
            print("Usage: chat-gpt-resume.py <path-to-vtt-file> [canonical-names.json]")
            sys.exit(1)

        vtt_file = self.args[1]
        canonical_names_file = self.args[2] if len(self.args) > 2 else None

        if not os.path.isfile(vtt_file):
            print(f"Error: file not found: {vtt_file}")
            sys.exit(1)

        canonical_names = []
        if canonical_names_file:
            if not os.path.isfile(canonical_names_file):
                print(f"Error: canonical names file not found: {canonical_names_file}")
                sys.exit(1)
            with open(canonical_names_file, "r", encoding="utf-8") as f:
                try:
                    data = json.load(f)
                    if isinstance(data, list):
                        canonical_names = data
                    elif isinstance(data, dict) and "names" in data:
                        canonical_names = data["names"]
                    else:
                        print("Error: canonical names file must be a list or a dict with a 'names' key.")
                        sys.exit(1)
                except Exception as e:
                    print(f"Error parsing canonical names file: {e}")
                    sys.exit(1)
        
        return vtt_file, canonical_names