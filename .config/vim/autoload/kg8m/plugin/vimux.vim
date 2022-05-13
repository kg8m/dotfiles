vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy: true,
    hook_source: () => OnSource(),
  })
enddef

export def RunCommand(command: string): void
  kg8m#plugin#EnsureSourced("vimux")

  CalculateRunnerIndex()
  execute "VimuxRunCommand" shellescape(command)
enddef

# Always use current pane's next one.
def CalculateRunnerIndex(): void
  if has_key(g:, "VimuxRunnerIndex")
    # Reset every time because panes sometimes change
    unlet g:VimuxRunnerIndex
  endif

  const views = split(system("tmux list-panes -F '#{pane_active}:#{pane_id}'"), "\\n")
  const views_length = len(views)

  var index = views_length - 1

  while index >= 0
    const view = views[index]

    # `pane_active` is `1` if the pane is active
    if kg8m#util#string#StartsWith(view, "1")
      if index !=# views_length - 1
        g:VimuxRunnerIndex = split(views[index + 1], ":")[1]
      endif

      return
    endif

    index -= 1
  endwhile
enddef

def OnSource(): void
  g:VimuxHeight      = 30
  g:VimuxOrientation = "v"
  g:VimuxUseNearest  = false

  augroup vimrc-plugin-vimux
    autocmd!
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END
enddef
