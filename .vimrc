" ----------------------------------------------
" initialize  " {{{
let s:vim_root_path       = expand($HOME . "/.vim")
let s:plugins_path        = expand(s:vim_root_path . "/plugins")
let s:plugin_manager_path = expand(s:plugins_path . "/repos/github.com/Shougo/dein.vim")

let s:on_mac  = has("mac")
let s:on_tmux = exists("$TMUX")

let s:ag_available  = executable("ag")
let s:ack_available = executable("ack")

let s:native_incsearch_highlightable = v:version >= 800 && has("patch1238")

" plugin management functions  " {{{
function! UpdatePlugins() abort  " {{{
  call dein#update()
  Unite dein/log -buffer-name=update_plugins
  let @/ = "Updated"
endfunction  " }}}

function! s:SetupPluginStart() abort  " {{{
  return dein#begin(s:plugins_path)
endfunction  " }}}

function! s:SetupPluginEnd() abort  " {{{
  return dein#end()
endfunction  " }}}

function! s:RegisterPlugin(plugin_name, ...) abort  " {{{
  " FIXME: gundo: dein does not support hg
  if a:plugin_name =~# "/gundo\.vim$"
    if !isdirectory($HOME . "/.vim/bundle/gundo.vim")
      call system("hg clone https://bitbucket.org/heavenshell/gundo.vim " . $HOME . "/.vim/bundle/gundo.vim")
    endif

    set runtimepath+=$HOME/.vim/bundle/gundo.vim
    let g:dein#name = a:plugin_name

    return 1
  endif

  let options = get(a:000, 0, {})
  let enabled = 1

  if has_key(options, "if")
    if !options["if"]
      " don't load but fetch the plugin
      let options["rtp"] = ""
      call remove(options, "if")
      let enabled = 0
    endif
  else
    " sometimes dein doesn't add runtimepath if no options given
    let options["if"] = 1
  endif

  call dein#add(a:plugin_name, options)
  return dein#tap(fnamemodify(a:plugin_name, ":t")) && enabled
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
  let command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
  let command = command_prefix . " -e 'print Gem.path.join(\"\\n\")'"
  return split(system(command), "\\n")
endfunction  " }}}

function! ExecuteWithConfirm(command) abort  " {{{
  if !ConfirmCommand(a:command)
    return
  endif

  let result = system(a:command)

  if v:shell_error
    echomsg result
  endif
endfunction  " }}}

function! ConfirmCommand(command) abort  " {{{
  if input("execute `" . a:command . "` ? [y/n] : ") !~? "y"
    echo " -> canceled."
    return 0
  endif

  return 1
endfunction  " }}}
" }}}

let g:mapleader = ","

set conceallevel=2
set concealcursor=nvic
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
  if !isdirectory(s:plugin_manager_path)
    echo "Installing plugin manager...."
    call system("git clone https://github.com/Shougo/dein.vim " . s:plugin_manager_path)
  endif

  execute "set runtimepath+=" . s:plugin_manager_path
endif

call s:SetupPluginStart()
" }}}

" plugins list and settings  " {{{
call s:RegisterPlugin(s:plugin_manager_path)
call s:RegisterPlugin("Shougo/vimproc", { "build": "make" })

call s:RegisterPlugin("kg8m/.vim")

if s:RegisterPlugin("soramugi/auto-ctags.vim", { "if": OnRailsDir() })  " {{{
  let g:auto_ctags = 1

  augroup AutoCtagsAucocommands  " {{{
    autocmd!
    autocmd VimEnter,BufWritePost * silent call auto_ctags#ctags(0)
    autocmd VimEnter              * silent call s:CreateRubyGemsCtags()
  augroup END  " }}}

  function! s:CreateRubyGemsCtags() abort  " {{{
    let original_current_directory = getcwd()
    let original_directory_list    = g:auto_ctags_directory_list

    for ruby_gem_path in RubyGemPaths()
      if isdirectory(ruby_gem_path)
        execute "cd " . ruby_gem_path
        let g:auto_ctags_directory_list = [ruby_gem_path]
        call auto_ctags#ctags(0)
      endif
    endfor

    execute "cd " . original_current_directory
    let g:auto_ctags_directory_list = original_directory_list

    echomsg "ctags for Ruby gems have been created."
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("vim-scripts/autodate.vim")  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%(' .
                              \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                              \   '\%(最終更新日\?\)\|' .
                              \   '\%(更新日\)' .
                              \ '\):'
  let g:autodate_keyword_post = '\.$'
endif  " }}}

if s:RegisterPlugin("tyru/caw.vim")  " {{{
  nmap gc <Plug>(caw:hatpos:toggle)
  vmap gc <Plug>(caw:hatpos:toggle)

  let g:caw_no_default_keymappings = 1
  let g:caw_hatpos_skip_blank_line = 1

  augroup SetCawSpecialCommentMarkers  " {{{
    autocmd!
    autocmd FileType gemfile let b:caw_oneline_comment = "#"
  augroup END  " }}}

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["nv", "<Plug>(caw:"]],
     \ })
endif  " }}}

call s:RegisterPlugin("Shougo/context_filetype.vim")

if s:RegisterPlugin("spolu/dwm.vim")  " {{{
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

if s:RegisterPlugin("leafcage/foldCC")  " {{{
  let g:foldCCtext_enable_autofdc_adjuster = 1
  let g:foldCCtext_maxchars = 120
  set foldtext=FoldCCtext()
endif  " }}}

if s:RegisterPlugin("https://bitbucket.org/heavenshell/gundo.vim")  " {{{
  nnoremap <F5> :<C-u>GundoToggle<Cr>

  " http://d.hatena.ne.jp/heavenshell/20120218/1329532535
  let g:gundo_auto_preview = 0
  let g:gundo_prefer_python3 = 1

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "GundoToggle",
     \ })
endif  " }}}

if s:RegisterPlugin("sk1418/HowMuch")  " {{{
  let g:HowMuch_scale = 5

  function! s:DefineHowMuchMappings() abort  " {{{
    vmap <Leader>?  <Plug>AutoCalcReplace
    vmap <Leader>?s <Plug>AutoCalcReplaceWithSum
  endfunction  " }}}
  call s:DefineHowMuchMappings()

  function! s:ConfigPluginOnPostSource_HowMuch() abort  " {{{
    " overwriting default mappings
    call s:DefineHowMuchMappings()
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["v", "<Plug>AutoCalc"]],
     \   "hook_post_source": function("s:ConfigPluginOnPostSource_HowMuch"),
     \ })
endif  " }}}

if s:RegisterPlugin("nishigori/increment-activator")  " {{{
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

if s:native_incsearch_highlightable
  nnoremap / /\v
else
  if s:RegisterPlugin("haya14busa/incsearch.vim")  " {{{
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
  endif  " }}}
endif

if s:RegisterPlugin("Yggdroot/indentLine")  " {{{
  let g:indentLine_char = "|"
  let g:indentLine_faster = 1
  let g:indentLine_concealcursor = &concealcursor
  let g:indentLine_conceallevel = &conceallevel
  let g:indentLine_fileTypeExclude = [
    \   "",
    \   "diff",
    \   "startify",
    \   "unite",
    \   "vimfiler",
    \   "vimshell",
    \ ]
endif  " }}}

" interested in future features
call s:RegisterPlugin("pocke/iro.vim", { "if": 0 })

if s:RegisterPlugin("https://bitbucket.org/teramako/jscomplete-vim.git")  " {{{
  let g:jscomplete_use = ["dom", "moz", "es6th"]
endif  " }}}

if s:RegisterPlugin("itchyny/lightline.vim")  " {{{
  " http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2
  let s:lightline_elements = {
    \   "left": [
    \     ["mode", "paste"],
    \     ["bufnum", "filename"],
    \     ["filetype", "fileencoding", "fileformat"],
    \     ["lineinfo_with_percent"],
    \   ],
    \   "right": [
    \     ["anzu"],
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
    \     "anzu":     "AnzuSearchStatusForLightline",
    \   },
    \   "colorscheme": "kg8m",
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
    return &ft =~? 'help\|vimfiler\|gundo' ? "" : &modified ? "+" : &modifiable ? "" : "-"
  endfunction  " }}}

  function! AnzuSearchStatusForLightline() abort  " {{{
    if winwidth(0) >= 100
      return anzu#search_status()
    else
      return substitute(anzu#search_status(), '\v^.+\(([0-9]+/[0-9]+)\)$', '\1', "")
    endif
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("AndrewRadev/linediff.vim")  " {{{
  let g:linediff_second_buffer_command = "rightbelow vertical new"

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Linediff",
     \ })
endif  " }}}

call s:RegisterPlugin("vim-scripts/matchit.zip")
call s:RegisterPlugin("kg8m/moin.vim")

if s:RegisterPlugin("Shougo/neocomplete.vim")  " {{{
  function! s:ConfigPluginOnSource_neocomplete() abort  " {{{
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

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_i":   1,
     \   "on_cmd": "NeoCompleteBufferMakeCache",
     \   "hook_source": function("s:ConfigPluginOnSource_neocomplete"),
     \ })
