vim9script

def kg8m#plugin#fzf#configure(): void
  g:fzf_command_prefix = "Fzf"
  g:fzf_buffers_jump   = true
  g:fzf_layout         = { up: "~90%" }
  g:fzf_files_options  = [
    "--preview", "git diff-or-cat {1}",
    "--preview-window", "down:75%:wrap:nohidden",
  ]

  # See dwm.vim
  g:fzf_action = { ctrl-o: "DWMOpen" }

  # See also vim-fzf-tjump's mappings
  nnoremap <Leader><Leader>f :FzfFiles<CR>
  nnoremap <Leader><Leader>v :call kg8m#plugin#fzf#git_files#run()<CR>
  nnoremap <Leader><Leader>b :call kg8m#plugin#fzf#buffers#run()<CR>
  nnoremap <Leader><Leader>l :FzfBLines<CR>
  nnoremap <Leader><Leader>m :FzfMarks<CR>
  nnoremap <Leader><Leader>h :call kg8m#plugin#fzf#history#run()<CR>
  nnoremap <Leader><Leader>H :FzfHelptags<CR>
  nnoremap <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#run()<CR>
  noremap  <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#run("")<CR>
  noremap  <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#run("SimpleAlign ")<CR>
  nnoremap <Leader><Leader>[ :call kg8m#plugin#fzf#jumplist#back()<CR>
  nnoremap <Leader><Leader>] :call kg8m#plugin#fzf#jumplist#forward()<CR>

  noremap <expr> <Leader><Leader>g kg8m#plugin#fzf#grep#expr()
  noremap <expr> <Leader><Leader>G kg8m#plugin#fzf#grep#expr(#{ path: v:true })

  nnoremap <silent> m :call kg8m#plugin#fzf#marks#increment()<CR>

  if kg8m#util#on_rails_dir()
    nnoremap <Leader><Leader>r :FzfRails<Space>
    command! -nargs=1 -complete=customlist,kg8m#plugin#fzf#rails#type_names FzfRails kg8m#plugin#fzf#rails#run(<q-args>)
  endif

  augroup my_vimrc
    autocmd FileType fzf s:setup_window()
  augroup END

  kg8m#plugin#configure({
    lazy:     true,
    on_cmd:   ["FzfFiles", "FzfLines", "FzfMarks", "FzfHelptags"],
    on_start: true,
    depends:  "fzf",
  })

  # Add to runtimepath (and use its Vim scripts) but don't use its binary.
  # Use fzf binary already installed instead.
  if kg8m#plugin#register("junegunn/fzf")
    kg8m#plugin#configure({
      lazy: true,
    })
  endif

  if kg8m#plugin#register("thinca/vim-qfreplace")
    kg8m#plugin#configure({
      lazy:   true,
      on_cmd: "Qfreplace",
    })
  endif

  if kg8m#plugin#register("kg8m/vim-fzf-tjump")
    kg8m#plugin#fzf_tjump#configure()
  endif
enddef

def s:setup_window(): void
  # Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
enddef
