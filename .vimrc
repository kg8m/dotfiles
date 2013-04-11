"----------------------------------------------

let s:is_windows = has('win32') || has('win64')
let s:in_tmux    = exists('$TMUX')


"----------------------------------------------

" neobundle.vim
" https://github.com/Shougo/shougo-s-github/blob/master/vim/.vimrc

set nocompatible
filetype off

if s:is_windows
  if has('vim_starting')
    set runtimepath+=~/vimfiles/bundle/neobundle.vim/
  endif

  call neobundle#rc(expand('~/vimfiles/bundle/'))
else
  if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
  endif

  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/vimproc', {
        \   'build' : {
        \     'windows' : 'echo "Sorry, cannot update vimproc binary file in Windows."',
        \     'cygwin'  : 'make -f make_cygwin.mak',
        \     'mac'     : 'make -f make_mac.mak',
        \     'unix'    : 'make -f make_unix.mak',
        \   },
        \ },
NeoBundle 'Shougo/neobundle.vim'

" plugins from github
NeoBundle 'kg8m/.vim'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'taichouchou2/alpaca_complete', {
        \   'depends' : ['tpope/vim-rails', 'Shougo/neocomplcache'],
        \ },
NeoBundle 'vim-scripts/AutoClose'
NeoBundle 'rhysd/clever-f.vim'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'othree/javascript-libraries-syntax.vim'
NeoBundle 'kg8m/moin.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'tyru/operator-camelize.vim'
"NeoBundle 'vim-scripts/QuickBuf'
NeoBundle 'chrisbra/Recover.vim'
NeoBundle 'honza/snipmate-snippets'
NeoBundle 'kg8m/svn-diff.vim'
NeoBundle 'vim-scripts/Unicode-RST-Tables'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'osyo-manga/unite-filetype'
NeoBundle 'Shougo/unite-help'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'tsukkee/unite-tag'
NeoBundle 'pasela/unite-webcolorname'
NeoBundle 'h1mesuke/vim-alignta'
NeoBundle 'hail2u/vim-css-syntax'
NeoBundle 'hail2u/vim-css3-syntax'
"NeoBundle 'tpope/vim-endwise'  incompatible with neosnippet
NeoBundle 'tobiassvn/vim-gemfile'
NeoBundle 'tpope/vim-haml'
NeoBundle 'michaeljsmith/vim-indent-object'
"NeoBundle 'pangloss/vim-javascript'  trying othree/javascript-libraries-syntax
NeoBundle 'kana/vim-operator-replace'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'tpope/vim-rails'
NeoBundle 'thinca/vim-ref'
NeoBundle 'vim-ruby/vim-ruby', {
        \   'autoload' : {
        \     'mappings' : '<Plug>(ref-keyword)',
        \     'filetypes' : 'ruby'
        \   },
        \ },
NeoBundle 'kg8m/vim-rubytest'
NeoBundle 'tpope/vim-surround'
NeoBundle 'rhysd/vim-textobj-ruby'
NeoBundle 'jgdavey/vim-turbux'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'thinca/vim-unite-history'
NeoBundle 'hrsh7th/vim-unite-vcs'
NeoBundle 'hrsh7th/vim-versions'
NeoBundle 'superbrothers/vim-vimperator'
NeoBundle 'Shougo/vimfiler', { 'depends' : 'Shougo/unite.vim' }
NeoBundle 'Shougo/vimshell'
NeoBundle 'benmills/vimux'
NeoBundle 'vim-scripts/YankRing.vim'
NeoBundle 'mattn/zencoding-vim'

" plugins from vim.org
NeoBundle 'Align'
NeoBundle 'EnhCommentify.vim'
NeoBundle 'eruby.vim'
NeoBundle 'matchit.zip'
NeoBundle 'sequence'
NeoBundle 'sudo.vim'

" colorschemes
NeoBundle 'hail2u/h2u_colorscheme'  " for printing
NeoBundle 'kg8m/molokai'

filetype plugin indent on

