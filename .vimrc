" ----------------------------------------------
" initialize "{{{
let $dotvim_path    = expand("~/.vim")
let $bundles_path   = expand($dotvim_path . "/bundle")
let $neobundle_path = expand($bundles_path . "/neobundle.vim")

let s:on_windows = has('win32') || has('win64')
let s:on_tmux    = exists('$TMUX')

" http://rhysd.hatenablog.com/entry/2013/08/24/223438
let s:neocomplete_available = has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))

let s:ag_available = executable("ag")
let s:ack_available = executable("ack")
let s:migemo_available = has("migemo") || executable("cmigemo")

function! s:AvailabilityMessage(target)
  return a:target . ' is ' . (eval('s:' . a:target . '_available') ? '' : 'NOT ') . 'available'
endfunction
" }}}

" ----------------------------------------------
" neobundle "{{{
if has('vim_starting')
  " http://qiita.com/td2sk/items/2299a5518f58ffbfc5cf
  if !isdirectory($neobundle_path)
    echo "Installing neobundle...."
    call system("git clone git://github.com/Shougo/neobundle.vim " . $neobundle_path)
  endif

  set runtimepath+=$neobundle_path
endif

call neobundle#begin($bundles_path)

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc', {
        \   'build': {
        \     'windows': 'make -f make_mingw32.mak',
        \     'cygwin':  'make -f make_cygwin.mak',
        \     'mac':     'make -f make_mac.mak',
        \     'unix':    'make -f make_unix.mak',
        \   },
        \ },

" plugins from github
NeoBundle 'kg8m/.vim'
" NeoBundle 'mileszs/ack.vim'
" NeoBundleLazy 'alpaca-tc/alpaca_complete', {
"             \   'autoload': {
"             \     'filetypes': ['ruby', 'eruby']
"             \   },
"             \ },
NeoBundleLazy 'alpaca-tc/alpaca_rails_support', {
            \   'autoload': {
            \     'insert':        1,
            \     'unite_sources': 'rails_support/locales',
            \     'commands':      [
            \       'RSCreateRoutesCache', 'RSCleanCache',
            \       'RSShowLocale', 'RSCreateLocaleCache',
            \     ]
            \   }
            \ }
NeoBundle 'vim-scripts/autodate.vim'
NeoBundleLazy 'itchyny/calendar.vim', {
            \   'autoload': {
            \     'commands': 'Calendar',
            \     'mappings': '<Plug>(calendar_',
            \   },
            \ },
NeoBundleLazy 'tyru/caw.vim', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>(caw:'],
            \   },
            \ },
" NeoBundle 'rhysd/clever-f.vim'
NeoBundle 'lilydjwg/colorizer'
NeoBundleLazy 'cocopon/colorswatch.vim', {
            \   'autoload': {
            \     'commands': 'ColorSwatchGenerate',
            \   },
            \ },
" NeoBundle 'rhysd/conflict-marker.vim'
NeoBundle 'spolu/dwm.vim'
" former zencoding-vim
NeoBundleLazy 'mattn/emmet-vim', {
              \   'autoload': {
              \     'insert': 1,
              \   },
              \ },
NeoBundle 'LeafCage/foldCC'
NeoBundleLazy 'mattn/gist-vim', {
            \   'autoload': {
            \     'commands': 'Gist',
            \   },
            \ },
" NeoBundle 'sjl/gundo.vim'  " replaced by bitbucket.org/heavenshell/gundo.vim
NeoBundleLazy 'sk1418/HowMuch', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>AutoCalc'],
            \   },
            \ },
NeoBundle 'nishigori/increment-activator'
" NeoBundle 'Yggdroot/indentLine'
NeoBundle 'othree/javascript-libraries-syntax.vim', { 'rev': '4f63ea4f78' }
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'kg8m/moin.vim'

if s:neocomplete_available
  NeoBundleFetch 'Shougo/neocomplcache.vim'
  NeoBundleLazy 'Shougo/neocomplete.vim', {
              \   'autoload': {
              \     'insert':   1,
              \     'commands': 'NeoCompleteBufferMakeCache',
              \   },
              \ },
else
  NeoBundle 'Shougo/neocomplcache.vim'
  NeoBundleFetch 'Shougo/neocomplete.vim'
endif

NeoBundle 'Shougo/neomru.vim'
NeoBundleLazy 'Shougo/neosnippet', {
            \   'autoload': {
            \     'insert':        1,
            \     'filetypes':     ['snippet', 'neosnippet'],
            \     'unite_sources': ['neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
            \   },
            \ },
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundleLazy 'kg8m/open-browser.vim', {
            \   'autoload': {
            \     'commands':  ['OpenBrowserSearch', 'OpenBrowser'],
            \     'functions': 'openbrowser#open',
            \     'mappings':  '<Plug>(openbrowser-open)',
            \   },
            \ },
NeoBundleLazy 'tyru/operator-camelize.vim', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>(operator-camelize)', '<Plug>(operator-decamelize)'],
            \   },
            \ },
" NeoBundle 'vim-scripts/QuickBuf'
" NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'chrisbra/Recover.vim'
NeoBundle 'joeytwiddle/sexy_scroller.vim'
NeoBundle 'jiangmiao/simple-javascript-indenter'
NeoBundleLazy 'AndrewRadev/splitjoin.vim', {
            \   'autoload': {
            \     'commands':  ['SplitjoinJoin', 'SplitjoinSplit'],
            \   },
            \ },
