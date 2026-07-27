// Romaji ⇄ kana conversion.
//
// SYLLABLES maps typeable romaji to hiragana, for converting keystrokes into kana.
// READINGS maps hiragana (including digraphs) to Hepburn romaji, for generating
// the readings shown in ruby annotations. Uppercase romaji produces katakana.

const SYLLABLES = {
  a: "あ", i: "い", u: "う", e: "え", o: "お",
  ka: "か", ki: "き", ku: "く", ke: "け", ko: "こ",
  ga: "が", gi: "ぎ", gu: "ぐ", ge: "げ", go: "ご",
  sa: "さ", si: "し", shi: "し", su: "す", se: "せ", so: "そ",
  za: "ざ", zi: "じ", ji: "じ", zu: "ず", ze: "ぜ", zo: "ぞ",
  ta: "た", ti: "ち", chi: "ち", tu: "つ", tsu: "つ", te: "て", to: "と",
  da: "だ", di: "ぢ", du: "づ", de: "で", do: "ど",
  na: "な", ni: "に", nu: "ぬ", ne: "ね", no: "の",
  ha: "は", hi: "ひ", hu: "ふ", fu: "ふ", he: "へ", ho: "ほ",
  ba: "ば", bi: "び", bu: "ぶ", be: "べ", bo: "ぼ",
  pa: "ぱ", pi: "ぴ", pu: "ぷ", pe: "ぺ", po: "ぽ",
  ma: "ま", mi: "み", mu: "む", me: "め", mo: "も",
  ya: "や", yu: "ゆ", yo: "よ",
  ra: "ら", ri: "り", ru: "る", re: "れ", ro: "ろ",
  wa: "わ", wo: "を",
  kya: "きゃ", kyu: "きゅ", kyo: "きょ",
  gya: "ぎゃ", gyu: "ぎゅ", gyo: "ぎょ",
  sya: "しゃ", syu: "しゅ", syo: "しょ",
  sha: "しゃ", shu: "しゅ", sho: "しょ", she: "しぇ",
  ja: "じゃ", ju: "じゅ", jo: "じょ", je: "じぇ",
  jya: "じゃ", jyu: "じゅ", jyo: "じょ",
  zya: "じゃ", zyu: "じゅ", zyo: "じょ",
  cha: "ちゃ", chu: "ちゅ", cho: "ちょ", che: "ちぇ",
  tya: "ちゃ", tyu: "ちゅ", tyo: "ちょ",
  dya: "ぢゃ", dyu: "ぢゅ", dyo: "ぢょ",
  nya: "にゃ", nyu: "にゅ", nyo: "にょ",
  hya: "ひゃ", hyu: "ひゅ", hyo: "ひょ",
  bya: "びゃ", byu: "びゅ", byo: "びょ",
  pya: "ぴゃ", pyu: "ぴゅ", pyo: "ぴょ",
  mya: "みゃ", myu: "みゅ", myo: "みょ",
  rya: "りゃ", ryu: "りゅ", ryo: "りょ",
  fa: "ふぁ", fi: "ふぃ", fe: "ふぇ", fo: "ふぉ",
  va: "ゔぁ", vi: "ゔぃ", vu: "ゔ", ve: "ゔぇ", vo: "ゔぉ",
  wi: "うぃ", we: "うぇ",
  thi: "てぃ", dhi: "でぃ",
  tsa: "つぁ", tse: "つぇ", tso: "つぉ",
  xa: "ぁ", xi: "ぃ", xu: "ぅ", xe: "ぇ", xo: "ぉ",
  la: "ぁ", li: "ぃ", lu: "ぅ", le: "ぇ", lo: "ぉ",
  xya: "ゃ", xyu: "ゅ", xyo: "ょ",
  lya: "ゃ", lyu: "ゅ", lyo: "ょ",
  xtu: "っ", xtsu: "っ", ltu: "っ", ltsu: "っ"
}

const PUNCTUATION = {
  "-": "ー", ",": "、", ".": "。", "!": "！", "?": "？"
}