endif  " }}}

if s:RegisterPlugin("Shougo/neosnippet")  " {{{
  function! s:ConfigPluginOnSource_neosnippet() abort  " {{{
    imap <expr><Tab>   pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    smap <expr><Tab>   neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
    imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    imap <expr><Cr>    neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#close_popup() : "\<Cr>"

    let g:neosnippet#snippets_directory = [
      \   s:PluginInfo(".vim").path . "/snippets",
      \ ]
    let g:neosnippet#disable_runtime_snippets = {
      \   "_" : 1,
      \ }

    augroup NeoSnippetClearMarkers  " {{{
      autocmd!
      autocmd InsertLeave * NeoSnippetClearMarkers
    augroup END  " }}}
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":      1,
     \   "on_i":      1,
     \   "on_ft":     ["snippet", "neosnippet"],
     \   "on_source": "unite.vim",
     \   "depends":   [".vim"],
     \   "hook_source": function("s:ConfigPluginOnSource_neosnippet"),
     \ })
endif  " }}}

if s:RegisterPlugin("tyru/open-browser.vim")  " {{{
  nmap <Leader>o <Plug>(openbrowser-open)
  vmap <Leader>o <Plug>(openbrowser-open)

  let g:openbrowser_browser_commands = [
    \   {
    \     "name": "ssh",
    \     "args": "ssh main 'open '\\''{uri}'\\'''",
    \   }
    \ ]

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_cmd":  ["OpenBrowserSearch", "OpenBrowser"],
     \   "on_func": "openbrowser#open",
     \   "on_map":  [["nv", "<Plug>(openbrowser-open)"]],
     \ })

endif  " }}}

if s:RegisterPlugin("tyru/operator-camelize.vim")  " {{{
  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [
     \     ["v", "<Plug>(operator-camelize)"],
     \     ["v", "<Plug>(operator-decamelize)"]
     \   ],
     \ })
endif  " }}}

call s:RegisterPlugin("chrisbra/Recover.vim")

if s:RegisterPlugin("vim-scripts/sequence")  " {{{
  vmap <Leader>+ <Plug>SequenceV_Increment
  vmap <Leader>- <Plug>SequenceV_Decrement
  nmap <Leader>+ <Plug>SequenceN_Increment
  nmap <Leader>- <Plug>SequenceN_Decrement

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["vn", "<Plug>Sequence"]],
     \ })
endif  " }}}

if s:RegisterPlugin("jiangmiao/simple-javascript-indenter")  " {{{
  let g:SimpleJsIndenter_BriefMode = 2
  let g:SimpleJsIndenter_CaseIndentLevel = -1
endif  " }}}

if s:RegisterPlugin("AndrewRadev/splitjoin.vim")  " {{{
  nnoremap <Leader>J :<C-u>SplitjoinJoin<Cr>
  nnoremap <Leader>S :<C-u>SplitjoinSplit<Cr>

  let g:splitjoin_split_mapping       = ""
  let g:splitjoin_join_mapping        = ""
  let g:splitjoin_ruby_trailing_comma = 1
  let g:splitjoin_ruby_hanging_args   = 0

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": ["SplitjoinJoin", "SplitjoinSplit"],
     \ })
endif  " }}}

call s:RegisterPlugin("vim-scripts/sudo.vim")
call s:RegisterPlugin("kg8m/svn-diff.vim", { "if": OnSvnDir() })

