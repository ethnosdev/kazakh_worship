import json
import os
import re

os.makedirs('assets/songs', exist_ok=True)
os.makedirs('assets/prayers', exist_ok=True)
os.makedirs('assets/guitar', exist_ok=True)
os.makedirs('assets/categories', exist_ok=True)

# 1. Export songs
with open('/tmp/all_songs_chordpro.json', 'r', encoding='utf-8') as f:
    songs = json.load(f)

song_list_entries = []
for s in songs:
    num = s['number']
    filename = f"{num}.txt"
    filepath = os.path.join('assets/songs', filename)
    with open(filepath, 'w', encoding='utf-8') as sf:
        sf.write(f"{{number: {num}}}\n")
        sf.write(f"{{title: {s['title']}}}\n")
        if s['meter']:
            sf.write(f"{{meter: {s['meter']}}}\n")
        if s['category']:
            sf.write(f"{{category: {s['category']}}}\n")
        if s['language']:
            sf.write(f"{{language: {s['language']}}}\n")
        sf.write("\n")
        sf.write(s['chords'].strip() + "\n")
    song_list_entries.append(f"{num}:{s['title']}")

with open('assets/songs/songs_list.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(song_list_entries) + "\n")

print(f"Exported {len(songs)} song files to assets/songs/")

# 2. Export prayers from lib/data/prayers_data.dart
with open('lib/data/prayers_data.dart', 'r', encoding='utf-8') as f:
    p_code = f.read()

p_blocks = re.findall(r"PrayerItem\((.*?)\),", p_code, re.DOTALL)
prayer_ids = []
for pb in p_blocks:
    p_id = re.search(r"id:\s*'([^']+)'", pb).group(1)
    title_kk = re.search(r"titleKk:\s*'([^']+)'", pb).group(1)
    
    m_mn = re.search(r"titleMn:\s*'([^']+)'", pb)
    title_mn = m_mn.group(1) if m_mn else ""
    
    m_ref = re.search(r"scriptureRef:\s*'([^']+)'", pb)
    scripture = m_ref.group(1) if m_ref else ""
    
    c_kk = re.search(r"contentKk:\s*'''(.*?)'''", pb, re.DOTALL).group(1).strip()
    
    m_cmn = re.search(r"contentMn:\s*'''(.*?)'''", pb, re.DOTALL)
    c_mn = m_cmn.group(1).strip() if m_cmn else ""
    
    filepath = os.path.join('assets/prayers', f"{p_id}.txt")
    with open(filepath, 'w', encoding='utf-8') as pf:
        pf.write(f"{{id: {p_id}}}\n")
        pf.write(f"{{title_kk: {title_kk}}}\n")
        if title_mn:
            pf.write(f"{{title_mn: {title_mn}}}\n")
        if scripture:
            pf.write(f"{{scripture: {scripture}}}\n")
        pf.write("\n--- kk ---\n")
        pf.write(c_kk + "\n")
        if c_mn:
            pf.write("\n--- mn ---\n")
            pf.write(c_mn + "\n")
    prayer_ids.append(p_id)

with open('assets/prayers/prayers_list.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(prayer_ids) + "\n")

print(f"Exported {len(prayer_ids)} prayer files to assets/prayers/")

# 3. Export guitar guides from lib/data/guitar_data.dart
with open('lib/data/guitar_data.dart', 'r', encoding='utf-8') as f:
    g_code = f.read()

g_blocks = re.findall(r"GuitarGuideItem\((.*?)\),", g_code, re.DOTALL)
guide_ids = []
for gb in g_blocks:
    g_id = re.search(r"id:\s*'([^']+)'", gb).group(1)
    title = re.search(r"title:\s*'([^']+)'", gb).group(1)
    subtitle = re.search(r"subtitle:\s*'([^']+)'", gb).group(1)
    content = re.search(r"content:\s*'''(.*?)'''", gb, re.DOTALL).group(1).strip()
    
    filepath = os.path.join('assets/guitar', f"{g_id}.txt")
    with open(filepath, 'w', encoding='utf-8') as gf:
        gf.write(f"{{id: {g_id}}}\n")
        gf.write(f"{{title: {title}}}\n")
        if subtitle:
            gf.write(f"{{subtitle: {subtitle}}}\n")
        gf.write("\n")
        gf.write(content + "\n")
    guide_ids.append(g_id)

with open('assets/guitar/guitar_list.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(guide_ids) + "\n")

print(f"Exported {len(guide_ids)} guitar guide files to assets/guitar/")

# 4. Export categories from lib/data/categories_data.dart
with open('lib/data/categories_data.dart', 'r', encoding='utf-8') as f:
    c_code = f.read()

c_blocks = re.findall(r"SongCategory\((.*?)\),", c_code, re.DOTALL)
cat_lines = []
for cb in c_blocks:
    name = re.search(r"name:\s*'([^']+)'", cb).group(1)
    verse = re.search(r"scriptureVerse:\s*'([^']+)'", cb).group(1)
    cat_lines.append(f"{name} | {verse}")

with open('assets/categories/categories.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(cat_lines) + "\n")

print(f"Exported {len(cat_lines)} categories to assets/categories/categories.txt")
