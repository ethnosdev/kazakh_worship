import re
import os

def normalize_text(text: str) -> str:
    text = text.replace('\u200d', '').replace('\u200c', '').replace('\ufeff', '')
    text = text.replace('ə', 'ә').replace('Ə', 'Ә')
    # Replace Latin x in Kazakh/Mongolian words with Cyrillic х
    text = re.sub(r'([А-Яа-яӨөҮүҢңҒғҚқҺһІі])x', r'\1х', text)
    text = re.sub(r'x([А-Яа-яӨөҮүҢңҒғҚқҺһІі])', r'х\1', text)
    return text

def escape_dart_string(s: str) -> str:
    # Escape $ for Dart string interpolation
    return s.replace('\\', '\\\\').replace('$', r'\$')

with open('/tmp/extracted_songbook.txt', 'r', encoding='utf-8') as f:
    raw_text = f.read()

normalized_full = normalize_text(raw_text)
pages_split = re.split(r'--- PAGE (\d+) ---\n', normalized_full)
page_map = {int(pages_split[i]): pages_split[i+1].strip() for i in range(1, len(pages_split), 2)}

# Thematic categories by page
cat_markers = [
    (10, 'Мәсіхтің туылуы', 'Ал Құдай белгілеген уақыты жеткенде, Өзінің рухани Ұлын өмірге жіберді. Ол әйелден туылып, Таурат заңына бағынды. - Ғалаттықтарға 4:4'),
    (20, 'Исаның киелі құрбандығы', 'Жақия пайғамбар Иса тұралы мынандай куәлік келтірді: «Міне, дүниенің күнәсін мойнына алатын Құдайдың Қозысы!» - Жохан 1:29'),
    (27, 'Исаның тірілу күні', 'Иса: - Қайта тірілу мен шынайы өмір - Менмін. Маған сенетін кісі өлсе де өмір сүреді, - деді. - Жохан 11:25'),
    (32, 'Сиыну', 'Еш нәрсені уайымдамай, барлық жағдайда сиынып, тілектеріңізді Құдайға білдіріңіздер, ризашылықпен шүкіршілік етіңіздер! - Філіпіліктерге 4:6'),
    (39, 'Халқымыз үшін жалбарыну', 'Ол барлық адамдардың құтқарылып, шындықты толық біліп тануын қалайды. - 1 Тімотеге 2:4'),
    (46, 'Құдайдың сөзі', 'Сонымен бірге балалық шағыңнан-ақ Киелі жазбалармен таныс екеніңді білесің. Бұл Жазбалар Мәсіх Исаға сену арқылы құтқарылуға жетелейтін даналық бере алады. - 2 Тімотеге 3:15'),
    (51, 'Тәубеге шақыру', 'Сонда алдыңда күнәмді мойындадым, Әділетсіздігімді енді жасырмадым. Жаратқанға кінәмді ашық айтам дедім, Сен сонда барлық күнәмді кешірдің. - Забур жырлары 31:5'),
    (59, 'Құдайдың кешірімі', 'Тәңір Ие біздің күнәларымызды ешқашан күнә ретінде есептемейді! Ол бізге жасаған қателіктерімізге сәйкес жаза бермейді. - Забур жырлары 102:10'),
    (66, 'Құдайды мойындау', 'Себебі Мәсіхке жүрегімен сенуі арқылы адам ақталады, ал Оны аузымен мойындауы арқылы құтқарылады. - Римдіктерге 10:10'),
    (70, 'Мәсіхшілік өмірі', 'Сендер Иеміз Мәсіх Исаны қалай қабылдаған болсаңдар, бұдан былай да Онымен тығыз байланыста өмір сүріңдер! - Қолостықтарға 2:6'),
    (81, 'Қауым', 'Мәсіх - сенушілер қауымының, яғни Өзінің рухани денесінің Басы. Ол - барлығының Бастауы әрі өлгендердің арасынан алғашқы болып қайта тірілген. - Қолостықтарға 1:18'),
    (83, 'Құдайдың жетелеуі', 'Өз «қойларым» даусымды естіп, бағынады. Мен оларды білемін, олар да Менің соңымнан ереді. - Жохан 10:27'),
    (91, 'Сенім', 'Өйткені барлығың Иса Мәсіхке деген сенімдерің арқылы Құдайдың рухани балаларысыңдар. - Ғалаттықтарға 3:26'),
    (96, 'Нан үзу рәсімі', 'Біз Иеміздің құрбандығын еске алып «шүкірлік тостағанынан» ішкенде, Мәсіхтің төгілген қанының шапағатын көреміз емес пе? Үлескен нанды бірге жегенде, Мәсіхтің рухани денесіне ортақ боламыз емес пе? - 1 Қорынттықтарға 10:16'),
    (99, 'Үш-бірлік', 'Бәріміз біртұтас рухани денеміз, Құдайдың Рухы да Біреу, әрі Құдай сендерді бір ғана үмітке шақырды. Бір ғана Иеміз, бір ғана сенім, бір ғана шомылдыру рәсімі бар. - Ефестіктерге 4:4-5'),
    (103, 'Сүйіспеншілік', 'Бұл сүйіспеншіліктің мәнісі мынада: Құдайды сүйген біз емес, қайта, бізді Сүйіп, күнәларымызды өтейтін құрбандық ретінде Өз Ұлын жіберген - Оның Өзі. - 1 Жохан 4:10'),
    (132, 'Құдай біздің арамызда', '«Естеріңде болсын: Мен бұл дүниенің ақыр соңына дейін әр күні өздеріңмен бірге болып, сендерге жар боламын!» (Аумин.) - Матай 28:20'),
    (139, 'Балаларға арналған әндер', 'Ал Иса былай деді: «Балалардың Маған келуіне жол беріңдер, оларға бөгет жасамаңдар, өйткені Көктегі Патшалық осындайлардікі!» - Матай 19:14'),
    (152, 'Монгол магтан дуунууд', 'Аяа ЭЗЭН, Таны бүтээсэн бүх улс үндэстэн ирж, Таны өмнө мэхийж, Таны нэрийг алдаршуулна. Учир нь Та аугаа бөгөөд гайхамшгийг үйлддэг. Та бол Бурхан, Та ганцаараа. - Дуулал 86:9-10'),
]

