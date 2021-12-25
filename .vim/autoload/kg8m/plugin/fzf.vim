vim9script

def kg8m#plugin#fzf#configure(): void
  # See also vim-fzf-tjump's mappings
  nnoremap <silent> <Leader><Leader>f :call kg8m#plugin#fzf#run_command("FzfFiles")<CR>
  nnoremap <silent> <Leader><Leader>v :call kg8m#plugin#fzf#git_files#run()<CR>
  nnoremap <silent> <Leader><Leader>b :call kg8m#plugin#fzf#buffers#run()<CR>
  nnoremap <silent> <Leader><Leader>l :call kg8m#plugin#fzf#buffer_lines#run()<CR>
  nnoremap <silent> <Leader><Leader>m :call kg8m#plugin#fzf#run_command("FzfMarks")<CR>
  nnoremap <silent> <Leader><Leader>h :call kg8m#plugin#fzf#history#run()<CR>
  nnoremap <silent> <Leader><Leader>H :call kg8m#plugin#fzf#run_command("FzfHelptags")<CR>
  nnoremap <silent> <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#run()<CR>
  nnoremap <silent> <Leader><Leader>g :call kg8m#plugin#fzf#grep#enter_command()<CR>
  xnoremap <silent> <Leader><Leader>g "zy:call kg8m#plugin#fzf#grep#enter_command(@z)<CR>
  noremap  <silent> <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#run("")<CR>
  noremap  <silent> <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#run("SimpleAlign ")<CR>
  nnoremap <silent> <Leader><Leader>[ :call kg8m#plugin#fzf#jumplist#back()<CR>
  nnoremap <silent> <Leader><Leader>] :call kg8m#plugin#fzf#jumplist#forward()<CR>

  if kg8m#util#on_rails_dir()
    nnoremap <silent> <Leader><Leader>r :call kg8m#plugin#fzf#rails#enter_command()<CR>
  endif

  kg8m#plugin#configure({
    lazy:     true,
    on_cmd:   ["FzfFiles", "FzfLines", "FzfMarks", "FzfHelptags"],
    on_start: true,
    depends:  "fzf",
    hook_source: () => s:on_source(),
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

# Temporarily set `ambiwidth` to `single` because fzf.vim doesn't use unicode characters for rendering borders when
# `ambiwidth` is `double`.
def kg8m#plugin#fzf#run(Callback: func): void
  const original_ambiwidth = &ambiwidth

  try
    set ambiwidth=single
    Callback()
  finally
    &ambiwidth = original_ambiwidth
  endtry
enddef

def kg8m#plugin#fzf#run_command(command: string): void
  # Use `feedkeys(...)` instead of `execute(command)` for preventing "E930: Cannot use :redir inside execute()".
  kg8m#plugin#fzf#run(() => feedkeys(":" .. command .. "\<CR>"))
enddef

def s:setup_window(): void
  # Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
enddef

def s:on_source(): void
  g:fzf_command_prefix = "Fzf"
  g:fzf_buffers_jump   = true
  g:fzf_layout         = { up: "~90%" }
  g:fzf_files_options  = [
    "--preview", "git diff-or-cat {1}",
    "--preview-window", "down:75%:wrap:nohidden",
  ]

  # See dwm.vim
  g:fzf_action = { ctrl-o: "DWMOpen" }

  augroup vimrc-plugin-fzf
    autocmd!
    autocmd FileType fzf s:setup_window()
  augroup END
enddef
