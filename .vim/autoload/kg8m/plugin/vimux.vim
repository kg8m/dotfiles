vim9script

def kg8m#plugin#vimux#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:    true,
    on_cmd:  "VimuxCloseRunner",
    on_func: "VimuxRunCommand",
    hook_source:      function("s:on_source"),
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

# Wrap vimux's `VimuxRunCommand` because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
def kg8m#plugin#vimux#run_command(command: string): void  # {{{
  if !kg8m#plugin#is_sourced("vimux")
    kg8m#plugin#source("vimux")
  endif

  execute "VimuxRunCommand " .. string(command)
enddef  # }}}

def s:on_source(): void  # {{{
  g:VimuxHeight     = 30
  g:VimuxUseNearest = true

  augroup my_vimrc  # {{{
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END  # }}}
enddef  # }}}

def s:on_post_source(): void  # {{{
  # Overwrite function: Always use current pane's next one.
  # https://github.com/benmills/vimux/blob/37f41195e6369ac602a08ec61364906600b771f1/plugin/vimux.vim#L173-L183
  # Use `delfunction` because `def! _VimuxNearestIndex()` produces "E1117: Cannot use ! with nested :def".
  # Use `execute` because "E117: Unknown function: _VimuxNearestIndex" occurs without `execute`.
  const overwrite =<< trim VIM
    delfunction _VimuxNearestIndex
    def _VimuxNearestIndex(): number
      const views = split(_VimuxTmux("list-" .. _VimuxRunnerType() .. "s"), "\\n")
      var index = len(views) - 1

      while index >= 0
        const view = views[index]

        if match(view, "(active)") != -1
          if index ==# len(views) - 1
            return -1
          else
            return str2nr(split(views[index + 1], ":")[0])
          endif
        endif

        index -= 1
      endwhile

      return -1
    enddef
  VIM
  execute join(overwrite, "\n")
enddef  # }}}