if s:RegisterPlugin("Shougo/unite.vim")  " {{{
  nnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  vnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  nnoremap <Leader>ug :<C-u>Unite -no-quit -winheight=30% -buffer-name=grep grep:./::
  vnoremap <Leader>ug "gy:<C-u>Unite -no-quit -winheight=30% -buffer-name=grep_<C-r>" grep:./::<C-r>"
  nnoremap <Leader>uy :<C-u>Unite history/yank<Cr>
  nnoremap <F4> :<C-u>Unite buffer<Cr>

  function! s:ConfigPluginOnSource_unite() abort  " {{{
    let g:unite_winheight = "100%"

    if s:ag_available
      let g:unite_source_grep_command       = "ag"
      let g:unite_source_grep_recursive_opt = ""
      let g:unite_source_grep_default_opts  = "--nocolor --nogroup --nopager"
    elseif s:ack_available
      let g:unite_source_grep_command       = "ack"
      let g:unite_source_grep_recursive_opt = ""
      let g:unite_source_grep_default_opts  = "--nocolor --nogroup --nopager"
    endif

    let g:unite_source_grep_search_word_highlight = "Special"

    call unite#custom#source("buffer", "sorters", "sorter_word")
    call unite#custom#source("grep", "max_candidates", 10000)

    " unite-shortcut  " {{{
      " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
      " http://d.hatena.ne.jp/tyru/20120110/prompt
      let g:unite_source_menu_menus = {}
      let g:unite_source_menu_menus.shortcuts = {
        \   "description": "My Shortcuts"
        \ }

      " http://nanasi.jp/articles/vim/hz_ja_vim.html
      let g:unite_source_menu_menus.shortcuts.candidates = [
        \   ["[Plugins] Update Plugins",        "call UpdatePlugins()"],
        \   ["[Plugins] Resume Update Plugins", "UniteResume update_plugins"],
        \
        \   ["[String Utility] All to Hankaku",           "'<,'>Hankaku"],
        \   ["[String Utility] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
        \   ["[String Utility] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
        \   ["[String Utility] All to Zenkaku",           "'<,'>Zenkaku"],
        \   ["[String Utility] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],
        \   ["[String Utility] Translate",                "'<,'>Translate"],
        \
        \   ["[Reload with Encoding] latin1",      "edit ++enc=latin1 +set\\ noreadonly"],
        \   ["[Reload with Encoding] cp932",       "edit ++enc=cp932 +set\\ noreadonly"],
        \   ["[Reload with Encoding] shift-jis",   "edit ++enc=shift-jis +set\\ noreadonly"],
        \   ["[Reload with Encoding] iso-2022-jp", "edit ++enc=iso-2022-jp +set\\ noreadonly"],
        \   ["[Reload with Encoding] euc-jp",      "edit ++enc=euc-jp +set\\ noreadonly"],
        \   ["[Reload with Encoding] utf-8",       "edit ++enc=utf-8 +set\\ noreadonly"],
        \
        \   ["[Reload by Sudo]", "edit sudo:%"],
        \
        \   ["[Set Encoding] latin1",      "set fenc=latin1"],
        \   ["[Set Encoding] cp932",       "set fenc=cp932"],
        \   ["[Set Encoding] shift-jis",   "set fenc=shift-jis"],
        \   ["[Set Encoding] iso-2022-jp", "set fenc=iso-2022-jp"],
        \   ["[Set Encoding] euc-jp",      "set fenc=euc-jp"],
        \   ["[Set Encoding] utf-8",       "set fenc=utf-8"],
        \
        \   ["[Set File Format] dos",  "set ff=dos"],
        \   ["[Set File Format] unix", "set ff=unix"],
        \   ["[Set File Format] mac",  "set ff=mac"],
        \
        \   ["[Manipulate File] Make Editable",                           "set noreadonly"],
        \   ["[Manipulate File] Convert to HTML",                         "colorscheme h2u_white | TOhtml"],
        \   ["[Manipulate File] Replace/Sed Texts of All Buffers [Edit]", "bufdo set eventignore-=Syntax | %s/{foo}/{bar}/gce | update"],
        \   ["[Manipulate File] Transform to New Ruby Hash Syntax",       "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
        \   ["[Manipulate File] Transform to Old Ruby Hash Syntax",       "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],
        \
        \   ["[Autoformat] Format Source Codes",         "Autoformat"],
        \   ["[autoft] Enable autoft on current buffer", "let b:autoft_enable = 1"],
        \
        \   ["[Diff] Linediff",       "'<,'>Linediff"],
        \   ["[Diff] DirDiff [Edit]", "DirDiff {dir1} {dir2}"],
        \
        \   ["[Rails] Reset Buffer", "if RailsDetect() | call rails#buffer_setup() | endif"],
        \
        \   ["[Unite plugin] gist",                 "Unite gista"],
        \   ["[Unite plugin] mru files",            "Unite neomru/file"],
        \   ["[Unite plugin] outline",              "Unite outline:!"],
        \   ["[Unite plugin] mark",                 "Unite mark"],
        \   ["[Unite plugin] tag with cursor word", "UniteWithCursorWord tag"],
        \   ["[Unite plugin] versions/status",      "UniteVersions status:./"],
        \   ["[Unite plugin] versions/log",         "UniteVersions log:./"],
        \   ["[Unite plugin] giti/status",          "Unite giti/status"],
        \   ["[Unite plugin] svn/status",           "Unite svn/status"],
        \   ["[Unite plugin] webcolorname",         "Unite webcolorname"],
        \
        \   ["[Unite] buffers",                       "Unite buffer"],
        \   ["[Unite] files",                         "UniteWithBufferDir file"],
        \   ["[Unite] various sources",               "UniteWithBufferDir buffer neomru/file bookmark file"],
        \   ["[Unite] history/yank",                  "Unite history/yank"],
        \   ["[Unite] register",                      "Unite register"],
        \   ["[Unite] grep current directory [Edit]", "Unite -no-quit -winheight=30% -buffer-name=grep grep:./::{words}"],
        \   ["[Unite] grep all buffers [Edit]",       "Unite -no-quit -winheight=30% -buffer-name=grep grep:$buffers::{words}"],
        \   ["[Unite] resume [Edit]",                 "UniteResume {buffer-name}"],
        \
        \   ["[Help] autocommand-events", "help autocommand-events"],
        \ ]

      " show formatted candidates, for example:
      "   [Plugins] Update Plugins                   --  `call UpdatePlugins()`
      "   [Plugins] Resume Update Plugins            --  `UniteResume update_plugins`
      "
      "   [String Utility] All to Hankaku            --  `'<,'>Hankaku`
      "   [String Utility] Alphanumerics to Hankaku  --  `'<,'>HzjaConvert han_eisu`
      "   ....
      function! s:FormatUniteShortcuts() abort  " {{{
        function! s:UniteShortcutsPrefix(word) abort  " {{{
          return substitute(a:word, '\v^\[([^]]+)\].*$', '\1', "")
        endfunction  " }}}

        function! s:UniteShortcutsWordPadding(word) abort  " {{{
          return repeat(" ", s:max_unite_shortcuts_word_length - strlen(a:word))
        endfunction  " }}}

        function! s:GroupUniteShortcuts() abort  " {{{
          let first_candidate                      = g:unite_source_menu_menus.shortcuts.candidates[0]
          let temporary_unite_shortcuts_prefix     = s:UniteShortcutsPrefix(first_candidate[0])
          let temporary_unite_shortcuts_candidates = []

          for candidate in g:unite_source_menu_menus.shortcuts.candidates
            let prefix = s:UniteShortcutsPrefix(candidate[0])

            if prefix != temporary_unite_shortcuts_prefix
              call add(temporary_unite_shortcuts_candidates, ["", ""])
              let temporary_unite_shortcuts_prefix = prefix
            endif

            call add(temporary_unite_shortcuts_candidates, candidate)
          endfor

          let g:unite_source_menu_menus.shortcuts.candidates = temporary_unite_shortcuts_candidates
        endfunction  " }}}

        call s:GroupUniteShortcuts()
        let s:max_unite_shortcuts_word_length = max(
          \   map(
          \     copy(g:unite_source_menu_menus.shortcuts.candidates),
          \     "strlen(v:val[0])"
          \   )
          \ )

        function! g:unite_source_menu_menus.shortcuts.map(key, value) abort  " {{{
          let [word, value] = a:value

          if empty(word) && empty(value)
            return { "word": "", "kind": "" }
          else
            return {
                 \   "word": word . s:UniteShortcutsWordPadding(word) . "  --  `" . value . "`",
                 \   "kind": "command",
                 \   "action__command": value,
                 \ }
          endif
        endfunction  " }}}
      endfunction  " }}}
      call s:FormatUniteShortcuts()
    " }}}
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Unite",
     \   "hook_source": function("s:ConfigPluginOnSource_unite"),
     \ })

  if s:RegisterPlugin("Shougo/neomru.vim")  " {{{
    call s:ConfigPlugin({
       \   "lazy": 0,
       \ })

    nnoremap <Leader>m :<C-u>Unite neomru/file<Cr>

    let g:neomru#time_format     = "%Y/%m/%d %H:%M:%S"
    let g:neomru#filename_format = ":~:."
    let g:neomru#file_mru_limit  = 1000
  endif  " }}}

  if s:RegisterPlugin("Shougo/neoyank.vim")  " {{{
    call s:ConfigPlugin({
       \   "lazy": 0,
       \ })

    let g:neoyank#limit = 300
  endif  " }}}

  if s:RegisterPlugin("kg8m/unite-dwm")  " {{{
    let g:unite_dwm_source_names_as_default_action = "buffer,file,file_mru,cdable"

    call s:ConfigPlugin({
       \   "lazy":  1,
       \   "on_ft": ["unite", "vimfiler"],
       \ })
  endif  " }}}

  if s:RegisterPlugin("osyo-manga/unite-filetype")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  call s:RegisterPlugin("Shougo/unite-help")

  if s:RegisterPlugin("kg8m/unite-mark")  " {{{
    nnoremap <Leader>um :<C-u>Unite mark<Cr>
    nnoremap <silent> m :<C-u>call AutoMark()<Cr>

    function! s:ConfigPluginOnSource_unite_mark() abort  " {{{
      " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
      let g:mark_increment_keys = [
        \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        \ ]
      let g:unite_source_mark_marks = join(g:mark_increment_keys, "")
      let s:mark_increment_key_regexp = "^[" . g:unite_source_mark_marks . "]$"

      function! AutoMark() abort  " {{{
        let mark_increment_key = s:DetectMarkIncrementKey()

        if mark_increment_key =~# s:mark_increment_key_regexp
          echo "Already marked to " . mark_increment_key
          return
        endif

        if !exists("g:mark_increment_index")
          let g:mark_increment_index = 0
        else
          let g:mark_increment_index = (g:mark_increment_index + 1) % len(g:mark_increment_keys)
        endif

        execute "mark " . g:mark_increment_keys[g:mark_increment_index]
        echo "Marked to " . g:mark_increment_keys[g:mark_increment_index]
      endfunction  " }}}

      function! s:DetectMarkIncrementKey() abort  " {{{
        let detected_mark_key   = 0
        let current_filepath    = expand("%")
        let current_line_number = line(".")

        for mark_key in g:mark_increment_keys
          let position = getpos("'" . mark_key)

          if position[0]
            let filepath    = bufname(position[0])
            let line_number = position[1]

            if filepath == current_filepath && line_number == current_line_number
              let detected_mark_key = mark_key
              break
            else
              continue
            endif
          else
            continue
          endif
        endfor

        return detected_mark_key
      endfunction  " }}}

      execute "delmarks " . join(g:mark_increment_keys, "")
    endfunction  " }}}

    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_func":   "AutoMark",
       \   "on_source": "unite.vim",
       \   "hook_source": function("s:ConfigPluginOnSource_unite_mark"),
       \ })
  endif  " }}}

  if s:RegisterPlugin("Shougo/unite-outline")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })

    nnoremap <Leader>uo :<C-u>Unite outline:!<Cr>
  endif  " }}}

  if s:RegisterPlugin("basyura/unite-rails", { "if": OnRailsDir() })  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })

    nnoremap <Leader>ur :<C-u>Unite rails/
  endif  " }}}

  if s:RegisterPlugin("tsukkee/unite-tag")  " {{{
    call s:ConfigPlugin("unite.vim", {
       \   "on_cmd": s:PluginInfo("unite.vim")["on_cmd"] + ["UniteWithCursorWord"],
       \ })

    nnoremap g] :<C-u>UniteWithCursorWord -immediately tag<Cr>
    vnoremap g] :<C-u>UniteWithCursorWord -immediately tag<Cr>
    nnoremap g[ :<C-u>Unite jump<Cr>
    nnoremap <Leader>ut :<C-u>UniteWithCursorWord -immediately tag<Cr>

    let g:unite_source_tag_max_name_length  = 50
    let g:unite_source_tag_max_fname_length = 100

    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  if s:RegisterPlugin("thinca/vim-unite-history")  " {{{
    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \ })
  endif  " }}}

  if s:RegisterPlugin("kg8m/vim-unite-giti", { "if": OnGitDir() })  " {{{
    if mapcheck("<Leader>uv") == ""
      nnoremap <Leader>uv :<C-u>Unite giti/status<Cr>
    endif

    let g:giti_log_default_line_count = 1000

    function! s:ConfigPluginOnPostSource_vim_unite_giti() abort  " {{{
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

    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \   "hook_post_source": function("s:ConfigPluginOnPostSource_vim_unite_giti"),
       \ })
  endif  " }}}

  if s:RegisterPlugin("kmnk/vim-unite-svn", { "if": OnSvnDir() })  " {{{
    if mapcheck("<Leader>uv") == ""
      nnoremap <Leader>uv :<C-u>Unite svn/status<Cr>
    endif

    function! s:ConfigPluginOnPostSource_vim_unite_svn() abort  " {{{
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

    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_source": "unite.vim",
       \   "hook_post_source": function("s:ConfigPluginOnPostSource_vim_unite_svn"),
       \ })
  endif  " }}}

  if s:RegisterPlugin("hrsh7th/vim-versions", { "if": OnGitDir() || OnSvnDir() })  " {{{
    nnoremap <Leader>u<S-v> :<C-u>UniteVersions status:./<Cr>

    function! s:ConfigPluginOnSource_vim_versions() abort  " {{{
      let g:versions#type#svn#status#ignore_status = ["X"]

      function! s:AddActionsToVersions() abort  " {{{
        let action = {
          \   "description":   "open files",
          \   "is_selectable": 1,
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

    call s:ConfigPlugin({
       \   "lazy":      1,
       \   "on_cmd":    "UniteVersions",
       \   "on_source": "unite.vim",
       \   "hook_source": function("s:ConfigPluginOnSource_vim_versions"),
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("h1mesuke/vim-alignta")  " {{{
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
    \   ["Align at 'hoge:'    --  `00 [a-zA-Z0-9_\"']\\+:\\s`", "00 [a-zA-Z0-9_\"']\\+:\\s"],
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

if s:RegisterPlugin("osyo-manga/vim-anzu")  " {{{
  if s:native_incsearch_highlightable
    nmap n <Plug>(anzu-n-with-echo)
    nmap N <Plug>(anzu-N-with-echo)
    vmap n n<Plug>(anzu-update-search-status)
    vmap N N<Plug>(anzu-update-search-status)
  else
    " see incsearch
  endif

  nnoremap <Leader>/ :<C-u>nohlsearch<Cr>:call anzu#clear_search_status()<Cr>

  " see asterisk for more settings
endif  " }}}

if s:RegisterPlugin("FooSoft/vim-argwrap")  " {{{
  nnoremap <Leader>a :ArgWrap<Cr>

  let g:argwrap_padded_braces = "{"

  augroup ConfigArgWrapAutocmd  " {{{
    autocmd!
    autocmd FileType eruby let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType ruby  let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType vim   let b:argwrap_line_prefix = '\'
    autocmd FileType vim   let b:argwrap_tail_comma_braces = "[{"
  augroup END  " }}}

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "ArgWrap",
     \ })
endif  " }}}

if s:RegisterPlugin("haya14busa/vim-asterisk")  " {{{
  if s:native_incsearch_highlightable
    map *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
    map #  <Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)
    map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
    map g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)
  else
    " see incsearch
  endif