NeoBundle 'kg8m/svn-diff.vim'
NeoBundle 'vim-scripts/Unicode-RST-Tables'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'kg8m/unite-dwm'
NeoBundleLazy 'osyo-manga/unite-filetype', {
            \   'autoload': {
            \     'unite_sources': ['filetype'],
            \   },
            \ },
NeoBundleLazy 'kg8m/unite-gist', {
            \   'autoload': {
            \     'unite_sources': ['gist'],
            \   },
            \ },
NeoBundleLazy 'Shougo/unite-help', {
            \   'autoload': {
            \     'unite_sources': ['help'],
            \   },
            \ },
NeoBundle 'tacroe/unite-mark'
NeoBundleLazy 'Shougo/unite-outline', {
            \   'autoload': {
            \     'unite_sources': ['outline'],
            \   },
            \ },
NeoBundle 'basyura/unite-rails'
NeoBundleLazy 'tsukkee/unite-tag', {
            \   'autoload': {
            \     'unite_sources': ['tag', 'tag/include', 'tag/file'],
            \   },
            \ },
NeoBundleLazy 'pasela/unite-webcolorname', {
            \   'autoload': {
            \     'unite_sources': ['webcolorname'],
            \   },
            \ },
NeoBundleLazy 'h1mesuke/vim-alignta', {
            \   'autoload': {
            \     'commands':      'Alignta',
            \     'unite_sources': ['alignta'],
            \   },
            \ },
NeoBundleLazy 'osyo-manga/vim-anzu', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>(anzu-'],
            \   },
            \ },
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'kg8m/vim-blockle'
NeoBundle 't9md/vim-choosewin', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>(choosewin)'],
            \   },
            \ },
NeoBundle 'hail2u/vim-css-syntax'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'Lokaltog/vim-easymotion'
" NeoBundle 'tpope/vim-endwise'  incompatible with neosnippet
NeoBundle 'thinca/vim-ft-diff_fold'
NeoBundle 'thinca/vim-ft-help_fold'
NeoBundle 'thinca/vim-ft-markdown_fold'
NeoBundleLazy 'thinca/vim-prettyprint', {
            \   'autoload': {
            \     'commands':  ['PrettyPrint', 'PP'],
            \     'functions': ['PrettyPrint', 'PP'],
            \   },
            \ },
NeoBundle 'thinca/vim-ft-svn_diff'
" NeoBundle 'thinca/vim-ft-vim_fold'
NeoBundle 'muz/vim-gemfile'
NeoBundle 'tpope/vim-haml'
NeoBundle 'michaeljsmith/vim-indent-object'
" NeoBundle 'pangloss/vim-javascript'
NeoBundleLazy 'jelera/vim-javascript-syntax', {
            \   'autoload': {
            \     'filetypes': ['javascript', 'eruby'],
            \     'functions': ['JavaScriptFold'],
            \   },
            \ },
NeoBundle 'elzr/vim-json'
NeoBundle 'rcmdnk/vim-markdown'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
" NeoBundle 'amdt/vim-niji'
NeoBundleLazy 'kana/vim-operator-replace', {
            \   'autoload': {
            \     'mappings': ['ns', '<Plug>(operator-replace)'],
            \   },
            \ },
" not working in case like following:
"   (1) text:      hoge "fu*ga piyo"
"   (2) call: <Plug>(operator-surround-append)"'
"   (3) expected:  hoge* '"fuga piyo"'
"   (4) result:    hoge*' "fuga piyo"'
" or following:
"   (2) call: <Plug>(operator-surround-replace)"'
"   (3) expected:  hoge* 'fuga piyo'
"   (4) result:    hoge*' fuga piyo'
" NeoBundleLazy 'rhysd/vim-operator-surround', {
"             \   'autoload': {
"             \     'mappings': ['ns', '<Plug>(operator-surround-'],
"             \   },
"             \ },
NeoBundleLazy 'kana/vim-operator-user', {
            \   'functions': 'operator#user#define',
            \ }
NeoBundleLazy 'thinca/vim-qfreplace', {
            \   'autoload': {
            \     'filetypes': ['unite', 'quickfix']
            \   },
            \ },
NeoBundle 'tpope/vim-rails'
NeoBundleLazy 'thinca/vim-ref', {
            \   'autoload': {
            \     'commands': 'Ref',
            \     'mappings': '<Plug>(ref-keyword)',
            \   },
            \ },
NeoBundle 'tpope/vim-repeat'
" ftdetecting does not working
" NeoBundleLazy 'vim-ruby/vim-ruby', {
"             \   'autoload': {
"             \     'commands':  'Ref',
"             \     'mappings':  '<Plug>(ref-keyword)',
"             \     'filetypes': ['ruby', 'eruby']
"             \   },
"             \ },
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'joker1007/vim-ruby-heredoc-syntax'
NeoBundle 'kg8m/vim-rubytest'
NeoBundleLazy 'thinca/vim-singleton', {
            \   'gui': 1,
            \ },
