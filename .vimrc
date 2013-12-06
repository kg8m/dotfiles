" ----------------------------------------------
" initialize "{{{
scriptencoding utf-8

let s:is_windows = has('win32') || has('win64')
let s:in_tmux    = exists('$TMUX')
" }}}

" ----------------------------------------------
" neobundle "{{{
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
NeoBundle 'lilydjwg/colorizer'
NeoBundle 'rhysd/conflict-marker.vim'
NeoBundle 'mattn/emmet-vim'  " former zencoding-vim
NeoBundle 'LeafCage/foldCC'
"NeoBundle 'sjl/gundo.vim'  " replaced by bitbucket.org/heavenshell/gundo.vim
NeoBundle 'sk1418/HowMuch'
NeoBundle 'othree/javascript-libraries-syntax.vim', { 'rev' : '4f63ea4f78' }
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'kg8m/moin.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'kg8m/open-browser.vim'
NeoBundle 'tyru/operator-camelize.vim'
"NeoBundle 'vim-scripts/QuickBuf'
"NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'chrisbra/Recover.vim'
NeoBundle 'kg8m/svn-diff.vim'
NeoBundle 'vim-scripts/Unicode-RST-Tables'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'osyo-manga/unite-filetype'
NeoBundle 'Shougo/unite-help'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'tsukkee/unite-tag'
NeoBundle 'pasela/unite-webcolorname'
NeoBundle 'h1mesuke/vim-alignta'
NeoBundle 'osyo-manga/vim-anzu'
NeoBundle 'kg8m/vim-blockle'
NeoBundle 'hail2u/vim-css-syntax'
NeoBundle 'hail2u/vim-css3-syntax'
"NeoBundle 'tpope/vim-endwise'  incompatible with neosnippet
NeoBundle 'thinca/vim-ft-diff_fold'
NeoBundle 'thinca/vim-ft-help_fold'
NeoBundle 'thinca/vim-ft-markdown_fold'
NeoBundle 'thinca/vim-ft-svn_diff'
NeoBundle 'thinca/vim-ft-vim_fold'
NeoBundle 'muz/vim-gemfile'
NeoBundle 'tpope/vim-haml'
NeoBundle 'michaeljsmith/vim-indent-object'
"NeoBundle 'pangloss/vim-javascript'  trying othree/javascript-libraries-syntax
NeoBundleLazy 'jelera/vim-javascript-syntax', {
            \   'autoload': {
            \     'filetypes': ['javascript'],
            \   }
            \ }
NeoBundle 'plasticboy/vim-markdown'
"NeoBundle 'amdt/vim-niji'
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
NeoBundle 'joker1007/vim-ruby-heredoc-syntax'
NeoBundle 'kg8m/vim-rubytest'
NeoBundle 'thinca/vim-singleton'
NeoBundle 'honza/vim-snippets'
NeoBundle 'nishigori/vim-sunday'
NeoBundle 'tpope/vim-surround'
NeoBundle 'deris/vim-textobj-enclosedsyntax', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'kana/vim-textobj-jabraces'
NeoBundle 'rhysd/vim-textobj-ruby'
NeoBundle 'jgdavey/vim-turbux'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'thinca/vim-unite-history'
NeoBundle 'hrsh7th/vim-unite-vcs'
NeoBundle 'hrsh7th/vim-versions'
NeoBundle 'superbrothers/vim-vimperator'
NeoBundle 'Shougo/vimfiler', { 'depends' : 'Shougo/unite.vim' }
NeoBundle 'Shougo/vimshell'
NeoBundle 'benmills/vimux', { 'rev' : '8e091d6' }
NeoBundle 'LeafCage/yankround.vim'

" plugins from bitbucket
NeoBundle 'https://bitbucket.org/heavenshell/gundo.vim'

" plugins from vim.org
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
" }}}

" ----------------------------------------------
" singleton "{{{
if has('gui_running') && !singleton#is_master()
  let g:singleton#opener = 'drop'
  call singleton#enable()
endif
" }}}

" ----------------------------------------------
" encoding "{{{
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
" }}}

" ----------------------------------------------
" general looks "{{{
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
set cursorline
set cursorcolumn
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufRead * set cursorcolumn cursorline
augroup END
set scrolloff=15
" set showbreak=++++
set iskeyword& iskeyword+=-

" make listchars visible
set list
set listchars=tab:>\ ,eol:\ ,trail:_

" make ZenkakuSpace visible
au BufNewFile,BufRead * match Underlined /　/
" }}}

" ----------------------------------------------
" spaces, indents "{{{
set tabstop=2
set shiftwidth=2
set textwidth=0
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

if has('vim_starting')
  " formatoptions
  autocmd FileType * setlocal fo+=q fo+=2 fo+=l
  autocmd FileType * setlocal fo-=t fo-=c fo-=a fo-=b
  autocmd FileType text,mkd,moin setlocal fo-=r fo-=o

  " folding
  set foldmethod=marker  " zo: open, zc: close, zR: open all, zM: close all
  set foldopen=hor
  set foldminlines=3
  set foldcolumn=3
  set fillchars=vert:\|

  autocmd FileType ruby set foldmethod=syntax
  autocmd FileType yaml set foldmethod=indent
  autocmd WinEnter,BufEnter,BufRead,BufNewFile * if &ft == 'javascript' | call JavaScriptFold() | endif

  " http://d.hatena.ne.jp/gnarl/20120308/1331180615
  autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
  autocmd BufWritePost,FileWritePost,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
endif
" }}}

" ----------------------------------------------
" search "{{{
set hlsearch
set ignorecase
set smartcase
set incsearch
" }}}

" ----------------------------------------------
" controls "{{{
set restorescreen
" set clipboard=unnamed

" backup, recover
set nobackup
set directory=~/tmp

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

" move
set whichwrap=b,s,h,l,<,>,[,],~

" move as shown
" nnoremap j gj
" nnoremap k gk
" nnoremap gj j
" nnoremap gk k

" IME
" augroup InsModeImEnable
"   autocmd!
"   autocmd InsertEnter,CmdwinEnter * set noimdisable
"   autocmd InsertLeave,CmdwinLeave * set imdisable
" augroup END

" http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
autocmd BufWriteCmd *[,*] call s:write_check_typo(expand('<afile>'))
function! s:write_check_typo(file)
  let writecmd = 'write'.(v:cmdbang ? '!' : '').' '.a:file

  if a:file =~ '[qfreplace]'
    return
  endif

  let prompt = "possible typo: really want to write to '" . a:file . "'?(y/n):"
  let input = input(prompt)

  if input ==# 'YES'
    execute writecmd
    let b:write_check_typo_nocheck = 1
  elseif input =~? '^y\(es\)\=$'
    execute writecmd
  endif
endfunction
" }}}

" ----------------------------------------------
" commands "{{{
" http://vim-users.jp/2009/05/hack17/
" :Rename newfilename.ext
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))
" }}}

" ----------------------------------------------
" keymappings "{{{
" ,r => reload .vimrc
nnoremap ,r :source ~/.vimrc<Cr>

" <Esc><Esc> => nohilight
nnoremap <Esc><Esc> :nohlsearch<Cr>

" ,v => vsplit
noremap ,v :vsplit<Cr>

" svn diff
nmap ,d :call SVNDiff()<Cr>
function! SVNDiff()
  edit diff
  silent! setlocal ft=diff bufhidden=delete nobackup noswf nobuflisted wrap buftype=nofile
  execute "normal :r!svn diff\n"
endfunction

" copy/paste by clipboard
vnoremap ,y "*y
nnoremap ,p "*p

" ,w => erase spaces of EOL for selected
vnoremap ,w :s/\s\+$//ge<Cr>

" search for selected
" http://vim-users.jp/2009/11/hack104/
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<Cr><Cr>

" prevent unconscious operation
inoremap <C-w> <Esc><C-w>
" }}}

" ----------------------------------------------
" plugins "{{{
" alignta "{{{
noremap ,a :Alignta<Space>
vnoremap ,ua :<C-u>Unite alignta:arguments<CR>
let g:unite_source_alignta_preset_arguments = [
  \ ["Align at '=>'     --  `=>`",        '=>'],
  \ ["Align at /\S/     --  `-r \S\+/g`", '-r \S\+/g'],
  \ ["Align at '='      --  `=>\=`",      '=>\='],
  \ ["Align at ':hoge'  --  `10 :`",      '10 :'],
  \ ["Align at 'hoge:'  --  `01 :`",      '01 :'],
  \ ["Align at '|'      --  `|`",         '|'],
  \ ["Align at ')'      --  `0 )`",       '0 )'],
  \ ["Align at ']'      --  `0 ]`",       '0 ]'],
  \ ["Align at '}'      --  `}`",         '}'],
\]
let s:alignta_comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'
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
  \ ["Regexp", '-r {regexp}/{regexp_options}'],
  \
  \ 'v/' . s:alignta_comment_leadings,
  \ 'g/' . s:alignta_comment_leadings,
\]
unlet s:alignta_comment_leadings
" }}}

" anzu "{{{
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)
" }}}

" blockle "{{{
let g:blockle_mapping = ",b"
let g:blockle_erase_spaces_around_starting_brace = 1
" }}}

" colorizer "{{{
let g:colorizer_startup = 0
let s:colorizer_target_filetypes = ['eruby', 'haml', 'html', 'css', 'scss', 'javascript', 'diff']
autocmd WinEnter,BufEnter,BufRead,BufNewFile * if index(s:colorizer_target_filetypes, &ft) >= 0 | ColorHighlight | else | ColorClear | endif
" }}}

" EnhCommentify "{{{
let g:EnhCommentifyBindInInsert = 'no'
" }}}

" foldCC "{{{
let g:foldCCtext_enable_autofdc_adjuster = 1
let g:foldCCtext_maxchars = 120
set foldtext=FoldCCtext()
" }}}

" gundo "{{{
" http://d.hatena.ne.jp/heavenshell/20120218/1329532535
" r => show diff preview
let g:gundo_auto_preview = 0
nnoremap <F5> :GundoToggle<CR>
" }}}

" HowMuch "{{{
" replace expr with result
vmap ,? <Plug>AutoCalcReplace
let g:HowMuch_scale = 5
" }}}

" lightline "{{{
set laststatus=2
let s:lightline_elements = {
\ 'left': [
\   [ 'mode', 'paste' ],
\   [ 'bufnum', 'readonly', 'absolutepath', 'modified' ],
\   [ 'filetype', 'fileencoding', 'fileformat' ],
\   [ 'lineinfo_with_percent' ],
\ ],
\ 'right': [
\ ],
\}
let g:lightline = {
    \ 'active': s:lightline_elements,
    \ 'inactive': s:lightline_elements,
    \ 'component': {
    \   'bufnum': '#%n',
    \   'lineinfo_with_percent': '%3l/%L(%3p%%) : %-2v',
    \ },
    \ 'colorscheme': 'wombat',
\ }
" }}}

" neocomplcache "{{{
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
let g:neocomplcache_force_overwrite_completefunc = 1

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
" }}}

" neosnippet "{{{
imap <expr><CR> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplcache#smart_close_popup() : "\<CR>"
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
" }}}

" open-browser "{{{
let g:openbrowser_browser_commands = [
  \   {
  \     "name": "ssh",
  \     "args": "ssh main 'open {uri}'",
  \   }
  \ ]
nmap ,g <Plug>(openbrowser-open)
vmap ,g <Plug>(openbrowser-open)
" }}}

" operator-camelize "{{{
map ,C <Plug>(operator-camelize)
map ,c <Plug>(operator-decamelize)
" }}}

" operator-replace "{{{
nmap r <Plug>(operator-replace)
vmap r <Plug>(operator-replace)
" }}}

" rails "{{{
" http://fg-180.katamayu.net/archives/2006/09/02/125150
autocmd FileType ruby set path+=test/lib
let g:rails_level = 4
let g:rails_projections = {
  \   "app/controllers/shared/*.rb": {
  \     "test": [
  \       "test/functional/shared/%s_test.rb",
  \       "test/functional/shared/%s_tests.rb",
  \     ],
  \   },
  \   "app/helpers/*_builder.rb": {
  \     "command": "helper",
  \   },
  \   "app/models/*_counter.rb": {
  \     "command": "counter",
  \   },
  \   "app/models/*_type.rb": {
  \     "command": "type",
  \   },
  \   "app/models/finder/*.rb": {
  \     "command": "finder",
  \   },
  \   "spec/fabricators/*_fabricator.rb": {
  \     "command":   "fabricator",
  \     "affinity":  "model",
  \     "alternate": "app/models/%s.rb",
  \     "related":   "db/schema.rb#%p",
  \     "test":      "spec/models/%s_spec.rb",
  \   },
  \   "spec/support/*.rb": {
  \     "command": "support",
  \   },
  \ }
" }}}

" rubytest "{{{
let g:no_rubytest_mappings = 1
if !s:in_tmux
  map <leader>T <Plug>RubyFileRun
  map <leader>t <Plug>RubyTestRun
endif
" }}}

" sequence "{{{
vmap ,,a <plug>SequenceV_Increment
vmap ,,x <plug>SequenceV_Decrement
nmap ,,a <plug>SequenceN_Increment
nmap ,,x <plug>SequenceN_Decrement
" }}}

" turbux "{{{
let g:no_turbux_mappings = 1
if s:in_tmux
  map <leader>T <Plug>SendTestToTmux
  map <leader>t <Plug>SendFocusedTestToTmux
endif
" }}}

" Unicode-RST-Tables "{{{
let g:no_rst_table_maps = 0
if has("python3")
  noremap <silent> ,,c :python3 CreateTable()<CR>
  noremap <silent> ,,f :python3 FixTable()<CR>
elseif has("python")
  noremap <silent> ,,c :python  CreateTable()<CR>
  noremap <silent> ,,f :python  FixTable()<CR>
endif
" }}}

" unite "{{{
let g:unite_winheight = 70
let g:unite_cursor_line_highlight = 'CursorLine'
let g:unite_source_history_yank_enable = 1
let g:unite_source_history_yank_limit = 300
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

" unite-shortcut "{{{
  " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
  " http://d.hatena.ne.jp/tyru/20120110/prompt
  map <silent> ,us :<C-u>Unite menu:shortcuts<CR>
  let g:unite_source_menu_menus = {}
  let g:unite_source_menu_menus.shortcuts = {
    \   "description" : "shortcuts"
    \ }

  " http://nanasi.jp/articles/vim/hz_ja_vim.html
  let g:unite_source_menu_menus.shortcuts.candidates = [
    \   ["[String Utility] All to Hankaku          ", "'<,'>Hankaku"],
    \   ["[String Utility] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
    \   ["[String Utility] ASCII to Hankaku        ", "'<,'>HzjaConvert han_ascii"],
    \   ["[String Utility] All to Zenkaku          ", "'<,'>Zenkaku"],
    \   ["[String Utility] Kana to Zenkaku         ", "'<,'>HzjaConvert zen_kana"],
    \
    \   ["[Reload with Encoding] latin1            ", "edit ++enc=latin1"],
    \   ["[Reload with Encoding] cp932             ", "edit ++enc=cp932"],
    \   ["[Reload with Encoding] shift-jis         ", "edit ++enc=shift-jis"],
    \   ["[Reload with Encoding] iso-2022-jp       ", "edit ++enc=iso-2022-jp"],
    \   ["[Reload with Encoding] euc-jp            ", "edit ++enc=euc-jp"],
    \   ["[Reload with Encoding] utf-8             ", "edit ++enc=utf-8"],
    \
    \   ["[Set Encoding] latin1                    ", "set fenc=latin1"],
    \   ["[Set Encoding] cp932                     ", "set fenc=cp932"],
    \   ["[Set Encoding] shift-jis                 ", "set fenc=shift-jis"],
    \   ["[Set Encoding] iso-2022-jp               ", "set fenc=iso-2022-jp"],
    \   ["[Set Encoding] euc-jp                    ", "set fenc=euc-jp"],
    \   ["[Set Encoding] utf-8                     ", "set fenc=utf-8"],
    \
    \   ["[Set File Format] dos                    ", "set ff=dos"],
    \   ["[Set File Format] unix                   ", "set ff=unix"],
    \   ["[Set File Format] mac                    ", "set ff=mac"],
    \
    \   ["[Manipulate File] set noreadonly         ", "set noreadonly"],
    \   ["[Manipulate File] to HTML                ", "colorscheme h2u_white | TOhtml"],
    \
    \   ["[System] Remove                          ", "!rm %"],
    \   ["[System] SVN Remove                      ", "!svn rm %"],
    \ ]

  function! g:unite_source_menu_menus.shortcuts.map(key, value)
    let [word, value] = a:value

    return {
         \   'word' : word . "  --  `" . value . "`",
         \   'kind' : 'command',
         \   'action__command' : value,
         \ }
  endfunction
" }}}

" unite plugins "{{{
  " nnoremap <silent> ,uv :<C-u>Unite vcs/status<CR>
  nnoremap <silent> ,uv :<C-u>UniteVersions status:!<CR>
  function! AddActionsToVersions()
    let l:action = {
      \   "description" : "open files",
      \   "is_selectable" : 1,
      \ }

    function! l:action.func(candidates)
      for l:candidate in a:candidates
        let l:candidate.action__path = candidate.source__args.path . '/' . l:candidate.action__status.path
        let l:candidate.action__directory = unite#util#path2directory(l:candidate.action__path)

        if l:candidate.action__path == l:candidate.action__directory
          let l:candidate.kind = 'directory'
          call unite#take_action("vimfiler", l:candidate)
        else
          let l:candidate.kind = 'file'
          call unite#take_action("open", l:candidate)
        endif
      endfor
    endfunction

    call unite#custom#action("versions/git/status,versions/svn/status", "open", l:action)
  endfunction
  call AddActionsToVersions()
  call unite#custom#default_action("versions/git/status,versions/svn/status", "open")

  " other unite keymappings: they used to be for plugins replaced by unite
  nnoremap <silent> ,m :<C-u>Unite file_mru<CR>
  nnoremap <F4> :<C-u>Unite buffer<CR>
" }}}
" }}}

" vimfiler "{{{
let g:vimfiler_safe_mode_by_default = 0
noremap ,e :VimFilerBufferDir -quit<Cr>
" }}}

" vimshell "{{{
noremap ,s :VimShell<Cr>

if s:is_windows
  let g:_user_name = $USERNAME
else
  let g:_user_name = $USER
endif

let g:vimshell_user_prompt = '"[".g:_user_name."@".hostname()."] ".getcwd()'
let g:vimshell_right_prompt = '"(".strftime("%y/%m/%d %H:%M:%S", localtime()).")"'
let g:vimshell_prompt = '% '
" }}}

" vimux "{{{
let g:VimuxHeight = 30
if s:in_tmux
  autocmd VimLeavePre * :VimuxCloseRunner
endif
" }}}

" yankround "{{{
nmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)
" }}}

" emmet (zencoding) "{{{
" command: <C-y>,
let g:user_emmet_settings = {
  \   'indentation' : '  ',
  \   'lang' : 'ja',
  \   'eruby' : {
  \     'extends' : 'html',
  \   },
  \   'javascript' : {
  \     'snippets' : {
  \       'jq' : "$(function() {\n  ${cursor}${child}\n});",
  \       'jq:each' : "$.each(arr, function(index, item)\n  ${child}\n});",
  \       'fn' : "(function() {\n  ${cursor}\n})();",
  \       'tm' : "setTimeout(function() {\n  ${cursor}\n}, 100);",
  \       'if' : "if (${cursor}) {\n};",
  \       'ife' : "if (${cursor}) {\n} else if (${cursor}) {\n} else {\n};",
  \     },
  \   },
  \ }
" }}}
" }}}

" ----------------------------------------------
" GUI settings "{{{
if has('gui_running')
  gui
  set guioptions-=T

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
" }}}

" ----------------------------------------------
" external sources "{{{
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
" }}}
