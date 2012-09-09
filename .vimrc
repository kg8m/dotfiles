
"----------------------------------------------

" encoding
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
"if has('iconv')
"  let s:enc_euc = 'euc-jp'
"  let s:enc_jis = 'iso-2022-jp'
"  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
"    let s:enc_euc = 'eucjp-ms'
"    let s:enc_jis = 'iso-2022-jp-3'
"  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
"    let s:enc_euc = 'euc-jisx0213'
"    let s:enc_jis = 'iso-2022-jp-3'
"  endif
"  if &encoding ==# 'utf-8'
"    let s:fileencodings_default = &fileencodings
"    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
"    let &fileencodings = &fileencodings .','. s:fileencodings_default
"    unlet s:fileencodings_default
"  else
"    let &fileencodings = &fileencodings .','. s:enc_jis
"    set fileencodings+=utf-8,ucs-2le,ucs-2
"    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
"      set fileencodings+=cp932
"      set fileencodings-=euc-jp
"      set fileencodings-=euc-jisx0213
"      set fileencodings-=eucjp-ms
"      let &encoding = s:enc_euc
"      let &fileencoding = s:enc_euc
"    else
"      let &fileencodings = &fileencodings .','. s:enc_euc
"    endif
"  endif
"  unlet s:enc_euc
"  unlet s:enc_jis
"endif
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
set fileformats=unix,dos,mac
if exists('&ambiwidth')
  set ambiwidth=double
endif


"----------------------------------------------

" general looks

if has('vim_starting')
  syntax on
endif

set showmatch
set nu
set showmode
set showcmd
highlight Visual ctermbg=darkgray
set cursorline
set cursorcolumn
highlight CursorLine cterm=reverse
highlight CursorColumn cterm=reverse
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufRead * set cursorcolumn cursorline
augroup END
set scrolloff=3
set showbreak=++++
set iskeyword& iskeyword+=-