const READINGS = {
  "あ": "a", "い": "i", "う": "u", "え": "e", "お": "o",
  "か": "ka", "き": "ki", "く": "ku", "け": "ke", "こ": "ko",
  "が": "ga", "ぎ": "gi", "ぐ": "gu", "げ": "ge", "ご": "go",
  "さ": "sa", "し": "shi", "す": "su", "せ": "se", "そ": "so",
  "ざ": "za", "じ": "ji", "ず": "zu", "ぜ": "ze", "ぞ": "zo",
  "た": "ta", "ち": "chi", "つ": "tsu", "て": "te", "と": "to",
  "だ": "da", "ぢ": "ji", "づ": "zu", "で": "de", "ど": "do",
  "な": "na", "に": "ni", "ぬ": "nu", "ね": "ne", "の": "no",
  "は": "ha", "ひ": "hi", "ふ": "fu", "へ": "he", "ほ": "ho",
  "ば": "ba", "び": "bi", "ぶ": "bu", "べ": "be", "ぼ": "bo",
  "ぱ": "pa", "ぴ": "pi", "ぷ": "pu", "ぺ": "pe", "ぽ": "po",
  "ま": "ma", "み": "mi", "む": "mu", "め": "me", "も": "mo",
  "や": "ya", "ゆ": "yu", "よ": "yo",
  "ら": "ra", "り": "ri", "る": "ru", "れ": "re", "ろ": "ro",
  "わ": "wa", "ゐ": "wi", "ゑ": "we", "を": "o",
  "ん": "n", "ゔ": "vu",
  "ぁ": "a", "ぃ": "i", "ぅ": "u", "ぇ": "e", "ぉ": "o",
  "ゃ": "ya", "ゅ": "yu", "ょ": "yo", "ゎ": "wa",
  "っ": "",
  "ー": "-",
  "きゃ": "kya", "きゅ": "kyu", "きょ": "kyo",
  "ぎゃ": "gya", "ぎゅ": "gyu", "ぎょ": "gyo",
  "しゃ": "sha", "しゅ": "shu", "しょ": "sho", "しぇ": "she",
  "じゃ": "ja", "じゅ": "ju", "じょ": "jo", "じぇ": "je",
  "ちゃ": "cha", "ちゅ": "chu", "ちょ": "cho", "ちぇ": "che",
  "ぢゃ": "ja", "ぢゅ": "ju", "ぢょ": "jo",
  "にゃ": "nya", "にゅ": "nyu", "にょ": "nyo",
  "ひゃ": "hya", "ひゅ": "hyu", "ひょ": "hyo",
  "びゃ": "bya", "びゅ": "byu", "びょ": "byo",
  "ぴゃ": "pya", "ぴゅ": "pyu", "ぴょ": "pyo",
  "みゃ": "mya", "みゅ": "myu", "みょ": "myo",
  "りゃ": "rya", "りゅ": "ryu", "りょ": "ryo",
  "ふぁ": "fa", "ふぃ": "fi", "ふぇ": "fe", "ふぉ": "fo",
  "ゔぁ": "va", "ゔぃ": "vi", "ゔぇ": "ve", "ゔぉ": "vo",
  "うぃ": "wi", "うぇ": "we", "うぉ": "wo",
  "てぃ": "ti", "でぃ": "di", "とぅ": "tu", "どぅ": "du",
  "つぁ": "tsa", "つぇ": "tse", "つぉ": "tso"
}

const MACRONS = { a: "ā", i: "ī", u: "ū", e: "ē", o: "ō" }

const SOKUON_CONSONANTS = "bcdfghjkmpqrstvwz"

export const KANA_RUN_PATTERN = /[ぁ-ゖァ-ヺー]+/

