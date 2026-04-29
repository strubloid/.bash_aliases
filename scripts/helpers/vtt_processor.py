import re

class VTTProcessor:
    """Parses and cleans .vtt files."""

    @staticmethod
    def get_trimmed_transcription(vtt_file, from_time):
        """
        Uses ffmpeg to trim the VTT file from the given time, saves to truncated.vtt, and returns the processed transcription.
        """
        import subprocess
        import os
        debug = True

        output_vtt = "truncated.vtt"
        print(f"[NEW TRIMING] Trimming VTT from {from_time} and saving to {output_vtt}...")
        # Build ffmpeg command
        if from_time:
            cmd = [
                "ffmpeg", "-y", "-i", vtt_file, "-ss", from_time, "-c", "copy", output_vtt
            ]
            try:
                subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            except subprocess.CalledProcessError as e:
                print(f"Error running ffmpeg: {e.stderr.decode()}")
                raise
            vtt_to_process = output_vtt
        else:
            vtt_to_process = vtt_file

        with open(vtt_to_process, "r", encoding="utf-8") as f:
            trimmed_vtt_content = f.read()

        if debug:
            print("\nFirst 500 characters of trimmed VTT:")
            print(trimmed_vtt_content[:500])

        return VTTProcessor.process(trimmed_vtt_content)
    
    @staticmethod
    def process(vtt_input):
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

        return transcription