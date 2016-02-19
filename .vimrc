" ----------------------------------------------
" initialize  "{{{
let $dotvim_path    = expand("~/.vim")
let $bundles_path   = expand($dotvim_path . "/bundle")
let $neobundle_path = expand($bundles_path . "/neobundle.vim")

let s:on_windows = has("win32") || has("win64")
let s:on_mac     = has("mac")
let s:on_tmux    = exists("$TMUX")

" http://rhysd.hatenablog.com/entry/2013/08/24/223438
let s:neocomplete_available = has("lua") && (v:version > 703 || (v:version == 703 && has("patch885")))

let s:pt_available     = executable("pt")
let s:ag_available     = executable("ag")
let s:ack_available    = executable("ack")
let s:migemo_available = has("migemo") || executable("cmigemo")

function! OnTmux() abort
  return s:on_tmux
endfunction

function! NeocompleteAvailable() abort
  return s:neocomplete_available
endfunction

function! s:AvailabilityMessage(target)
  return a:target . " is " . (eval("s:" . a:target . "_available") ? "" : "NOT ") . "available"
endfunction

let g:mapleader = ","
" }}}

" ----------------------------------------------
" neobundle/plugins  "{{{
" neobundle#begin  "{{{
if has("vim_starting")
  " http://qiita.com/td2sk/items/2299a5518f58ffbfc5cf
  if !isdirectory($neobundle_path)
    echo "Installing neobundle...."
    call system("git clone git://github.com/Shougo/neobundle.vim " . $neobundle_path)
  endif

  set runtimepath+=$neobundle_path
endif

call neobundle#begin($bundles_path)
" }}}

" plugins list  "{{{
NeoBundleFetch "Shougo/neobundle.vim"
NeoBundle "Shougo/vimproc", {
        \   "build": {
        \     "windows": "tools\\update-dll-mingw",
        \     "cygwin":  "make -f make_cygwin.mak",
        \     "mac":     "make -f make_mac.mak",
        \     "linux":   "make",
        \     "unix":    "make",
        \   },
        \ },

NeoBundle "kg8m/.vim"
NeoBundle "mileszs/ack.vim", { "disabled": 1 }
NeoBundle "alpaca-tc/alpaca_complete", { "disabled": 1 }
NeoBundle "alpaca-tc/alpaca_rails_support", { "disabled": 1 }
NeoBundle "vim-scripts/autodate.vim"
NeoBundle "itchyny/calendar.vim"
NeoBundle "tyru/caw.vim"
NeoBundle "rhysd/clever-f.vim", {
        \   "disabled":    1,
        \   "description": "replaced by easymotion",
        \ }
NeoBundle "lilydjwg/colorizer", {
        \   "disabled":    1,
        \   "description": "replaced by vim-coloresque",
        \ }
NeoBundle "cocopon/colorswatch.vim"
NeoBundle "rhysd/conflict-marker.vim", { "disabled": 1 }
NeoBundleFetch "chrisbra/csv.vim"
NeoBundle "spolu/dwm.vim"
NeoBundle "mattn/emmet-vim", { "description": "former zencoding-vim" }
NeoBundle "EnhCommentify.vim", {
        \   "disabled":    1,
        \   "description": "replaced by caw",
        \ }
NeoBundle "eruby.vim", { "disabled": 1 }
NeoBundle "LeafCage/foldCC"
NeoBundle "sjl/gundo.vim", {
        \   "disabled":    1,
        \   "description": "replaced by heavenshell/gundo.vim",
        \ }
NeoBundle "bitbucket:heavenshell/gundo.vim"
NeoBundle "sk1418/HowMuch"
NeoBundle "nishigori/increment-activator"
NeoBundle "haya14busa/incsearch.vim"
NeoBundle "haya14busa/incsearch-index.vim", { "disabled": 1 }
NeoBundle "Yggdroot/indentLine", { "disabled": 1 }
NeoBundle "othree/javascript-libraries-syntax.vim", { "disabled": 1 }
NeoBundle "fuenor/JpFormat.vim"
NeoBundle "bitbucket:teramako/jscomplete-vim.git"
NeoBundle "itchyny/lightline.vim"
NeoBundle "AndrewRadev/linediff.vim"
NeoBundle "matchit.zip"
NeoBundle "kg8m/moin.vim"
NeoBundle "Shougo/neocomplcache.vim", { "disabled": NeocompleteAvailable() }
NeoBundle "Shougo/neocomplete.vim", { "disabled": !NeocompleteAvailable() }
NeoBundle "Shougo/neomru.vim"
NeoBundle "Shougo/neoyank.vim"
NeoBundle "Shougo/neosnippet", { "depends": "Shougo/context_filetype.vim" }
NeoBundle "Shougo/neosnippet-snippets"
NeoBundle "tyru/open-browser.vim"
NeoBundle "tyru/operator-camelize.vim"
NeoBundle "vim-scripts/QuickBuf", { "disabled": 1 }
NeoBundle "kien/rainbow_parentheses.vim", { "disabled": 1 }
NeoBundle "chrisbra/Recover.vim"
NeoBundle "sequence"
NeoBundle "joeytwiddle/sexy_scroller.vim"
NeoBundle "jiangmiao/simple-javascript-indenter"
NeoBundle "AndrewRadev/splitjoin.vim"
NeoBundle "sudo.vim"
NeoBundle "kg8m/svn-diff.vim"
NeoBundle "vim-scripts/Unicode-RST-Tables"
NeoBundle "Shougo/unite.vim"
NeoBundle "kg8m/unite-dwm"
NeoBundle "osyo-manga/unite-filetype"
NeoBundle "Shougo/unite-help"
NeoBundle "tacroe/unite-mark"
NeoBundle "Shougo/unite-outline"
NeoBundle "basyura/unite-rails"
NeoBundle "tsukkee/unite-tag"
NeoBundle "pasela/unite-webcolorname"
NeoBundle "h1mesuke/vim-alignta"
NeoBundle "osyo-manga/vim-anzu"
NeoBundle "haya14busa/vim-asterisk"
NeoBundle "Townk/vim-autoclose"
NeoBundle "itchyny/vim-autoft"
NeoBundle "kg8m/vim-blockle"
NeoBundle "t9md/vim-choosewin"
NeoBundle "kchmck/vim-coffee-script"
NeoBundle "kg8m/vim-coloresque"
NeoBundle "hail2u/vim-css-syntax"
NeoBundle "hail2u/vim-css3-syntax"
NeoBundle "Lokaltog/vim-easymotion"
NeoBundle "tpope/vim-endwise", {
        \   "disabled":    1,
        \   "description": "incompatible with neosnippet",
        \ }
NeoBundle "thinca/vim-ft-diff_fold"
NeoBundle "thinca/vim-ft-help_fold"
NeoBundle "thinca/vim-ft-markdown_fold"
NeoBundle "lambdalisue/vim-gista"
NeoBundle "thinca/vim-ft-svn_diff"
NeoBundle "thinca/vim-ft-vim_fold", { "disabled": 1 }
NeoBundle "muz/vim-gemfile"
NeoBundle "tpope/vim-git"
NeoBundle "tpope/vim-haml"
NeoBundle "michaeljsmith/vim-indent-object"
NeoBundle "pangloss/vim-javascript", { "disabled": 1 }
NeoBundle "jelera/vim-javascript-syntax"
NeoBundle "elzr/vim-json"
NeoBundle "rcmdnk/vim-markdown"
NeoBundle "joker1007/vim-markdown-quote-syntax"
NeoBundle "amdt/vim-niji", { "disabled": 1 }
NeoBundle "kana/vim-operator-replace"
" not working in case like following:
"   (1) text:      hoge "fu*ga piyo"
"   (2) call: <Plug>(operator-surround-append)"'
"   (3) expected:  hoge* '"fuga piyo"'
"   (4) result:    hoge*' "fuga piyo"'
" or following:
"   (2) call: <Plug>(operator-surround-replace)"'
"   (3) expected:  hoge* 'fuga piyo'
"   (4) result:    hoge*' fuga piyo'
NeoBundle "rhysd/vim-operator-surround", { "disabled": 1 }
NeoBundle "kana/vim-operator-user"
NeoBundle "thinca/vim-prettyprint"
NeoBundle "thinca/vim-qfreplace"
NeoBundle "tpope/vim-rails"
NeoBundle "thinca/vim-ref"
NeoBundle "tpope/vim-repeat"
NeoBundle "vim-ruby/vim-ruby", {
        \   "description": "do not make lazy because ftdetecting does not work",
        \ }
NeoBundle "joker1007/vim-ruby-heredoc-syntax"
NeoBundle "kg8m/vim-rubytest", { "disabled": OnTmux() }
NeoBundle "thinca/vim-singleton"
NeoBundle "honza/vim-snippets"
NeoBundle "mhinz/vim-startify"
NeoBundle "kopischke/vim-stay"
NeoBundle "tpope/vim-surround"
NeoBundle "deris/vim-textobj-enclosedsyntax"
NeoBundle "kana/vim-textobj-jabraces"
NeoBundle "osyo-manga/vim-textobj-multitextobj"
NeoBundle "rhysd/vim-textobj-ruby"
NeoBundle "jgdavey/vim-turbux", { "disabled": !OnTmux() }
NeoBundle "kana/vim-textobj-user"
NeoBundle "thinca/vim-unite-history"
NeoBundle "hrsh7th/vim-unite-vcs", {
        \   "disabled":    1,
        \   "description": "replaced by vim-versions",
        \ }
NeoBundle "hrsh7th/vim-versions"
NeoBundle "superbrothers/vim-vimperator"
NeoBundle "thinca/vim-zenspace"
NeoBundle "Shougo/vimfiler"
NeoBundle "Shougo/vimshell"
NeoBundle "benmills/vimux", { "disabled": !OnTmux() }
NeoBundle "simeji/winresizer"
NeoBundle "LeafCage/yankround.vim"

" colorschemes
NeoBundle "hail2u/h2u_colorscheme"  " for printing
NeoBundle "kg8m/molokai"
" }}}

" plugins settings  "{{{
if neobundle#tap("alpaca_complete")  "{{{
  call neobundle#config({
  \ "on_ft": ["ruby", "eruby"],
  \})
endif  " }}}

if neobundle#tap("autodate.vim")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:autodate_format       = "%Y/%m/%d"
    let g:autodate_lines        = 100
    let g:autodate_keyword_pre  = '\c\%(' .
                                \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                                \   '\%(最終更新日\?\)\|' .
                                \   '\%(更新日\)' .
                                \ '\):'
    let g:autodate_keyword_post = '\.$'
  endfunction
endif  " }}}

if neobundle#tap("calendar.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": "Calendar",
  \})

  function! neobundle#hooks.on_source(bundle) abort
    let g:calendar_google_calendar = 1
    let g:calendar_first_day       = "monday"
  endfunction
endif  " }}}

if neobundle#tap("caw.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>(caw:"],
  \})

  nmap gc <Plug>(caw:i:toggle)
  vmap gc <Plug>(caw:i:toggle)

  function! neobundle#hooks.on_source(bundle) abort
    let g:caw_no_default_keymappings = 1
    let g:caw_i_skip_blank_line      = 1
  endfunction
endif  " }}}

if neobundle#tap("colorswatch.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": "ColorSwatchGenerate",
  \})
endif  " }}}

if neobundle#tap("dwm.vim")  "{{{
  nmap <C-w>n       :call DWM_New()<Cr>
  nmap <C-w>c       :call DWM_Close()<Cr>
  nmap <C-w><Space> :call DWM_AutoEnter()<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    let g:dwm_map_keys = 0
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
  endfunction
endif  " }}}

if neobundle#tap("emmet-vim")  "{{{
  call neobundle#config({
  \ "lazy": 1,
  \ "on_i": 1,
  \})

  function! neobundle#hooks.on_source(bundle) abort
    " command: <C-y>,
    let g:user_emmet_settings = {
      \   "indentation": "  ",
      \   "lang": "ja",
      \   "eruby": {
      \     "extends": ["javascript", "html"],
      \   },
      \   "html": {
      \     "extends": "javascript",
      \     "snippets" : {
      \       "label": "<label>${cursor}</label>",
      \       "script": "<script type=\"text/javascript\">\n  ${cursor}\n</script>",
      \     },
      \   },
      \   "javascript": {
      \     "snippets": {
      \       "jq": "jQuery(function() {\n  ${cursor}${child}\n});",
      \       "jq:each": "jQuery.each(arr, function(index, item)\n  ${child}\n});",
      \       "fn": "(function() {\n  ${cursor}\n})();",
      \       "tm": "setTimeout(function() {\n  ${cursor}\n}, 100);",
      \       "if": "if (${cursor}) {\n};",
      \       "ife": "if (${cursor}) {\n} else if (${cursor}) {\n} else {\n};",
      \     },
      \   },
      \ }
  endfunction
endif  " }}}

if neobundle#tap("foldCC")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:foldCCtext_enable_autofdc_adjuster = 1
    let g:foldCCtext_maxchars = 120
    set foldtext=FoldCCtext()
  endfunction
endif  " }}}

if neobundle#tap("gundo.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": "GundoToggle",
  \})

  nnoremap <F5> :GundoToggle<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    " http://d.hatena.ne.jp/heavenshell/20120218/1329532535
    let g:gundo_auto_preview = 0
  endfunction
endif  " }}}

if neobundle#tap("HowMuch")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>AutoCalc"],
  \})

  vmap <Leader>? <Plug>AutoCalcReplace
  vmap <Leader>?s <Plug>AutoCalcReplaceWithSum

  function! neobundle#hooks.on_source(bundle) abort
    " replace expr with result
    let g:HowMuch_scale = 5
  endfunction
endif  " }}}

if neobundle#tap("increment-activator")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:increment_activator_filetype_candidates = {
      \   "_": [
      \     ["有", "無"],
      \     ["日", "月", "火", "水", "木", "金", "土"],
      \     [
      \       "a", "b", "c", "d", "e", "f", "g",
      \       "h", "i", "j", "k", "l", "m", "n", "o", "p",
      \       "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
      \     ],
      \     [
      \       "A", "B", "C", "D", "E", "F", "G",
      \       "H", "I", "J", "K", "L", "M", "N", "O", "P",
      \       "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
      \     ],
      \     [
      \       "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩",
      \       "⑪", "⑫", "⑬", "⑭", "⑮", "⑯", "⑰", "⑱", "⑲", "⑳",
      \     ],
      \     [
      \       "first", "second", "third", "fourth", "fifth",
      \       "sixth", "seventh", "eighth", "ninth", "tenth",
      \     ],
      \   ],
      \   "ruby": [
      \     ["should", "should_not"],
      \     ["be_true", "be_false"],
      \     ["be_present", "be_blank", "be_empty", "be_nil"],
      \   ],
      \ }
  endfunction
