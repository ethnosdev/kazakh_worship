import json
import os
import re

special_breaks = {
    14: [6, 12],
    21: [2],
    22: [1],
    35: [4],
    41: [3],
    49: [4],
    62: [4, 8],
    63: [2],
    71: [4],
    78: [4],
    89: [3],
    90: [2],
    91: [2],
    92: [3, 6],
    93: [4],
    96: [4, 6],
    102: [3],
    103: [4],
    110: [2, 4],
    114: [4],
    115: [4, 8],
    116: [2],
    124: [2],
    126: [4],
    127: [4, 6, 8],
    134: [4],
    135: [4, 8, 12],
    136: [4, 8],
    137: [6, 12],
    138: [12],
    139: [6],
    140: [10, 16],
    142: [6],
}

def format_chords_lines(num, lines):
    new_lines = []
    spec_indices = set(special_breaks.get(num, []))
    for i, line in enumerate(lines):
        clean = re.sub(r'\[.*?\]', '', line).strip()
        is_break = False
        if i in spec_indices:
            is_break = True
        elif re.match(r'^\d+\.', clean):
            is_break = True
        elif re.match(r'^(?:Қ-сы|Қайырмасы|Қайырма|ДХ|Дх|Соңы|Көпір)\b', clean, re.IGNORECASE):
            is_break = True
        elif clean.startswith('Құдайдың жетелеуі') or clean.startswith('Құдай біздің арамызда') or clean.startswith('Монгол магтан дуунууд'):
            is_break = True
        elif clean.startswith('- Жохан') or clean.startswith('- Матай') or clean.startswith('- Дуулал'):
            if new_lines and not (new_lines[-1].strip().startswith('Құдай') or new_lines[-1].strip().startswith('Монгол') or len(new_lines[-1].strip()) > 30):
                is_break = True

        if is_break and new_lines and new_lines[-1] != "":
            new_lines.append("")
        new_lines.append(line)
    return new_lines

def generate_lyrics(chords_lines):
    lyric_lines = []
    for cl in chords_lines:
        if cl.strip() == '':
            if lyric_lines and lyric_lines[-1] != '':
                lyric_lines.append('')
            continue
        stripped = re.sub(r'\[.*?\]', '', cl).strip()
        non_punct = re.sub(r'[()/-:, \t0-9prрxх]', '', stripped)
        if not non_punct:
            # Instrumental / repetition line
            continue
        lyric_lines.append(stripped)
    while lyric_lines and lyric_lines[-1] == '':
        lyric_lines.pop()
    return "\n".join(lyric_lines)

# Process all 142 songs
all_songs_data = []

for n in range(1, 143):
    path = f'assets/songs/{n}.txt'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    parts = content.split('\n\n', 1)
    header = parts[0]
    body = parts[1] if len(parts) > 1 else ""
    
    title_m = re.search(r'\{title:\s*(.*?)\}', header)
    title = title_m.group(1).strip() if title_m else f"Ән #{n}"
    
    meter_m = re.search(r'\{meter:\s*(.*?)\}', header)
    meter = meter_m.group(1).strip() if meter_m else ""
    
    cat_m = re.search(r'\{category:\s*(.*?)\}', header)
    category = cat_m.group(1).strip() if cat_m else ""
    
    lang_m = re.search(r'\{language:\s*(.*?)\}', header)
    language = lang_m.group(1).strip() if lang_m else ("mn" if n >= 134 or n == 82 or n == 115 else "kk")
    
    raw_lines = [l for l in body.strip().split('\n') if l.strip()]
    formatted_chord_lines = format_chords_lines(n, raw_lines)
    formatted_chords = "\n".join(formatted_chord_lines).strip()
    formatted_lyrics = generate_lyrics(formatted_chord_lines).strip()
    
    # Overwrite assets/songs/{n}.txt with formatted chords (with blank lines between verses)
    with open(path, 'w', encoding='utf-8') as sf:
        sf.write(f"{{number: {n}}}\n")
        sf.write(f"{{title: {title}}}\n")
        if meter:
            sf.write(f"{{meter: {meter}}}\n")
        if category:
            sf.write(f"{{category: {category}}}\n")
        if language:
            sf.write(f"{{language: {language}}}\n")
        sf.write("\n")
        sf.write(formatted_chords + "\n")
        
    all_songs_data.append({
        'number': n,
        'id': str(n),
        'title': title,
        'meter': meter,
        'category': category,
        'language': language,
        'lyrics': formatted_lyrics,
        'chords': formatted_chords,
    })

print(f"Updated {len(all_songs_data)} asset files in assets/songs/")
