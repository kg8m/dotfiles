vim9script

import autoload "kg8m/events.vim"
import autoload "kg8m/plugin/neosnippet/contextual.vim"

const script_filepath = expand("<sfile>")

var snippets_dirpath: string

export def OnSource(): void
  g:neosnippet#snippets_directory = [SnippetsDirpath()]
  g:neosnippet#disable_runtime_snippets = { _: true }

  augroup vimrc-plugin-neosnippet
    autocmd!
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END

  contextual.Setup()
enddef

export def OnPostSource(): void
  timer_start(0, (_) => events.NotifyInsertModePluginLoaded())
  timer_start(0, (_) => contextual.Source())
enddef

export def SnippetsDirpath(): string
  if empty(snippets_dirpath)
    snippets_dirpath = fnamemodify(script_filepath, ":h:h:h:h") .. "/snippets"
  endif

  return snippets_dirpath
enddef