endif  " }}}

if neobundle#tap("incsearch.vim")  "{{{
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
  map n  <Plug>(incsearch-nohl-n)<Plug>(anzu-update-search-status-with-echo)
  map N  <Plug>(incsearch-nohl-N)<Plug>(anzu-update-search-status-with-echo)
  map *  <Plug>(incsearch-nohl)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
  map #  <Plug>(incsearch-nohl)<Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)
  map g* <Plug>(incsearch-nohl)<Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
  map g# <Plug>(incsearch-nohl)<Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)

  function! neobundle#hooks.on_source(bundle) abort
    " asterisk's `z` commands are "stay star motions"
    let g:incsearch#auto_nohlsearch = 0
    let g:incsearch#magic = '\v'
  endfunction

  if neobundle#tap("incsearch-index.vim")  "{{{
    map /  <Plug>(incsearch-index-/)
    map ?  <Plug>(incsearch-index-?)
  endif  " }}}
endif  " }}}

if neobundle#tap("indentLine")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:indentLine_char = "|"
  endfunction
endif  " }}}

if neobundle#tap("JpFormat.vim")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let JpCountChars = 37
  endfunction
endif  " }}}

if neobundle#tap("jscomplete-vim.git")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:jscomplete_use = ["dom", "moz", "es6th"]
  endfunction
