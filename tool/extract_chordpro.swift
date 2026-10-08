import PDFKit
import Foundation

let url = URL(fileURLWithPath: "supplemental/songbook.pdf")
guard let doc = PDFDocument(url: url) else {
    print("Cannot open PDF")
    exit(1)
}

func normalizeText(_ s: String) -> String {
    var res = s.replacingOccurrences(of: "\u{200d}", with: "")
        .replacingOccurrences(of: "\u{200c}", with: "")
        .replacingOccurrences(of: "\u{feff}", with: "")
        .replacingOccurrences(of: "ə", with: "ә")
        .replacingOccurrences(of: "Ə", with: "Ә")
    // Replace Latin x in Cyrillic words
    if let regex = try? NSRegularExpression(pattern: "([А-Яа-яӨөҮүҢңҒғҚқҺһІі])x", options: []) {
        res = regex.stringByReplacingMatches(in: res, options: [], range: NSRange(location: 0, length: res.utf16.count), withTemplate: "$1х")
    }
    if let regex = try? NSRegularExpression(pattern: "x([А-Яа-яӨөҮүҢңҒғҚқҺһІі])", options: []) {
        res = regex.stringByReplacingMatches(in: res, options: [], range: NSRange(location: 0, length: res.utf16.count), withTemplate: "х$1")
    }
    return res
}

func isChordToken(_ s: String) -> Bool {
    let clean = s.trimmingCharacters(in: CharacterSet(charactersIn: "()/-:,0123456789pPрР \t"))
    if clean.isEmpty { return false }
    let chordPattern = "^[A-G][b#]?(?:m|maj|min|sus|dim|aug|add)?[0-9]?(?:/[A-G][b#]?)?$"
    return clean.range(of: chordPattern, options: .regularExpression) != nil
}

func cleanChordName(_ s: String) -> String {
    var c = s.trimmingCharacters(in: CharacterSet(charactersIn: "()/-:, \t"))
    c = c.replacingOccurrences(of: "2p", with: "")
    c = c.replacingOccurrences(of: "2р", with: "")
    c = c.replacingOccurrences(of: "3p", with: "")
    c = c.replacingOccurrences(of: "3р", with: "")
    return c
}

func isChordLine(_ line: String) -> Bool {
    let l = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if l.isEmpty { return false }
    if l.hasPrefix("Қ-сы:") || l.hasPrefix("ДХ:") || l.range(of: "^\\d+\\.", options: .regularExpression) != nil {
        return false
    }
    // If it contains Cyrillic words of 2 or more letters, it is a lyric line
    if l.range(of: "[А-Яа-яӨөҮүҢңҒғҚқҺһІі]{2,}", options: .regularExpression) != nil {
        return false
    }
    let tokens = l.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    if tokens.isEmpty { return false }
    var chordCount = 0
    for t in tokens {
        if isChordToken(t) {
            chordCount += 1
        }
    }
    return chordCount >= 1
}

struct LineGroup {
    let y: CGFloat
    let blocks: [(x: CGFloat, w: CGFloat, str: String)]
    var fullLine: String {
        return blocks.sorted(by: { $0.x < $1.x }).map { $0.str }.joined(separator: " ")
    }
}