endif  " }}}

if s:RegisterPlugin("Townk/vim-autoclose")  " {{{
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

if s:RegisterPlugin("Chiel92/vim-autoformat")  " {{{
  let g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif  " }}}

if s:RegisterPlugin("itchyny/vim-autoft")  " {{{
  let g:autoft_enable = 0
  let g:autoft_config = [
    \   { "filetype": "html",       "pattern": '<\%(!DOCTYPE\|html\|head\|script\)' },
    \   { "filetype": "javascript", "pattern": '\%(^\s*\<var\>\s\+[a-zA-Z]\+\)\|\%(function\%(\s\+[a-zA-Z]\+\)\?\s*(\)' },
    \   { "filetype": "c",          "pattern": '^\s*#\s*\%(include\|define\)\>' },
    \   { "filetype": "sh",         "pattern": '^#!.*\%(\<sh\>\|\<bash\>\)\s*$' },
    \ ]
endif  " }}}

if s:RegisterPlugin("kg8m/vim-blockle")  " {{{
  let g:blockle_mapping = ",b"
endif  " }}}

if s:RegisterPlugin("jkramer/vim-checkbox")  " {{{
  augroup ConfigCheckbox
    autocmd!
    autocmd FileType markdown,moin nnoremap <buffer> <Leader>c :ToggleCB<Cr>
  augroup END

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "ToggleCB",
     \ })