" status line
set laststatus=2
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).'\|'.&ff.']'}\ \ %l/%L\ (%P)%m%=%{strftime(\"%Y/%m/%d\ %H:%M\")}

" spaces, indents
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start
"set foldmethod=indent  " zo: open, zc: close, zR: open all, zM: close all
set foldminlines=5

" search
set hlsearch
set ignorecase
set smartcase
set incsearch

" syntax
autocmd BufRead,BufNewFile *.html.erb set filetype=eruby.html

" colorscheme
colorscheme molokai

" make listchars visible
set list
set listchars=tab:>\ ,eol:\ ,trail:_

" make ZenkakuSpace visible
highlight ZenkakuSpace cterm=underline ctermfg=lightblue gui=underline guifg=blue
au BufNewFile,BufRead * match ZenkakuSpace /Å@/


"----------------------------------------------

" restore screen
set restorescreen

" clipboard
set clipboard=unnamed

" move
set whichwrap=b,s,h,l,<,>,[,],~

" undo
set hidden

" wildmode
set wildmenu
set wildmode=list:longest,full

" auto reload
augroup CheckTimeHook
  autocmd!
  autocmd InsertEnter * :checktime
  autocmd InsertLeave * :checktime
augroup END

" filetype
filetype on
filetype indent on
filetype plugin on

" IME
" augroup InsModeImEnable
"   autocmd!
"   autocmd InsertEnter,CmdwinEnter * set noimdisable
"   autocmd InsertLeave,CmdwinLeave * set imdisable
" augroup END


"----------------------------------------------

" ,r => reload .vimrc
nnoremap ,r :source ~/.vimrc<Cr>

" ,<S-r> => set noreadonly
nnoremap ,<S-r> :set noreadonly

" <Esc><Esc> => nohilight
nnoremap <Esc><Esc> :noh<Cr>

" ,v => vsplit
noremap ,v :vsplit<Cr>

" ,cu => UTF-8 and LF (UNIX)
nnoremap ,cu :set fileencoding=utf-8<Cr>:set fileformat=unix

" ,c<S-u> => reload with utf-8
nnoremap ,c<S-u> :e ++enc=utf-8

" ,h => TOhtml
nnoremap ,h :colorscheme h2u_white<Cr>:TOhtml

" svn diff
nmap ,d :call SVNDiff()<Cr>
function! SVNDiff()
  edit diff
  silent! setlocal ft=diff nobackup noswf buftype=nofile
  execute "normal :r!LANG=ja_JP.UTF8 svn diff\n"
  goto 1
endfunction

" ,w => erase spaces of EOL for selected
vnoremap ,w :s/\s\+$//ge<Cr>

" search for selected
" http://vim-users.jp/2009/11/hack104/
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<Cr><Cr>

" increments
nnoremap <silent> co :ContinuousNumber <C-a><CR>
vnoremap <silent> co :ContinuousNumber <C-a><CR>
command! -count -nargs=1 ContinuousNumber let c = col('.')|for n in range(1, <count>?<count>-line('.'):1)|exec 'normal! j' . n . <q-args>|call cursor('.', c)|endfor


"----------------------------------------------

" change status line color when insert mode
" http://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-color#color-insertmode
let g:hi_insert = 'highlight StatusLine ctermfg=black ctermbg=yellow cterm=none guifg=black guibg=darkyellow gui=bold'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction


"----------------------------------------------

" align.vim
noremap ,a :Align<Space>
let g:Align_xstrlen = 3

" incbufswitch-color.vim
noremap ,i :IncBufSwitch<Cr>

" mru.vim
noremap ,m :MRU<Cr>
let MRU_Window_Height = 20
let MRU_Max_Entries   = 500

" neocomplcache.vim
"let g:neocomplcache_enable_at_startup = 1
"let g:NeoComplCache_SnippetsDir = '~/.vim/snippets'
"imap <silent> <TAB> <Plug>(neocomplcache_snippets_expand)
"smap <silent> <TAB> <Plug>(neocomplcache_snippets_expand)

" operator-camelize.vim
map ,c <Plug>(operator-camelize)
map ,C <Plug>(operator-decamelize)

" rails.vim
" http://fg-180.katamayu.net/archives/2006/09/02/125150
let g:rails_level=4
autocmd User Rails Rnavcommand fabricator spec/fabricators -suffix=_fabricator.rb -default=model()
autocmd User Rails Rnavcommand ssupport spec/support -suffix=.rb
"autocmd User Rails Rnavcommand config config

" rubytest.vim
let g:rubytest_in_remote = 1

" unite.vim
let g:unite_winheight = 50
let g:unite_source_file_mru_limit = 500
let g:unite_source_history_yank_enable = 1
nnoremap <silent> ,uy :<C-u>Unite history/yank<CR>
nnoremap <silent> ,uo :<C-u>Unite outline<CR>
nnoremap <silent> ,uc :<C-u>Unite webcolorname<CR>
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

  " unite plugins
  nnoremap <silent> ,us :<C-u>Unite svn/status<CR>
  nnoremap <silent> ,uv :<C-u>Unite vcs/status<CR>

" vimshell
noremap ,s :VimShell<Cr>

" zencoding.vim
" command: <C-y>,
let g:user_zen_settings = {
\ 'indentation' : '  ',
\ 'lang' : 'ja',
\ 'javascript' : {
\   'snippets' : {
\     'jq' : "$(function() {\n  ${cursor}${child}\n});",
\     'jq:each' : "$.each(arr, function(index, item)\n  ${child}\n});",
\     'fn' : "(function() {\n  ${cursor}\n})();",
\     'tm' : "setTimeout(function() {\n  ${cursor}\n}, 100);",
\     'if' : "if (${cursor}) {\n};",
\     'ife' : "if (${cursor}) {\n} else if (${cursor}) {\n} else {\n};",
\   },
\ },
\}


"----------------------------------------------

" for GUI Vim
if has('gui')
  gui
  set nobackup
  set guioptions-=T
  "set lines=65
  "set columns=240

  "colorscheme torte
  colorscheme molokai


  nmap <C-v> <C-v>
  nmap <C-y> <C-y>

  "nnoremap ,r :source ~\_gvimrc<CR>

  " indent_guides.vim
  "autocmd VimEnter * :IndentGuidesToggle
  "let g:indent_guides_guide_size = 1

  " save window's size and position
  " http://vim-users.jp/2010/01/hack120/
  let g:save_window_file = expand('~/.vimwinpos')
  augroup SaveWindow
    autocmd!
    autocmd VimLeavePre * call s:save_window()
    function! s:save_window()
      let options = [
        \ 'set columns=' . &columns,
        \ 'set lines=' . &lines,
        \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
        \ ]
      call writefile(options, g:save_window_file)
    endfunction
  augroup END

  if filereadable(g:save_window_file)
    execute 'source' g:save_window_file
  endif
endif


"----------------------------------------------