func getPageLineGroups(page: PDFPage) -> [LineGroup] {
    guard let sel = doc.selection(from: page, atCharacterIndex: 0, to: page, atCharacterIndex: page.numberOfCharacters) else { return [] }
    var rawBlocks: [(y: CGFloat, x: CGFloat, w: CGFloat, str: String)] = []
    for line in sel.selectionsByLine() {
        let b = line.bounds(for: page)
        let s = (line.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.isEmpty {
            rawBlocks.append((y: b.origin.y, x: b.origin.x, w: b.size.width, str: s))
        }
    }
    var groups: [(y: CGFloat, blocks: [(x: CGFloat, w: CGFloat, str: String)])] = []
    for rb in rawBlocks {
        if let idx = groups.firstIndex(where: { abs($0.y - rb.y) < 4.0 }) {
            groups[idx].blocks.append((x: rb.x, w: rb.w, str: rb.str))
        } else {
            groups.append((y: rb.y, blocks: [(x: rb.x, w: rb.w, str: rb.str)]))
        }
    }
    groups.sort(by: { $0.y > $1.y })
    return groups.map { LineGroup(y: $0.y, blocks: $0.blocks.sorted(by: { $0.x < $1.x })) }
}

struct ChordPos {
    let x: CGFloat
    let chord: String
}

struct LyricWordPos {
    let x: CGFloat
    let w: CGFloat
    let word: String
}

func alignChordAndLyric(chordGroup: LineGroup, lyricGroup: LineGroup, page: PDFPage) -> String {
    // 1. Extract chords and their X positions from chordGroup
    var chordPositions: [ChordPos] = []
    for b in chordGroup.blocks {
        let tokens = b.str.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var curX = b.x
        let step = b.w / CGFloat(max(1, tokens.count))
        for tok in tokens {
            if isChordToken(tok) {
                let cName = cleanChordName(tok)
                let sels = doc.findString(cName, withOptions: [])
                var exactX = curX
                for s in sels where s.pages.contains(page) {
                    let sb = s.bounds(for: page)
                    if abs(sb.origin.y - chordGroup.y) < 6.0 && abs(sb.origin.x - curX) < 30.0 {
                        exactX = sb.origin.x
                        break
                    }
                }
                chordPositions.append(ChordPos(x: exactX, chord: cName))
            }
            curX += step
        }
    }
    chordPositions.sort(by: { $0.x < $1.x })

    // 2. Extract words and their X positions from lyricGroup
    var wordPositions: [LyricWordPos] = []
    for b in lyricGroup.blocks {
        let words = b.str.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var curX = b.x
        let step = b.w / CGFloat(max(1, words.count))
        for w in words {
            let clean = w.trimmingCharacters(in: CharacterSet(charactersIn: ".,!?:;\"'«»/-()[] \t"))
            var exactX = curX
            var exactW = step
            if !clean.isEmpty {
                let sels = doc.findString(clean, withOptions: [])
                for s in sels where s.pages.contains(page) {
                    let sb = s.bounds(for: page)
                    if abs(sb.origin.y - lyricGroup.y) < 6.0 && abs(sb.origin.x - curX) < 30.0 {
                        exactX = sb.origin.x
                        exactW = sb.size.width
                        break
                    }
                }
            }
            wordPositions.append(LyricWordPos(x: exactX, w: exactW, word: w))
            curX += step
        }
    }

    if wordPositions.isEmpty {
        return chordGroup.fullLine
    }

    // 3. Map chords to words
    var startIndex = 0
    if wordPositions.count > 1 && (wordPositions[0].word.hasPrefix("Қ-сы:") || wordPositions[0].word.hasPrefix("ДХ:")) {
        startIndex = 1
    }

    var chordsPerWord: [[String]] = Array(repeating: [], count: wordPositions.count)
    var trailingChords: [String] = []

    for c in chordPositions {
        if c.x <= wordPositions[startIndex].x + 5 {
            chordsPerWord[startIndex].append(c.chord)
            continue
        }
        
        let lastWord = wordPositions.last!
        if c.x >= lastWord.x + lastWord.w + 10 {
            trailingChords.append(c.chord)
            continue
        }

        var bestIdx = startIndex
        var bestDist: CGFloat = 999999
        for wIdx in startIndex..<wordPositions.count {
            let w = wordPositions[wIdx]
            let nextX = (wIdx + 1 < wordPositions.count) ? wordPositions[wIdx + 1].x : (w.x + w.w + 40)
            if c.x >= w.x - 10 && c.x < nextX {
                bestIdx = wIdx
                break
            }
            let dist = abs(c.x - w.x)
            if dist < bestDist {
                bestDist = dist
                bestIdx = wIdx
            }
        }
        chordsPerWord[bestIdx].append(c.chord)
    }

    // 4. Build output string
    var resultParts: [String] = []
    for (wIdx, w) in wordPositions.enumerated() {
        let chords = chordsPerWord[wIdx]
        if !chords.isEmpty {
            let chordPrefix = chords.map { "[\($0)]" }.joined()
            resultParts.append("\(chordPrefix)\(w.word)")
        } else {
            resultParts.append(w.word)
        }
    }
    if !trailingChords.isEmpty {
        resultParts.append(trailingChords.map { "[\($0)]" }.joined())
    }

    return resultParts.joined(separator: " ")
}

// Categories list
let categories: [(page: Int, cat: String)] = [
    (10, "Мәсіхтің туылуы"),
    (20, "Исаның киелі құрбандығы"),
    (27, "Исаның тірілу күні"),
    (32, "Сиыну"),
    (39, "Халқымыз үшін жалбарыну"),
    (46, "Құдайдың сөзі"),
    (51, "Тәубеге шақыру"),
    (59, "Құдайдың кешірімі"),
    (66, "Құдайды мойындау"),
    (70, "Мәсіхшілік өмірі"),
    (81, "Қауым"),
    (83, "Құдайдың жетелеуі"),
    (91, "Сенім"),
    (96, "Нан үзу рәсімі"),
    (99, "Үш-бірлік"),
    (103, "Сүйіспеншілік"),
    (132, "Құдай біздің арамызда"),
    (139, "Балаларға арналған әндер"),
    (152, "Монгол магтан дуунууд"),
]

func getCategory(for page: Int) -> String {
    var cat = "Жалпы"
    for c in categories {
        if page >= c.page {
            cat = c.cat
        }
    }
    return cat
}

// Scan all pages for song headers: (pageIndex, lineIndex, songNumber, songTitle)
struct SongHeader {
    let page: Int
    let groupIndex: Int
    let number: Int
    let title: String
}

var allHeaders: [SongHeader] = []

for p in 10..<162 {
    guard let page = doc.page(at: p) else { continue }
    let groups = getPageLineGroups(page: page)
    for (gIdx, g) in groups.enumerated() {
        let s = g.fullLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.contains("Забур жырлары") || s.contains("Матай") || s.contains("Иохан") || s.contains("Жохан") || s.contains("Руларды") || s.contains("Қолостықтар") || s.contains("Дуулал") {
            continue
        }
        // Match: "123 Title" or "Title 123"
        let m1 = s.range(of: "^(\\d{1,3})\\s+(.+)$", options: .regularExpression)
        let m2 = s.range(of: "^(.+?)\\s+(\\d{1,3})$", options: .regularExpression)
        if let r = m1 {
            let matched = String(s[r])
            let parts = matched.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if let num = Int(parts[0]), num >= 1 && num <= 142 {
                let title = parts.dropFirst().joined(separator: " ")
                if !title.allSatisfy({ $0.isNumber }) && !allHeaders.contains(where: { $0.number == num }) {
                    allHeaders.append(SongHeader(page: p, groupIndex: gIdx, number: num, title: title))
                }
            }
        } else if let r = m2 {
            let matched = String(s[r])
            let parts = matched.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if let num = Int(parts.last!), num >= 1 && num <= 142 {
                let title = parts.dropLast().joined(separator: " ")
                if !title.allSatisfy({ $0.isNumber }) && !allHeaders.contains(where: { $0.number == num }) {
                    allHeaders.append(SongHeader(page: p, groupIndex: gIdx, number: num, title: title))
                }
            }
        }
    }
}

allHeaders.sort(by: { $0.number < $1.number })
print("Found \(allHeaders.count) headers")

struct SongOutput: Codable {
    let number: Int
    let id: String
    let title: String
    let meter: String
    let category: String
    let language: String
    let lyrics: String
    let chords: String
}

var extractedSongs: [SongOutput] = []

for hIdx in 0..<allHeaders.count {
    let h = allHeaders[hIdx]
    let nextH = (hIdx + 1 < allHeaders.count) ? allHeaders[hIdx + 1] : nil
    
    var meter = ""
    var chordProLines: [String] = []
    
    // Pages for this song: from h.page to (nextH != nil ? nextH!.page : h.page)
    let endPage = (nextH != nil) ? nextH!.page : h.page
    
    for p in h.page...endPage {
        guard let page = doc.page(at: p) else { continue }
        let groups = getPageLineGroups(page: page)
        
        let startG = (p == h.page) ? (h.groupIndex + 1) : 0
        let endG = (nextH != nil && p == nextH!.page) ? nextH!.groupIndex : groups.count
        
        var gIdx = startG
        while gIdx < endG {
            let g = groups[gIdx]
            let line = g.fullLine.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if meter line
            if meter.isEmpty && (line.range(of: "^(?:[23468]\\/|[23468]\\/[А-Яа-яA-Za-z]+|\\(капо.*\\).*|\\d\\/\\d)$", options: .regularExpression) != nil) {
                meter = line
                gIdx += 1
                continue
            }
            if meter.isEmpty && (line.range(of: "^([23468]\\/[А-Яа-яA-Za-z]?)\\s+(.*)$", options: .regularExpression) != nil) {
                let parts = line.components(separatedBy: .whitespaces)
                meter = parts[0]
                gIdx += 1
                continue
            }
            
            // Check if chord line
            if isChordLine(line) {
                // If it's an interlude like "(G - A D) 2p" or standalone chords
                let isParenthesized = line.hasPrefix("(") && line.contains(")")
                if isParenthesized || gIdx + 1 >= endG || isChordLine(groups[gIdx+1].fullLine) || groups[gIdx+1].fullLine.range(of: "^\\d+\\.", options: .regularExpression) != nil {
                    // Standalone chords: wrap chord names in [...]
                    let tokens = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                    let converted = tokens.map { tok -> String in
                        let c = cleanChordName(tok)
                        if isChordToken(c) {
                            return "[\(c)]"
                        } else {
                            return tok
                        }
                    }.joined(separator: " ")
                    chordProLines.append(converted)
                    gIdx += 1
                } else {
                    // Align with next lyric line
                    let chordPro = alignChordAndLyric(chordGroup: g, lyricGroup: groups[gIdx+1], page: page)
                    chordProLines.append(chordPro)
                    gIdx += 2
                }
            } else {
                // Regular lyric line
                chordProLines.append(line)
                gIdx += 1
            }
        }
    }
    
    // Clean up empty lines
    while chordProLines.first?.isEmpty == true { chordProLines.removeFirst() }
    while chordProLines.last?.isEmpty == true { chordProLines.removeLast() }
    
    let chordsText = normalizeText(chordProLines.joined(separator: "\n"))
    
    // Generate clean lyrics by stripping [Chord]
    let lyricsLines = chordProLines.compactMap { line -> String? in
        // If line is purely chords like "[G] [A]" or "([G] [A]) 2p", omit from pure lyrics if no words
        let stripped = line.replacingOccurrences(of: "\\[[^\\]]+\\]", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
        // If stripped only has repetition punctuation or empty
        let nonPunct = stripped.trimmingCharacters(in: CharacterSet(charactersIn: "()/-:, \t"))
        if nonPunct.isEmpty && !line.trimmingCharacters(in: .whitespaces).isEmpty {
            return nil
        }
        return stripped
    }
    let lyricsText = normalizeText(lyricsLines.joined(separator: "\n"))
    
    let cat = getCategory(for: h.page + 1)
    let lang = (h.number == 82 || h.number == 115 || h.number >= 134) ? "mn" : "kk"
    
    extractedSongs.append(SongOutput(
        number: h.number,
        id: String(h.number),
        title: normalizeText(h.title),
        meter: normalizeText(meter),
        category: cat,
        language: lang,
        lyrics: lyricsText,
        chords: chordsText
    ))
}

print("Extracted \(extractedSongs.count) songs")

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
if let data = try? encoder.encode(extractedSongs) {
    try? data.write(to: URL(fileURLWithPath: "/tmp/all_songs_chordpro.json"))
    print("Saved /tmp/all_songs_chordpro.json, bytes: \(data.count)")
}
