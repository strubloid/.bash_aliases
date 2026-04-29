class TimeExtractor:
    @staticmethod
    def extract_start_time(transcription):
        """
        Extract the 'from=time' value from the transcription.
        This method should parse the transcription and find the start time.
        """
        # Assuming transcription is a string with time information
        # This is a basic implementation - you may need to adjust based on your actual format
        import re

        # Look for time patterns like "from=00:01:23.456" or similar
        time_match = re.search(r'from=(\d{2}:\d{2}:\d{2}\.\d{3})', transcription)
        if time_match:
            return time_match.group(1)

        # If no 'from=' pattern found, return None or handle as needed
        return None

    @staticmethod
    def remove_time_from_transcription(transcription, start_time):
        """
        Remove all content from the transcription starting at the given time value and forward.
        Keep only the content before that point.
        """
        if not start_time:
            return transcription

        # Split the transcription into lines
        lines = transcription.split('\n')

        # Find the line that contains the start time
        filtered_lines = []
        time_found = False

        for line in lines:
            if start_time in line:
                time_found = True
                # Add this line but don't add anything after it
                filtered_lines.append(line)
                break
            elif not time_found:
                filtered_lines.append(line)

        # If we didn't find the time, return original transcription
        if not time_found:
            return transcription

        return '\n'.join(filtered_lines)