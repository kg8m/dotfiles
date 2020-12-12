function kg8m#plugin#jpformat#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: ["gq"],
  \   hook_source: function("s:on_source"),
  \ })
endfunction  " }}}

function s:set_formatexpr() abort  " {{{
  if has_key(b:, "jpformat_formatexpr_set")
    return
  endif

  if &l:formatexpr !=# s:formatexpr
    " Replace built-in `jq` operator
    let &l:formatexpr = s:formatexpr
  endif

  let b:jpformat_formatexpr_set = v:true
endfunction  " }}}

function s:on_source() abort  " {{{
  let s:formatexpr = "jpfmt#formatexpr()"
  call s:set_formatexpr()

  let JpFormatCursorMovedI = v:false
  let JpAutoJoin = v:false
  let JpAutoFormat = v:false

  augroup my_vimrc  " {{{
    " Overwrite formatexpr
    autocmd OptionSet formatexpr call timer_start(200, { -> s:set_formatexpr() })
  augroup END  " }}}
endfunction  " }}}
