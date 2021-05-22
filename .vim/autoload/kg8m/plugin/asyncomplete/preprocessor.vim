vim9script

# Sort items by their each priority and filter them that fuzzy match
def kg8m#plugin#asyncomplete#preprocessor#callback(options: dict<any>, matches: dict<any>): void
  const base_matcher = matchstr(options.base, b:asyncomplete_refresh_pattern)

  var items     = []
  var startcols = []

  if !empty(base_matcher)
    final context = {
      matcher:  base_matcher,
      priority: 0,
      cache:    {},
    }

    for [source_name, source_matches] in items(matches)
      var original_length = len(items)

      # Language server sources have no priority
      context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

      items += matchfuzzy(source_matches.items, context.matcher, { key: "word" })

      if len(items) !=# original_length
        startcols += [source_matches.startcol]
      endif
    endfor

    for item in items
      s:decorate_item(item, context)
    endfor

    sort(items, "s:sorter")
  endif

  # https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
  options.startcol = min(startcols)

  asyncomplete#preprocess_complete(options, items)
enddef

def s:decorate_item(item: dict<any>, context: dict<any>): void
  item.priority = s:word_priority(item.word, context)
enddef

def s:word_priority(word: string, context: dict<any>): number
  if !has_key(context.cache, word)
    const target = matchstr(word, '\v\w+.*')
    const lower_target  = tolower(target)
    const lower_matcher = tolower(context.matcher)

    if kg8m#util#string#starts_with(target, context.matcher)
      context.cache[word] = 2
    elseif kg8m#util#string#starts_with(lower_target, lower_matcher)
      context.cache[word] = 3
    elseif kg8m#util#string#includes(target, context.matcher)
      context.cache[word] = 5
    elseif kg8m#util#string#includes(lower_target, lower_matcher)
      context.cache[word] = 8
    else
      context.cache[word] = 13
    endif
  endif

  return context.cache[word] * context.priority
enddef

# The result of `matchfuzzy()` is used if each priority is same
def s:sorter(lhs: dict<any>, rhs: dict<any>): number
  return lhs.priority - rhs.priority
enddef
