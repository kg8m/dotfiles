vim9script

const s:formatexpr = "jpfmt#formatexpr()"

def kg8m#plugin#jpformat#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:   true,
    on_map: ["gq"],
    hook_source: function("s:on_source"),
  })
enddef  # }}}

def s:set_formatexpr(): void  # {{{
  if has_key(b:, "jpformat_formatexpr_set")
    return
  endif

  if &l:formatexpr !=# s:formatexpr
    # Replace built-in `jq` operator
    &l:formatexpr = s:formatexpr
  endif

  b:jpformat_formatexpr_set = true
enddef  # }}}

def s:on_source(): void  # {{{
  s:set_formatexpr()

  g:JpFormatCursorMovedI = false
  g:JpAutoJoin = false
  g:JpAutoFormat = false

  augroup my_vimrc  # {{{
    # Overwrite formatexpr
    autocmd OptionSet formatexpr timer_start(200, { -> s:set_formatexpr() })
  augroup END  # }}}
enddef  # }}}