NeoBundle 'honza/vim-snippets'
NeoBundle 'mhinz/vim-startify'
NeoBundle 'tpope/vim-surround'
NeoBundle 'deris/vim-textobj-enclosedsyntax'
NeoBundle 'kana/vim-textobj-jabraces'
NeoBundle 'osyo-manga/vim-textobj-multitextobj'
NeoBundle 'rhysd/vim-textobj-ruby'

if s:on_tmux
  NeoBundle 'jgdavey/vim-turbux'
endif

NeoBundle 'kana/vim-textobj-user'
NeoBundleLazy 'thinca/vim-unite-history', {
            \   'autoload': {
            \     'unite_sources': ['history/command', 'history/search'],
            \   },
            \ },
" NeoBundle 'hrsh7th/vim-unite-vcs'  replaced by vim-versions
NeoBundle 'hrsh7th/vim-versions'
NeoBundle 'superbrothers/vim-vimperator'
NeoBundleLazy 'Shougo/vimfiler', {
            \   'autoload': {
            \     'commands': ['VimFiler', 'VimFilerBufferDir'],
            \   },
            \ },
NeoBundleLazy 'Shougo/vimshell', {
            \   'autoload': {
            \     'commands': ['VimShell', 'VimShellExecute'],
            \   },
            \ },

if s:on_tmux
  NeoBundle 'benmills/vimux'
endif

NeoBundle 'LeafCage/yankround.vim'

" plugins from bitbucket
NeoBundleLazy 'https://bitbucket.org/heavenshell/gundo.vim', {
            \   'autoload': {
            \     'commands': 'GundoToggle',
            \   },
            \ },
NeoBundle 'https://bitbucket.org/teramako/jscomplete-vim.git'

" plugins from vim.org
" NeoBundle 'EnhCommentify.vim'
" NeoBundle 'eruby.vim'
NeoBundle 'matchit.zip'
NeoBundle 'sequence'
NeoBundle 'sudo.vim'

" colorschemes
NeoBundle 'hail2u/h2u_colorscheme'  " for printing
NeoBundle 'kg8m/molokai'

call neobundle#end()
filetype plugin indent on

NeoBundleCheck
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

function! s:RecheckFileencoding()
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding=&encoding
  endif
endfunction

augroup CheckEncoding
  autocmd!
  autocmd BufReadPost * call s:RecheckFileencoding()
augroup END

set fileformats=unix,dos,mac

if exists('&ambiwidth')
  set ambiwidth=double
endif

scriptencoding utf-8
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
augroup ToggleActiveWindowCursor
  autocmd!
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufWinEnter,FileType,ColorScheme * set cursorcolumn cursorline
augroup END
set scrolloff=15
" set showbreak=++++
set iskeyword& iskeyword+=-

" make listchars visible
set list
set listchars=tab:>\ ,eol:\ ,trail:_

" make ZenkakuSpace visible
augroup HighlightZenkakuSpace
  autocmd!
  autocmd BufNewFile,BufRead * match Underlined /　/
augroup END
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
  autocmd FileType text,markdown,moin setlocal fo-=r fo-=o

  " folding
  set foldmethod=marker  " zo: open, zc: close, zR: open all, zM: close all
  set foldopen=hor
  set foldminlines=3
  set foldcolumn=3
  set fillchars=vert:\|

  autocmd FileType vim  set foldmethod=marker
  autocmd FileType ruby set foldmethod=syntax
  autocmd FileType yaml set foldmethod=indent
  autocmd BufEnter * if &ft == 'javascript' | call s:MyJavascriptFold() | endif

  " http://d.hatena.ne.jp/gnarl/20120308/1331180615
  autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
  autocmd BufWritePost,FileWritePost,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

 " update filetype
  autocmd BufWritePost *
  \ if &l:filetype ==# '' || exists('b:ftdetect')
  \ | unlet! b:ftdetect
  \ | filetype detect
  \ | endif

  autocmd FileType gitcommit,qfreplace setlocal nofoldenable
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
set mouse=
set t_vb=

" smoothen screen drawing; wait procedures' completion
set lazyredraw
set ttyfast

" backup, recover
set nobackup
set directory=~/tmp

" undo
set hidden

" wildmode
set wildmenu
set wildmode=list:longest,full

" ctags
if has('vim_starting') && exists('$RUBYGEMS_PATH')
  let &tags = &tags . "," . $RUBYGEMS_PATH . "**/tags"
endif

" auto reload
augroup CheckTimeHook
  autocmd!
  autocmd InsertEnter * :checktime
  autocmd InsertLeave * :checktime
augroup END

" move
set whichwrap=b,s,h,l,<,>,[,],~

" move as shown
" disable because of difference between normal mode and other modes (e.g., visual mode)
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
augroup CheckTypo
  autocmd!
  autocmd BufWriteCmd *[,*] call s:WriteCheckTypo(expand('<afile>'))
augroup END
function! s:WriteCheckTypo(file)
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
let g:mapleader = ','

" ,r => reload .vimrc
nnoremap <Leader>r :source ~/.vimrc<Cr>

" <Esc><Esc> => nohilight
nnoremap <Esc><Esc> :nohlsearch<Cr>

" ,v => vsplit
nnoremap <Leader>v :vsplit<Cr>