endif  " }}}

if neobundle#tap("lightline.vim")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    " http://d.hatena.ne.jp/itchyny/20130828/1377653592
    set laststatus=2
    let s:lightline_elements = {
      \   "left": [
      \     [ "mode", "paste" ],
      \     [ "bufnum", "filename" ],
      \     [ "filetype", "fileencoding", "fileformat" ],
      \     [ "lineinfo_with_percent" ],
      \   ],
      \   "right": [
      \   ],
      \ }
    let g:lightline = {
      \   "active": s:lightline_elements,
      \   "inactive": s:lightline_elements,
      \   "component": {
      \     "bufnum": "#%n",
      \     "lineinfo_with_percent": "%l/%L(%p%%) : %v",
      \   },
      \   "component_function": {
      \     "filename": "FilepathForLightline",
      \   },
      \   "colorscheme": "molokai",
      \ }

    function! ReadonlySymbolForLightline()
      return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? "X" : ""
    endfunction

    function! FilepathForLightline()
      return ("" != ReadonlySymbolForLightline() ? ReadonlySymbolForLightline() . " " : "") .
           \ (
           \   &ft == "vimfiler" ? vimfiler#get_status_string() :
           \   &ft == "unite" ? unite#get_status_string() :
           \   &ft == "vimshell" ? vimshell#get_status_string() :
           \   "" != expand("%:t") ? (
           \     winwidth(0) >= 100 ? expand("%:F") : expand("%:t")
           \   ) : "[No Name]"
           \ ) .
           \ ("" != ModifiedSymbolForLightline() ? " " . ModifiedSymbolForLightline() : "")
    endfunction

    function! ModifiedSymbolForLightline()
      return &ft =~ 'help\|vimfiler\|gundo' ? "" : &modified ? "+" : &modifiable ? "" : "-"
    endfunction
  endfunction
endif  " }}}

if neobundle#tap("linediff.vim")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:linediff_second_buffer_command = "rightbelow vertical new"
  endfunction
endif  " }}}

if neobundle#tap("neocomplcache.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_i":   1,
  \ "on_cmd": "NeoCompleteBufferMakeCache",
  \})

  function! neobundle#hooks.on_source(bundle) abort
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

    if !exists("g:neocomplcache_keyword_patterns")
      let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns["default"] = '\h\w*'
    let g:neocomplcache_keyword_patterns["ruby"] = '\h\w*'

    if !exists("g:neocomplcache_omni_patterns")
      let g:neocomplcache_omni_patterns = {}
    endif
    let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

    let g:neocomplcache_caching_limit_file_size = 500000
  endfunction
endif  " }}}

