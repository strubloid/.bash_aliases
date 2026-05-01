def canonicalize_names(text, name_map):
    for wrong, right in name_map.items():
        text = text.replace(wrong, right)
    return text
