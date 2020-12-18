vim9script

def kg8m#plugin#asyncomplete#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy: v:true,
    on_i: v:true,
    hook_source:      function("s:on_source"),
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

def s:priority_sorted_fuzzy_filter(options: dict<any>, matches: dict<any>): void  # {{{
  const filetype      = kg8m#plugin#lsp#is_target_buffer() && kg8m#plugin#lsp#is_buffer_enabled() ? &filetype : "_"
  const match_pattern = kg8m#plugin#completion#refresh_pattern(filetype)
  const base_matcher  = matchstr(options.base, match_pattern)

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
        { text_cb: { item -> s:matchfuzzy_text_cb(item, sorter_context) } }
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
enddef  # }}}

def s:matchfuzzy_text_cb(item: dict<any>, sorter_context: dict<any>): string  # {{{
  item.priority = s:item_priority(item, sorter_context)
  return item.word
enddef  # }}}

def s:item_priority(item: dict<any>, context: dict<any>): number  # {{{
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
enddef  # }}}

def s:sorter(lhs: dict<any>, rhs: dict<any>): number  # {{{
  return lhs.priority - rhs.priority
enddef  # }}}

def s:on_source(): void  # {{{
  g:asyncomplete_auto_popup = v:true
  g:asyncomplete_popup_delay = 50
  g:asyncomplete_auto_completeopt = v:false
  g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  # Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  g:asyncomplete_preprocessor = [function("s:priority_sorted_fuzzy_filter")]

  augroup my_vimrc  # {{{
    autocmd BufWinEnter,FileType * kg8m#plugin#completion#set_refresh_pattern()
  augroup END  # }}}
enddef  # }}}

def s:on_post_source(): void  # {{{
  timer_start(0, { -> kg8m#plugin#completion#define_refresh_mappings() })

  if get(b:, "asyncomplete_enable", v:true)
    asyncomplete#enable_for_buffer()
  endif
enddef  # }}}