if neobundle#tap("neocomplete.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_i":   1,
  \ "on_cmd": "NeoCompleteBufferMakeCache",
  \})

  function! neobundle#hooks.on_source(bundle) abort
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
    let g:neocomplete#sources#tags#cache_limit_size = 1000

    if !exists("g:neocomplete#keyword_patterns")
      let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns["default"] = '\h\w*'
    let g:neocomplete#keyword_patterns["ruby"] = '\h\w*'

    if !exists("g:neocomplete#sources#omni#input_patterns")
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
    let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

    let g:sources#buffer#cache_limit_size = 500000

    if !exists("g:neocomplete#same_filetypes")
      let g:neocomplete#same_filetypes = {}
    endif
    let g:neocomplete#same_filetypes._ = "_"

    augroup SetOmunifuncs
      autocmd!
      autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
      autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
      autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
      autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
      " jscomplete
      autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
    augroup END
  endfunction
endif  " }}}

if neobundle#tap("neosnippet")  "{{{
  call neobundle#config({
  \ "lazy":      1,
  \ "on_i":      1,
  \ "on_ft":     ["snippet", "neosnippet"],
  \ "on_source": "unite.vim",
  \})

  function! neobundle#hooks.on_source(bundle) abort
    imap <expr><Tab> pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    smap <expr><Tab> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    if s:neocomplete_available
      imap <expr><Cr> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#close_popup() : "\<Cr>"
    else
      imap <expr><Cr> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplcache#close_popup() : "\<Cr>"
    endif

    if has("conceal")
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
  endfunction
endif  " }}}

if neobundle#tap("open-browser.vim")  "{{{
  call neobundle#config({
  \ "lazy":    1,
  \ "on_cmd":  ["OpenBrowserSearch", "OpenBrowser"],
  \ "on_func": "openbrowser#open",
  \ "on_map":  "<Plug>(openbrowser-open)",
  \})

  nmap <Leader>o <Plug>(openbrowser-open)
  vmap <Leader>o <Plug>(openbrowser-open)

  function! neobundle#hooks.on_source(bundle) abort
    let g:openbrowser_browser_commands = [
      \   {
      \     "name": "ssh",
      \     "args": "ssh main 'open '\\''{uri}'\\'''",
      \   }
      \ ]
  endfunction
endif  " }}}

if neobundle#tap("operator-camelize.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"],
  \})

  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)
endif  " }}}

if neobundle#tap("sequence")  "{{{
  vmap <Leader>+ <plug>SequenceV_Increment
  vmap <Leader>- <plug>SequenceV_Decrement
  nmap <Leader>+ <plug>SequenceN_Increment
  nmap <Leader>- <plug>SequenceN_Decrement
endif  " }}}

if neobundle#tap("simple-javascript-indenter")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:SimpleJsIndenter_BriefMode = 2
    let g:SimpleJsIndenter_CaseIndentLevel = -1
  endfunction
endif  " }}}

if neobundle#tap("splitjoin.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": ["SplitjoinJoin", "SplitjoinSplit"],
  \})

  nnoremap <Leader>J :SplitjoinJoin<Cr>
  nnoremap <Leader>S :SplitjoinSplit<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    let g:splitjoin_split_mapping       = ""
    let g:splitjoin_join_mapping        = ""
    let g:splitjoin_ruby_trailing_comma = 1
    let g:splitjoin_ruby_hanging_args   = 0
  endfunction
endif  " }}}

if neobundle#tap("Unicode-RST-Tables")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:no_rst_table_maps = 0
  endfunction
endif  " }}}