// Converts a romaji buffer into kana. Complete syllables are returned in
// `converted`; a trailing sequence that could still become a syllable with more
// input (e.g. "k", "ky", "n") is returned untouched in `pending`.
export function romajiToKana(input) {
  let converted = ""
  let index = 0

  while (index < input.length) {
    const rest = input.slice(index).toLowerCase()
    const katakana = /[A-Z]/.test(input[index])

    if (PUNCTUATION[rest[0]]) {
      converted += PUNCTUATION[rest[0]]
      index += 1
      continue
    }

    if (rest[0] === "n" && rest.length > 1 && (rest[1] === "n" || rest[1] === "'")) {
      converted += kanaFor("ん", katakana)
      index += 2
      continue
    }

    if (rest[0] === "n" && rest.length > 1 && !"aiueoy".includes(rest[1])) {
      converted += kanaFor("ん", katakana)
      index += 1
      continue
    }

    if (rest.length > 1 && rest[0] === rest[1] && SOKUON_CONSONANTS.includes(rest[0])) {
      converted += kanaFor("っ", katakana)
      index += 1
      continue
    }

    const syllable = longestSyllableAt(rest)
    if (syllable) {
      converted += kanaFor(SYLLABLES[syllable], katakana)
      index += syllable.length
      continue
    }

    if (couldBecomeSyllable(rest)) {
      return { converted, pending: input.slice(index) }
    }

    converted += input[index]
    index += 1
  }

  return { converted, pending: "" }
}

// Splits a run of kana into annotatable tokens, one per syllable, each with its
// Hepburn reading: "きょっと" → [{ text: "きょ", reading: "kyo" }, { text: "っと", reading: "tto" }]
export function tokenizeKana(run) {
  const tokens = []
  let index = 0

  while (index < run.length) {
    const { text, reading, nextIndex } = nextToken(run, index)
    tokens.push({ text, reading })
    index = nextIndex
  }

  return tokens
}

function longestSyllableAt(rest) {
  for (let length = Math.min(4, rest.length); length > 0; length--) {
    const candidate = rest.slice(0, length)
    if (SYLLABLES[candidate]) return candidate
  }
  return null
}

function couldBecomeSyllable(rest) {
  return Object.keys(SYLLABLES).some(syllable => syllable.startsWith(rest))
}

function kanaFor(hiragana, katakana) {
  return katakana ? toKatakana(hiragana) : hiragana
}

function nextToken(run, index) {
  const character = run[index]

  if (isSokuon(character) && index + 1 < run.length && !isSokuon(run[index + 1])) {
    const next = nextToken(run, index + 1)
    return { text: character + next.text, reading: geminate(next.reading), nextIndex: next.nextIndex }
  }

  let text = character
  let reading = READINGS[toHiragana(character)] ?? ""
  let nextIndex = index + 1

  const pair = run.slice(index, index + 2)
  if (pair.length === 2 && READINGS[toHiragana(pair)]) {
    text = pair
    reading = READINGS[toHiragana(pair)]
    nextIndex = index + 2
  }

  while (nextIndex < run.length && run[nextIndex] === "ー") {
    text += "ー"
    reading = lengthenReading(reading)
    nextIndex += 1
  }

  return { text, reading, nextIndex }
}

function isSokuon(character) {
  return character === "っ" || character === "ッ"
}

function geminate(reading) {
  if (reading.startsWith("ch")) {
    return `t${reading}`
  } else if (reading && !"aiueo".includes(reading[0])) {
    return reading[0] + reading
  } else {
    return reading
  }
}

export function lengthenReading(reading) {
  const lastLetter = reading.slice(-1)

  if (MACRONS[lastLetter]) {
    return reading.slice(0, -1) + MACRONS[lastLetter]
  } else {
    return `${reading}-`
  }
}

function toHiragana(text) {
  return shiftKanaRange(text, 0x30A1, 0x30F6, -0x60)
}

function toKatakana(text) {
  return shiftKanaRange(text, 0x3041, 0x3096, 0x60)
}

function shiftKanaRange(text, from, to, offset) {
  return Array.from(text, character => {
    const code = character.charCodeAt(0)
    return code >= from && code <= to ? String.fromCharCode(code + offset) : character
  }).join("")
}
