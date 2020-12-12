function kg8m#plugin#vimux#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_cmd:  "VimuxCloseRunner",
  \   on_func: "VimuxRunCommand",
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:VimuxHeight     = 30
  let g:VimuxUseNearest = v:true

  augroup my_vimrc  " {{{
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END  " }}}
endfunction  " }}}

function s:on_post_source() abort  " {{{
  " Overwrite function: Always use current pane's next one
  " https://github.com/benmills/vimux/blob/37f41195e6369ac602a08ec61364906600b771f1/plugin/vimux.vim#L173-L183
  function! _VimuxNearestIndex() abort
    let views = split(_VimuxTmux("list-".._VimuxRunnerType().."s"), "\n")
    let index = len(views) - 1

    while index >= 0
      let view = views[index]

      if match(view, "(active)") != -1
        if index ==# len(views) - 1
          return -1
        else
          return split(views[index + 1], ":")[0]
        endif
      endif

      let index = index - 1
    endwhile
  endfunction
endfunction  " }}}
