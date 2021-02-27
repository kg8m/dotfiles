vim9script

def kg8m#plugin#vimux#configure(): void
  kg8m#plugin#configure({
    lazy: true,
    hook_source: () => s:on_source(),
  })
enddef

# Wrap vimux's `VimuxRunCommand` because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
def kg8m#plugin#vimux#run_command(command: string): void
  if !kg8m#plugin#is_sourced("vimux")
    kg8m#plugin#source("vimux")
  endif

  s:calculate_runner_index()
  execute "VimuxRunCommand " .. string(command)
enddef

# Always use current pane's next one.
def s:calculate_runner_index(): void
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
    if kg8m#util#string#starts_with(view, "1")
      if index !=# views_length - 1
        g:VimuxRunnerIndex = split(views[index + 1], ":")[1]
      endif

      return
    endif

    index -= 1
  endwhile
enddef

def s:on_source(): void
  g:VimuxHeight      = 30
  g:VimuxOrientation = "v"
  g:VimuxUseNearest  = false

  augroup my_vimrc
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END
enddef
