" ----------------------------------------------
" initialize  " {{{
let $vim_root_path       = expand("~/.vim")
let $plugins_path        = expand($vim_root_path . "/plugins")
let $plugin_manager_path = expand($plugins_path . "/dein.vim")

let s:on_windows = has("win32") || has("win64")
let s:on_mac     = has("mac")
let s:on_tmux    = exists("$TMUX")

" http://rhysd.hatenablog.com/entry/2013/08/24/223438
let s:neocomplete_available = has("lua") && (v:version > 703 || (v:version == 703 && has("patch885")))

let s:pt_available     = executable("pt")
let s:ag_available     = executable("ag")
let s:ack_available    = executable("ack")
let s:migemo_available = has("migemo") || executable("cmigemo")

" plugin management functions  " {{{
function! UpdatePlugins() abort  " {{{
  call dein#update()
  Unite dein/log -buffer-name=update_plugins -input=!Same\\ revision\ !Already\\ up-to-date.\ !git\\ pull
endfunction  " }}}

function! s:SetupPluginStart(plugins_path) abort  " {{{
  return dein#begin(a:plugins_path)
endfunction  " }}}

function! s:SetupPluginEnd() abort  " {{{
  return dein#end()
endfunction  " }}}

function! s:RegisterPlugin(plugin_name, ...) abort  " {{{
  return dein#add(a:plugin_name, get(a:000, 0, {}))
endfunction  " }}}

function! s:TapPlugin(plugin_name) abort  " {{{
  return dein#tap(a:plugin_name)
endfunction  " }}}

function! s:ConfigPlugin(arg, ...) abort  " {{{
  if type(a:arg) != type([])
    return dein#config(a:arg, get(a:000, 0, {}))
  else
    return dein#config(a:arg)
  endif
endfunction  " }}}

function! s:PluginInfo(plugin_name) abort  " {{{
  return dein#get(a:plugin_name)
endfunction  " }}}

function! s:InstallablePluginExists(...) abort  " {{{
  if empty(a:000)
    return dein#check_install()
  else
    return dein#check_install(get(a:000, 0))
  endif
endfunction  " }}}

function! s:InstallPlugins(...) abort  " {{{
  if empty(a:000)
    return dein#install()
  else
    return dein#install(get(a:000, 0))
  endif
endfunction  " }}}
" }}}

" utility functions  " {{{
function! s:AvailabilityMessage(target) abort  " {{{
  return a:target . " is " . (eval("s:" . a:target . "_available") ? "" : "NOT ") . "available"
endfunction  " }}}

function! OnTmux() abort  " {{{
  return s:on_tmux
endfunction  " }}}

function! OnRailsDir() abort  " {{{
  return isdirectory("./app") && filereadable("./config/environment.rb")
endfunction  " }}}

function! OnGitDir() abort  " {{{
  silent! !git status > /dev/null 2>&1
  return !v:shell_error
endfunction  " }}}

function! OnSvnDir() abort  " {{{
  return isdirectory("./.svn")
endfunction  " }}}

function! RubyVersion() abort  " {{{
  return system("ruby -e 'print RUBY_VERSION'")
endfunction  " }}}

function! RubyGemPaths() abort  " {{{
  return system("ruby -r rubygems -e 'print Gem.path.join(\":\")'")
endfunction  " }}}

function! ExecuteWithConfirm(command) abort  " {{{
  if input("execute `" . a:command . "` ? [y/n] : ") !~ "[yY]"
    echo " -> canceled."
    return
  endif

  let result = system(a:command)

  if v:shell_error
    echomsg result
  endif
endfunction  " }}}
" }}}

let g:mapleader = ","
" }}}

" ----------------------------------------------
" encoding  " {{{
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# "utf-8"
  set encoding=japan
  set fileencoding=japan
endif

function! s:RecheckFileencoding() abort  " {{{
  if &fileencoding =~# "iso-2022-jp" && search("[^\x01-\x7e]", "n") == 0
    let &fileencoding=&encoding
  endif
endfunction  " }}}

augroup CheckEncoding  " {{{
  autocmd!
  autocmd BufReadPost * call s:RecheckFileencoding()
augroup END  " }}}

set fileformats=unix,dos,mac

if exists("&ambiwidth")
  set ambiwidth=double
endif

scriptencoding utf-8
" }}}

" ----------------------------------------------
" plugins  " {{{
" initialize plugin manager  " {{{
if has("vim_starting")
  if !isdirectory($plugin_manager_path)
    echo "Installing plugin manager...."
    call system("git clone https://github.com/Shougo/dein.vim " . $plugin_manager_path)
  endif

  set runtimepath+=$plugin_manager_path
endif

call s:SetupPluginStart($plugins_path)
" }}}

" plugins list  " {{{
call s:RegisterPlugin("Shougo/dein.vim")
call s:RegisterPlugin("Shougo/vimproc", { "build": "make" })

call s:RegisterPlugin("kg8m/.vim")
call s:RegisterPlugin("soramugi/auto-ctags.vim", { "if": OnRailsDir() })
call s:RegisterPlugin("vim-scripts/autodate.vim")
call s:RegisterPlugin("itchyny/calendar.vim")
call s:RegisterPlugin("tyru/caw.vim")
call s:RegisterPlugin("cocopon/colorswatch.vim")
call s:RegisterPlugin("Shougo/context_filetype.vim")
call s:RegisterPlugin("chrisbra/csv.vim", { "if": 0 })               " sometimes excessively works
call s:RegisterPlugin("spolu/dwm.vim")
call s:RegisterPlugin("mattn/emmet-vim")                             " former zencoding-vim
call s:RegisterPlugin("bogado/file-line", { "if": 0 })               " conflicts with sudo.vim (`vim sudo:path/to/file` not working)
call s:RegisterPlugin("leafcage/foldCC")
" dein does not support hg
" call s:RegisterPlugin("https://bitbucket.org/heavenshell/gundo.vim")
if !isdirectory("~/.vim/bundle/gundo.vim")
  call system("hg clone https://bitbucket.org/heavenshell/gundo.vim ~/.vim/bundle/gundo.vim")
endif
set runtimepath+=~/.vim/bundle/gundo.vim
call s:RegisterPlugin("sk1418/HowMuch")
call s:RegisterPlugin("nishigori/increment-activator")
call s:RegisterPlugin("haya14busa/incsearch.vim")
call s:RegisterPlugin("haya14busa/incsearch-index.vim", { "if": 0 }) " experimental
call s:RegisterPlugin("fuenor/JpFormat.vim")
call s:RegisterPlugin("https://bitbucket.org/teramako/jscomplete-vim.git")
call s:RegisterPlugin("itchyny/lightline.vim")
call s:RegisterPlugin("AndrewRadev/linediff.vim")
call s:RegisterPlugin("matchit.zip")
call s:RegisterPlugin("kg8m/moin.vim")
call s:RegisterPlugin("Shougo/neocomplete.vim")
call s:RegisterPlugin("Shougo/neomru.vim")
call s:RegisterPlugin("Shougo/neoyank.vim")
call s:RegisterPlugin("Shougo/neosnippet")
call s:RegisterPlugin("Shougo/neosnippet-snippets")
call s:RegisterPlugin("tyru/open-browser.vim")
call s:RegisterPlugin("tyru/operator-camelize.vim")
call s:RegisterPlugin("kien/rainbow_parentheses.vim", { "if": 0 })   " sometimes break colorschemes
call s:RegisterPlugin("chrisbra/Recover.vim")
call s:RegisterPlugin("todesking/ruby_hl_lvar.vim", { "if": RubyVersion() >= '1.9.0' })
call s:RegisterPlugin("sequence")
call s:RegisterPlugin("joeytwiddle/sexy_scroller.vim")
call s:RegisterPlugin("jiangmiao/simple-javascript-indenter")
call s:RegisterPlugin("AndrewRadev/splitjoin.vim")
call s:RegisterPlugin("sudo.vim")
call s:RegisterPlugin("kg8m/svn-diff.vim", { "if": OnSvnDir() })
call s:RegisterPlugin("vim-scripts/Unicode-RST-Tables")
call s:RegisterPlugin("Shougo/unite.vim")
call s:RegisterPlugin("kg8m/unite-dwm")
call s:RegisterPlugin("osyo-manga/unite-filetype")
call s:RegisterPlugin("Shougo/unite-help")
call s:RegisterPlugin("tacroe/unite-mark")
call s:RegisterPlugin("Shougo/unite-outline")
call s:RegisterPlugin("basyura/unite-rails", { "if": OnRailsDir() })
call s:RegisterPlugin("tsukkee/unite-tag")
call s:RegisterPlugin("pasela/unite-webcolorname")
call s:RegisterPlugin("h1mesuke/vim-alignta")
call s:RegisterPlugin("osyo-manga/vim-anzu")
call s:RegisterPlugin("haya14busa/vim-asterisk")
call s:RegisterPlugin("Townk/vim-autoclose")
call s:RegisterPlugin("Chiel92/vim-autoformat")
call s:RegisterPlugin("itchyny/vim-autoft")
call s:RegisterPlugin("kg8m/vim-blockle")
call s:RegisterPlugin("t9md/vim-choosewin")
call s:RegisterPlugin("kchmck/vim-coffee-script")
call s:RegisterPlugin("kg8m/vim-coloresque")
call s:RegisterPlugin("hail2u/vim-css-syntax")
call s:RegisterPlugin("hail2u/vim-css3-syntax")
call s:RegisterPlugin("itchyny/vim-cursorword", { "if": 0 })         " confusing with IME's underline
call s:RegisterPlugin("Lokaltog/vim-easymotion")
call s:RegisterPlugin("tpope/vim-endwise", { "if": 0 })              " incompatible with neosnippet
call s:RegisterPlugin("kg8m/vim-dirdiff")
call s:RegisterPlugin("thinca/vim-ft-diff_fold")
call s:RegisterPlugin("thinca/vim-ft-help_fold")
call s:RegisterPlugin("thinca/vim-ft-markdown_fold")
call s:RegisterPlugin("lambdalisue/vim-gista")
call s:RegisterPlugin("thinca/vim-ft-svn_diff")
call s:RegisterPlugin("muz/vim-gemfile")
call s:RegisterPlugin("tpope/vim-git")
call s:RegisterPlugin("lambdalisue/vim-gita", { "if": 0 })           " hope to future features
call s:RegisterPlugin("tpope/vim-haml")
call s:RegisterPlugin("michaeljsmith/vim-indent-object")
call s:RegisterPlugin("jelera/vim-javascript-syntax")
call s:RegisterPlugin("elzr/vim-json")
call s:RegisterPlugin("rcmdnk/vim-markdown")
call s:RegisterPlugin("joker1007/vim-markdown-quote-syntax")
call s:RegisterPlugin("losingkeys/vim-niji", { "if": 0 })            " sometimes break colorschemes
call s:RegisterPlugin("kana/vim-operator-replace")
" not working in case like following:
"   (1) text:      hoge "fu*ga piyo"
"   (2) call: <Plug>(operator-surround-append)"'
"   (3) expected:  hoge* '"fuga piyo"'
"   (4) result:    hoge*' "fuga piyo"'
" or following:
"   (2) call: <Plug>(operator-surround-replace)"'
"   (3) expected:  hoge* 'fuga piyo'
"   (4) result:    hoge*' fuga piyo'
call s:RegisterPlugin("rhysd/vim-operator-surround", { "if": 0 })    " not working in some edge cases
call s:RegisterPlugin("kana/vim-operator-user")
call s:RegisterPlugin("itchyny/vim-parenmatch")
call s:RegisterPlugin("thinca/vim-prettyprint")
call s:RegisterPlugin("thinca/vim-qfreplace")
call s:RegisterPlugin("tpope/vim-rails", { "if": OnRailsDir() })
call s:RegisterPlugin("thinca/vim-ref")
call s:RegisterPlugin("tpope/vim-repeat")
call s:RegisterPlugin("vim-ruby/vim-ruby")
call s:RegisterPlugin("joker1007/vim-ruby-heredoc-syntax")
call s:RegisterPlugin("kg8m/vim-rubytest", { "if": !OnTmux() })
call s:RegisterPlugin("thinca/vim-singleton")
call s:RegisterPlugin("honza/vim-snippets")
call s:RegisterPlugin("mhinz/vim-startify")
call s:RegisterPlugin("kopischke/vim-stay", { "if": 0 })             " sometimes excessively works
call s:RegisterPlugin("tpope/vim-surround")
call s:RegisterPlugin("deris/vim-textobj-enclosedsyntax")
call s:RegisterPlugin("kana/vim-textobj-jabraces")
call s:RegisterPlugin("kana/vim-textobj-lastpat")
call s:RegisterPlugin("osyo-manga/vim-textobj-multitextobj")
call s:RegisterPlugin("rhysd/vim-textobj-ruby")
call s:RegisterPlugin("jgdavey/vim-turbux", { "if": OnTmux() })
call s:RegisterPlugin("kana/vim-textobj-user")
call s:RegisterPlugin("thinca/vim-unite-history")
call s:RegisterPlugin("kg8m/vim-unite-giti", { "if": OnGitDir() })
call s:RegisterPlugin("kmnk/vim-unite-svn", { "if": OnSvnDir() })
call s:RegisterPlugin("hrsh7th/vim-versions", { "if": OnGitDir() || OnSvnDir() })
call s:RegisterPlugin("superbrothers/vim-vimperator")
call s:RegisterPlugin("thinca/vim-zenspace")
call s:RegisterPlugin("Shougo/vimfiler")
call s:RegisterPlugin("Shougo/vimshell")
call s:RegisterPlugin("benmills/vimux", { "if": OnTmux() })
call s:RegisterPlugin("simeji/winresizer")
call s:RegisterPlugin("LeafCage/yankround.vim")

" colorschemes
call s:RegisterPlugin("hail2u/h2u_colorscheme")                      " for printing
call s:RegisterPlugin("kg8m/molokai")
" }}}

" plugins settings  " {{{
if s:TapPlugin("auto-ctags.vim")  " {{{
  let g:auto_ctags = 1

  augroup AutoCtagsAtVinEnter  " {{{
    autocmd!
    autocmd VimEnter * call auto_ctags#ctags(0)
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("autodate.vim")  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%(' .
                              \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                              \   '\%(最終更新日\?\)\|' .
                              \   '\%(更新日\)' .
                              \ '\):'
  let g:autodate_keyword_post = '\.$'
endif  " }}}

if s:TapPlugin("calendar.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Calendar",
     \   "hook_source": "call ConfigPluginOnSource_calendar()",
     \ })

  function! ConfigPluginOnSource_calendar() abort  " {{{
    let g:calendar_google_calendar = 1
    let g:calendar_first_day       = "monday"
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("caw.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>(caw:",
     \   "hook_source": "call ConfigPluginOnSource_caw()",
     \ })

  nmap gc <Plug>(caw:hatpos:toggle)
  vmap gc <Plug>(caw:hatpos:toggle)

  function! ConfigPluginOnSource_caw() abort  " {{{
    let g:caw_no_default_keymappings = 1
    let g:caw_hatpos_skip_blank_line = 1
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("colorswatch.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "ColorSwatchGenerate",
     \ })
endif  " }}}

if s:TapPlugin("dwm.vim")  " {{{
  nmap <C-w>n       :<C-u>call DWM_New()<Cr>
  nmap <C-w>c       :<C-u>call DWM_Close()<Cr>
  nmap <C-w><Space> :<C-u>call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = 0
  let g:dwm_augroup_cleared = 0

  function! s:ClearDwmAugroup() abort  " {{{
    if !g:dwm_augroup_cleared
      augroup dwm  " {{{
        autocmd!
      augroup END  " }}}

      let g:dwm_augroup_cleared = 1
    endif
  endfunction  " }}}

  augroup ClearDWMAugroup  " {{{
    autocmd!
    autocmd VimEnter * call s:ClearDwmAugroup()
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("emmet-vim")  " {{{
  " command: <C-y>,
  call s:ConfigPlugin({
     \   "lazy": 1,
     \   "on_i": 1,
     \   "hook_source": "call ConfigPluginOnSource_emmet_vim()",
     \ })

  function! ConfigPluginOnSource_emmet_vim() abort  " {{{
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
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("foldCC")  " {{{
  let g:foldCCtext_enable_autofdc_adjuster = 1
  let g:foldCCtext_maxchars = 120
  set foldtext=FoldCCtext()
endif  " }}}

" if s:TapPlugin("gundo.vim")  " {{{
"   call s:ConfigPlugin({
"      \   "lazy":   1,
"      \   "on_cmd": "GundoToggle",
"      \   "hook_source": "call ConfigPluginOnSource_gundo()",
"      \ })

  nnoremap <F5> :<C-u>GundoToggle<Cr>

"   function! ConfigPluginOnSource_gundo() abort  " {{{
    " http://d.hatena.ne.jp/heavenshell/20120218/1329532535
    let g:gundo_auto_preview = 0
    let g:gundo_prefer_python3 = 1
"   endfunction  " }}}
" endif  " }}}

if s:TapPlugin("HowMuch")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>AutoCalc",
     \   "hook_source": "call ConfigPluginOnSource_HowMuch()",
     \ })

  vmap <Leader>?  <Plug>AutoCalcReplace
  vmap <Leader>?s <Plug>AutoCalcReplaceWithSum

  function! ConfigPluginOnSource_HowMuch() abort  " {{{
    " replace expr with result
    let g:HowMuch_scale = 5
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("increment-activator")  " {{{
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
endif  " }}}

if s:TapPlugin("incsearch.vim")  " {{{
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
  map n  <Plug>(incsearch-nohl-n)<Plug>(anzu-update-search-status-with-echo)
  map N  <Plug>(incsearch-nohl-N)<Plug>(anzu-update-search-status-with-echo)
  " asterisk's `z` commands are "stay star motions"
  map *  <Plug>(incsearch-nohl)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
  map #  <Plug>(incsearch-nohl)<Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)
  map g* <Plug>(incsearch-nohl)<Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
  map g# <Plug>(incsearch-nohl)<Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)

  let g:incsearch#auto_nohlsearch = 0
  let g:incsearch#magic = '\v'

  if s:TapPlugin("incsearch-index.vim")  " {{{
    map /  <Plug>(incsearch-index-/)
    map ?  <Plug>(incsearch-index-?)
  endif  " }}}
endif  " }}}

if s:TapPlugin("JpFormat.vim")  " {{{
  let JpCountChars = 37
endif  " }}}

if s:TapPlugin("jscomplete-vim.git")  " {{{
  let g:jscomplete_use = ["dom", "moz", "es6th"]
endif  " }}}

if s:TapPlugin("lightline.vim")  " {{{
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

  function! ReadonlySymbolForLightline() abort  " {{{
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? "X" : ""
  endfunction  " }}}

  function! FilepathForLightline() abort  " {{{
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
  endfunction  " }}}

  function! ModifiedSymbolForLightline() abort  " {{{
    return &ft =~ 'help\|vimfiler\|gundo' ? "" : &modified ? "+" : &modifiable ? "" : "-"
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("linediff.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Linediff",
     \   "hook_source": "call ConfigPluginOnSource_linediff()",
     \ })

  function! ConfigPluginOnSource_linediff() abort  " {{{
    let g:linediff_second_buffer_command = "rightbelow vertical new"
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("neocomplete.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_i":   1,
     \   "on_cmd": "NeoCompleteBufferMakeCache",
     \   "hook_source": "call ConfigPluginOnSource_neocomplete()",
     \ })

  function! ConfigPluginOnSource_neocomplete() abort  " {{{
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

    augroup SetOmunifuncs  " {{{
      autocmd!
      autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
      autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
      autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
      autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
      " jscomplete
      autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
    augroup END  " }}}
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("neosnippet")  " {{{
  call s:ConfigPlugin({
     \   "lazy":      1,
     \   "on_i":      1,
     \   "on_ft":     ["snippet", "neosnippet"],
     \   "on_source": "unite.vim",
     \   "depends":   [".vim", "vim-snippets"],
     \   "hook_source": "call ConfigPluginOnSource_neosnippet()",
     \ })

  function! ConfigPluginOnSource_neosnippet() abort  " {{{
    imap <expr><Tab> pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    smap <expr><Tab> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    imap <expr><Cr> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#close_popup() : "\<Cr>"

    if has("conceal")
      set conceallevel=2 concealcursor=i
    endif

    let g:neosnippet#snippets_directory = [
      \   s:PluginInfo(".vim").path . "/snippets",
      \   s:PluginInfo("vim-snippets").path . "/snippets",
      \ ]

    augroup NeoSnippetClearMarkers  " {{{
      autocmd!
      autocmd InsertLeave * NeoSnippetClearMarkers
    augroup END  " }}}
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("open-browser.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_cmd":  ["OpenBrowserSearch", "OpenBrowser"],
     \   "on_func": "openbrowser#open",
     \   "on_map":  "<Plug>(openbrowser-open)",
     \   "hook_source": "call ConfigPluginOnSource_open_browser()",
     \ })

  nmap <Leader>o <Plug>(openbrowser-open)
  vmap <Leader>o <Plug>(openbrowser-open)

  function! ConfigPluginOnSource_open_browser() abort  " {{{
    let g:openbrowser_browser_commands = [
      \   {
      \     "name": "ssh",
      \     "args": "ssh main 'open '\\''{uri}'\\'''",
      \   }
      \ ]
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("operator-camelize.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": ["<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"],
     \ })

  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)
endif  " }}}

if s:TapPlugin("ruby_hl_lvar.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":  1,
     \   "on_ft": ["ruby"],
     \ })
endif  " }}}

if s:TapPlugin("sequence")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [
     \     "<Plug>SequenceV_Increment",
     \     "<Plug>SequenceV_Decrement",
     \     "<Plug>SequenceN_Increment",
     \     "<Plug>SequenceN_Decrement",
     \   ],
     \ })

  vmap <Leader>+ <Plug>SequenceV_Increment
  vmap <Leader>- <Plug>SequenceV_Decrement
  nmap <Leader>+ <Plug>SequenceN_Increment
  nmap <Leader>- <Plug>SequenceN_Decrement
endif  " }}}

if s:TapPlugin("simple-javascript-indenter")  " {{{
  let g:SimpleJsIndenter_BriefMode = 2
  let g:SimpleJsIndenter_CaseIndentLevel = -1
endif  " }}}

if s:TapPlugin("splitjoin.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": ["SplitjoinJoin", "SplitjoinSplit"],
     \   "hook_source": "call ConfigPluginOnSource_splitjoin()",
     \ })

  nnoremap <Leader>J :<C-u>SplitjoinJoin<Cr>
  nnoremap <Leader>S :<C-u>SplitjoinSplit<Cr>

  function! ConfigPluginOnSource_splitjoin() abort  " {{{
    let g:splitjoin_split_mapping       = ""
    let g:splitjoin_join_mapping        = ""
    let g:splitjoin_ruby_trailing_comma = 1
    let g:splitjoin_ruby_hanging_args   = 0
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("Unicode-RST-Tables")  " {{{
  let g:no_rst_table_maps = 0
endif  " }}}

if s:TapPlugin("unite.vim")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Unite",
     \   "hook_source": "call ConfigPluginOnSource_unite()",
     \ })

  nnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  vnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  nnoremap <Leader>ug :<C-u>Unite -no-quit -winheight=50% grep:./::
  vnoremap <Leader>ug "vy:<C-u>Unite -no-quit -winheight=50% grep:./::<C-r>"
  nnoremap <Leader>uy :<C-u>Unite history/yank<Cr>
  nnoremap <F4> :<C-u>Unite buffer<Cr>

  function! ConfigPluginOnSource_unite() abort  " {{{
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
    call unite#custom#source("grep", "max_candidates", 10000)

    " unite-shortcut  " {{{
      " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
      " http://d.hatena.ne.jp/tyru/20120110/prompt
      let g:unite_source_menu_menus = {}
      let g:unite_source_menu_menus.shortcuts = {
        \   "description" : "shortcuts"
        \ }

      " http://nanasi.jp/articles/vim/hz_ja_vim.html
      let g:unite_source_menu_menus.shortcuts.candidates = [
        \   ["[Plugins] Update Plugins                 ", "call UpdatePlugins()"],
        \
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
        \   ["[Autoformat] format source codes         ", "Autoformat"],
        \   ["[JpFormat] format all selected for mail  ", "'<,'>JpFormatAll!"],
        \
        \   ["[Calendar] Year View                     ", "Calendar -view=year  -position=hear!"],
        \   ["[Calendar] Month View                    ", "Calendar -view=month -position=hear!"],
        \   ["[Calendar] Week View                     ", "Calendar -view=week  -position=hear!"],
        \   ["[Calendar] Day View                      ", "Calendar -view=day   -position=hear! -split=vertical -width=75"],
        \
        \   ["[Diff] Linediff                          ", "'<,'>Linediff"],
        \   ["[Diff] DirDiff [Edit]                    ", "DirDiff {dir1} {dir2}"],
        \
        \   ["[Rails] Reset Buffer                     ", "if RailsDetect() | call rails#buffer_setup() | endif"],
        \
        \   ["[Unicode-RST-Tables] Create Table        ", "python CreateTable()"],
        \   ["[Unicode-RST-Tables] Fix Table           ", "python FixTable()"],
        \
        \   ["[Unite plugin] gist                      ", "Unite gista"],
        \   ["[Unite plugin] mru files list            ", "Unite neomru/file"],
        \   ["[Unite plugin] outline                   ", "Unite outline:!"],
        \   ["[Unite plugin] tag with cursor word      ", "UniteWithCursorWord tag"],
        \   ["[Unite plugin] versions/status           ", "UniteVersions status:./"],
        \   ["[Unite plugin] versions/log              ", "UniteVersions log:./"],
        \   ["[Unite plugin] giti/status               ", "Unite giti/status"],
        \   ["[Unite plugin] svn/status                ", "Unite svn/status"],
        \   ["[Unite plugin] webcolorname              ", "Unite webcolorname"],
        \   ["[Unite] buffers list                     ", "Unite buffer"],
        \   ["[Unite] files list                       ", "UniteWithBufferDir file"],
        \   ["[Unite] various sources list             ", "UniteWithBufferDir buffer neomru/file bookmark file"],
        \   ["[Unite] history/yank                     ", "Unite history/yank"],
        \   ["[Unite] register                         ", "Unite register"],
        \   ["[Unite] grep [Edit]                      ", "Unite -no-quit grep:./::{words}"],
        \   ["[Unite] resume [Edit]                    ", "UniteResume {buffer-name}"],
        \
        \   ["[Help] autocommand-events                ", "help autocommand-events"],
        \ ]

      function! g:unite_source_menu_menus.shortcuts.map(key, value) abort  " {{{
        let [word, value] = a:value

        return {
             \   "word" : word . "  --  `" . value . "`",
             \   "kind" : "command",
             \   "action__command" : value,
             \ }
      endfunction  " }}}
    " }}}
  endfunction  " }}}

  if s:TapPlugin("neomru.vim")  " {{{
    call s:ConfigPlugin({
       \   "lazy": 0,
       \ })

    nnoremap <Leader>m :<C-u>Unite neomru/file<Cr>

    let g:neomru#time_format     = "(%Y/%m/%d %H:%M:%S) "
    let g:neomru#filename_format = ":~:."
    let g:neomru#file_mru_limit  = 1000
  endif  " }}}

  if s:TapPlugin("neoyank.vim")  " {{{
    call s:ConfigPlugin({
       \   "lazy": 0,
       \ })

    let g:neoyank#limit = 300
  endif  " }}}

  if s:TapPlugin("unite-dwm")  " {{{
    call s:ConfigPlugin({
       \   "lazy":  1,
       \   "on_ft": "unite",
       \   "hook_source": "call ConfigPluginOnSource_unite_dwm()",
       \ })

    function! ConfigPluginOnSource_unite_dwm() abort  " {{{
      let g:unite_dwm_source_names_as_default_action = "buffer,file,file_mru,cdable"
    endfunction  " }}}
  endif  " }}}

  if s:TapPlugin("unite-filetype")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  if s:TapPlugin("unite-mark")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_func":   "AutoMark",
       \   "on_source": "unite.vim",
       \   "hook_source": "call ConfigPluginOnSource_unite_mark()",
       \ })

    nnoremap <Leader>um :<C-u>Unite mark<Cr>
    " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
    nnoremap <silent> m :<C-u>call AutoMark()<Cr>

    function! ConfigPluginOnSource_unite_mark() abort  " {{{
      let g:mark_ids = [
        \   "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        \   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        \ ]
      let g:unite_source_mark_marks = join(g:mark_ids, "")

      function! AutoMark() abort  " {{{
        if !exists("b:mark_position")
          let b:mark_position = 0
        else
          let b:mark_position = (b:mark_position + 1) % len(g:mark_ids)
        endif

        execute "mark" g:mark_ids[b:mark_position]
        echo "marked" g:mark_ids[b:mark_position]
      endfunction  " }}}

      augroup InitMarks  " {{{
        autocmd!
        autocmd BufReadPost * delmarks!
      augroup END  " }}}
    endfunction  " }}}
  endif  " }}}

  if s:TapPlugin("unite-outline")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })

    nnoremap <Leader>uo :<C-u>Unite outline:!<Cr>
  endif  " }}}

  if s:TapPlugin("unite-rails")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })

    nnoremap <Leader>ur :<C-u>Unite rails/
  endif  " }}}

  if s:TapPlugin("unite-tag")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \   "hook_source": "call ConfigPluginOnSource_unite_tag()",
       \ })

    call s:ConfigPlugin("unite.vim", {
       \   "on_cmd": s:PluginInfo("unite.vim")["on_cmd"] + ["UniteWithCursorWord"],
       \ })

    nnoremap g] :<C-u>UniteWithCursorWord -immediately tag<Cr>
    vnoremap g] :<C-u>UniteWithCursorWord -immediately tag<Cr>
    nnoremap g[ :<C-u>Unite jump<Cr>
    nnoremap <Leader>ut :<C-u>UniteWithCursorWord -immediately tag<Cr>

    function! ConfigPluginOnSource_unite_tag() abort  " {{{
      let g:unite_source_tag_max_name_length  = 50
      let g:unite_source_tag_max_fname_length = 100
    endfunction  " }}}
  endif  " }}}

  if s:TapPlugin("unite-webcolorname")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  if s:TapPlugin("vim-unite-history")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  if s:TapPlugin("vim-unite-giti")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \   "hook_source":      "call ConfigPluginOnSource_vim_unite_giti()",
       \   "hook_post_source": "call ConfigPluginOnPostSource_vim_unite_giti()",
       \ })

    if !mapcheck("<Leader>uv")
      nnoremap <Leader>uv :<C-u>Unite giti/status<Cr>
    endif

    function! ConfigPluginOnSource_vim_unite_giti() abort  " {{{
      let g:giti_log_default_line_count = 1000
    endfunction  " }}}

    function! ConfigPluginOnPostSource_vim_unite_giti() abort  " {{{
      function! s:AddActionsToUniteGiti() abort  " {{{
        let kind = unite#kinds#giti#status#define()
        let kind.action_table.file_delete = {
          \   "description":         "delete/remove directories/files",
          \   "is_selectable":       1,
          \   "is_invalidate_cache": 1,
          \ }
        let kind.action_table.intent_to_add = {
          \   "description":         "add --intent-to-add",
          \   "is_selectable":       1,
          \   "is_invalidate_cache": 1,
          \ }

        function! kind.action_table.file_delete.func(candidates) abort  " {{{
          let files   = map(copy(a:candidates), "v:val.action__path")
          let command = printf("yes | rm -r %s", join(files))

          call ExecuteWithConfirm(command)
        endfunction  " }}}

        function! kind.action_table.intent_to_add.func(candidates) abort  " {{{
          let files   = map(copy(a:candidates), "v:val.action__path")
          let command = printf("add --intent-to-add %s", join(files))

          return giti#system(command)
        endfunction  " }}}

        let kind.alias_table.directory_delete = "file_delete"
      endfunction  " }}}
      call s:AddActionsToUniteGiti()
    endfunction  " }}}
  endif  " }}}

  if s:TapPlugin("vim-unite-svn")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \   "hook_post_source": "call ConfigPluginOnPostSource_vim_unite_svn()",
       \ })

    if !mapcheck("<Leader>uv")
      nnoremap <Leader>uv :<C-u>Unite svn/status<Cr>
    endif

    function! ConfigPluginOnPostSource_vim_unite_svn() abort  " {{{
      function! s:AddActionsToUniteSvn() abort  " {{{
        let file_delete_action = {
          \   "description":         "delete/remove directories/files",
          \   "is_selectable":       1,
          \   "is_invalidate_cache": 1,
          \ }

        function! file_delete_action.func(candidates) abort  " {{{
          let files   = map(copy(a:candidates), "v:val.action__path")
          let command = printf("yes | rm -r %s", join(files))

          call ExecuteWithConfirm(command)
        endfunction  " }}}

        call unite#custom_action("source/svn/status/jump_list", "file_delete", file_delete_action)
        call unite#custom_action("source/svn/status/jump_list", "directory_delete", copy(file_delete_action))
      endfunction  " }}}
      call s:AddActionsToUniteSvn()
    endfunction  " }}}
  endif  " }}}

  if s:TapPlugin("vim-versions")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_cmd":    "UniteVersions",
       \   "on_source": "unite.vim",
       \   "hook_source": "call ConfigPluginOnSource_vim_versions()",
       \ })

    nnoremap <Leader>u<S-v> :<C-u>UniteVersions status:./<Cr>

    function! ConfigPluginOnSource_vim_versions() abort  " {{{
      let g:versions#type#svn#status#ignore_status = ["X"]

      function! s:AddActionsToVersions() abort  " {{{
        let action = {
          \   "description" :   "open files",
          \   "is_selectable" : 1,
          \ }

        function! action.func(candidates) abort  " {{{
          for candidate in a:candidates
            let candidate.action__path = candidate.source__args.path . candidate.action__status.path
            let candidate.action__directory = unite#util#path2directory(candidate.action__path)

            if candidate.action__path == candidate.action__directory
              let candidate.kind = "directory"
              call unite#take_action("vimfiler", candidate)
            else
              let candidate.kind = "file"
              call unite#take_action("open", candidate)
            endif
          endfor
        endfunction  " }}}

        call unite#custom#action("versions/git/status,versions/svn/status", "open", action)
        call unite#custom#default_action("versions/git/status,versions/svn/status", "open")
      endfunction  " }}}
      call s:AddActionsToVersions()
    endfunction  " }}}
  endif  " }}}
