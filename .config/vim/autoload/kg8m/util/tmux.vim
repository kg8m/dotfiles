vim9script

const PANE_SIZE = 30
const INVALID_PANE_INDEX = -1

augroup vimrc-util-tmux
  autocmd!
  autocmd VimLeavePre * Teardown()
augroup END

export def ExecuteCommand(command: string): void
  const pane_indexes = GetPaneIndexes()

  if pane_indexes.next ==# INVALID_PANE_INDEX
    CreatePane()
    SendToTmux(command, GetPaneIndexes().next)
  else
    SendToTmux(command, pane_indexes.next)
  endif
enddef

def GetPaneIndexes(): dict<number>
  const panes_info = system("tmux list-panes -F '#{pane_active}:#{pane_top}:#{pane_left}:#{pane_bottom}'")->split("\n")

  final result = { active: INVALID_PANE_INDEX, next: INVALID_PANE_INDEX }
  var i = 0

  for pane_info in panes_info
    const [current_active, _, current_left, current_bottom] = split(pane_info, ":")

    if current_active ==# "1"
      result.active = i
      const next_pane_info = get(panes_info, i + 1, null)

      if next_pane_info !=# null
        const [_, next_top, next_left, _] = split(next_pane_info, ":")

        if next_left ==# current_left && str2nr(next_top) ># str2nr(current_bottom)
          result.next = i + 1
        endif
      endif

      break
    endif

    i += 1
  endfor

  return result
enddef

def CreatePane(): void
  const pane_indexes = GetPaneIndexes()

  system($"tmux split-window -v -l {PANE_SIZE}")
  system($"tmux select-pane -t {pane_indexes.active}")
enddef

def SendToTmux(command: string, pane_index: number): void
  system($"tmux send-keys -t {pane_index} {shellescape(command)} Enter")
enddef

def Teardown(): void
  const pane_indexes = GetPaneIndexes()

  if pane_indexes.next !=# INVALID_PANE_INDEX
    system($"tmux kill-pane -t {pane_indexes.next}")
  endif
enddef
