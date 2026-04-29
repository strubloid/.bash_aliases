class TextChunker:
    """Splits transcription into manageable chunks."""

    @staticmethod
    def chunk_text(transcription, num_parts=4):
        if not transcription:
            return []
            
        part_length = len(transcription) // num_parts if len(transcription) >= num_parts else len(transcription)
        chunks = [transcription[i*part_length:(i+1)*part_length] for i in range(num_parts)]
        return [c for c in chunks if c.strip()]