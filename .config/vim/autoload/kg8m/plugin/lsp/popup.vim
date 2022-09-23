vim9script

# TODO: Create pull requests to vim-lsp.
#   - Add functions to get a float window for completion documentation and diagnostics float such as
#     `lsp#document_hover_preview_winid()`
#   - Trigger `lsp_float_opened` user event even if a float window is moved, or add another event like
#     `lsp_float_changed`
#   - Add an option to hide diagnostics float while Insert mode

const ASCII_BORDERCHARS   = ["-", "|", "-", "|", "+", "+", "+", "+"]
const UNICODE_BORDERCHARS = ["─", "│", "─", "│", "┌", "┐", "┘", "└"]

const FIXED_OPTIONS = {
  borderchars: UNICODE_BORDERCHARS,
  padding: [0, 1, 0, 1],
}

export def Setup(): void
  augroup vimrc-plugin-lsp-popup
    autocmd!
    autocmd User lsp_float_opened OnFloatOpened()

    autocmd CompleteChanged * OnCompleteChanged()
    autocmd InsertEnter     * OnInsertEnter()
  augroup END
enddef

def OnFloatOpened(): void
  FixBorders()
enddef

# Close popups on `CompleteChanged` because `lsp_float_opened` user event is not triggered if popups already exist.
def OnCompleteChanged(): void
  Close()
enddef

# Close popups on `InsertEnter` because I don't want to see them while editing.
def OnInsertEnter(): void
  Close()
enddef

def FixBorders(): void
  WithBorderchars((winid, borderchars) => {
    if borderchars ==# ASCII_BORDERCHARS
      popup_setoptions(winid, FIXED_OPTIONS)
    endif
  })
enddef

def Close(): void
  WithBorderchars((winid, borderchars) => {
    if borderchars ==# UNICODE_BORDERCHARS
      popup_close(winid)
    endif
  })
enddef

def WithBorderchars(Callback: func): void
  for winid in popup_list()
    const popup_options = popup_getoptions(winid)
    const borderchars   = get(popup_options, "borderchars", [])

    Callback(winid, borderchars)
  endfor
enddef