if neobundle#tap("unite.vim")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": "Unite",
  \})

  nnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  nnoremap <Leader>ug :<C-u>Unite -no-quit -winheight=50% grep:./::
  vnoremap <Leader>ug "vy:<C-u>Unite -no-quit -winheight=50% grep:./::<C-r>"
  nnoremap <Leader>uy :<C-u>Unite history/yank<Cr>
  nnoremap <Leader>uc :<C-u>Unite webcolorname<Cr>
  nnoremap <Leader>ub :<C-u>Unite buffer<Cr>
  nnoremap <Leader>uf :<C-u>UniteWithBufferDir -buffer-name=files file<Cr>
  " nnoremap <Leader>ur :<C-u>Unite -buffer-name=register register<Cr>
  " nnoremap <Leader>um :<C-u>Unite neomru/file<Cr>
  nnoremap <Leader>uu :<C-u>Unite buffer neomru/file<Cr>
  nnoremap <Leader>ua :<C-u>UniteWithBufferDir -buffer-name=files buffer neomru/file bookmark file<Cr>
  nnoremap <F4> :<C-u>Unite buffer<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    let g:unite_winheight = "100%"
    let g:unite_cursor_line_highlight = "CursorLine"

    " use ack because pt and ag don't sort search result
    if s:pt_available || s:ag_available || s:ack_available
      let g:unite_source_grep_recursive_opt = ""

      if s:pt_available && 0
        let g:unite_source_grep_command      = "pt"
        let g:unite_source_grep_default_opts = "--nocolor --nogroup"
      else
        let g:unite_source_grep_default_opts = "--nocolor --nogroup --nopager"

        if s:ag_available && 0
          let g:unite_source_grep_command = "ag"
        elseif s:ack_available
          let g:unite_source_grep_command = "ack"
        endif
      endif
    endif

    let g:unite_source_grep_search_word_highlight = "Special"

    call unite#custom#source("buffer", "sorters", "sorter_word")
    call unite#custom#source("grep", "max_candidates", 1000)

    " unite-shortcut  "{{{
      " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
      " http://d.hatena.ne.jp/tyru/20120110/prompt
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
        \   ["[System] Remove/Delete                   ", "!rm %"],
        \   ["[System] SVN Remove/Delete               ", "!svn rm %"],
        \
        \   ["[JpFormat] format all selected for mail  ", "'<,'>JpFormatAll!"],
        \
        \   ["[Calendar] Year View                     ", "Calendar -view=year  -position=hear!"],
        \   ["[Calendar] Month View                    ", "Calendar -view=month -position=hear!"],
        \   ["[Calendar] Week View                     ", "Calendar -view=week  -position=hear!"],
        \   ["[Calendar] Day View                      ", "Calendar -view=day   -position=hear! -split=vertical -width=75"],
        \
        \   ["[Unicode-RST-Tables] Create Table        ", "python CreateTable()"],
        \   ["[Unicode-RST-Tables] Fix Table           ", "python FixTable()"],
        \
        \   ["[Unite plugin] gist                      ", "Unite gista"],
        \   ["[Unite plugin] mru files list            ", "Unite neomru/file"],
        \   ["[Unite plugin] neobundle/update          ", "Unite neobundle/update:all -log"],
        \   ["[Unite plugin] outline                   ", "Unite outline:!"],
        \   ["[Unite plugin] tag with cursor word      ", "UniteWithCursorWord tag"],
        \   ["[Unite plugin] versions/status           ", "UniteVersions status:./"],
        \   ["[Unite plugin] versions/log              ", "UniteVersions log:./"],
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
             \   "word" : word . "  --  `" . value . "`",
             \   "kind" : "command",
             \   "action__command" : value,
             \ }
      endfunction
    " }}}
  endfunction

  if neobundle#tap("neomru.vim")  "{{{
    call neobundle#config({
    \ "lazy":      0,
    \ "on_source": "unite.vim",
    \})

    nnoremap <Leader>m :<C-u>Unite neomru/file<Cr>

    function! neobundle#hooks.on_source(bundle) abort
      let g:neomru#time_format     = "(%Y/%m/%d %H:%M:%S) "
      let g:neomru#filename_format = ":~:."
      let g:neomru#file_mru_limit  = 1000
    endfunction
  endif  " }}}

  if neobundle#tap("neoyank.vim")  "{{{
    call neobundle#config({
    \ "lazy":      0,
    \ "on_source": "unite.vim",
    \})

    function! neobundle#hooks.on_source(bundle) abort
      let g:neoyank#limit = 300
    endfunction
  endif  " }}}

  if neobundle#tap("unite-dwm")  "{{{
    call neobundle#config({
    \ "lazy":  1,
    \ "on_ft": "unite",
    \})

    function! neobundle#hooks.on_source(bundle) abort
      let g:unite_dwm_source_names_as_default_action = "buffer,file,file_mru,cdable"
    endfunction
  endif  " }}}

  if neobundle#tap("unite-filetype")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_source": "unite.vim",
    \})
  endif  " }}}

  if neobundle#tap("unite-mark")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_func":   "AutoMark",
    \ "on_source": "unite.vim",
    \ "depends":   "unite.vim",
    \})

    nnoremap <Leader>um :<C-u>Unite mark<Cr>
    " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
    nnoremap <silent> m :<C-u>call AutoMark()<Cr>

    function! neobundle#hooks.on_source(bundle) abort
      let g:mark_ids = [
        \   "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        \   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        \ ]
      let g:unite_source_mark_marks = join(g:mark_ids, "")
      function! AutoMark()
          if !exists("b:mark_position")
            let b:mark_position = 0
          else
            let b:mark_position = (b:mark_position + 1) % len(g:mark_ids)
          endif

          execute "mark" g:mark_ids[b:mark_position]
          echo "marked" g:mark_ids[b:mark_position]
      endfunction
      augroup InitMarks
        autocmd!
        autocmd BufReadPost * delmarks!
      augroup END
    endfunction
  endif  " }}}

  if neobundle#tap("unite-outline")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_source": "unite.vim",
    \})

    nnoremap <Leader>uo :<C-u>Unite outline:!<Cr>
  endif  " }}}

  if neobundle#tap("unite-rails")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_source": "unite.vim",
    \})

    nnoremap <Leader>ur :<C-u>Unite rails/
  endif  " }}}

  if neobundle#tap("unite-tag")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_cmd":    "UniteWithCursorWord",
    \ "on_source": "unite.vim",
    \ "depends":   "unite.vim",
    \})

    nnoremap g] :<C-u>UniteWithCursorWord -immediately tag<CR>
    vnoremap g] :<C-u>UniteWithCursorWord -immediately tag<CR>
    nnoremap g[ :<C-u>Unite jump<CR>
    nnoremap <Leader>ut :<C-u>UniteWithCursorWord -immediately tag<Cr>
  endif  " }}}

  if neobundle#tap("unite-webcolorname")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_source": "unite.vim",
    \})
  endif  " }}}

  if neobundle#tap("vim-unite-history")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_source": "unite.vim",
    \})
  endif  " }}}

  if neobundle#tap("vim-versions")  "{{{
    call neobundle#config({
    \ "lazy":      1,
    \ "on_cmd":    "UniteVersions",
    \ "on_source": "unite.vim",
    \ "depends":   "unite.vim",
    \})

    nnoremap <Leader>uv :<C-u>UniteVersions status:./<Cr>

    function! neobundle#hooks.on_source(bundle) abort
      let g:versions#type#svn#status#ignore_status = ["X"]

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
              let l:candidate.kind = "directory"
              call unite#take_action("vimfiler", l:candidate)
            else
              let l:candidate.kind = "file"
              call unite#take_action("open", l:candidate)
            endif
          endfor
        endfunction

        call unite#custom#action("versions/git/status,versions/svn/status", "open", l:action)
        call unite#custom#default_action("versions/git/status,versions/svn/status", "open")
      endfunction
      call s:AddActionsToVersions()
    endfunction
  endif  " }}}
endif  " }}}

if neobundle#tap("vim-alignta")  "{{{
  call neobundle#config({
  \ "lazy":      0,
  \ "on_cmd":    "Alignta",
  \ "on_source": "unite.vim",
  \})

  vnoremap <Leader>a :Alignta<Space>
  vnoremap <Leader>ua :<C-u>Unite alignta:arguments<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    let g:unite_source_alignta_preset_arguments = [
      \   ["Align at '=>'       --  `=>`",                        '=>'],
      \   ["Align at /\\S/      --  `\\S\\+`",                    '\S\+'],
      \   ["Align at /\\S/ once --  `\\S\\+/1`",                  '\S\+/1'],
      \   ["Align at '='        --  `=>\\=`",                     '=>\='],
      \   ["Align at ':hoge'    --  `10 :`",                      '10 :'],
      \   ["Align at 'hoge:'    --  `00 [a-zA-Z0-9_\"']\\+:\\s`", " 00 [a-zA-Z0-9_\"']\\+:\\s"],
      \   ["Align at '|'        --  `|`",                         '|'],
      \   ["Align at ')'        --  `0 )`",                       '0 )'],
      \   ["Align at ']'        --  `0 ]`",                       '0 ]'],
      \   ["Align at '}'        --  `}`",                         '}'],
      \   ["Align at 'hoge,'    --  `00 \\w\\+, ` -- not working", '00 \w\+, '],
      \ ]
    let s:alignta_comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'
    let g:unite_source_alignta_preset_options = [
      \   ["Justify Left",      "<<"],
      \   ["Justify Center",    "||"],
      \   ["Justify Right",     ">>"],
      \   ["Justify None",      "=="],
      \   ["Shift Left",        "<-"],
      \   ["Shift Right",       "->"],
      \   ["Shift Left [Tab]",  "<--"],
      \   ["Shift Right [Tab]", "-->"],
      \   ["Margin 0:0",        "0"],
      \   ["Margin 0:1",        "01"],
      \   ["Margin 1:0",        "10"],
      \   ["Margin 1:1",        "1"],
      \
      \   ["Regexp", "-r {regexp}/{regexp_options}"],
      \
      \   "v/" . s:alignta_comment_leadings,
      \   "g/" . s:alignta_comment_leadings,
      \ ]
    unlet s:alignta_comment_leadings
  endfunction