endif  " }}}

if s:TapPlugin("vim-alignta")  " {{{
  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })

  vnoremap <Leader>a  :Alignta<Space>
  vnoremap <Leader>ua :<C-u>Unite alignta:arguments<Cr>

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
endif  " }}}

if s:TapPlugin("vim-anzu")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>(anzu-",
     \ })

  " see incsearch
endif  " }}}

if s:TapPlugin("vim-asterisk")  " {{{
  " see incsearch
endif  " }}}

if s:TapPlugin("vim-autoclose")  " {{{
  " annoying to type "<<" in Ruby code or type "<" for comparing in many languages
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
endif  " }}}

if s:TapPlugin("vim-autoformat")  " {{{
  let g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif  " }}}

if s:TapPlugin("vim-autoft")  " {{{
  let g:autoft_config = [
    \   { "filetype": "html",       "pattern": '<\%(!DOCTYPE\|html\|head\|script\)' },
    \   { "filetype": "javascript", "pattern": '\%(^\s*\<var\>\s\+[a-zA-Z]\+\)\|\%(function\%(\s\+[a-zA-Z]\+\)\?\s*(\)' },
    \   { "filetype": "c",          "pattern": '^\s*#\s*\%(include\|define\)\>' },
    \   { "filetype": "sh",         "pattern": '^#!.*\%(\<sh\>\|\<bash\>\)\s*$' },
    \ ]
