import re

class VTTProcessor:
    """Parses and cleans .vtt files."""

    @staticmethod
    def get_trimmed_transcription(vtt_file, from_time):
        """
        Trims the VTT file from the given time (hh:mm:ss or mm:ss), returns the processed transcription.
        """
        import re
        debug = False

        def time_to_seconds(t):
            parts = t.split(":")
            parts = [float(p) for p in parts]
            if len(parts) == 3:
                return parts[0]*3600 + parts[1]*60 + parts[2]
            elif len(parts) == 2:
                return parts[0]*60 + parts[1]
            else:
                return float(parts[0])

        start_sec = time_to_seconds(from_time)
        with open(vtt_file, "r", encoding="utf-8") as f:
            lines = f.readlines()

        output_lines = []
        keep = False
        for line in lines:
            # VTT cue: 00:01:23.456 --> 00:01:25.789 or 01.00.00.000 --> ...
            match = re.match(r"^(\d{2}[:.]\d{2}[:.]\d{2}[.:]\d{3}) -->", line)
            if match:
                cue_start = match.group(1)
                # Robustly split cue_start into h, m, s, ms regardless of separator
                time_match = re.match(r"(\d{2})[:.](\d{2})[:.](\d{2})[.:](\d{3})", cue_start)
                if time_match:
                    h, m, s, ms = time_match.groups()
                    cue_sec = int(h)*3600 + int(m)*60 + int(s) + int(ms)/1000
                    keep = cue_sec >= start_sec
                else:
                    # If parsing fails, skip this cue
                    keep = False
            if keep or line.startswith("WEBVTT") or line.strip() == "":
                output_lines.append(line)

        trimmed_vtt_content = "".join(output_lines)
        if debug:
            print("\nFirst 500 characters of trimmed VTT:")
            print(trimmed_vtt_content[:500])

        return VTTProcessor.process(trimmed_vtt_content)
    
    @staticmethod
    def process(vtt_input):
        debug = False
        """
        Accepts either a file path (str) or raw VTT content (str with newlines).
        If the input is a file path, reads the file. If it's a string with newlines, processes as content.
        """
        if isinstance(vtt_input, str) and ('\n' in vtt_input or '\r' in vtt_input):
            raw = vtt_input
        else:
            with open(vtt_input, "r", encoding="utf-8") as f:
                raw = f.read()

        lines = raw.splitlines()
        text_lines = []
        for line in lines:
            if line.startswith("WEBVTT") or line.startswith("NOTE") or line.strip() == "":
                continue
            if re.match(r"^\d{2}:\d{2}[\d:.]+\s*-->\s*", line):
                continue
            cleaned = re.sub(r"<[^>]+>", "", line).strip()
            if cleaned:
                text_lines.append(cleaned)

        deduped = []
        for line in text_lines:
            if not deduped or line != deduped[-1]:
                deduped.append(line)

        transcription = " ".join(deduped)
        if not transcription:
            raise ValueError("No transcription text found in the vtt file.")
        
        if debug:
            print("\nFirst 500 characters of trimmed VTT:")
            print(transcription[:500])

        return transcription
    

    