endif  " }}}

if s:RegisterPlugin("t9md/vim-choosewin")  " {{{
  nmap <C-w>f <Plug>(choosewin)

  let g:choosewin_overlay_enable          = 0  " wanna set true but too heavy
  let g:choosewin_overlay_clear_multibyte = 1
  let g:choosewin_blink_on_land           = 0
  let g:choosewin_statusline_replace      = 1  " wanna set false and use overlay
  let g:choosewin_tabline_replace         = 0

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": "<Plug>(choosewin)",
     \ })
endif  " }}}

call s:RegisterPlugin("kchmck/vim-coffee-script")
call s:RegisterPlugin("hail2u/vim-css-syntax")
call s:RegisterPlugin("hail2u/vim-css3-syntax")

if s:RegisterPlugin("kg8m/vim-dirdiff")  " {{{
  let g:DirDiffExcludes   = "CVS,*.class,*.exe,.*.swp,*.git,db/development_structure.sql,log,tags,tmp"
  let g:DirDiffIgnore     = "Id:,Revision:,Date:"
  let g:DirDiffSort       = 1
  let g:DirDiffIgnoreCase = 0
  let g:DirDiffForceLang  = "C"

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "DirDiff",
     \ })
endif  " }}}

if s:RegisterPlugin("Lokaltog/vim-easymotion")  " {{{
  nmap <Leader>f <Plug>(easymotion-s)
  vmap <Leader>f <Plug>(easymotion-s)
  omap <Leader>f <Plug>(easymotion-s)
  nmap <Leader>w <Plug>(easymotion-overwin-f)
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

call s:RegisterPlugin("thinca/vim-ft-diff_fold")
call s:RegisterPlugin("thinca/vim-ft-help_fold")
call s:RegisterPlugin("thinca/vim-ft-markdown_fold")

if s:RegisterPlugin("tpope/vim-fugitive", { "if": OnGitDir() })  " {{{
  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_cmd": "Gblame",
     \ })
endif  " }}}

call s:RegisterPlugin("thinca/vim-ft-svn_diff")
call s:RegisterPlugin("muz/vim-gemfile")
call s:RegisterPlugin("kana/vim-gf-user")

if s:RegisterPlugin("tpope/vim-git")  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup PreventVimGitFromChangingSettings  " {{{
    autocmd!
    autocmd FileType gitcommit let b:did_ftplugin = 1
  augroup END  " }}}
endif  " }}}

call s:RegisterPlugin("tpope/vim-haml")
call s:RegisterPlugin("michaeljsmith/vim-indent-object")

if s:RegisterPlugin("jelera/vim-javascript-syntax")  " {{{
  function! s:MyJavascriptFold() abort  " {{{
    if !exists("b:javascript_folded")
      call JavaScriptFold()
      setl foldlevelstart=0
      let b:javascript_folded = 1
    endif
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("elzr/vim-json")  " {{{
  let g:vim_json_syntax_conceal = 0
endif  " }}}

if s:RegisterPlugin("rcmdnk/vim-markdown")  " {{{
  let g:vim_markdown_override_foldtext = 0
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_no_extensions_in_markdown = 1
  let g:vim_markdown_autowrite = 1

  function! s:MarkdownCustomFormatoptions() abort  " {{{
    setlocal formatoptions-=r
  endfunction  " }}}

  augroup ResetMarkdownSettings  " {{{
    autocmd!
    autocmd InsertEnter * if &ft == "markdown" | call s:MarkdownCustomFormatoptions() | endif
  augroup END  " }}}

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "depends": "vim-markdown-quote-syntax",
     \   "on_ft":   "markdown",
     \ })
