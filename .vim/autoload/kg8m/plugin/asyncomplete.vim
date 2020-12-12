function kg8m#plugin#asyncomplete#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy: v:true,
  \   on_i: v:true,
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:priority_sorted_fuzzy_filter(options, matches) abort  " {{{
  let filetype      = kg8m#plugin#lsp#is_target_buffer() && kg8m#plugin#lsp#is_buffer_enabled() ? &filetype : "_"
  let match_pattern = kg8m#plugin#completion#refresh_pattern(filetype)
  let base_matcher  = matchstr(a:options.base, match_pattern)

  let items     = []
  let startcols = []

  if !empty(base_matcher)
    let sorter_context = #{
    \   matcher:  base_matcher,
    \   priority: 0,
    \   cache:    {},
    \ }

    for [source_name, source_matches] in items(a:matches)
      let original_length = len(items)

      " Language server sources have no priority
      let sorter_context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

      let items += matchfuzzy(
      \   source_matches.items, sorter_context.matcher,
      \   #{ text_cb: { item -> s:matchfuzzy_text_cb(item, sorter_context) } }
      \ )

      if len(items) !=# original_length
        let startcols += [source_matches.startcol]
      endif
    endfor

    call sort(items, function("s:sorter"))
  endif

  " https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
  let a:options["startcol"] = min(startcols)

  call asyncomplete#preprocess_complete(a:options, items)
endfunction  " }}}

function s:matchfuzzy_text_cb(item, sorter_context) abort  " {{{
  let a:item.priority = s:item_priority(a:item, a:sorter_context)
  return a:item.word
endfunction  " }}}

function s:item_priority(item, context) abort  " {{{
  let word = a:item.word

  if !has_key(a:context.cache, word)
    let target = matchstr(word, '\v\w+.*')

    if target =~# "^"..a:context.matcher
      let a:context.cache[word] = 2
    elseif target =~? "^"..a:context.matcher
      let a:context.cache[word] = 3
    elseif target =~# a:context.matcher
      let a:context.cache[word] = 5
    elseif target =~? a:context.matcher
      let a:context.cache[word] = 8
    else
      let a:context.cache[word] = 13
    endif
  endif

  return a:context.cache[word] * a:context.priority
endfunction  " }}}

function s:sorter(lhs, rhs) abort  " {{{
  return a:lhs.priority - a:rhs.priority
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:asyncomplete_auto_popup = v:true
  let g:asyncomplete_popup_delay = 50
  let g:asyncomplete_auto_completeopt = v:false
  let g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  " Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  let g:asyncomplete_preprocessor = [function("s:priority_sorted_fuzzy_filter")]

  augroup my_vimrc  " {{{
    autocmd BufWinEnter,FileType * call kg8m#plugin#completion#set_refresh_pattern()
  augroup END  " }}}
endfunction  " }}}

function s:on_post_source() abort  " {{{
  call timer_start(0, { -> kg8m#plugin#completion#define_refresh_mappings() })

  if get(b:, "asyncomplete_enable", v:true)
    call asyncomplete#enable_for_buffer()
  endif
endfunction  " }}}