endif  " }}}

if s:TapPlugin("vim-blockle")  " {{{
  let g:blockle_mapping = ",b"
  let g:blockle_erase_spaces_around_starting_brace = 1
endif  " }}}

if s:TapPlugin("vim-choosewin")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>(choosewin)",
     \   "hook_source": "call ConfigPluginOnSource_vim_choosewin()",
     \ })

  nmap <C-w>f <Plug>(choosewin)

  function! ConfigPluginOnSource_vim_choosewin() abort  " {{{
    let g:choosewin_overlay_enable          = 0  " wanna set true but too heavy
    let g:choosewin_overlay_clear_multibyte = 1
    let g:choosewin_blink_on_land           = 0
    let g:choosewin_statusline_replace      = 1  " wanna set false and use overlay
    let g:choosewin_tabline_replace         = 0
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-dirdiff")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "DirDiff",
     \   "hook_source": "call ConfigPluginOnSource_vim_dirdiff()",
     \ })

  function! ConfigPluginOnSource_vim_dirdiff() abort  " {{{
    let g:DirDiffExcludes   = "CVS,*.class,*.exe,.*.swp,*.git,db/development_structure.sql,log,tags,tmp"
    let g:DirDiffIgnore     = "Id:,Revision:,Date:"
    let g:DirDiffSort       = 1
    let g:DirDiffIgnoreCase = 0
    let g:DirDiffForceLang  = "C"
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-easymotion")  " {{{
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
endif  " }}}

if s:TapPlugin("vim-gista")  " {{{
  call s:ConfigPlugin({
     \   "lazy":      1,
     \   "on_cmd":    "Gista",
     \   "on_map":    "<Plug>(gista-",
     \   "on_source": "unite.vim",
     \   "hook_source": "call ConfigPluginOnSource_vim_gista()",
     \ })

  function! ConfigPluginOnSource_vim_gista() abort  " {{{
    let g:gista#github_user = "kg8m"
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-git")  " {{{
  augroup PreventVimGitFromChangingSettings  " {{{
    autocmd!
    autocmd FileType gitcommit let b:did_ftplugin = 1
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("vim-javascript-syntax")  " {{{
  function! s:MyJavascriptFold() abort  " {{{
    if !exists("b:javascript_folded")
      call JavaScriptFold()
      setl foldlevelstart=0
      let b:javascript_folded = 1
    endif
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-json")  " {{{
  let g:vim_json_syntax_conceal = 0
endif  " }}}

if s:TapPlugin("vim-markdown")  " {{{
  let g:markdown_quote_syntax_filetypes = {
    \   "coffee": {
    \     "start": "coffee",
    \   },
    \   "crontab": {
    \     "start": "cron\\%(tab\\)\\?",
    \   },
    \ }

  augroup ResetMarkdownIndentexpr  " {{{
    autocmd!
    autocmd FileType markdown setlocal indentexpr=smartindent
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("vim-operator-replace")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_map": "<Plug>(operator-replace)",
     \ })

  nmap r <Plug>(operator-replace)
  vmap r <Plug>(operator-replace)
endif  " }}}

if s:TapPlugin("vim-operator-surround")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>(operator-surround-",
     \ })

  nmap <silent>sa <Plug>(operator-surround-append)
  nmap <silent>sd <Plug>(operator-surround-delete)
  nmap <silent>sr <Plug>(operator-surround-replace)
  vmap <silent>sa <Plug>(operator-surround-append)
  vmap <silent>sd <Plug>(operator-surround-delete)
  vmap <silent>sr <Plug>(operator-surround-replace)
endif  " }}}

if s:TapPlugin("vim-operator-user")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_func": "operator#user#define",
     \ })
endif  " }}}

if s:TapPlugin("vim-parenmatch")  " {{{
  let g:loaded_matchparen = 1

  augroup HighlightParenmatch  " {{{
    autocmd!
    autocmd VimEnter,ColorScheme * highlight ParenMatch ctermbg=white ctermfg=black guibg=white guifg=black
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("vim-prettyprint")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_cmd":  ["PrettyPrint", "PP"],
     \   "on_func": ["PrettyPrint", "PP"],
     \ })
endif  " }}}

if s:TapPlugin("vim-qfreplace")  " {{{
  call s:ConfigPlugin({
     \   "lazy":  1,
     \   "on_ft": ["unite", "quickfix"]
     \ })
endif  " }}}

if s:TapPlugin("vim-rails")  " {{{
  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })

  " http://fg-180.katamayu.net/archives/2006/09/02/125150
  let g:rails_level = 4

  if !exists("g:rails_projections")
    let g:rails_projections = {}
  endif

  let g:rails_projections["config/*"] = { "command": "config" }
  let g:rails_projections["script/*"] = {
    \   "command": "script",
    \   "test":    [
    \     "test/script/%s_test.rb",
    \   ],
    \ }
  let g:rails_projections["spec/fabricators/*_fabricator.rb"] = {
    \   "command":   "fabricator",
    \   "affinity":  "model",
    \   "alternate": "app/models/%s.rb",
    \   "related":   "db/schema.rb#%p",
    \   "test":      "spec/models/%s_spec.rb",
    \ }
  let g:rails_projections["spec/support/*.rb"] = { "command": "support" }

  if !exists("g:rails_path_additions")
    let g:rails_path_additions = []
  endif

  let g:rails_path_additions += [
    \   "spec/support",
    \ ]

  " prevent `rails.vim` from defining keymappings
  nmap <Leader>Rwf  <Plug>RailsSplitFind
  nmap <Leader>Rwgf <Plug>RailsTabFind