endif  " }}}

if s:RegisterPlugin("joker1007/vim-markdown-quote-syntax")  " {{{
  call s:ConfigPlugin({
     \   "lazy":  1,
     \   "on_ft": "markdown",
     \ })
endif  " }}}

call s:RegisterPlugin("xolox/vim-misc")

if s:RegisterPlugin("kana/vim-operator-replace")  " {{{
  nmap r <Plug>(operator-replace)
  vmap r <Plug>(operator-replace)

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "depends": ["vim-operator-user"],
     \   "on_map":  [["nv", "<Plug>(operator-replace)"]],
     \ })
endif  " }}}

if s:RegisterPlugin("rhysd/vim-operator-surround")  " {{{
  " sa<Char>         => surround by <Char>
  " sd<Char>         => delete surrounding <Char>
  " sr<Char1><Char2> => replace surrounding <Char1> by <Char2>
  nmap <silent><Leader>sa <Plug>(operator-surround-append)aw
  nmap <silent><Leader>sd <Plug>(operator-surround-delete)a
  nmap <silent><Leader>sr <Plug>(operator-surround-replace)a
  vmap <silent><Leader>sa <Plug>(operator-surround-append)
  vmap <silent><Leader>sd <Plug>(operator-surround-delete)a
  vmap <silent><Leader>sr <Plug>(operator-surround-replace)a

  function! s:ConfigPluginOnSource_vim_operator_surround() abort  " {{{
    let g:operator#surround#blocks = { "-": [] }

    " some pairs don't work as `keys` if they require IME's `henkan`
    " but they works as `block`
    let pairs = [
      \   ["（", "）"],
      \   ["［", "］"],
      \   ["「", "」"],
      \   ["『", "』"],
      \   ["〈", "〉"],
      \   ["《", "》"],
      \   ["【", "】"],
      \   ["“", "”"],
      \   ["‘", "’"],
      \ ]

    for pair in pairs
      call add(g:operator#surround#blocks["-"], {
        \   "block": pair, "motionwise": ["char", "line", "block"], "keys": pair
        \ })
    endfor
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "depends": ["vim-operator-user"],
     \   "on_map":  [["nv", "<Plug>(operator-surround-"]],
     \   "hook_source": function("s:ConfigPluginOnSource_vim_operator_surround"),
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-operator-user")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_func": "operator#user#define",
     \ })
endif  " }}}

if s:RegisterPlugin("itchyny/vim-parenmatch")  " {{{
  let g:loaded_matchparen = 1

  augroup HighlightParenmatch  " {{{
    autocmd!
    autocmd VimEnter,ColorScheme * highlight ParenMatch ctermbg=white ctermfg=black guibg=white guifg=black
  augroup END  " }}}
endif  " }}}

if s:RegisterPlugin("thinca/vim-prettyprint")  " {{{
  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_cmd":  ["PrettyPrint", "PP"],
     \   "on_func": ["PrettyPrint", "PP"],
     \ })
endif  " }}}

if s:RegisterPlugin("thinca/vim-qfreplace")  " {{{
  call s:ConfigPlugin({
     \   "lazy":  1,
     \   "on_ft": ["unite", "quickfix"]
     \ })
endif  " }}}

if s:RegisterPlugin("tpope/vim-rails", { "if": OnRailsDir() })  " {{{
  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })

  " http://fg-180.katamayu.net/archives/2006/09/02/125150
  let g:rails_level = 4

  if !exists("g:rails_projections")
    let g:rails_projections = {}
  endif

  let g:rails_projections["config/*"] = { "command": "config" }
  let g:rails_projections["config/database.yml"] = {
    \   "command": "db",
    \ }
  let g:rails_projections["script/*.rb"] = {
    \   "alternate": "test/script/{}_test.rb",
    \   "test":      "test/script/{}_test.rb",
    \ }
  let g:rails_projections["script/*"] = {
    \   "command":   "script",
    \   "alternate": "test/script/{}_test.rb",
    \   "test":      "test/script/{}_test.rb",
    \ }
  let g:rails_projections["spec/fabricators/*_fabricator.rb"] = {
    \   "command":   "fabricator",
    \   "affinity":  "model",
    \   "alternate": "app/models/{}.rb",
    \   "related":   "db/schema.rb#%p",
    \   "test":      "spec/models/{}_spec.rb",
    \ }
  let g:rails_projections["spec/support/*.rb"] = { "command": "support" }

  if !exists("g:rails_path_additions")
    let g:rails_path_additions = []
  endif

  let g:rails_path_additions += [
    \   "spec/support",
    \ ]

  augroup SetupRails
    autocmd!
    autocmd BufEnter,BufWinEnter,WinEnter * 
          \ if RailsDetect() | call rails#buffer_setup() | endif
  augroup END

  " prevent `rails.vim` from defining keymappings
  nmap <Leader>Rwf  <Plug>RailsSplitFind
  nmap <Leader>Rwgf <Plug>RailsTabFind
endif  " }}}

call s:RegisterPlugin("tpope/vim-repeat")

if s:RegisterPlugin("vim-ruby/vim-ruby")  " {{{
  " see vim-gemfile
  augroup PreventVimRubyFromChangingSettings  " {{{
    autocmd!
    autocmd BufEnter Gemfile set filetype=Gemfile
  augroup END  " }}}

  let g:no_ruby_maps = 1

  call s:ConfigPlugin({
     \   "lazy": 0,
     \ })
endif  " }}}

if s:RegisterPlugin("joker1007/vim-ruby-heredoc-syntax")  " {{{
  let g:ruby_heredoc_syntax_filetypes = {
    \   "haml": { "start": "HAML" },
    \   "ruby": { "start": "RUBY" },
    \ }

  call s:ConfigPlugin({
     \   "depends": "vim-coffee-script",
     \ })
endif  " }}}

if s:RegisterPlugin("kg8m/vim-rubytest", { "if": !OnTmux() })  " {{{
  augroup ConfigRubytest  " {{{
    autocmd!
    autocmd FileType ruby nmap <buffer> <leader>T <Plug>RubyFileRun
    autocmd FileType ruby nmap <buffer> <leader>t <Plug>RubyTestRun
  augroup END  " }}}

  let g:no_rubytest_mappings = 1
  let g:rubytest_in_vimshell = 1

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["n", "<Plug>RubyFileRun"], ["n", "<Plug>RubyTestRun"]],
     \ })
endif  " }}}

