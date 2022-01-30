vim9script

def kg8m#plugin#startify#configure(): void
  if argc() ># 0
    # `on_event: "BufWritePre"` for `s:save_session`: Load startify before writing buffer (on `BufWritePre`) and
    # register autocmd for `BufWritePost`
    kg8m#plugin#configure({
      lazy:     true,
      on_cmd:   "Startify",
      on_event: "BufWritePre",
      hook_source:      () => s:on_source(),
      hook_post_source: () => s:on_post_source(),
    })
  else
    s:setup()
  endif
enddef

def s:setup(): void
  set sessionoptions=buffers,folds

  g:startify_session_autoload    = false
  g:startify_session_dir         = getcwd() .. "/.vim-sessions"
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
    { p: "call kg8m#plugin#update#run()" },
    { P: "call kg8m#plugin#update#run(#{ bulk: v:false })" },
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
    autocmd ColorScheme  *    s:overwrite_colors()
    autocmd BufWritePost *    s:save_session()
    autocmd VimLeavePre  *    s:delete_last_session_link()
  augroup END
enddef

def s:overwrite_colors(): void
  highlight StartifyFile   guifg=#FFFFFF
  highlight StartifyHeader guifg=#FFFFFF
  highlight StartifyPath   guifg=#777777
  highlight StartifySlash  guifg=#777777
enddef

def s:save_session(): void
  if s:session_savable()
    kg8m#configure#folding#manual#restore()
    mkdir(g:startify_session_dir, "p")
    execute "silent SSave! " .. s:session_name()
  endif
enddef

def s:session_savable(): bool
  if &filetype ==# ""
    const filename = expand("%:t")

    if kg8m#util#string#starts_with(filename, "mmv-")
      return false
    else
      return true
    endif
  else
    return true
  endif
enddef

def s:session_name(): string
  return "%:p"
    ->expand()
    ->substitute("/", "+=", "g")
    ->substitute('^\.', "_", "")
enddef

def s:delete_last_session_link(): void
  const filepath = printf("%s/__LAST__", g:startify_session_dir)

  # Don't use `filereadable(filepath)` because it returns FALSE if the symlink is broken.
  if !empty(glob(filepath, false, false, true))
    delete(filepath)
  endif
enddef

def s:on_source(): void
  s:setup()
enddef

def s:on_post_source(): void
  s:overwrite_colors()
enddef
