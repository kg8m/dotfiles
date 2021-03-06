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
    "  LSPs: ",
  ]

  for server_name in kg8m#plugin#lsp#servers#candidate_names()->copy()->sort()
    const is_available = kg8m#plugin#lsp#servers#is_available(server_name)
    g:startify_custom_header += [
      "  " .. (is_available ? "👼 " : "😈 ") .. server_name,
    ]
  endfor

  g:startify_custom_header += [""]

  augroup my_vimrc
    autocmd FileType startify setlocal cursorline cursorlineopt=both
    autocmd ColorScheme  *    s:overwrite_colors()
    autocmd BufWritePost *    s:save_session()
  augroup END
enddef

def s:overwrite_colors(): void
  highlight StartifyFile   guifg=#FFFFFF
  highlight StartifyHeader guifg=#FFFFFF
  highlight StartifyPath   guifg=#777777
  highlight StartifySlash  guifg=#777777
enddef

def s:save_session(): void
  kg8m#configure#folding#manual#restore()
  mkdir(g:startify_session_dir, "p")
  execute "silent SSave! " .. s:session_name()
enddef

def s:session_name(): string
  return "%"
    ->expand()
    ->fnamemodify(":p")
    ->substitute("/", "+=", "g")
    ->substitute('^\.', "_", "")
enddef

def s:on_source(): void
  s:setup()
enddef

def s:on_post_source(): void
  s:overwrite_colors()
enddef