if s:RegisterPlugin("xolox/vim-session")  " {{{
  " also see vim-startify's settings

  let g:session_directory         = getcwd() . "/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = 0

  set sessionoptions=buffers,curdir

  augroup ExtendPluginSession  " {{{
    autocmd!
    autocmd BufWritePost * silent call s:SaveSession()
    autocmd BufWritePost * silent call s:CleanUpSession()
  augroup END  " }}}

  function! s:SaveSession() abort  " {{{
    if s:IsSessionSavable()
      execute "SaveSession " . s:SessionName()
    endif
  endfunction  " }}}

  function! s:IsSessionSavable() abort  " {{{
    return bufname(1) != ".git/COMMIT_EDITMSG" &&
         \ bufname(1) != ".git/addp-hunk-edit.diff" &&
         \ bufname(1) != "Startify"
  endfunction  " }}}

  function! s:SessionName() abort  " {{{
    return substitute(@%, "/", "+=", "g")
  endfunction  " }}}

  function! s:CleanUpSession() abort  " {{{
    execute " ! /usr/bin/env ls -at " . g:session_directory .
          \ " | /usr/bin/env grep '\\.vim$'" .
          \ " | /usr/bin/env tail -n +11" .
          \ " | /usr/bin/env xargs -I% rm -f " . g:session_directory . "/%"
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "depends": ["vim-misc"],
     \ })
endif  " }}}

if s:RegisterPlugin("thinca/vim-singleton")  " {{{
  if has("gui_running") && !singleton#is_master()
    let g:singleton#opener = "drop"
    call singleton#enable()
  endif

  call s:ConfigPlugin({
     \   "gui": 1,
     \ })
endif  " }}}

if s:RegisterPlugin("mhinz/vim-startify")  " {{{
  function! s:ConfigPluginOnSource_vim_startify() abort  " {{{
    " see vim-session's settings
    let g:startify_session_dir         = g:session_directory
    let g:startify_session_persistence = 0
    let g:startify_session_sort        = 1

    let g:startify_enable_special = 1
    let g:startify_change_to_dir  = 0
    let g:startify_relative_path  = 1
    let g:startify_list_order     = [
      \   ["My commands:"],
      \   "commands",
      \   ["My bookmarks:"],
      \   "bookmarks",
      \   ["My sessions:"],
      \   "sessions",
      \   ["Recently opened files:"],
      \   "files",
      \   ["Recently modified files in the current directory:"],
      \   "dir",
      \ ]
    let g:startify_commands = [
      \   { "p": "call UpdatePlugins()" },
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
      \   "",
      \ ]
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_vim_startify() abort  " {{{
    highlight StartifyFile   ctermfg=255
    highlight StartifyHeader ctermfg=255
    highlight StartifyPath   ctermfg=245
    highlight StartifySlash  ctermfg=245
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":     1,
     \   "on_event": "VimEnter",
     \   "hook_source":      function("s:ConfigPluginOnSource_vim_startify"),
     \   "hook_post_source": function("s:ConfigPluginOnPostSource_vim_startify"),
     \ })
endif  " }}}

if s:RegisterPlugin("kopischke/vim-stay")  " {{{
  set viewoptions=cursor,folds
endif  " }}}

call s:RegisterPlugin("tpope/vim-surround")