endif  " }}}

if s:TapPlugin("vim-ref")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Ref",
     \   "on_map": "<Plug>(ref-keyword)",
     \ })

  nmap K <Plug>(ref-keyword)
endif  " }}}

if s:TapPlugin("vim-ruby")  " {{{
  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })

  let g:no_ruby_maps = 1
endif  " }}}

if s:TapPlugin("vim-ruby-heredoc-syntax")  " {{{
  let g:ruby_heredoc_syntax_filetypes = {
    \   "haml": { "start": "HAML" },
    \   "ruby": { "start": "RUBY" },
    \ }
endif  " }}}

if s:TapPlugin("vim-rubytest")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": ["<Plug>RubyFileRun", "<Plug>RubyTestRun"],
     \   "hook_source": "call ConfigPluginOnSource_vim_rubytest()",
     \ })

  nmap <leader>T <Plug>RubyFileRun
  nmap <leader>t <Plug>RubyTestRun

  function! ConfigPluginOnSource_vim_rubytest() abort  " {{{
    let g:no_rubytest_mappings = 1
    let g:rubytest_in_vimshell = 1
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-singleton")  " {{{
  call s:ConfigPlugin({
     \   "gui": 1,
     \   "hook_source": "call ConfigPluginOnSource_vim_singleton()",
     \ })

  function! ConfigPluginOnSource_vim_singleton() abort  " {{{
    if has("gui_running") && !singleton#is_master()
      let g:singleton#opener = "drop"
      call singleton#enable()
    endif
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-startify")  " {{{
  call s:ConfigPlugin({
     \   "lazy":     1,
     \   "on_event": "VimEnter",
     \   "hook_source":      "call ConfigPluginOnSource_vim_startify()",
     \   "hook_post_source": "call ConfigPluginOnPostSource_vim_startify()",
     \ })

  function! ConfigPluginOnSource_vim_startify() abort  " {{{
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
  endfunction  " }}}

  function! ConfigPluginOnPostSource_vim_startify() abort  " {{{
    highlight StartifyFile   ctermfg=255
    highlight StartifyHeader ctermfg=255
    highlight StartifyPath   ctermfg=245
    highlight StartifySlash  ctermfg=245
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-stay")  " {{{
  set viewoptions=cursor
endif  " }}}

if s:TapPlugin("vim-textobj-multitextobj")  " {{{
  omap aj <Plug>(textobj-multitextobj-a)
  omap ij <Plug>(textobj-multitextobj-i)
  vmap aj <Plug>(textobj-multitextobj-a)
  vmap ij <Plug>(textobj-multitextobj-i)

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
endif  " }}}

if s:TapPlugin("vim-turbux")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": ["<Plug>SendTestToTmux", "<Plug>SendFocusedTestToTmux"],
     \   "hook_source": "call ConfigPluginOnSource_vim_turbux()",
     \ })

  map <leader>T <Plug>SendTestToTmux
  map <leader>t <Plug>SendFocusedTestToTmux

  function! ConfigPluginOnSource_vim_turbux() abort  " {{{
    let g:no_turbux_mappings = 1
    let g:turbux_test_type   = ""  " FIXME: escape undefined g:turbux_test_type error
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup HighlightZenkakuSpace  " {{{
    autocmd!
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("vimfiler")  " {{{
  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })

  nnoremap <Leader>e :<C-u>VimFilerBufferDir -force-quit<Cr>

  call vimfiler#custom#profile("default", "context", {
     \   "safe": 0,
     \   "split_action": "dwm_open",
     \ })
endif  " }}}

if s:TapPlugin("vimshell")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": ["VimShell", "VimShellExecute"],
     \   "hook_source": "call ConfigPluginOnSource_vimshell()",
     \ })

  nnoremap <Leader>s :<C-u>VimShell<Cr>

  function! ConfigPluginOnSource_vimshell() abort  " {{{
    if s:on_windows
      let g:_user_name = $USERNAME
    else
      let g:_user_name = $USER
    endif

    let g:vimshell_user_prompt = '"[".g:_user_name."@".hostname()."] ".getcwd()'
    let g:vimshell_right_prompt = '"(".strftime("%y/%m/%d %H:%M:%S", localtime()).")"'
    let g:vimshell_prompt = "% "
  endfunction  " }}}
endif  " }}}

if s:TapPlugin("vimux")  " {{{
  call s:ConfigPlugin({
     \   "lazy":     1,
     \   "on_event": "VimEnter",
     \   "hook_source":      "call ConfigPluginOnSource_vimux()",
     \   "hook_post_source": "call ConfigPluginOnPostSource_vimux()",
     \ })

  function! ConfigPluginOnSource_vimux() abort  " {{{
    let g:VimuxHeight     = 30
    let g:VimuxUseNearest = 1
  endfunction  " }}}

  function! ConfigPluginOnPostSource_vimux() abort  " {{{
    " overriding default function: use current pane's next one
    execute join([
    \   'function! _VimuxNearestIndex() abort',
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
  endfunction  " }}}

  augroup Vimux  " {{{
    autocmd!
    autocmd VimLeavePre * :VimuxCloseRunner
  augroup END  " }}}
endif  " }}}

if s:TapPlugin("winresizer")  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<C-w><C-e>",
     \ })

  let g:winresizer_start_key = "<C-w><C-e>"
endif  " }}}

if s:TapPlugin("yankround.vim")  " {{{
  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap P     <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif  " }}}
" }}}

" finish plugin manager initialization  " {{{
call s:SetupPluginEnd()
filetype plugin indent on
syntax enable

if s:InstallablePluginExists(["vimproc"])
  call s:InstallPlugins(["vimproc"])
endif

if s:InstallablePluginExists()
  call s:InstallPlugins()
endif

" colorscheme
if s:TapPlugin("molokai")  " {{{
  let g:molokai_original = 1
  colorscheme molokai
endif  " }}}
" }}}
" }}}

" ----------------------------------------------
" general looks  " {{{
set showmatch
set number
set showmode
set showcmd
set cursorline
set cursorcolumn

augroup ToggleActiveWindowCursor  " {{{
  autocmd!
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,TabEnter,BufEnter,BufWinEnter,FileType,ColorScheme * set cursorcolumn cursorline
augroup END  " }}}

set scrolloff=15
set iskeyword& iskeyword+=-
let g:sh_noisk = 1

" for vimdiff
set wrap
" http://stackoverflow.com/questions/16840433/forcing-vimdiff-to-wrap-lines
augroup SetWrapForVimdiff  " {{{
  autocmd!
  autocmd VimEnter * if &diff | execute "windo set wrap" | endif
augroup END  " }}}
set diffopt+=horizontal,context:10,iwhite

" make listchars visible
set list
set listchars=tab:>\ ,eol:\ ,trail:_

" https://teratail.com/questions/24046
augroup LimitLargeFileSyntax  " {{{
  autocmd!
  autocmd Syntax * if 10000 < line("$") | syntax sync minlines=1000 | endif
augroup END  " }}}
" }}}

" ----------------------------------------------
" spaces, indents  " {{{
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

  " cinkeys
  autocmd FileType text,markdown,moin setlocal cinkeys-=:

  " folding
  " frequently used keys:
  "   zo: open
  "   zc: close
  "   zR: open all
  "   zM: close all
  "   zx: recompute all
  "   [z: move to start of current fold
  "   ]z: move to end of current fold
  "   zj: move to start of next fold
  "   zk: move to end of previous fold
  set foldmethod=marker
  set foldopen=hor
  set foldminlines=0
  set foldcolumn=3
  set fillchars=vert:\|

  autocmd FileType vim  setlocal foldmethod=marker
  autocmd FileType yaml setlocal foldmethod=indent
  autocmd FileType haml setlocal foldmethod=indent
  autocmd FileType gitcommit,qfreplace setlocal nofoldenable
  autocmd BufEnter * if &ft == "javascript" | call s:MyJavascriptFold() | endif

  " http://d.hatena.ne.jp/gnarl/20120308/1331180615
  autocmd InsertEnter * if !exists("w:last_fdm") | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
  autocmd BufWritePost,FileWritePost,WinLeave * if exists("w:last_fdm") | let &foldmethod=w:last_fdm | unlet w:last_fdm | endif

  " update filetype
  autocmd BufWritePost * if &filetype ==# "" || exists("b:ftdetect") | unlet! b:ftdetect | filetype detect | endif
endif
" }}}

" ----------------------------------------------
" search  " {{{
set hlsearch
set ignorecase
set smartcase
set incsearch
" }}}

" ----------------------------------------------
" controls  " {{{
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
set undofile
set undodir=~/tmp

" wildmode
set wildmenu
set wildmode=list:longest,full

" ctags
for s:ruby_gem_path in split(RubyGemPaths(), ":")
  let &tags = &tags . "," . s:ruby_gem_path . "/**/tags"
endfor

" auto reload
augroup CheckTimeHook  " {{{
  autocmd!
  autocmd InsertEnter * checktime
  autocmd InsertLeave * checktime
augroup END  " }}}

" move
set whichwrap=b,s,h,l,<,>,[,],~

" http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
augroup CheckTypo  " {{{
  autocmd!
  autocmd BufWriteCmd *[,*] call s:WriteCheckTypo(expand("<afile>"))
augroup END  " }}}

function! s:WriteCheckTypo(file) abort  " {{{
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
endfunction  " }}}
" }}}

" ----------------------------------------------
" commands  " {{{
" http://vim-users.jp/2009/05/hack17/
" :Rename newfilename.ext
command! -nargs=1 -complete=file Rename f <args>|call delete(expand("#"))
" }}}

" ----------------------------------------------
" keymappings  " {{{
" ,r => reload .vimrc
nnoremap <Leader>r :<C-u>source ~/.vimrc<Cr>

" <C-/> => nohilight
nnoremap <Leader>/ :<C-u>nohlsearch<Cr>

" ,v => vsplit
nnoremap <Leader>v :<C-u>vsplit<Cr>

" ,d => svn diff
nnoremap <Leader>d :<C-u>call SvnDiff()<Cr>
function! SvnDiff() abort  " {{{
  edit diff
  silent! setlocal ft=diff bufhidden=delete nobackup noswf nobuflisted wrap buftype=nofile
  execute "normal :r!svn diff\n"
endfunction  " }}}

" ,y/,p => copy/paste by clipboard
if s:on_tmux
  function! UnnamedRegisterToRemoteCopy() abort  " {{{
    let text = @"
    let text = substitute(text, "^\\n\\+", "", "")
    let text = substitute(text, "\\n\\+$", "", "")

    if text =~ "\n"
      let filter = ""
    else
      let filter = " | tr -d '\\n'"
    endif

    call system("echo '" . substitute(text, "'", "'\\\\''", "g") . "'" . filter . " | ssh main pbcopy")
    echomsg "Copy the Selection by pbcopy."
  endfunction  " }}}

  vnoremap <Leader>y "zy:<C-u>call UnnamedRegisterToRemoteCopy()<Cr>
else
  vnoremap <Leader>y "*y
endif
nnoremap <Leader>p "*p

" ,w => <C-w>
nnoremap <Leader>w <C-w>

" ,w => erase spaces of EOL for selected
vnoremap <Leader>w :s/\s\+$//ge<Cr>

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
inoremap <C-f> <PageDown>
inoremap <C-b> <PageUp>
" }}}

" ----------------------------------------------
" GUI settings  " {{{
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
  augroup SaveWindow  " {{{
    autocmd!
    autocmd VimLeavePre * call s:SaveWindow()

    function! s:SaveWindow() abort  " {{{
      let options = [
        \ "set columns=" . &columns,
        \ "set lines=" . &lines,
        \ "winpos " . getwinposx() . " " . getwinposy(),
        \ ]
      call writefile(options, s:save_window_file)
    endfunction  " }}}
  augroup END  " }}}

  if has("vim_starting") && filereadable(s:save_window_file)
    execute "source" s:save_window_file
  endif
endif
" }}}

" ----------------------------------------------
" external sources  " {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}
