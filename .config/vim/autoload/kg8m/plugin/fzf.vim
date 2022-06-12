vim9script

export def Configure(): void
  # See also vim-fzf-tjump's mappings
  nnoremap <silent> <Leader><Leader>f :call kg8m#plugin#fzf#files#Run()<CR>
  nnoremap <silent> <Leader><Leader>v :call kg8m#plugin#fzf#git_files#Run()<CR>
  nnoremap <silent> <Leader><Leader>b :call kg8m#plugin#fzf#buffers#Run()<CR>
  nnoremap <silent> <Leader><Leader>l :call kg8m#plugin#fzf#buffer_lines#Run()<CR>
  nnoremap <silent> <Leader><Leader>m :call kg8m#plugin#fzf#marks#Run()<CR>
  nnoremap <silent> <Leader><Leader>h :call kg8m#plugin#fzf#history#Run()<CR>
  nnoremap <silent> <Leader><Leader>H :call kg8m#plugin#fzf#helptags#Run()<CR>
  nnoremap <silent> <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#Run()<CR>
  nnoremap <silent> <Leader><Leader>g :call kg8m#plugin#fzf#grep#EnterCommand()<CR>
  xnoremap <silent> <Leader><Leader>g "zy:call kg8m#plugin#fzf#grep#EnterCommand(@z)<CR>
  xnoremap <silent> <Leader><Leader>G "zy:call kg8m#plugin#fzf#grep#EnterCommand(@z, #{ word_boundary: v:true })<CR>
  noremap  <silent> <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#Run("")<CR>
  noremap  <silent> <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#Run("SimpleAlign ")<CR>
  nnoremap <silent> <Leader><Leader>[ :call kg8m#plugin#fzf#jumplist#Back()<CR>
  nnoremap <silent> <Leader><Leader>] :call kg8m#plugin#fzf#jumplist#Forward()<CR>

  if kg8m#util#OnRailsDir()
    nnoremap <silent> <Leader><Leader>r :call kg8m#plugin#fzf#rails#EnterCommand()<CR>
  endif

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    depends:  "fzf",
    hook_source: () => OnSource(),
  })

  # Add to runtimepath (and use its Vim scripts) but don't use its binary.
  # Use fzf binary already installed instead.
  if kg8m#plugin#Register("junegunn/fzf")
    kg8m#plugin#Configure({
      lazy: true,
    })
  endif

  if kg8m#plugin#Register("kg8m/vim-fzf-tjump")
    kg8m#plugin#fzf_tjump#Configure()
  endif
enddef

# Temporarily set `ambiwidth` to `single` because fzf.vim doesn't use unicode characters for rendering borders when
# `ambiwidth` is `double`.
export def Run(Callback: func): void
  const original_ambiwidth = &ambiwidth

  try
    set ambiwidth=single
    Callback()
  finally
    &ambiwidth = original_ambiwidth
  endtry
enddef

def SetupWindow(): void
  # Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
enddef

def OnSource(): void
  g:fzf_command_prefix = "Fzf"
  g:fzf_buffers_jump   = true
  g:fzf_layout         = { up: "~90%" }
  g:fzf_files_options  = [
    "--preview", "preview {}",
    "--preview-window", "down:75%:wrap:nohidden",
  ]

  # See dwm.vim
  g:fzf_action = { ctrl-o: "DWMOpen" }

  augroup vimrc-plugin-fzf
    autocmd!
    autocmd FileType fzf SetupWindow()
  augroup END
enddef
