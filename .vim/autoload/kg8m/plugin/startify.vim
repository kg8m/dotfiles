function kg8m#plugin#startify#configure() abort  " {{{
  if argc()
    call kg8m#plugin#configure(#{
    \   lazy:   v:true,
    \   on_cmd: "Startify",
    \   hook_source:      function("s:on_source"),
    \   hook_post_source: function("s:on_post_source"),
    \ })
  else
    call s:setup()
  endif
endfunction  " }}}

function s:setup() abort  " {{{
  set sessionoptions=buffers,folds

  let g:startify_session_dir         = g:session_directory
  let g:startify_session_number      = 10
  let g:startify_session_persistence = v:false
  let g:startify_session_sort        = v:true

  let g:startify_enable_special = v:true
  let g:startify_change_to_dir  = v:false
  let g:startify_relative_path  = v:true
  let g:startify_lists          = [
  \   #{ type: "commands",  header: ["My commands:"] },
  \   #{ type: "bookmarks", header: ["My bookmarks:"] },
  \   #{ type: "sessions",  header: ["My sessions:"] },
  \   #{ type: "files",     header: ["Recently opened files:"] },
  \   #{ type: "dir",       header: ["Recently modified files in the current directory:"] },
  \ ]
  let g:startify_commands = [
  \   #{ p: "call kg8m#plugin#update_all()" },
  \   #{ P: "call kg8m#plugin#update_all(#{ bulk: v:false })" },
  \ ]

  " https://gist.github.com/SammysHP/5611986#file-gistfile1-txt
  let g:startify_custom_header  = [
  \   "                      .",
  \   "      ##############..... ##############",
  \   "      ##############......##############",
  \   "        ##########..........##########",
  \   "        ##########........##########",
  \   "        ##########.......##########",
  \   "        ##########.....##########..",
  \   "        ##########....##########.....",
  \   "      ..##########..##########.........",
  \   "    ....##########.#########.............",
  \   "      ..################JJJ............",
  \   "        ################.............",
  \   "        ##############.JJJ.JJJJJJJJJJ",
  \   "        ############...JJ...JJ..JJ  JJ",
  \   "        ##########....JJ...JJ..JJ  JJ",
  \   "        ########......JJJ..JJJ JJJ JJJ",
  \   "        ######    .........",
  \   "                    .....",
  \   "                      .",
  \ ]

  let g:startify_custom_header += [
  \   "",
  \   "",
  \   "  Vim version: "..v:versionlong,
  \   "",
  \   "  LSPs: ",
  \ ]

  for server in kg8m#plugin#lsp#servers()
    let g:startify_custom_header += [
    \   "  "..(server.available ? "👼 " : "👿 ")..server.name,
    \ ]
  endfor

  let g:startify_custom_header += [""]

  augroup my_vimrc  " {{{
    autocmd ColorScheme * call s:overwrite_colors()
  augroup END  " }}}
endfunction  " }}}

function s:overwrite_colors() abort  " {{{
  highlight StartifyFile   guifg=#FFFFFF
  highlight StartifyHeader guifg=#FFFFFF
  highlight StartifyPath   guifg=#777777
  highlight StartifySlash  guifg=#777777
endfunction  " }}}

function s:on_source() abort  " {{{
  call s:setup()
endfunction  " }}}

function s:on_post_source() abort  " {{{
  call s:overwrite_colors()
endfunction  " }}}