def get_category_info(page: int):
    cat_title = 'Жалпы'
    cat_verse = ''
    for p, c, v in cat_markers:
        if page >= p:
            cat_title = c
            cat_verse = v
    return cat_title, cat_verse

def is_chord_line(line: str) -> bool:
    l = line.strip()
    if not l:
        return False
    # If starts with verse number or chorus label
    if re.match(r'^(?:\d+\.|\d+\)|\/|\/p|Қ-сы:|ДХ:)', l):
        return False
    tokens = l.split()
    if not tokens:
        return False
    chord_count = 0
    for tok in tokens:
        c = tok.strip('()/-:,23456789pPрР')
        if not c:
            chord_count += 1
            continue
        if re.match(r'^[A-G][b#]?(?:m|maj|min|sus|dim|aug|add)?[0-9]?(?:/[A-G][b#]?)?$', c):
            chord_count += 1
        elif c in ['-', '/', '2p', '3p', '2р', '3р', '8/', '6/', '4/', '4/Б', '2/', '3/']:
            chord_count += 1
    return (chord_count / len(tokens)) >= 0.65

# Scan song headers
page_headers = {}
for p in range(11, 162):
    txt = page_map.get(p, '')
    if not txt:
        continue
    lines = txt.split('\n')
    p_heads = []
    for idx, l in enumerate(lines):
        ls = l.strip()
        if any(w in ls for w in ['Забур жырлары', 'Матай', 'Иохан', 'Жохан', 'Руларды', 'Қолостықтар', 'Дуулал']):
            continue
        m1 = re.match(r'^(\d{1,3})\s+(.+)$', ls)
        m2 = re.match(r'^(.+?)\s+(\d{1,3})$', ls)
        if m1 and 1 <= int(m1.group(1)) <= 142 and not m1.group(2).strip().isdigit():
            p_heads.append((idx, int(m1.group(1)), m1.group(2).strip()))
        elif m2 and 1 <= int(m2.group(2)) <= 142 and not m2.group(1).strip().isdigit():
            p_heads.append((idx, int(m2.group(2)), m2.group(1).strip()))
    if p_heads:
        p_heads.sort(key=lambda x: x[0])
        seen = set()
        clean_heads = []
        for h in p_heads:
            if h[1] not in seen:
                seen.add(h[1])
                clean_heads.append(h)
        page_headers[p] = clean_heads

