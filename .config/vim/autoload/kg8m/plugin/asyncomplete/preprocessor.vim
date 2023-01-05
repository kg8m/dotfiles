vim9script

import autoload "kg8m/util/string.vim" as stringUtil

# Sort items by their each priority and filter them that fuzzy match.
# Omit items with lower priority.
# Remove characters overlapping with following text.
export def Callback(options: dict<any>, matches: dict<any>): void
  const base_matcher = matchstr(options.base, b:asyncomplete_refresh_pattern)

  var items     = []
  var startcols = []

  if !empty(base_matcher)
    final context = {
      matcher: base_matcher,
      priority: 0,
      following_text: strpart(getline("."), options.col - 1),
      cache: {},
    }

    for [source_name, source_matches] in items(matches)
      var original_length = len(items)

      # Language server sources have no priority
      context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

      items += matchfuzzy(
        source_matches.items, context.matcher,
        { text_cb: (item) => MatchfuzzyTextCb(item, context) },
      )

      if len(items) !=# original_length
        startcols += [source_matches.startcol]
      endif
    endfor

    if !empty(items)
      SelectItems(items)
      DecorateItems(items, context)
    endif
  endif

  # https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
  options.startcol = min(startcols)

  asyncomplete#preprocess_complete(options, items)
enddef

def MatchfuzzyTextCb(item: dict<any>, context: dict<any>): string
  if !has_key(item, "priority")
    item.priority = WordPriority(item.word, context)
  endif

  return item.word
enddef

def SortItems(items: list<dict<any>>): void
  sort(items, (lhs, rhs) => lhs.priority - rhs.priority)
enddef

def SelectItems(items: list<dict<any>>): void
  SortItems(items)

  if len(items) ># 30
    remove(items, 30, -1)
  endif
enddef

def DecorateItems(items: list<dict<any>>, context: dict<any>): void
  var priority_changed = false

  for item in items
    if !has_key(item, "overlap_removed")
      # :h complete-items
      # item.word: the text that will be inserted, mandatory
      # item.abbr: abbreviation of "word"; when not empty it is used in the menu instead of "word"
      item.abbr = item.word
      item.word = RemoveOverlapWithFollowingText(item.word, context.following_text)

      # The item may have higher score when overlap has been removed.
      if item.word !=# item.abbr
        item.priority = item.priority / 2
        priority_changed = true
      endif

      item.overlap_removed = true
    endif
  endfor

  if priority_changed
    SortItems(items)
  endif
enddef

def RemoveOverlapWithFollowingText(original_text: string, following_text: string): string
  const max_index = len(original_text) - 1
  var i = 0

  while i <=# max_index
    const tail = strpart(original_text, i)

    if stringUtil.StartsWith(following_text, tail)
      return strpart(original_text, 0, i)
    endif

    i += 1
  endwhile

  return original_text
enddef

def WordPriority(word: string, context: dict<any>): number
  if !has_key(context.cache, word)
    const target = matchstr(word, '\v\w+.*')
    const lower_target  = tolower(target)
    const lower_matcher = tolower(context.matcher)

    if target ==# context.matcher
      # Ignore candidates exactly matched
      context.cache[word] = 999
    elseif lower_target ==# lower_matcher
      context.cache[word] = 2
    elseif stringUtil.StartsWith(target, context.matcher)
      context.cache[word] = 3
    elseif stringUtil.StartsWith(lower_target, lower_matcher)
      context.cache[word] = 5
    elseif stringUtil.Includes(target, context.matcher)
      context.cache[word] = 8
    elseif stringUtil.Includes(lower_target, lower_matcher)
      context.cache[word] = 13
    else
      context.cache[word] = 21
    endif
  endif

  return context.cache[word] * context.priority
enddef