endif  " }}}

if neobundle#tap("vim-anzu")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>(anzu-"],
  \})

  " see incsearch
endif  " }}}

if neobundle#tap("vim-asterisk")  "{{{
  " see incsearch
endif  " }}}

if neobundle#tap("vim-autoclose")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    " annoying to type "<<" in Ruby code>
    " let g:AutoClosePairs_add = "<>"
    let g:AutoCloseSelectionWrapPrefix = "<Leader>ac"

    " https://github.com/Townk/vim-autoclose/blob/master/plugin/AutoClose.vim#L29
    if s:on_mac
      imap <silent> <Esc>OA <Up>
      imap <silent> <Esc>OB <Down>
      imap <silent> <Esc>OC <Right>
      imap <silent> <Esc>OD <Left>
      imap <silent> <Esc>OH <Home>
      imap <silent> <Esc>OF <End>
      imap <silent> <Esc>[5~ <PageUp>
      imap <silent> <Esc>[6~ <PageDown>
    endif
  endfunction
endif  " }}}

if neobundle#tap("vim-autoft")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:autoft_config = [
      \   { "filetype": "html",       "pattern": '<\%(!DOCTYPE\|html\|head\|script\)' },
      \   { "filetype": "javascript", "pattern": '\%(^\s*\<var\>\s\+[a-zA-Z]\+\)\|\%(function\%(\s\+[a-zA-Z]\+\)\?\s*(\)' },
      \   { "filetype": "c",          "pattern": '^\s*#\s*\%(include\|define\)\>' },
      \   { "filetype": "sh",         "pattern": '^#!.*\%(\<sh\>\|\<bash\>\)\s*$' },
      \ ]
  endfunction
endif  " }}}

if neobundle#tap("vim-blockle")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:blockle_mapping = ",b"
    let g:blockle_erase_spaces_around_starting_brace = 1
  endfunction
endif  " }}}

if neobundle#tap("vim-choosewin")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>(choosewin)"],
  \})

  nmap <C-w>f <Plug>(choosewin)

  function! neobundle#hooks.on_source(bundle) abort
    let g:choosewin_overlay_enable          = 0  " wanna set true but too heavy
    let g:choosewin_overlay_clear_multibyte = 1
    let g:choosewin_blink_on_land           = 0
    let g:choosewin_statusline_replace      = 1  " wanna set false and use overlay
    let g:choosewin_tabline_replace         = 0
  endfunction
endif  " }}}

if neobundle#tap("vim-easymotion")  "{{{
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

  function! neobundle#hooks.on_source(bundle) abort
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
  endfunction
endif  " }}}

if neobundle#tap("vim-gista")  "{{{
  call neobundle#config({
  \ "lazy":      1,
  \ "on_cmd":    "Gista",
  \ "on_map":    "<Plug>(gista-",
  \ "on_source": "unite.vim",
  \})

  function! neobundle#hooks.on_source(bundle) abort
    let g:gista#github_user = "kg8m"
  endfunction
endif  " }}}

if neobundle#tap("vim-javascript-syntax")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    function! s:MyJavascriptFold()
      if !exists("b:javascript_folded")
        call JavaScriptFold()
        setl foldlevelstart=0
        let b:javascript_folded = 1
      endif
    endfunction
  endfunction
endif  " }}}

if neobundle#tap("vim-json")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:vim_json_syntax_conceal = 0
  endfunction
endif  " }}}

if neobundle#tap("vim-markdown")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:markdown_quote_syntax_filetypes = {
      \   "coffee": {
      \     "start": "coffee",
      \   },
      \   "crontab": {
      \     "start": "cron\\%(tab\\)\\?",
      \   },
      \ }

    augroup ResetMarkdownIndentexpr
      autocmd!
      autocmd FileType markdown setlocal indentexpr=smartindent
    augroup END
  endfunction
endif  " }}}

if neobundle#tap("vim-operator-replace")  "{{{
  call neobundle#config({
  \ "lazy":    1,
  \ "on_map": ["ns", "<Plug>(operator-replace)"],
  \})

  nmap r <Plug>(operator-replace)
  vmap r <Plug>(operator-replace)
endif  " }}}

if neobundle#tap("vim-operator-surround")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["ns", "<Plug>(operator-surround-"],
  \})

  nmap <silent>sa <Plug>(operator-surround-append)
  nmap <silent>sd <Plug>(operator-surround-delete)
  nmap <silent>sr <Plug>(operator-surround-replace)
  vmap <silent>sa <Plug>(operator-surround-append)
  vmap <silent>sd <Plug>(operator-surround-delete)
  vmap <silent>sr <Plug>(operator-surround-replace)
endif  " }}}

if neobundle#tap("vim-operator-user")  "{{{
  call neobundle#config({
  \ "lazy":    1,
  \ "on_func": "operator#user#define",
  \})
endif  " }}}

if neobundle#tap("vim-prettyprint")  "{{{
  call neobundle#config({
  \ "lazy":    1,
  \ "on_cmd":  ["PrettyPrint", "PP"],
  \ "on_func": ["PrettyPrint", "PP"],
  \})
endif  " }}}

if neobundle#tap("vim-qfreplace")  "{{{
  call neobundle#config({
  \ "lazy":  1,
  \ "on_ft": ["unite", "quickfix"]
  \})
endif  " }}}

if neobundle#tap("vim-rails")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    " http://fg-180.katamayu.net/archives/2006/09/02/125150
    let g:rails_level = 4
    let g:rails_projections = {
      \   "config/*": {
      \     "command": "config",
      \   },
      \   "script/*": {
      \     "command": "script",
      \     "test":    [
      \       "test/script/%s_test.rb",
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
      \ }
    " prevent `rails.vim` from defining keymappings
    nmap <Leader>Rwf  <Plug>RailsSplitFind
    nmap <Leader>Rwgf <Plug>RailsTabFind

    let &path = &path . ",spec/support"
  endfunction
endif  " }}}

if neobundle#tap("vim-ref")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": "Ref",
  \ "on_map": "<Plug>(ref-keyword)",
  \})

  nmap K <Plug>(ref-keyword)
