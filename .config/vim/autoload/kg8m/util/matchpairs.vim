vim9script

const BASIC_KEY_PAIRS          = { "(": ")", "[": "]", "{": "}", "<": ">" }
const INVERTED_BASIC_KEY_PAIRS = { ")": "(", "]": "[", "}": "{", ">": "<" }

export def JapanesePairs(): list<list<string>>
  return GroupedJapanesePairs()->values()->reduce((result, pairs) => result + pairs, [])
enddef

export def GroupedJapanesePairs(): dict<list<list<string>>>
  return {
    "(": [
      ["（", "）"],
    ],
    "[": [
      ["［", "］"],
      ["「", "」"],
      ["『", "』"],
      ["【", "】"],
      ["〔", "〕"],
    ],
    "{": [
      ["｛", "｝"],
    ],
    "<": [
      ["〈", "〉"],
      ["《", "》"],
      ["＜", "＞"],
    ],
    '"': [
      ["“", "”"],
    ],
    "'": [
      ["‘", "’"],
    ],
  }
enddef

export def KeyPairFor(key: string): list<string>
  return [key, get(BASIC_KEY_PAIRS, key, key)]
enddef

export def NormalizeKey(key: string): string
  return get(INVERTED_BASIC_KEY_PAIRS, key, key)
enddef

export def IsBasicStartKey(maybe_key: string): bool
  return has_key(BASIC_KEY_PAIRS, maybe_key)
enddef