if !s:is_windows && !has('gui_running')
  if neobundle#exists_not_installed_bundles()
    echomsg 'Not installed bundles : ' .
          \ string(neobundle#get_not_installed_bundle_names())
    echomsg 'Please execute ":NeoBundleInstall" command.'
    "finish
  endif
endif


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

" colorscheme
let g:molokai_original = 1
colorscheme molokai

set showmatch
set nu
set showmode
set showcmd
highlight Visual ctermbg=darkgray
set cursorline
set cursorcolumn
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
" set foldmethod=indent  " zo: open, zc: close, zR: open all, zM: close all
" set foldminlines=5

" search
set hlsearch
set ignorecase
set smartcase
set incsearch
highlight Search cterm=reverse ctermbg=none ctermfg=none

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
" set clipboard=unnamed

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

" IME
" augroup InsModeImEnable
"   autocmd!
"   autocmd InsertEnter,CmdwinEnter * set noimdisable
"   autocmd InsertLeave,CmdwinLeave * set imdisable
" augroup END


"----------------------------------------------

" http://vim-users.jp/2009/05/hack17/
" :Rename newfilename.ext
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


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

" continuous paste
" http://qiita.com/items/bd97a9b963dae40b63f5
vnoremap <silent> <C-p> "0p<CR>"

" ,w => erase spaces of EOL for selected
vnoremap ,w :s/\s\+$//ge<Cr>

" search for selected
" http://vim-users.jp/2009/11/hack104/
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<Cr><Cr>


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

" align.vim (replaced by alignta)
"let g:Align_xstrlen = 3
noremap ,a :Alignta<Space>

" alignta
vnoremap ,ua :<C-u>Unite alignta:arguments<CR>
let g:unite_source_alignta_preset_arguments = [
  \ ["Align at '=>'", '=>'],
  \ ["Align at /\S/", '<- -r \S\+/g'],
  \ ["Align at '='",  '=>\='],
  \ ["Align at ':hoge'",  '10 :'],
  \ ["Align at 'hoge:'",  '01 :'],
  \ ["Align at '|'",  '|'],
  \ ["Align at ')'",  '0 )'],
  \ ["Align at ']'",  '0 ]'],
  \ ["Align at '}'",  '}'],
\]
let s:comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'
let g:unite_source_alignta_preset_options = [
  \ ["Justify Left",      '<<'],
  \ ["Justify Center",    '||'],
  \ ["Justify Right",     '>>'],
  \ ["Justify None",      '=='],
  \ ["Shift Left",        '<-'],
  \ ["Shift Right",       '->'],
  \ ["Shift Left [Tab]",  '<--'],
  \ ["Shift Right [Tab]", '-->'],
  \ ["Margin 0:0",        '0'],
  \ ["Margin 0:1",        '01'],
  \ ["Margin 1:0",        '10'],
  \ ["Margin 1:1",        '1'],
  \
  \ 'v/' . s:comment_leadings,
  \ 'g/' . s:comment_leadings,
\]
unlet s:comment_leadings

" gundo
nnoremap <F5> :GundoToggle<CR>

" mru.vim (replaced  by unite.vim)
" noremap ,m :MRU<Cr>
" let MRU_Window_Height = 20
" let MRU_Max_Entries   = 500
nnoremap <silent> ,m :<C-u>Unite file_mru<CR>

" neocomplcache.vim
inoremap <expr><TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 0
let g:neocomplcache_enable_underbar_completion = 0
let g:neocomplcache_enable_fuzzy_completion = 1
let g:neocomplcache_min_syntax_length = 2
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 0
let g:neocomplcache_min_keyword_length = 3
let g:neocomplcache_enable_cursor_hold_i = 0
let g:neocomplcache_cursor_hold_i_time = 300
let g:neocomplcache_enable_insert_char_pre = 0
let g:neocomplcache_enable_prefetch = 0

if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
let g:neocomplcache_keyword_patterns['ruby'] = '\h\w*'

if s:is_windows
  let g:neocomplcache_snippets_dir = '~/vimfiles/snippets'
else
  let g:neocomplcache_snippets_dir = '~/.vim/snippets'
endif

if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplcache_caching_limit_file_size = 500000

" neosnippet
imap <expr><CR> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplcache#smart_close_popup() : "\<CR>"
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" operator-camelize.vim
map ,C <Plug>(operator-camelize)
map ,c <Plug>(operator-decamelize)

" QuickBuf (replaced by unite)
nnoremap <F4> :<C-u>Unite buffer<CR>

" rails.vim
" http://fg-180.katamayu.net/archives/2006/09/02/125150
let g:rails_level=4
autocmd User Rails Rnavcommand helper app/helpers -suffix=.rb  " for hoge_builder.rb
autocmd User Rails Rnavcommand fabricator spec/fabricators -suffix=_fabricator.rb -default=model()
autocmd User Rails Rnavcommand ssupport spec/support -suffix=.rb

" rubytest.vim
let g:no_rubytest_mappings = 1
if !s:in_tmux
  map <leader>T <Plug>RubyFileRun
  map <leader>t <Plug>RubyTestRun
endif

" sequence
vmap ,,a <plug>SequenceV_Increment
vmap ,,x <plug>SequenceV_Decrement
nmap ,,a <plug>SequenceN_Increment
nmap ,,x <plug>SequenceN_Decrement

" turbux
let g:no_turbux_mappings = 1
if s:in_tmux
  map <leader>T <Plug>SendTestToTmux
  map <leader>t <Plug>SendFocusedTestToTmux
endif

" unite.vim
let g:unite_winheight = 70
let g:unite_cursor_line_highlight = 'CursorLine'
let g:unite_source_history_yank_enable = 1
let g:unite_source_directory_mru_limit = 1000
let g:unite_source_file_mru_limit = 1000
let g:unite_source_grep_command = 'ack'
let g:unite_source_grep_default_opts = '--nocolor --nogroup --nopager'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_max_candidates = 1000
let g:unite_source_grep_search_word_highlight = 'Special'
call unite#custom_source("directory_mru", "max_candidates", 1000)
call unite#custom_source("file_mru", "max_candidates", 1000)
call unite#custom_source('buffer', 'sorters', 'sorter_word')
autocmd VimLeavePre * call unite#sources#outline#remove_cache_files()
nnoremap ,ug :<C-u>Unite grep:./::
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
  nnoremap <silent> ,uv :<C-u>Unite vcs/status<CR>
  " nnoremap <silent> ,uv :<C-u>UniteVersions status:!<CR>

" vimfiler
noremap ,e :VimFilerBufferDir -quit<Cr>

" vimshell
noremap ,s :VimShell<Cr>

if s:is_windows
  let g:_user_name = $USERNAME
else
  let g:_user_name = $USER
endif

let g:vimshell_user_prompt = '"[".g:_user_name."@".hostname()."] ".getcwd()'
let g:vimshell_right_prompt = '"(".strftime("%y/%m/%d %H:%M:%S", localtime()).")"'
let g:vimshell_prompt = '% '

" vimux
let g:VimuxHeight = 30
if s:in_tmux
  autocmd VimLeavePre * :VimuxCloseRunner
endif

" yankring
let g:yankring_max_history = 500

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
if has('gui_running') || has('win32') || has('win64')
  gui
  set nobackup
  set guioptions-=T

  colorscheme molokai

  nmap <C-v> <C-v>
  nmap <C-y> <C-y>

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
