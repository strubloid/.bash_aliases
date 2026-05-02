def canonicalize_names(text, name_map):
    for wrong, right in name_map.items():
        text = text.replace(wrong, right)
    return text


## This will be canalize the names in the final AI response using the provided name map
def fix_names(finalAiResponse):
    name_map = {
        "Elando": "Elandor",
        "Elandorr": "Elandor",

        "Pendraco" : "Phendrachion",
        "Fendrakion": "Phendrachion",
        "Fendracken": "Phendrachion",
        "Fendrack": "Phendrachion",
        "Fendrak": "Phendrachion",
        "Fendra": "Phendrachion",
        "Fendraken": "Phendrachion",
        "Fendrachion": "Phendrachion",
        "Fendren": "Phendrachion",
        "Phendrachionen": "Phendrachion",
        "Oneal": "Phendrachion",

        "Vasco": "Baskkol",
        "Básco": "Baskkol",
        "Bask": "Baskkol",
        "Basco": "Baskkol",

        "Dudu": "Elandor",
        "Rafael": "Baltazar",
        "Igor": "Root",
        "Cassio": "Baskkol",

        "Otário": "Otari",
        "otário": "Otari",
        "Serenai": "Sarenrae",

        "Karman": "Carman",
        "Karma": "Carman",
        "Carma": "Carman",
        "Carmann": "Carman",

        "Barra da Águia": "Crook Snook",
        "Cruxnook": "Crook Snook",
        "Cruxn": "Crook Snook",
        "Crook Snoob": "Crook Snook",

        "Guntler": "Gauntlight",
        "Guntlight": "Gauntlight",
        "Guntland": "Gauntlight",
        "Gunland": "Gauntlight",
        "Gutlight": "Gauntlight",
        "Glight": "Gauntlight",

        "Temley": "Tamily",
        "Vânia": "Vanda",

        "Celas Longasas": "Celas Longas",
        "Celas Long": "Celas Longas",

        "Farasma": "Pharasma",
        "Farrasman": "Pharasma",
        "Farrasna": "Pharasma",

        "Black Onix": "ônix negro",
        "black onix": "ônix negro",
        "Black Ónix": "ônix negro",

        "Soul do goblin": "alma do goblin",
        "buff": "bênção",
        "Buff": "bênção",
        "slot": "encaixe",
        "Slot": "encaixe",
        "dungeon": "masmorra",
        "Dungeon": "masmorra",
    }
    
    ## getting the canonicalized text by replacing the wrong names with the correct ones using the name_map
    canonicalized_text = canonicalize_names(finalAiResponse, name_map)
    
    return canonicalized_text