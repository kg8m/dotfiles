vim9script

const script_filepath = expand("<sfile>")

var snippets_dirpath: string

export def Configure(): void
  # `on_ft` for Syntaxes
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_ft:    ["snippet", "neosnippet"],
    on_start: true,
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

export def SnippetsDirpath(): string
  if empty(snippets_dirpath)
    snippets_dirpath = fnamemodify(script_filepath, ":h:h:h:h") .. "/snippets"
  endif

  return snippets_dirpath
enddef

def OnSource(): void
  g:neosnippet#snippets_directory = [kg8m#plugin#neosnippet#SnippetsDirpath()]
  g:neosnippet#disable_runtime_snippets = { _: true }

  augroup vimrc-plugin-neosnippet
    autocmd!
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END

  kg8m#plugin#neosnippet#contextual#Setup()
enddef

def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
  timer_start(0, (_) => kg8m#plugin#neosnippet#contextual#Source())
enddef
