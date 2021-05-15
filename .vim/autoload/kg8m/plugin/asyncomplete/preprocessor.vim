vim9script

# Sort items by their each priority and filter them that fuzzy match
def kg8m#plugin#asyncomplete#preprocessor#callback(options: dict<any>, matches: dict<any>): void
  const base_matcher = matchstr(options.base, b:asyncomplete_refresh_pattern)

  var items     = []
  var startcols = []

  if !empty(base_matcher)
    final sorter_context = {
      matcher:  base_matcher,
      priority: 0,
      cache:    {},
    }

    for [source_name, source_matches] in items(matches)
      var original_length = len(items)

      # Language server sources have no priority
      sorter_context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

      items += matchfuzzy(
        source_matches.items, sorter_context.matcher,
        { text_cb: (item) => s:matchfuzzy_text_cb(item, sorter_context) }
      )

      if len(items) !=# original_length
        startcols += [source_matches.startcol]
      endif
    endfor

    sort(items, "s:sorter")
  endif

  # https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
  options.startcol = min(startcols)

  asyncomplete#preprocess_complete(options, items)
enddef

def s:matchfuzzy_text_cb(item: dict<any>, sorter_context: dict<any>): string
  item.priority = s:item_priority(item, sorter_context)
  return item.word
enddef

def s:item_priority(item: dict<any>, context: dict<any>): number
  const word = item.word

  if !has_key(context.cache, word)
    const target = matchstr(item.word, '\v\w+.*')

    if target =~# "^" .. context.matcher
      extend(context.cache, { [word]: 2 })
    elseif target =~? "^" .. context.matcher
      extend(context.cache, { [word]: 3 })
    elseif target =~# context.matcher
      extend(context.cache, { [word]: 5 })
    elseif target =~? context.matcher
      extend(context.cache, { [word]: 8 })
    else
      extend(context.cache, { [word]: 13 })
    endif
  endif

  return context.cache[word] * context.priority
enddef

def s:sorter(lhs: dict<any>, rhs: dict<any>): number
  return lhs.priority - rhs.priority
enddef
