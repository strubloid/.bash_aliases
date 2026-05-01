import re
import os

## This class is responsible for detecting the language of the transcription based on the 
# filename of the VTT file. 
# It uses a regular expression to look for patterns like ".en.vtt" or ".pt-BR.vtt"
# and maps them to full language names using a predefined dictionary. 
# If no pattern is found, it defaults to Portuguese.
class LanguageDetector:
    """Detects language from filename and maps to full names."""
    
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

    ## This method detects the language based on the filename pattern. It looks for a pattern 
    # like ".en.vtt" or ".pt-BR.vtt" and maps it to a full language name. 
    # If no pattern is found, it defaults to Portuguese.
    @staticmethod
    def detect(vtt_file_path):
        languageToReturn = "Portuguese" 
        filename = os.path.basename(vtt_file_path)
        lang_match = re.search(r"\.([a-z]{2}(?:-[A-Z]{2})?)\.vtt$", filename)
        detected_lang = lang_match.group(1) if lang_match else None
        
        if not detected_lang:
            languageToReturn = LanguageDetector.LANG_NAMES.get(detected_lang, LanguageDetector.LANG_NAMES["pt"])
            print(f"[Detected language]: {languageToReturn}")
            return languageToReturn
        
        languageToReturn = LanguageDetector.LANG_NAMES.get(detected_lang, detected_lang)
        print(f"[Detected language]: {languageToReturn}")
        return languageToReturn