" ,d => svn diff
nnoremap <Leader>d :call SvnDiff()<Cr>
function! SvnDiff()
  edit diff
  silent! setlocal ft=diff bufhidden=delete nobackup noswf nobuflisted wrap buftype=nofile
  execute "normal :r!svn diff\n"
endfunction

" ,y/,p => copy/paste by clipboard
vnoremap <Leader>y "*y
nnoremap <Leader>p "*p

" ctags
" <C-]>: go to tag, <C-[>: back from tag
nnoremap <C-[> <C-S-t>

" ,w => <C-w>
nnoremap <Leader>w <C-w>

" ,w => erase spaces of EOL for selected
vnoremap <Leader>w :s/\s\+$//ge<Cr>

" search very magic as default
nnoremap / /\v

" search selected characters
vnoremap <silent> * "zy:let @/ = @z<Cr>n

" prevent unconscious operation
inoremap <C-w> <Esc><C-w>

" increment/decrement
nmap + <C-a>
nmap - <C-x>

" emacs like moving in INSERT mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" Page scroll in INSERT mode
inoremap <expr><C-f> "\<PageDown>"
inoremap <expr><C-b> "\<PageUp>"
" }}}

" ----------------------------------------------
" plugins "{{{
" alignta "{{{
vnoremap <Leader>a :Alignta<Space>
vnoremap <Leader>ua :<C-u>Unite alignta:arguments<Cr>
let g:unite_source_alignta_preset_arguments = [
  \ ["Align at '=>'     --  `=>`",                        '=>'],
  \ ["Align at /\\S/    --  `\\S\\+`",                    '\S\+'],
  \ ["Align at '='      --  `=>\\=`",                     '=>\='],
  \ ["Align at ':hoge'  --  `10 :`",                      '10 :'],
  \ ["Align at 'hoge:'  --  `00 [a-zA-Z0-9_\"']\\+:\\s`", " 00 [a-zA-Z0-9_\"']\\+:\\s"],
  \ ["Align at '|'      --  `|`",                         '|'],
  \ ["Align at ')'      --  `0 )`",                       '0 )'],
  \ ["Align at ']'      --  `0 ]`",                       '0 ]'],
  \ ["Align at '}'      --  `}`",                         '}'],
  \ ["Align at 'hoge,'  --  `00 \\w\\+, ` -- not working", '00 \w\+, '],
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

" autoclose "{{{
let g:AutoClosePairs_add = "<>"
" }}}

" autodate "{{{
let autodate_format       = '%Y/%m/%d'
let autodate_lines        = 100
let autodate_keyword_pre  = '\c\%(' .
                          \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                          \   '\%(最終更新日\?\)\|' .
                          \   '\%(更新日\)' .
                          \ '\):'
let autodate_keyword_post = '\.$'
" }}}

" blockle "{{{
let g:blockle_mapping = ",b"
let g:blockle_erase_spaces_around_starting_brace = 1
" }}}

" calendar "{{{
let g:calendar_google_calendar = 1
let g:calendar_first_day = "monday"
" }}}

" colorizer "{{{
let g:colorizer_startup = 0
let s:colorizer_target_filetypes = ['eruby', 'haml', 'html', 'css', 'scss', 'javascript', 'diff']
augroup ToogleColorizer
  autocmd!
  autocmd WinEnter,BufEnter,BufRead,BufNewFile * if index(s:colorizer_target_filetypes, &ft) >= 0 | ColorHighlight | else | ColorClear | endif
augroup END
" }}}

" caw "{{{
let g:caw_no_default_keymappings = 1
let g:caw_i_skip_blank_line = 1
nmap gc <Plug>(caw:i:toggle)
vmap gc <Plug>(caw:i:toggle)
" }}}

" choosewin "{{{
let g:choosewin_overlay_enable          = 0  " wanna set true but too heavy
let g:choosewin_overlay_clear_multibyte = 1
let g:choosewin_blink_on_land           = 0
let g:choosewin_statusline_replace      = 1  " wanna set false and use overlay
let g:choosewin_tabline_replace         = 0
nmap <C-w>f <Plug>(choosewin)
" }}}

" dwm "{{{
let g:dwm_map_keys = 0
nmap <C-w>n       :call DWM_New()<Cr>
nmap <C-w>c       :call DWM_Close()<Cr>
nmap <C-w><Space> :call DWM_AutoEnter()<Cr>
let g:dwm_augroup_cleared = 0
function! s:ClearDwmAugroup()
  if !g:dwm_augroup_cleared
    augroup dwm
      autocmd!
    augroup END
    let g:dwm_augroup_cleared = 1
  endif
endfunction
augroup ClearDWMAugroup
  autocmd!
  autocmd VimEnter * call s:ClearDwmAugroup()
augroup END
" }}}

" easymotion "{{{
" http://haya14busa.com/vim-lazymotion-on-speed/
let g:EasyMotion_do_mapping  = 0
let g:EasyMotion_do_shade    = 0
let g:EasyMotion_startofline = 0
let g:EasyMotion_smartcase   = 1
let g:EasyMotion_use_upper   = 1
let g:EasyMotion_keys        = "FJKLASDHGUIONMEREWC,;"
let g:EasyMotion_use_migemo  = 1
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_skipfoldedline   = 0
nmap <Leader>f <Plug>(easymotion-s2)
vmap <Leader>f <Plug>(easymotion-s2)
omap <Leader>f <Plug>(easymotion-s2)
" replace default `f`
nmap f <Plug>(easymotion-fl)
vmap f <Plug>(easymotion-fl)
omap f <Plug>(easymotion-fl)
nmap F <Plug>(easymotion-Fl)
vmap F <Plug>(easymotion-Fl)
omap F <Plug>(easymotion-Fl)
" replace default `/`
" very magic (\v) as default
" nmap / <Plug>(easymotion-sn)\v
" vmap / <Plug>(easymotion-sn)\v
" omap / <Plug>(easymotion-sn)\v
" }}}

" foldCC "{{{
let g:foldCCtext_enable_autofdc_adjuster = 1
let g:foldCCtext_maxchars = 120
set foldtext=FoldCCtext()
" }}}

" gist "{{{
let g:gist_detect_filetype  = 1
let g:gist_show_privates    = 1
let g:gist_post_private     = 1
let g:gist_get_multiplefile = 1
" }}}

" gundo "{{{
" http://d.hatena.ne.jp/heavenshell/20120218/1329532535
" r => show diff preview
let g:gundo_auto_preview = 0
nnoremap <F5> :GundoToggle<Cr>
" }}}

" HowMuch "{{{
" replace expr with result
vmap <Leader>? <Plug>AutoCalcReplace
vmap <Leader>?s <Plug>AutoCalcReplaceWithSum
let g:HowMuch_scale = 5
" }}}

" increment-activator "{{{
let g:increment_activator_filetype_candidates = {
  \   "_": [
  \     ["日", "月", "火", "水", "木", "金", "土"],
  \   ],
  \ }
" }}}

" indentline "{{{
" let g:indentLine_char = '|'
" }}}

" javascript-syntax "{{{
function! s:MyJavascriptFold()
  if !exists("b:javascript_folded")
    call JavaScriptFold()
    setl foldlevelstart=0
    let b:javascript_folded = 1
  endif
endfunction
" }}}

" jscomplete "{{{
let g:jscomplete_use = ['dom', 'moz', 'es6th']
" }}}

" lightline "{{{
" http://d.hatena.ne.jp/itchyny/20130828/1377653592
set laststatus=2
let s:lightline_elements = {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'bufnum', 'filename' ],
  \     [ 'filetype', 'fileencoding', 'fileformat' ],
  \     [ 'lineinfo_with_percent' ],
  \   ],
  \   'right': [
  \   ],
  \ }
let g:lightline = {
  \   'active': s:lightline_elements,
  \   'inactive': s:lightline_elements,
  \   'component': {
  \     'bufnum': '#%n',
  \     'lineinfo_with_percent': '%l/%L(%p%%) : %v',
  \   },
  \   'component_function': {
  \     'filename': 'MyFilename',
  \   },
  \   'colorscheme': 'molokai',
  \ }

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'X' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
       \ (
       \   &ft == 'vimfiler' ? vimfiler#get_status_string() :
       \   &ft == 'unite' ? unite#get_status_string() :
       \   &ft == 'vimshell' ? vimshell#get_status_string() :
       \   '' != expand('%:t') ? (
       \     winwidth(0) >= 100 ? expand('%:F') : expand('%:t')
       \   ) : '[No Name]'
       \ ) .
       \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction
" }}}

" neocomplcache/neocomplete "{{{
if s:neocomplete_available
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#enable_fuzzy_completion = 1
  let g:neocomplete#sources#syntax#min_keyword_length = 2
  let g:neocomplete#auto_completion_start_length = 1
  let g:neocomplete#manual_completion_start_length = 0
  let g:neocomplete#min_keyword_length = 3
  let g:neocomplete#enable_cursor_hold_i = 0
  let g:neocomplete#cursor_hold_i_time = 300
  let g:neocomplete#enable_insert_char_pre = 0
  let g:neocomplete#enable_prefetch = 0
  let g:neocomplete#force_overwrite_completefunc = 1

  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'
  let g:neocomplete#keyword_patterns['ruby'] = '\h\w*'

  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

  let g:sources#buffer#cache_limit_size = 500000
else
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_camel_case_completion = 0
  let g:neocomplcache_enable_underbar_completion = 0
  let g:neocomplcache_enable_fuzzy_completion = 1
  let g:neocomplcache_min_syntax_length = 2
  let g:neocomplcache_auto_completion_start_length = 1
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

  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

  let g:neocomplcache_caching_limit_file_size = 500000
endif

augroup SetOmunifuncs
  autocmd!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  " jscomplete
  autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
augroup END
" }}}

" neosnippet "{{{
imap <expr><Tab> pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
smap <expr><Tab> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

if s:neocomplete_available
  imap <expr><Cr> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#smart_close_popup() : "\<Cr>"
else
  imap <expr><Cr> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplcache#smart_close_popup() : "\<Cr>"
endif

if has('conceal')
  set conceallevel=2 concealcursor=i
endif

let g:neosnippet#snippets_directory = [
  \   $bundles_path . "/.vim/snippets",
  \   $bundles_path . "/vim-snippets/snippets",
  \ ]

augroup NeoSnippetClearMarkers
  autocmd!
  autocmd InsertLeave * NeoSnippetClearMarkers
augroup END
" }}}

" open-browser "{{{
let g:openbrowser_browser_commands = [
  \   {
  \     "name": "ssh",
  \     "args": "ssh main 'open {uri}'",
  \   }
  \ ]
nmap <Leader>g <Plug>(openbrowser-open)
vmap <Leader>g <Plug>(openbrowser-open)
" }}}

" operator-camelize "{{{
vmap <Leader>C <Plug>(operator-camelize)
vmap <Leader>c <Plug>(operator-decamelize)
" }}}

" operator-replace "{{{
nmap r <Plug>(operator-replace)
vmap r <Plug>(operator-replace)
" }}}

" operator-surround "{{{
" nmap <silent>sa <Plug>(operator-surround-append)
" nmap <silent>sd <Plug>(operator-surround-delete)
" nmap <silent>sr <Plug>(operator-surround-replace)
" vmap <silent>sa <Plug>(operator-surround-append)
" vmap <silent>sd <Plug>(operator-surround-delete)
" vmap <silent>sr <Plug>(operator-surround-replace)
" }}}

" rails "{{{
" http://fg-180.katamayu.net/archives/2006/09/02/125150
augroup Rails
  autocmd!
  autocmd FileType ruby set path+=test/lib
augroup END
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
  \   "config/routes.rb": {
  \     "command": "routes",
  \     "test": [
  \       "test/integration/routes_test.rb",
  \     ],
  \   },
  \   "script/*": {
  \     "command": "script",
  \     "test": [
  \       "test/unit/%s_test.rb",
  \     ],
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
  \   "test/functional/shared/*_tests.rb": {
  \     "alternate": "app/controllers/shared/%s.rb",
  \   },
  \ }
" prevent `rails.vim` from defining keymappings
nmap <Leader>Rwf  <Plug>RailsSplitFind
nmap <Leader>Rwgf <Plug>RailsTabFind
" }}}

" ref "{{{
nmap K <Plug>(ref-keyword)
" }}}

" ruby "{{{
let g:no_ruby_maps = 1
" }}}

" rubytest "{{{
let g:no_rubytest_mappings = 1
let g:rubytest_in_vimshell = 1
if !s:on_tmux
  nmap <leader>T <Plug>RubyFileRun
  nmap <leader>t <Plug>RubyTestRun
endif
" }}}

" sequence "{{{
vmap <Leader>+ <plug>SequenceV_Increment
vmap <Leader>- <plug>SequenceV_Decrement
nmap <Leader>+ <plug>SequenceN_Increment
nmap <Leader>- <plug>SequenceN_Decrement
" }}}

" simple-javascript-indenter "{{{
let g:SimpleJsIndenter_BriefMode = 2
let g:SimpleJsIndenter_CaseIndentLevel = -1
" }}}

" splitjoin "{{{
let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping  = ''
nnoremap <Leader>J :SplitjoinJoin<Cr>
nnoremap <Leader>S :SplitjoinSplit<Cr>
" }}}

" startify "{{{
let g:startify_enable_special = 1
let g:startify_change_to_dir  = 0
" https://gist.github.com/SammysHP/5611986#file-gistfile1-txt
let g:startify_custom_header = [
  \   '                      .',
  \   '      ##############..... ##############',
  \   '      ##############......##############',
  \   '        ##########..........##########',
  \   '        ##########........##########',
  \   '        ##########.......##########',
  \   '        ##########.....##########..',
  \   '        ##########....##########.....',
  \   '      ..##########..##########.........',
  \   '    ....##########.#########.............',
  \   '      ..################JJJ............',
  \   '        ################.............',
  \   '        ##############.JJJ.JJJJJJJJJJ',
  \   '        ############...JJ...JJ..JJ  JJ',
  \   '        ##########....JJ...JJ..JJ  JJ',
  \   '        ########......JJJ..JJJ JJJ JJJ',
  \   '        ######    .........',
  \   '                    .....',
  \   '                      .',
  \   '',
  \   '',
  \   '     * Vim version: ' . v:version,
  \   '',
  \   '     * ' . s:AvailabilityMessage("neocomplete"),
  \   '     * ' . s:AvailabilityMessage("ag"),
  \   '     * ' . s:AvailabilityMessage("ack"),
  \   '     * ' . s:AvailabilityMessage("migemo"),
  \   '',
  \   '',
  \ ]
" }}}

" textobj-multitextobj "{{{
let g:textobj_multitextobj_textobjects_a = [
  \   [
  \     "\<Plug>(textobj-jabraces-parens-a)",
  \     "\<Plug>(textobj-jabraces-braces-a)",
  \     "\<Plug>(textobj-jabraces-brackets-a)",
  \     "\<Plug>(textobj-jabraces-angles-a)",
  \     "\<Plug>(textobj-jabraces-double-angles-a)",
  \     "\<Plug>(textobj-jabraces-kakko-a)",
  \     "\<Plug>(textobj-jabraces-double-kakko-a)",
  \     "\<Plug>(textobj-jabraces-yama-kakko-a)",
  \     "\<Plug>(textobj-jabraces-double-yama-kakko-a)",
  \     "\<Plug>(textobj-jabraces-kikkou-kakko-a)",
  \     "\<Plug>(textobj-jabraces-sumi-kakko-a)",
  \   ],
  \ ]
let g:textobj_multitextobj_textobjects_i = [
  \   [
  \     "\<Plug>(textobj-jabraces-parens-i)",
  \     "\<Plug>(textobj-jabraces-braces-i)",
  \     "\<Plug>(textobj-jabraces-brackets-i)",
  \     "\<Plug>(textobj-jabraces-angles-i)",
  \     "\<Plug>(textobj-jabraces-double-angles-i)",
  \     "\<Plug>(textobj-jabraces-kakko-i)",
  \     "\<Plug>(textobj-jabraces-double-kakko-i)",
  \     "\<Plug>(textobj-jabraces-yama-kakko-i)",
  \     "\<Plug>(textobj-jabraces-double-yama-kakko-i)",
  \     "\<Plug>(textobj-jabraces-kikkou-kakko-i)",
  \     "\<Plug>(textobj-jabraces-sumi-kakko-i)",
  \   ],
  \ ]
omap aj <Plug>(textobj-multitextobj-a)
omap ij <Plug>(textobj-multitextobj-i)
vmap aj <Plug>(textobj-multitextobj-a)
vmap ij <Plug>(textobj-multitextobj-i)
" }}}

" turbux "{{{
let g:no_turbux_mappings = 1
if s:on_tmux
  map <leader>T <Plug>SendTestToTmux
  map <leader>t <Plug>SendFocusedTestToTmux
endif
" }}}

" Unicode-RST-Tables "{{{
let g:no_rst_table_maps = 0
if has("python3")
  nnoremap <silent> <Leader><Leader>c :python3 CreateTable()<Cr>
  nnoremap <silent> <Leader><Leader>f :python3 FixTable()<Cr>
elseif has("python")
  nnoremap <silent> <Leader><Leader>c :python  CreateTable()<Cr>
  nnoremap <silent> <Leader><Leader>f :python  FixTable()<Cr>
endif
" }}}

" unite, neomru, unite's plugins "{{{
let g:unite_winheight = '100%'
let g:unite_cursor_line_highlight = 'CursorLine'
let g:unite_source_history_yank_enable = 1
let g:unite_source_history_yank_limit = 300

if s:ag_available || s:ack_available
  if s:ag_available
    let g:unite_source_grep_command = 'ag'
  elseif s:ack_available
    let g:unite_source_grep_command = 'ack'
  endif

  let g:unite_source_grep_default_opts = '--nocolor --nogroup --nopager'
  let g:unite_source_grep_recursive_opt = ''
endif

let g:unite_source_grep_max_candidates = 1000
let g:unite_source_grep_search_word_highlight = 'Special'
call unite#custom_source('buffer', 'sorters', 'sorter_word')
nnoremap <Leader>ug :<C-u>Unite -no-quit grep:./::
vnoremap <Leader>ug "vy:<C-u>Unite -no-quit grep:./::<C-r>"
nnoremap <silent> <Leader>uy :<C-u>Unite history/yank<Cr>
nnoremap <silent> <Leader>uo :<C-u>Unite outline<Cr>
nnoremap <silent> <Leader>uc :<C-u>Unite webcolorname<Cr>
nnoremap <silent> <Leader>ub :<C-u>Unite buffer<Cr>
nnoremap <silent> <Leader>uf :<C-u>UniteWithBufferDir -buffer-name=files file<Cr>
" nnoremap <silent> <Leader>ur :<C-u>Unite -buffer-name=register register<Cr>
" nnoremap <silent> <Leader>um :<C-u>Unite neomru/file<Cr>
nnoremap <silent> <Leader>uu :<C-u>Unite buffer neomru/file<Cr>
nnoremap <silent> <Leader>ua :<C-u>UniteWithBufferDir -buffer-name=files buffer neomru/file bookmark file<Cr>

" unite-dwm "{{{
  let g:unite_dwm_source_names_as_default_action = "buffer,file,file_mru,cdable"
" }}}

" neomru "{{{
  let g:neomru#time_format     = "(%Y/%m/%d %H:%M:%S) "
  let g:neomru#filename_format = ":~:."
  let g:neomru#file_mru_limit  = 1000
  nnoremap <silent> <Leader>m :<C-u>Unite neomru/file<Cr>
" }}}

" unite-mark "{{{
  let g:mark_ids = [
    \   "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    \   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    \ ]
  let g:unite_source_mark_marks = join(g:mark_ids, "")
  nnoremap <Leader>um :<C-u>Unite mark<Cr>
  " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
  nnoremap <silent> m :<C-u>call <SID>auto_mark()<Cr>
  function! s:auto_mark()
      if !exists("b:mark_position")
        let b:mark_position = 0
      else
        let b:mark_position = (b:mark_position + 1) % len(g:mark_ids)
      endif

      execute 'mark' g:mark_ids[b:mark_position]
      echo 'marked' g:mark_ids[b:mark_position]
  endfunction
  augroup InitMarks
    autocmd!
    autocmd BufReadPost * delmarks!
  augroup END
" }}}

" unite-rails "{{{
  nnoremap <Leader>ur :<C-u>Unite rails/
" }}}

" unite-shortcut "{{{
  " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
  " http://d.hatena.ne.jp/tyru/20120110/prompt
  noremap <silent> <Leader>us :<C-u>Unite menu:shortcuts<Cr>
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
    \   ["[Reload with Encoding] latin1            ", "edit ++enc=latin1 +set\\ noreadonly"],
    \   ["[Reload with Encoding] cp932             ", "edit ++enc=cp932 +set\\ noreadonly"],
    \   ["[Reload with Encoding] shift-jis         ", "edit ++enc=shift-jis +set\\ noreadonly"],
    \   ["[Reload with Encoding] iso-2022-jp       ", "edit ++enc=iso-2022-jp +set\\ noreadonly"],
    \   ["[Reload with Encoding] euc-jp            ", "edit ++enc=euc-jp +set\\ noreadonly"],
    \   ["[Reload with Encoding] utf-8             ", "edit ++enc=utf-8 +set\\ noreadonly"],
    \
    \   ["[Reload by Sudo]                         ", "edit sudo:%"],
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
    \   ["[Manipulate File] sed all buffers [Edit] ", "bufdo %s/{foo}/{bar}/gce | update"],
    \
    \   ["[System] Remove                          ", "!rm %"],
    \   ["[System] SVN Remove                      ", "!svn rm %"],
    \
    \   ["[Calendar] Year View                     ", "Calendar -view=year  -position=hear!"],
    \   ["[Calendar] Month View                    ", "Calendar -view=month -position=hear!"],
    \   ["[Calendar] Week View                     ", "Calendar -view=week  -position=hear!"],
    \   ["[Calendar] Day View                      ", "Calendar -view=day   -position=hear! -split=vertical -width=75"],
    \
    \   ["[Unite plugin] gist                      ", "Unite gist"],
    \   ["[Unite plugin] mru files list            ", "Unite neomru/file"],
    \   ["[Unite plugin] outline                   ", "Unite outline"],
    \   ["[Unite plugin] tag with cursor word      ", "UniteWithCursorWord tag"],
    \   ["[Unite plugin] versions/status           ", "Unite versions/status"],
    \   ["[Unite plugin] versions/log              ", "Unite versions/log"],
    \   ["[Unite plugin] webcolorname              ", "Unite webcolorname"],
    \   ["[Unite] buffers list                     ", "Unite buffer"],
    \   ["[Unite] files list with buffer directory ", "UniteWithBufferDir file"],
    \   ["[Unite] history/yank                     ", "Unite history/yank"],
    \   ["[Unite] register                         ", "Unite register"],
    \   ["[Unite] grep [Edit]                      ", "Unite -no-quit grep:./::{words}"],
    \
    \   ["[Help]autocommand-events                 ", "help autocommand-events"],
    \   ["[Help][neobundle] Options-autoload       ", "help neobundle-options-autoload"],
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

" unite-tag "{{{
  nnoremap <silent> <Leader>ut :<C-u>UniteWithCursorWord -immediately tag<Cr>
" }}}

" unite-versions "{{{
  let g:versions#type#svn#status#ignore_status = ['X']
  " maybe bug exists: works like as `status:%` in subversion directory
  " nnoremap <silent> <Leader>uv :<C-u>UniteVersions status:!<Cr>
  nnoremap <silent> <Leader>uv :<C-u>UniteVersions status:./<Cr>
  function! s:AddActionsToVersions()
    let l:action = {
      \   "description" : "open files",
      \   "is_selectable" : 1,
      \ }

    function! l:action.func(candidates)
      for l:candidate in a:candidates
        let l:candidate.action__path = l:candidate.source__args.path . l:candidate.action__status.path
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
    call unite#custom#default_action("versions/git/status,versions/svn/status", "open")
  endfunction
  call s:AddActionsToVersions()
" }}}

" other unite keymappings: they used to be for plugins replaced by unite "{{{
  nnoremap <F4> :<C-u>Unite buffer<Cr>
" }}}
" }}}

" vimfiler "{{{
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_edit_action = 'dwm_open'
nnoremap <Leader>e :VimFilerBufferDir -quit<Cr>
" }}}

" vimshell "{{{
nnoremap <Leader>s :VimShell<Cr>

if s:on_windows
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
let g:VimuxUseNearestPane = 0  " deprecated?
let g:VimuxUseNearest = 0
if s:on_tmux
  augroup Vimux
    autocmd!
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END
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
  set guioptions=none
  " set clipboard=unnamed

  " reset mswin.vim's mappings
  nnoremap <C-v> <C-v>
  nnoremap <C-y> <C-y>

  " save window's size and position
  " http://vim-users.jp/2010/01/hack120/
  let s:save_window_file = expand('~/.vimwinpos')
  augroup SaveWindow
    autocmd!
    autocmd VimLeavePre * call s:SaveWindow()
    function! s:SaveWindow()
      let options = [
        \ 'set columns=' . &columns,
        \ 'set lines=' . &lines,
        \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
        \ ]
      call writefile(options, s:save_window_file)
    endfunction
  augroup END

  if has('vim_starting') && filereadable(s:save_window_file)
    execute 'source' s:save_window_file
  endif
endif
" }}}

" ----------------------------------------------
" external sources "{{{
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
" }}}
