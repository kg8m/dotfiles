vim9script

export def Configure(): void
  if argc() ># 0
    # `on_event: "BufWritePre"` for `SaveSession()`: Load startify before writing buffer (on `BufWritePre`) and
    # register autocmd for `BufWritePost`
    kg8m#plugin#Configure({
      lazy:     true,
      on_cmd:   "Startify",
      on_event: "BufWritePre",
      hook_source:      () => OnSource(),
      hook_post_source: () => OnPostSource(),
    })
  else
    Setup()
  endif
enddef

def Setup(): void
  set sessionoptions=buffers,folds

  g:startify_session_autoload    = false
  g:startify_session_dir         = SessionsDirpath()
  g:startify_session_number      = 10
  g:startify_session_persistence = false
  g:startify_session_sort        = true

  g:startify_enable_special = true
  g:startify_change_to_dir  = false
  g:startify_relative_path  = true
  g:startify_lists          = [
    { type: "commands",  header: ["My commands:"] },
    { type: "bookmarks", header: ["My bookmarks:"] },
    { type: "sessions",  header: ["My sessions:"] },
    { type: "files",     header: ["Recently opened files:"] },
    { type: "dir",       header: ["Recently modified files in the current directory:"] },
  ]
  g:startify_commands = [
    { p: "call kg8m#plugin#update#Run()" },
    { P: "call kg8m#plugin#update#Run(#{ bulk: v:false })" },
  ]

  # https://gist.github.com/SammysHP/5611986#file-gistfile1-txt
  g:startify_custom_header = [
    "                      .",
    "      ##############..... ##############",
    "      ##############......##############",
    "        ##########..........##########",
    "        ##########........##########",
    "        ##########.......##########",
    "        ##########.....##########..",
    "        ##########....##########.....",
    "      ..##########..##########.........",
    "    ....##########.#########.............",
    "      ..################JJJ............",
    "        ################.............",
    "        ##############.JJJ.JJJJJJJJJJ",
    "        ############...JJ...JJ..JJ  JJ",
    "        ##########....JJ...JJ..JJ  JJ",
    "        ########......JJJ..JJJ JJJ JJJ",
    "        ######    .........",
    "                    .....",
    "                      .",
  ]

  g:startify_custom_header += [
    "",
    "",
    "  Vim version: " .. v:versionlong,
    "",
  ]

  augroup vimrc-plugin-startify
    autocmd!
    autocmd FileType startify setlocal cursorline cursorlineopt=both
    autocmd ColorScheme  *    OverwriteColors()
    autocmd BufWritePost *    SaveSession()
    autocmd VimLeavePre  *    DeleteLastSessionLink()
  augroup END
enddef

def OverwriteColors(): void
  highlight StartifyFile   guifg=#FFFFFF
  highlight StartifyHeader guifg=#FFFFFF
  highlight StartifyPath   guifg=#777777
  highlight StartifySlash  guifg=#777777
enddef

def SessionsDirpath(): string
  const dirname = getcwd()->substitute("/", "=+", "g")
  return $"{$XDG_DATA_HOME}/vim/sessions/{dirname}"
enddef

def SaveSession(): void
  kg8m#configure#folding#manual#Restore()

  if SessionSavable()
    mkdir(g:startify_session_dir, "p")
    execute "silent SSave!" SessionName()
  endif
enddef

def SessionSavable(): bool
  if &filetype ==# ""
    const filename = expand("%:t")

    if kg8m#util#string#StartsWith(filename, "mmv-")
      return false
    else
      return true
    endif
  else
    return true
  endif
enddef

def SessionName(): string
  # Use a prefix for names starting with a dot (.), that is hidden from Startify session files list.
  const prefix = "session:"

  const body = kg8m#util#file#CurrentRelativePath()->substitute("/", "+=", "g")

  return $"{prefix}{body}"
enddef

def DeleteLastSessionLink(): void
  const filepath = $"{g:startify_session_dir}/__LAST__"

  # Don't use `filereadable(filepath)` because it returns FALSE if the symlink is broken.
  if !empty(glob(filepath, false, false, true))
    delete(filepath)
  endif
enddef

def OnSource(): void
  Setup()
enddef

def OnPostSource(): void
  OverwriteColors()
enddef