endif  " }}}

if neobundle#tap("vim-ruby")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:no_ruby_maps = 1
  endfunction
endif  " }}}

if neobundle#tap("vim-ruby-heredoc-syntax")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:ruby_heredoc_syntax_filetypes = {
      \   "haml": { "start": "HAML" },
      \   "ruby": { "start": "RUBY" },
      \ }
  endfunction
endif  " }}}

if neobundle#tap("vim-rubytest")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": ["<Plug>RubyFileRun", "<Plug>RubyTestRun"],
  \})

  nmap <leader>T <Plug>RubyFileRun
  nmap <leader>t <Plug>RubyTestRun

  function! neobundle#hooks.on_source(bundle) abort
    let g:no_rubytest_mappings = 1
    let g:rubytest_in_vimshell = 1
  endfunction
endif  " }}}

if neobundle#tap("vim-singleton")  "{{{
  call neobundle#config({
  \ "gui": 1,
  \})

  function! neobundle#hooks.on_source(bundle) abort
    if has("gui_running") && !singleton#is_master()
      let g:singleton#opener = "drop"
      call singleton#enable()
    endif
  endfunction
endif  " }}}

if neobundle#tap("vim-startify")  "{{{
  function! neobundle#hooks.on_post_source(bundle) abort
    highlight StartifyFile   ctermfg=255
    highlight StartifyHeader ctermfg=255
    highlight StartifyPath   ctermfg=245
    highlight StartifySlash  ctermfg=245
    let g:startify_enable_special = 1
    let g:startify_change_to_dir  = 0
    let g:startify_list_order     = [
      \   ["   My bookmarks:"],
      \   "bookmarks",
      \   ["   Last recently opened files:"],
      \   "files",
      \   ["   Last recently modified files in the current directory:"],
      \   "dir",
      \   ["   My sessions:"],
      \   "sessions",
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
      \   "",
      \   "",
      \   "     * Vim version: " . v:version,
      \   "",
      \   "     * " . s:AvailabilityMessage("neocomplete"),
      \   "     * " . s:AvailabilityMessage("pt"),
      \   "     * " . s:AvailabilityMessage("ag"),
      \   "     * " . s:AvailabilityMessage("ack"),
      \   "     * " . s:AvailabilityMessage("migemo"),
      \   "",
      \   "",
      \ ]
  endfunction
endif  " }}}

if neobundle#tap("vim-stay")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    set viewoptions=cursor
  endfunction
endif  " }}}

if neobundle#tap("vim-textobj-multitextobj")  "{{{
  omap aj <Plug>(textobj-multitextobj-a)
  omap ij <Plug>(textobj-multitextobj-i)
  vmap aj <Plug>(textobj-multitextobj-a)
  vmap ij <Plug>(textobj-multitextobj-i)

  function! neobundle#hooks.on_source(bundle) abort
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
  endfunction
endif  " }}}

if neobundle#tap("vim-turbux")  "{{{
  map <leader>T <Plug>SendTestToTmux
  map <leader>t <Plug>SendFocusedTestToTmux

  function! neobundle#hooks.on_source(bundle) abort
    let g:no_turbux_mappings = 1
    let g:turbux_test_type   = ""  " FIXME: escape undefined g:turbux_test_type error
  endfunction
endif  " }}}

if neobundle#tap("vim-zenspace")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:zenspace#default_mode = "on"

    augroup HighlightZenkakuSpace
      autocmd!
      autocmd ColorScheme * highlight ZenSpace term=underline ctermbg=Cyan guibg=Cyan
    augroup END
  endfunction
endif  " }}}

if neobundle#tap("vimfiler")  "{{{
  nnoremap <Leader>e :VimFilerBufferDir -force-quit<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    call vimfiler#custom#profile("default", "context", {
       \   "safe": 0,
       \   "split_action": "dwm_open",
       \ })
  endfunction
endif  " }}}

if neobundle#tap("vimshell")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_cmd": ["VimShell", "VimShellExecute"],
  \})

  nnoremap <Leader>s :VimShell<Cr>

  function! neobundle#hooks.on_source(bundle) abort
    if s:on_windows
      let g:_user_name = $USERNAME
    else
      let g:_user_name = $USER
    endif

    let g:vimshell_user_prompt = '"[".g:_user_name."@".hostname()."] ".getcwd()'
    let g:vimshell_right_prompt = '"(".strftime("%y/%m/%d %H:%M:%S", localtime()).")"'
    let g:vimshell_prompt = "% "
  endfunction
endif  " }}}

if neobundle#tap("vimux")  "{{{
  function! neobundle#hooks.on_source(bundle) abort
    let g:VimuxHeight = 30
    let g:VimuxUseNearest = 1

    function! s:ExtendVimux()
      " overriding default function: use current pane"s next one
      execute join([
      \   'function! _VimuxNearestIndex()',
      \     'let views = split(_VimuxTmux("list-"._VimuxRunnerType()."s"), "\n")',
      \     'let index = len(views) - 1',
      \
      \     'while index >= 0',
      \       'let view = views[index]',
      \
      \       'if match(view, "(active)") != -1',
      \         'if index == len(views) - 1',
      \           'return -1',
      \         'else',
      \           'return split(views[index + 1], ":")[0]',
      \         'endif',
      \       'endif',
      \
      \       'let index = index - 1',
      \     'endwhile',
      \   'endfunction',
      \ ], "\n")
    endfunction

    augroup Vimux
      autocmd!
      autocmd VimEnter * call s:ExtendVimux()
      autocmd VimLeavePre * :VimuxCloseRunner
    augroup END
  endfunction
endif  " }}}

if neobundle#tap("winresizer")  "{{{
  call neobundle#config({
  \ "lazy":   1,
  \ "on_map": "<C-w><C-e>",
  \})

  let g:winresizer_start_key = "<C-w><C-e>"
endif  " }}}

if neobundle#tap("yankround.vim")  "{{{
  nmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif  " }}}
" }}}