if s:RegisterPlugin("deris/vim-textobj-enclosedsyntax")  " {{{
  call s:ConfigPlugin({
     \   "depends": ["vim-textobj-user"],
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-textobj-jabraces")  " {{{
  call s:ConfigPlugin({
     \   "depends": ["vim-textobj-user"],
     \ })

  let g:textobj_jabraces_no_default_key_mappings = 1
endif  " }}}

if s:RegisterPlugin("kana/vim-textobj-lastpat")  " {{{
  call s:ConfigPlugin({
     \   "depends": ["vim-textobj-user"],
     \ })
endif  " }}}

if s:RegisterPlugin("osyo-manga/vim-textobj-multitextobj")  " {{{
  omap aj <Plug>(textobj-multitextobj-a)
  omap ij <Plug>(textobj-multitextobj-i)
  vmap aj <Plug>(textobj-multitextobj-a)
  vmap ij <Plug>(textobj-multitextobj-i)

  function! s:ConfigPluginOnSource_vim_textobj_multitextobj() abort
    let g:textobj_multitextobj_textobjects_a = [[]]
    let g:textobj_multitextobj_textobjects_i = [[]]
    let textobj_names = [
      \   "textobj-jabraces-parens",
      \   "textobj-jabraces-braces",
      \   "textobj-jabraces-brackets",
      \   "textobj-jabraces-angles",
      \   "textobj-jabraces-double-angles",
      \   "textobj-jabraces-kakko",
      \   "textobj-jabraces-double-kakko",
      \   "textobj-jabraces-yama-kakko",
      \   "textobj-jabraces-double-yama-kakko",
      \   "textobj-jabraces-kikkou-kakko",
      \   "textobj-jabraces-sumi-kakko",
      \   "textobj-myjabraces-double-quotation",
      \   "textobj-myjabraces-single-quotation",
      \ ]

    for textobj_name in textobj_names
      call add(g:textobj_multitextobj_textobjects_a[0], "\<Plug>(" . textobj_name . "-a)")
      call add(g:textobj_multitextobj_textobjects_i[0], "\<Plug>(" . textobj_name . "-i)")
    endfor
  endfunction

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "depends": ["vim-textobj-user"],
     \   "on_map":  [["ov", "<Plug>(textobj-multitextobj-"]],
     \   "hook_source": function("s:ConfigPluginOnSource_vim_textobj_multitextobj"),
     \ })
endif  " }}}

if s:RegisterPlugin("rhysd/vim-textobj-ruby")  " {{{
  call s:ConfigPlugin({
     \   "depends": ["vim-textobj-user"],
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-textobj-user")  " {{{
  function! s:ConfigPluginOnSource_vim_textobj_user() abort
    " some kakkos are not defined because they require IME's `henkan` and not work
    " - { "pair": ["｛", "｝"], "name": "bracket" },
    " - { "pair": ["『", "』"], "name": "double-kakko" },
    " - { "pair": ["【", "】"], "name": "sumi-kakko" },
    " - { "pair": ["〈", "〉"], "name": "yama-kakko" },
    " - { "pair": ["《", "》"], "name": "double-yama-kakko" },
    let jbrace_specs = [
      \   { "pair": ["（", "）"], "name": "paren" },
      \   { "pair": ["［", "］"], "name": "brace" },
      \   { "pair": ["「", "」"], "name": "kakko" },
      \   { "pair": ["“", "”"], "name": "double-quotation" },
      \   { "pair": ["‘", "’"], "name": "single-quotation" },
      \ ]

    let jbrace_config = {}
    for spec in jbrace_specs
      let jbrace_config[spec["name"]] = {
        \   "pattern":  spec["pair"],
        \   "select-a": ["a" . spec["pair"][0], "a" . spec["pair"][1]],
        \   "select-i": ["i" . spec["pair"][0], "i" . spec["pair"][1]],
        \ }
    endfor
    call textobj#user#plugin("myjabraces", jbrace_config)
  endfunction

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_func": "textobj#user",
     \   "hook_source": function("s:ConfigPluginOnSource_vim_textobj_user"),
     \ })
endif  " }}}

if s:RegisterPlugin("jgdavey/vim-turbux", { "if": OnTmux() })  " {{{
  augroup ConfigTurbux  " {{{
    autocmd!
    autocmd FileType ruby nmap <buffer> <leader>T <Plug>SendTestToTmux
    autocmd FileType ruby nmap <buffer> <leader>t <Plug>SendFocusedTestToTmux
  augroup END  " }}}

  let g:no_turbux_mappings = 1
  let g:turbux_test_type   = ""  " FIXME: escape undefined g:turbux_test_type error

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["n", "<Plug>SendTestToTmux"], ["n", "<Plug>SendFocusedTestToTmux"]],
     \ })
endif  " }}}

call s:RegisterPlugin("superbrothers/vim-vimperator")

if s:RegisterPlugin("thinca/vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup HighlightZenkakuSpace  " {{{
    autocmd!
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if s:RegisterPlugin("Shougo/vimfiler")  " {{{
  nnoremap <Leader>e :<C-u>VimFilerBufferDir -force-quit<Cr>

  function! s:ConfigPluginOnSource_vimfiler() abort  " {{{
    call vimfiler#custom#profile("default", "context", {
       \   "safe": 0,
       \   "split_action": "dwm_open",
       \ })
  endfunction  " }}}

  call s:ConfigPlugin({
     \   "lazy":    1,
     \   "on_func": "VimFilerBufferDir",
     \   "hook_source": function("s:ConfigPluginOnSource_vimfiler"),
     \ })
endif  " }}}

if s:RegisterPlugin("benmills/vimux", { "if": OnTmux() })  " {{{
  function! s:ConfigPluginOnSource_vimux() abort  " {{{
    let g:VimuxHeight     = 30
    let g:VimuxUseNearest = 1

    augroup Vimux  " {{{
      autocmd!
      autocmd VimLeavePre * :VimuxCloseRunner
    augroup END  " }}}
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_vimux() abort  " {{{
    " overwriting default function: use current pane's next one
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

  call s:ConfigPlugin({
     \   "lazy":     1,
     \   "on_event": "VimEnter",
     \   "hook_source":      function("s:ConfigPluginOnSource_vimux"),
     \   "hook_post_source": function("s:ConfigPluginOnPostSource_vimux"),
     \ })
endif  " }}}

if s:RegisterPlugin("simeji/winresizer")  " {{{
  let g:winresizer_start_key = "<C-w><C-e>"

  call s:ConfigPlugin({
     \   "lazy":   1,
     \   "on_map": [["n", g:winresizer_start_key]],
     \ })
endif  " }}}

if s:RegisterPlugin("LeafCage/yankround.vim")  " {{{
  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap P     <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif  " }}}

" colorschemes
if s:RegisterPlugin("kg8m/molokai")  " {{{
  let g:molokai_original = 1
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
" }}}
" }}}

" ----------------------------------------------
" general looks  " {{{
colorscheme molokai

set showmatch
set number
set showmode
set showcmd

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
  " (no)expandtab
  autocmd FileType neosnippet set noexpandtab

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

  autocmd FileType neosnippet setlocal foldmethod=marker
  autocmd FileType vim        setlocal foldmethod=marker
  autocmd FileType yaml       setlocal foldmethod=indent
  autocmd FileType haml       setlocal foldmethod=indent
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

let s:swapdir = $HOME . "/tmp/.vimswap"
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir, "p")
endif
execute "set directory=" . s:swapdir

" undo
set hidden
set undofile

let s:undodir = $HOME . "/tmp/.vimundo"
if !isdirectory(s:undodir)
  call mkdir(s:undodir, "p")
endif
execute "set undodir=" . s:undodir

" wildmode
set wildmenu
set wildmode=list:longest,full

" ctags
if has("vim_starting")
  function! s:SetupTags() abort  " {{{
    for ruby_gem_path in RubyGemPaths()
      if isdirectory(ruby_gem_path)
        let &tags = &tags . "," . ruby_gem_path . "/tags"
      endif
    endfor
  endfunction  " }}}
  call s:SetupTags()
endif

" auto reload
augroup CheckTimeHook  " {{{
  autocmd!
  autocmd InsertEnter * checktime
  autocmd InsertLeave * checktime
  autocmd CursorHold  * checktime
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

  if a:file =~? "[qfreplace]"
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

" http://qiita.com/momo-lab/items/7d35acc8ed835471ad4c
command! -range Translate <line1>,<line2>!trans -b
" }}}

" ----------------------------------------------
" keymappings  " {{{
" ,r => reload .vimrc
nnoremap <Leader>r :<C-u>source $HOME/.vimrc<Cr>

" <C-/> => nohilight
" see vim-anzu's settings
" nnoremap <Leader>/ :<C-u>nohlsearch<Cr>

" ,v => vertically split window
" ,h => horizontally split window
nnoremap <Leader>v :<C-u>vsplit<Cr>
nnoremap <Leader>h :<C-u>split<Cr>

" ,y/,p => copy/paste by clipboard
if s:on_tmux
  function! s:RegisterToRemoteCopy() abort  " {{{
    let text = @"
    let text = substitute(text, "^\\n\\+", "", "")
    let text = substitute(text, "\\n\\+$", "", "")

    if text =~# "\n"
      let filter = ""
    else
      let filter = " | tr -d '\\n'"
    endif

    call system("echo '" . substitute(text, "'", "'\\\\''", "g") . "'" . filter . " | ssh main 'LC_CTYPE=UTF-8 pbcopy'")
    echomsg "Copy the Selection by pbcopy."
  endfunction  " }}}

  vnoremap <Leader>y "yy:<C-u>call <SID>RegisterToRemoteCopy()<Cr>
else
  vnoremap <Leader>y "*y
endif
nnoremap <Leader>p "*p

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
inoremap <C-a> <Home>
inoremap <C-e> <End>

" Page scroll in INSERT mode
inoremap <C-f> <PageDown>
inoremap <C-b> <PageUp>

" <C-]> to insert a checkbox `[ ]` on markdown
augroup ConfigInsertCheckbox
  autocmd!
  autocmd FileType markdown inoremap <buffer> <C-]> [<Space>]<Space>
augroup END
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
if filereadable($HOME . "/.vimrc.local")
  source $HOME/.vimrc.local
endif
" }}}
