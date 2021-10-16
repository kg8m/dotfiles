vim9script

# Sort items by their each priority and filter them that fuzzy match.
# Omit items with lower priority.
# Remove characters overlapping with following text.
def kg8m#plugin#asyncomplete#preprocessor#callback(options: dict<any>, matches: dict<any>): void
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
        { text_cb: (item) => s:matchfuzzy_text_cb(item, context) },
      )

      if len(items) !=# original_length
        startcols += [source_matches.startcol]
      endif
    endfor

    s:select_items(items)
    s:decorate_items(items, context)
  endif

  # https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
  options.startcol = min(startcols)

  asyncomplete#preprocess_complete(options, items)
enddef

def s:matchfuzzy_text_cb(item: dict<any>, context: dict<any>): string
  item.priority = s:word_priority(item.word, context)
  return item.word
enddef

def s:sort_items(items: list<dict<any>>): void
  sort(items, (lhs, rhs) => lhs.priority - rhs.priority)
enddef

def s:select_items(items: list<dict<any>>): void
  s:sort_items(items)

  if len(items) ># 30
    remove(items, 30, -1)
  endif
enddef

def s:decorate_items(items: list<dict<any>>, context: dict<any>): void
  for item in items
    if !has_key(item, "overlap_removed")
      # :h complete-items
      # item.word: the text that will be inserted, mandatory
      # item.abbr: abbreviation of "word"; when not empty it is used in the menu instead of "word"
      item.abbr = item.word
      item.word = s:remove_overlap_with_following_text(item.word, context.following_text)

      item.overlap_removed = true
    endif
  endfor
enddef

def s:remove_overlap_with_following_text(original_text: string, following_text: string): string
  const max_index = len(original_text) - 1
  var i = 0

  while i <=# max_index
    const tail = strpart(original_text, i)

    if kg8m#util#string#starts_with(following_text, tail)
      return strpart(original_text, 0, i)
    endif

    i += 1
  endwhile

  return original_text
enddef

def s:word_priority(word: string, context: dict<any>): number
  if !has_key(context.cache, word)
    const target = matchstr(word, '\v\w+.*')
    const lower_target  = tolower(target)
    const lower_matcher = tolower(context.matcher)

    if target ==# context.matcher
      # Ignore candidates exactly matched
      context.cache[word] = 999
    elseif lower_target ==# lower_matcher
      context.cache[word] = 2
    elseif kg8m#util#string#starts_with(target, context.matcher)
      context.cache[word] = 3
    elseif kg8m#util#string#starts_with(lower_target, lower_matcher)
      context.cache[word] = 5
    elseif kg8m#util#string#includes(target, context.matcher)
      context.cache[word] = 8
    elseif kg8m#util#string#includes(lower_target, lower_matcher)
      context.cache[word] = 13
    else
      context.cache[word] = 21
    endif
  endif

  return context.cache[word] * context.priority
enddef
