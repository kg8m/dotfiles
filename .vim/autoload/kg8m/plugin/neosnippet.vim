vim9script

const s:script_filepath = expand("<sfile>")

var s:snippets_dirpath: string

def kg8m#plugin#neosnippet#configure(): void
  # `on_ft` for Syntaxes
  kg8m#plugin#configure({
    lazy:     true,
    on_ft:    ["snippet", "neosnippet"],
    on_i:     true,
    on_start: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def kg8m#plugin#neosnippet#snippets_dirpath(): string
  if empty(s:snippets_dirpath)
    s:snippets_dirpath = fnamemodify(s:script_filepath, ":h:h:h:h") .. "/snippets"
  endif

  return s:snippets_dirpath
enddef

def s:on_source(): void
  kg8m#plugin#completion#define_mappings()

  g:neosnippet#snippets_directory = [kg8m#plugin#neosnippet#snippets_dirpath()]
  g:neosnippet#disable_runtime_snippets = { _: true }

  augroup my_vimrc
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END

  kg8m#plugin#neosnippet#contextual#setup()
enddef

def s:on_post_source(): void
  timer_start(0, (_) => kg8m#plugin#neosnippet#contextual#source())
enddef