songs = {}
for p, heads in sorted(page_headers.items()):
    lines = page_map[p].split('\n')
    for h_i, (idx, num, title) in enumerate(heads):
        start_line = idx + 1
        end_line = heads[h_i + 1][0] if (h_i + 1 < len(heads)) else len(lines)
        song_lines = lines[start_line:end_line]
        
        meter = ''
        content_lines = []
        for sl in song_lines:
            sl_s = sl.strip()
            if not meter and re.match(r'^(?:[23468]\/|[23468]\/[А-Яа-яA-Za-z]+|\d\/\d)$', sl_s):
                meter = sl_s
            elif not meter and re.match(r'^([23468]\/[А-Яа-яA-Za-z]?)\s+(.*)$', sl_s):
                parts = sl_s.split(None, 1)
                meter = parts[0]
                if len(parts) > 1 and parts[1].strip():
                    content_lines.append(parts[1].strip())
            else:
                content_lines.append(sl)
                
        # Clean up empty lines at start and end
        while content_lines and not content_lines[0].strip():
            content_lines.pop(0)
        while content_lines and not content_lines[-1].strip():
            content_lines.pop()

        # Build chords text
        chords_text = '\n'.join(content_lines).strip()
        
        # Build pure lyrics text (excluding chord lines)
        lyrics_lines = []
        for cl in content_lines:
            if not is_chord_line(cl):
                # Clean any lingering chord artifacts if present at very end of line
                cl_cleaned = cl.rstrip()
                lyrics_lines.append(cl_cleaned)
            elif not cl.strip():
                lyrics_lines.append('')
        lyrics_text = '\n'.join(lyrics_lines).strip()
        
        cat_title, _ = get_category_info(p)
        lang = 'mn' if (num in [82, 115] or num >= 134) else 'kk'
        
        songs[num] = {
            'number': num,
            'id': str(num),
            'title': title,
            'meter': meter,
            'category': cat_title,
            'language': lang,
            'chords': chords_text,
            'lyrics': lyrics_text,
        }

print(f'Successfully built {len(songs)} song records.')

