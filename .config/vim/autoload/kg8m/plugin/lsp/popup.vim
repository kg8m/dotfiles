vim9script

import autoload "kg8m/util/logger.vim"

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

final cache = {
  sid: expand("<SID>"),
  original_handle_signature_help: (..._) => {
    logger.Warn("Overwrite this with original function.")
  },
}

export def Setup(): void
  augroup vimrc-plugin-lsp-popup
    autocmd!
    autocmd User lsp_float_opened OnFloatOpened()
    autocmd CompleteChanged * OnCompleteChanged()
  augroup END
enddef

def OnFloatOpened(): void
  FixBorders()
enddef

# Close popups on `CompleteChanged` because `lsp_float_opened` user event is not triggered if popups already exist.
def OnCompleteChanged(): void
  Close()
enddef

def FixBorders(): void
  WithBorderchars((winid, borderchars) => {
    if empty(borderchars) || borderchars ==# ASCII_BORDERCHARS
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

def OriginalHandleSignatureHelp(server: any, data: any): void
  cache.original_handle_signature_help(server, data)
enddef

def OverwriteHandleSignatureHelp(): void
  try
    # Call a dummy function which doesn't exist in order to load target script.
    lsp#ui#vim#signature_help#dummy()
  catch /^Vim:E117: Unknown function:/
    # Do nothing
  endtry

  const scripts = getscriptinfo({ name: "vim-lsp/autoload/lsp/ui/vim/signature_help.vim" })

  if empty(scripts)
    logger.Warn("Failed to detect vim-lsp's signature_help.vim script.")
  else
    const lsp_signature_help_sid = scripts[0].sid
    const function_name = $"<SNR>{lsp_signature_help_sid}_handle_signature_help"
    const new_definition_template =<< trim eval VIM
      function {function_name}(server, data) abort
        call {cache.sid}OriginalHandleSignatureHelp(a:server, a:data)
        doautocmd <nomodeline> User lsp_float_opened
      endfunction
    VIM
    const new_definition = new_definition_template->join("\n")

    cache.original_handle_signature_help = funcref(function_name)

    execute "delfunction" function_name
    execute new_definition
  endif
enddef
OverwriteHandleSignatureHelp()
