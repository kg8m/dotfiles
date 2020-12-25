vim9script

var s:fzf_filepath_format: string

def kg8m#plugin#fzf#configure(): void  # {{{
  g:fzf_command_prefix = "Fzf"
  g:fzf_buffers_jump   = v:true
  g:fzf_layout         = { up: "~90%" }
  g:fzf_files_options  = [
    "--preview", "git diff-or-cat {1}",
    "--preview-window", "right:50%:wrap:nohidden",
  ]

  # See dwm.vim
  g:fzf_action = { ctrl-o: "DWMOpen" }

  # See also vim-fzf-tjump's mappings
  nnoremap <Leader><Leader>f :FzfFiles<CR>
  nnoremap <Leader><Leader>v :call kg8m#plugin#fzf#git_files#run()<CR>
  nnoremap <Leader><Leader>b :call kg8m#plugin#fzf#buffers#run()<CR>
  nnoremap <Leader><Leader>l :FzfBLines<CR>
  nnoremap <Leader><Leader>g :FzfGrep<Space>
  nnoremap <Leader><Leader>G :FzfGrepForDir<Space>
  vnoremap <Leader><Leader>g "gy:FzfGrep<Space><C-r>"
  vnoremap <Leader><Leader>G "gy:FzfGrepForDir<Space><C-r>"
  nnoremap <Leader><Leader>m :FzfMarks<CR>
  nnoremap <Leader><Leader>h :call kg8m#plugin#fzf#history#run()<CR>
  nnoremap <Leader><Leader>H :FzfHelptags<CR>
  nnoremap <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#run()<CR>
  noremap  <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#run("")<CR>
  noremap  <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#run("'EasyAlign ")<CR>

  nnoremap <silent> m :call kg8m#plugin#fzf#marks#increment()<CR>

  command! -nargs=+ -complete=tag FzfGrep       kg8m#plugin#fzf#grep#run(<q-args>, "")
  command! -nargs=+ -complete=tag FzfGrepForDir kg8m#plugin#fzf#grep#run(<q-args>, kg8m#plugin#fzf#grep#input_dir())

  if kg8m#util#on_rails_dir()
    nnoremap <Leader><Leader>r :FzfRails<Space>
    command! -nargs=1 -complete=customlist,kg8m#plugin#fzf#rails#type_names FzfRails kg8m#plugin#fzf#rails#run(<q-args>)
  endif

  augroup my_vimrc  # {{{
    autocmd FileType fzf s:setup_window()
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:    v:true,
    on_cmd:  ["FzfFiles", "FzfLines", "FzfMarks", "FzfHelptags"],
    on_func: "fzf#",
    depends: "fzf",
  })

  # Add to runtimepath (and use its Vim scripts) but don't use its binary.
  # Use fzf binary already installed instead.
  if kg8m#plugin#register("junegunn/fzf")  # {{{
    kg8m#plugin#configure({
      lazy: v:true,
    })
  endif  # }}}

  if kg8m#plugin#register("thinca/vim-qfreplace")  # {{{
    kg8m#plugin#configure({
      lazy:   v:true,
      on_cmd: "Qfreplace",
    })
  endif  # }}}

  if kg8m#plugin#register("kg8m/vim-fzf-tjump")  # {{{
    kg8m#plugin#fzf_tjump#configure()
  endif  # }}}
enddef  # }}}

def kg8m#plugin#fzf#current_filepath(): string  # {{{
  const filepath = expand("%")
  return empty(filepath) ? "" : fnamemodify(filepath, kg8m#plugin#fzf#filepath_format())
enddef  # }}}

def kg8m#plugin#fzf#filepath_format(): string  # {{{
  if empty(s:fzf_filepath_format)
    s:fzf_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return s:fzf_filepath_format
enddef  # }}}

def s:setup_window(): void  # {{{
  # Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
enddef  # }}}
