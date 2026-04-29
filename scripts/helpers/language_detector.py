import re
import os

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

    @staticmethod
    def detect(vtt_file_path):
        filename = os.path.basename(vtt_file_path)
        lang_match = re.search(r"\.([a-z]{2}(?:-[A-Z]{2})?)\.vtt$", filename)
        detected_lang = lang_match.group(1) if lang_match else None
        
        if not detected_lang:
            return "the same language as the transcription"
            
        return LanguageDetector.LANG_NAMES.get(detected_lang, detected_lang)