# Write lib/data/songs_data.dart
os.makedirs('lib/data', exist_ok=True)
with open('lib/data/songs_data.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:kazakh_worship/models/song.dart';\n\n")
    f.write("const List<Song> songList = [\n")
    for num in sorted(songs.keys()):
        s = songs[num]
        f.write("  Song(\n")
        f.write(f"    number: {s['number']},\n")
        f.write(f"    id: '{s['id']}',\n")
        f.write(f"    title: '{escape_dart_string(s['title'])}',\n")
        f.write(f"    meter: '{escape_dart_string(s['meter'])}',\n")
        f.write(f"    category: '{escape_dart_string(s['category'])}',\n")
        f.write(f"    language: '{s['language']}',\n")
        f.write(f"    lyrics: '''\n{escape_dart_string(s['lyrics'])}\n''',\n")
        f.write(f"    chords: '''\n{escape_dart_string(s['chords'])}\n''',\n")
        f.write("  ),\n")
    f.write("];\n")

print('Wrote lib/data/songs_data.dart')

# Build prayers data
prayers = [
    {
        'id': 'apostles_creed',
        'titleKk': 'Сенім белгісі',
        'titleMn': 'Итгэлийн тунхаг',
        'contentKk': page_map[6].replace('Сенім белгісі\n', '').strip(),
        'contentMn': page_map[7].replace('Итгэлийн тунхаг\n', '').strip(),
        'scriptureRef': '',
    },
    {
        'id': 'lords_prayer',
        'titleKk': 'Иеміздің мінәжаты',
        'titleMn': 'Тэнгэр дэх, бидний Аав аа',
        # Page 8 has Kazakh at top, Mongolian at bottom
        'contentKk': page_map[8].split('Тэнгэр дэх')[0].replace('Иеміздің мінәжаты\n', '').strip(),
        'contentMn': ('Тэнгэр дэх' + page_map[8].split('Тэнгэр дэх')[1]).strip() if 'Тэнгэр дэх' in page_map[8] else '',
        'scriptureRef': 'Матай 6:9-13',
    },
    {
        'id': 'repentance',
        'titleKk': 'Тәубе ету және кешірім алу',
        'titleMn': 'Гэмших ба уучлал авах',
        'contentKk': page_map[9].split('Хэрэв бид')[0].replace('Тәубе ету және кешірім алу\n', '').strip(),
        'contentMn': ('Хэрэв бид' + page_map[9].split('Хэрэв бид')[1]).strip() if 'Хэрэв бид' in page_map[9] else '',
        'scriptureRef': '1 Жохан 1:6-2:1',
    },
    {
        'id': 'sunday_service',
        'titleKk': 'Қауым жиналысын өткізу реттілігі',
        'titleMn': None,
        'contentKk': page_map[3].replace('Қауым жиналысын өткізу реттілігі\n', '').strip(),
        'contentMn': None,
        'scriptureRef': 'Руларды санау 6:24-26',
    },
    {
        'id': 'home_church',
        'titleKk': 'Үй қауымның қызметі',
        'titleMn': None,
        'contentKk': page_map[4].replace('Үй қауымның қызметі\n', '').strip(),
        'contentMn': None,
        'scriptureRef': 'Руларды санау 6:24',
    },
    {
        'id': 'family_prayer',
        'titleKk': 'Отбасымен сиыну уақыты',
        'titleMn': None,
        'contentKk': page_map[5].replace('Отбасымен сиыну уақыты\n', '').strip(),
        'contentMn': None,
        'scriptureRef': 'Матай 18:20, Забур 94:1, Қолостықтар 4:2',
    },
]

with open('lib/data/prayers_data.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:kazakh_worship/models/prayer.dart';\n\n")
    f.write("const List<PrayerItem> prayerList = [\n")
    for p in prayers:
        f.write("  PrayerItem(\n")
        f.write(f"    id: '{p['id']}',\n")
        f.write(f"    titleKk: '{escape_dart_string(p['titleKk'])}',\n")
        if p['titleMn']:
            f.write(f"    titleMn: '{escape_dart_string(p['titleMn'])}',\n")
        f.write(f"    contentKk: '''\n{escape_dart_string(p['contentKk'])}\n''',\n")
        if p['contentMn']:
            f.write(f"    contentMn: '''\n{escape_dart_string(p['contentMn'])}\n''',\n")
        if p['scriptureRef']:
            f.write(f"    scriptureRef: '{escape_dart_string(p['scriptureRef'])}',\n")
        f.write("  ),\n")
    f.write("];\n")

print('Wrote lib/data/prayers_data.dart')

# Build guitar guide data
guitar_guides = [
    {
        'id': 'tuning',
        'title': 'Гитарды қалай көктеу',
        'subtitle': 'Гитараның дыбысын күйіне келтіру',
        'content': page_map[164].replace('Гитарды калай көктеу\n(Гитараның дыбысын күйіне келтіру)\n', '').strip(),
    },
    {
        'id': 'strumming',
        'title': 'Шерту немесе саусақ стилі',
        'subtitle': 'Саусақпен шерту және қағу әдістері',
        'content': page_map[165].strip(),
    },
    {
        'id': 'intro',
        'title': 'Кіріспе',
        'subtitle': 'Ән айтпас бұрын гитарада ойнау',
        'content': page_map[166].strip(),
    },
]

with open('lib/data/guitar_data.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:kazakh_worship/models/guitar_guide.dart';\n\n")
    f.write("const List<GuitarGuideItem> guitarGuideList = [\n")
    for g in guitar_guides:
        f.write("  GuitarGuideItem(\n")
        f.write(f"    id: '{g['id']}',\n")
        f.write(f"    title: '{escape_dart_string(g['title'])}',\n")
        f.write(f"    subtitle: '{escape_dart_string(g['subtitle'])}',\n")
        f.write(f"    content: '''\n{escape_dart_string(g['content'])}\n''',\n")
        f.write("  ),\n")
    f.write("];\n")

print('Wrote lib/data/guitar_data.dart')

# Build categories data
with open('lib/data/categories_data.dart', 'w', encoding='utf-8') as f:
    f.write("class SongCategory {\n")
    f.write("  final String name;\n")
    f.write("  final String scriptureVerse;\n\n")
    f.write("  const SongCategory({\n")
    f.write("    required this.name,\n")
    f.write("    required this.scriptureVerse,\n")
    f.write("  });\n")
    f.write("}\n\n")
    f.write("const List<SongCategory> categoryList = [\n")
    for _, name, verse in cat_markers:
        f.write("  SongCategory(\n")
        f.write(f"    name: '{escape_dart_string(name)}',\n")
        f.write(f"    scriptureVerse: '{escape_dart_string(verse)}',\n")
        f.write("  ),\n")
    f.write("];\n")

print('Wrote lib/data/categories_data.dart')
