function kg8m#plugin#fzf#configure() abort  " {{{
  let g:fzf_command_prefix = "Fzf"
  let g:fzf_buffers_jump   = v:true
  let g:fzf_layout         = #{ up: "~90%" }
  let g:fzf_files_options  = [
  \   "--preview", "git diff-or-cat {1}",
  \   "--preview-window", "right:50%:wrap:nohidden",
  \ ]

  " See dwm.vim
  let g:fzf_action = #{ ctrl-o: "DWMOpen" }

  " See also vim-fzf-tjump's mappings
  nnoremap <Leader><Leader>f :FzfFiles<Cr>
  nnoremap <Leader><Leader>v :call kg8m#plugin#fzf#git_files#run()<Cr>
  nnoremap <Leader><Leader>b :call kg8m#plugin#fzf#buffers#run()<Cr>
  nnoremap <Leader><Leader>l :FzfBLines<Cr>
  nnoremap <Leader><Leader>g :FzfGrep<Space>
  nnoremap <Leader><Leader>G :FzfGrepForDir<Space>
  vnoremap <Leader><Leader>g "gy:FzfGrep<Space><C-r>"
  vnoremap <Leader><Leader>G "gy:FzfGrepForDir<Space><C-r>"
  nnoremap <Leader><Leader>m :FzfMarks<Cr>
  nnoremap <Leader><Leader>h :call kg8m#plugin#fzf#history#run()<Cr>
  nnoremap <Leader><Leader>H :FzfHelptags<Cr>
  nnoremap <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#run()<Cr>
  noremap  <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#run("")<Cr>
  noremap  <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#run("'EasyAlign ")<Cr>

  nnoremap <silent> m :call kg8m#plugin#fzf#marks#increment()<Cr>

  command! -nargs=+ -complete=tag FzfGrep       call kg8m#plugin#fzf#grep#run(<q-args>, "")
  command! -nargs=+ -complete=tag FzfGrepForDir call kg8m#plugin#fzf#grep#run(<q-args>, kg8m#plugin#fzf#grep#input_dir())

  if kg8m#util#on_rails_dir()
    nnoremap <Leader><Leader>r :FzfRails<Space>
    command! -nargs=1 -complete=customlist,kg8m#plugin#fzf#rails#type_names FzfRails call kg8m#plugin#fzf#rails#run(<q-args>)
  endif

  augroup my_vimrc  " {{{
    autocmd FileType fzf call s:setup_window()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_cmd:  ["FzfFiles","FzfLines", "FzfMarks", "FzfHelptags"],
  \   on_func: "fzf#",
  \   depends: "fzf",
  \ })

  " Add to runtimepath (and use its Vim scripts) but don't use its binary.
  " Use fzf binary already installed instead.
  if kg8m#plugin#register("junegunn/fzf")  " {{{
    call kg8m#plugin#configure(#{
    \   lazy: v:true,
    \ })
  endif  " }}}

  if kg8m#plugin#register("thinca/vim-qfreplace")  " {{{
    call kg8m#plugin#configure(#{
    \   lazy:   v:true,
    \   on_cmd: "Qfreplace",
    \ })
  endif  " }}}

  if kg8m#plugin#register("kg8m/vim-fzf-tjump")  " {{{
    call kg8m#plugin#fzf_tjump#configure()
  endif  " }}}
endfunction  " }}}

function kg8m#plugin#fzf#current_filepath() abort  " {{{
  let filepath = expand("%")
  return empty(filepath) ? "" : fnamemodify(filepath, kg8m#plugin#fzf#filepath_format())
endfunction  " }}}

function kg8m#plugin#fzf#filepath_format() abort  " {{{
  if !has_key(s:, "fzf_filepath_format")
    let s:fzf_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return s:fzf_filepath_format
endfunction  " }}}

function s:setup_window() abort  " {{{
  " Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
endfunction  " }}}