" neobundle#end  "{{{
call neobundle#end()
filetype plugin indent on
syntax enable

if has("vim_starting")
  NeoBundleCheck
endif

" colorscheme
let g:molokai_original = 1
colorscheme molokai
" }}}
" }}}

" ----------------------------------------------
" encoding  "{{{
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# "utf-8"
  set encoding=japan
  set fileencoding=japan
endif

function! s:RecheckFileencoding()
  if &fileencoding =~# "iso-2022-jp" && search("[^\x01-\x7e]", "n") == 0
    let &fileencoding=&encoding
  endif
endfunction

augroup CheckEncoding
  autocmd!
  autocmd BufReadPost * call s:RecheckFileencoding()
augroup END

set fileformats=unix,dos,mac

if exists("&ambiwidth")
  set ambiwidth=double
endif

scriptencoding utf-8
" }}}

" ----------------------------------------------
" general looks  "{{{
set showmatch
set number
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
let g:sh_noisk = 1

" for vimdiff
set wrap
" http://stackoverflow.com/questions/16840433/forcing-vimdiff-to-wrap-lines
augroup SetWrapForVimdiff
  autocmd!
  autocmd VimEnter * if &diff | execute "windo set wrap" | endif
augroup END
set diffopt+=horizontal,context:10

" make listchars visible
set list
set listchars=tab:>\ ,eol:\ ,trail:_
" }}}

" ----------------------------------------------
" spaces, indents  "{{{
set tabstop=2
set shiftwidth=2
set textwidth=0
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

if has("vim_starting")
  " formatoptions
  autocmd FileType * setlocal fo+=q fo+=2 fo+=l
  autocmd FileType * setlocal fo-=t fo-=c fo-=a fo-=b
  autocmd FileType text,markdown,moin setlocal fo-=r fo-=o

  " cinkyes
  autocmd FileType text,markdown,moin setlocal cinkeys-=:

  " folding
  " Keys: `zo`: open, `zc`: close, `zR`: open all, `zM`: close all
  set foldmethod=marker
  set foldopen=hor
  set foldminlines=0
  set foldcolumn=3
  set fillchars=vert:\|

  autocmd FileType vim  setlocal foldmethod=marker
  autocmd FileType yaml setlocal foldmethod=indent
  autocmd FileType haml setlocal foldmethod=indent
  autocmd BufEnter * if &ft == "javascript" | call s:MyJavascriptFold() | endif

  " http://d.hatena.ne.jp/gnarl/20120308/1331180615
  autocmd InsertEnter * if !exists("w:last_fdm") | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
  autocmd BufWritePost,FileWritePost,WinLeave * if exists("w:last_fdm") | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

 " update filetype
  autocmd BufWritePost *
  \ if &l:filetype ==# "" || exists("b:ftdetect")
  \ | unlet! b:ftdetect
  \ | filetype detect
  \ | endif

  autocmd FileType gitcommit,qfreplace setlocal nofoldenable
endif
" }}}

" ----------------------------------------------
" search  "{{{
set hlsearch
set ignorecase
set smartcase
set incsearch
" }}}

" ----------------------------------------------
" controls  "{{{
set restorescreen
set mouse=
set t_vb=
let &path = ".," . &path

" smoothen screen drawing; wait procedures' completion
set lazyredraw
set ttyfast

" backup, recover
set nobackup
set directory=~/tmp

" undo
set hidden
set undofile
set undodir=~/tmp

" wildmode
set wildmenu
set wildmode=list:longest,full

" ctags
if has("vim_starting") && exists("$RUBYGEMS_PATH")
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

" IME
" augroup InsModeImEnable
"   autocmd!
"   autocmd InsertEnter,CmdwinEnter * set noimdisable
"   autocmd InsertLeave,CmdwinLeave * set imdisable
" augroup END

" http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
augroup CheckTypo
  autocmd!
  autocmd BufWriteCmd *[,*] call s:WriteCheckTypo(expand("<afile>"))
augroup END
function! s:WriteCheckTypo(file)
  let writecmd = "write".(v:cmdbang ? "!" : "")." ".a:file

  if a:file =~ "[qfreplace]"
    return
  endif

  let prompt = "possible typo: really want to write to '" . a:file . "'?(y/n):"
  let input = input(prompt)

  if input ==# "YES"
    execute writecmd
    let b:write_check_typo_nocheck = 1
  elseif input =~? '^y\(es\)\=$'
    execute writecmd
  endif
endfunction
" }}}

" ----------------------------------------------
" commands  "{{{
" http://vim-users.jp/2009/05/hack17/
" :Rename newfilename.ext
command! -nargs=1 -complete=file Rename f <args>|call delete(expand("#"))
" }}}

" ----------------------------------------------
" keymappings  "{{{
" ,r => reload .vimrc
nnoremap <Leader>r :source ~/.vimrc<Cr>

" <Esc><Esc> => nohilight
nnoremap <Esc><Esc> :<C-u>nohlsearch<Cr>

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
if s:on_tmux
  vnoremap <Leader>y "zy:!tmux set-buffer '<C-r>"'<Cr>
else
  vnoremap <Leader>y "*y
endif
nnoremap <Leader>p "*p

" ,w => <C-w>
nnoremap <Leader>w <C-w>

" ,w => erase spaces of EOL for selected
vnoremap <Leader>w :s/\s\+$//ge<Cr>

" search very magic as default
" replaced by incsearch
" nnoremap / /\v

" prevent unconscious operation
inoremap <C-w> <Esc><C-w>

" increment/decrement
nmap + <C-a>
nmap - <C-x>

" move as shown
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap j gj
vnoremap k gk
vnoremap gj j
vnoremap gk k

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
" GUI settings  "{{{
if has("gui_running")
  gui
  set guioptions=none
  " set clipboard=unnamed

  " reset mswin.vim's mappings
  nnoremap <C-v> <C-v>
  nnoremap <C-y> <C-y>

  " save window's size and position
  " http://vim-users.jp/2010/01/hack120/
  let s:save_window_file = expand("~/.vimwinpos")
  augroup SaveWindow
    autocmd!
    autocmd VimLeavePre * call s:SaveWindow()
    function! s:SaveWindow()
      let options = [
        \ "set columns=" . &columns,
        \ "set lines=" . &lines,
        \ "winpos " . getwinposx() . " " . getwinposy(),
        \ ]
      call writefile(options, s:save_window_file)
    endfunction
  augroup END

  if has("vim_starting") && filereadable(s:save_window_file)
    execute "source" s:save_window_file
  endif
endif
" }}}

" ----------------------------------------------
" external sources  "{{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}
