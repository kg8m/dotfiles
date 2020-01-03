" ----------------------------------------------
" Initialize  " {{{
let s:vim_root_path       = expand($HOME . "/.vim")
let s:plugins_path        = expand(s:vim_root_path . "/plugins")
let s:plugin_manager_path = expand(s:plugins_path . "/repos/github.com/Shougo/dein.vim")

" ----------------------------------------------
" Encoding  " {{{
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

augroup MyCheckEncoding  " {{{
  autocmd!
  autocmd BufReadPost * call s:RecheckFileencoding()
augroup END  " }}}

set fileformats=unix,dos,mac

if exists("&ambiwidth")
  set ambiwidth=double
endif

scriptencoding utf-8
" }}}

" Plugin management functions  " {{{
function! UpdatePlugins() abort  " {{{
  call dein#update()

  let initial_input = '!Same\\ revision'
    \   . '\ !Current\\ branch\\ master\\ is\\ up\\ to\\ date.'
    \   . '\ !^$'
    \   . '\ !(*/*)\\ [+'
    \   . '\ !Created\\ autostash'
    \   . '\ !Applied\\ autostash'
    \   . '\ !HEAD\\ is\\ now'
    \   . '\ !\\ *master\\ *->\\ origin/master'
    \   . '\ !^First,\\ rewinding\\ head\\ to\\ replay\\ your\\ work\\ on\\ top\\ of\\ it'
    \   . '\ !^Fast-forwarded\\ master\\ to'
    \   . '\ !^From\\ https://'

  execute "Unite dein/log -buffer-name=update_plugins -input=" . initial_input

  " Press `n` key to search "Updated"
  let @/ = "Updated"
endfunction  " }}}

" Global scope for calling by external sources
function! IsPluginSourced(plugin_name) abort  " {{{
  return dein#is_sourced(a:plugin_name)
endfunction  " }}}

function! s:SetupPluginStart() abort  " {{{
  return dein#begin(s:plugins_path)
endfunction  " }}}

function! s:SetupPluginEnd() abort  " {{{
  return dein#end()
endfunction  " }}}

function! s:RegisterPlugin(plugin_name, ...) abort  " {{{
  let options = get(a:000, 0, {})
  let enabled = 1

  if has_key(options, "if")
    if !options["if"]
      " Don't load but fetch the plugin
      let options["rtp"] = ""
      call remove(options, "if")
      let enabled = 0
    endif
  else
    " Sometimes dein doesn't add runtimepath if no options given
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

" for LSPs  " {{{
function! s:RegisterLSP(config) abort  " {{{
  if !exists("s:lsps")
    let s:lsps = []
  endif

  if has_key(a:config, "executable_name")
    let executable_name = a:config.executable_name
    call remove(a:config, "executable_name")
  else
    let executable_name = a:config.name
  endif

  if executable(executable_name)
    if !has_key(a:config, "root_uri")
      let a:config.root_uri = { server_info -> lsp#utils#path_to_uri(getcwd()) }
    endif

    let s:lsp_configs   = get(s:, "lsp_configs", []) + [a:config]
    let s:lsp_filetypes = get(s:, "lsp_filetypes", []) + a:config.whitelist

    call s:DefineLSPHooks()
    call add(s:lsps, #{ name: a:config.name, available: 1 })
  else
    call add(s:lsps, #{ name: a:config.name, available: 0 })
  endif
endfunction  " }}}

function! s:DefineLSPHooks() abort  " {{{
  if exists("s:is_lsp_hooks_defined")
    return
  endif

  augroup MyLspHooks  " {{{
    autocmd!
    autocmd FileType * call s:ResetLSPOmnifuncSet()
    autocmd InsertEnter * call s:SetLSPOmnifunc()
    autocmd User lsp_setup call s:EnableLSPs()
  augroup END  " }}}

  let s:is_lsp_hooks_defined = 1
endfunction  " }}}

function! s:EnableLSPs() abort  " {{{
  for config in s:lsp_configs
    call lsp#register_server(config)
  endfor

  augroup MyEnableLspDefinition
    autocmd!
    execute "autocmd FileType " . join(s:lsp_filetypes, ",") . " nmap <buffer> g] <Plug>(lsp-definition)"
  augroup END

  doautocmd FileType
endfunction  " }}}

" Lazily call this function to overwrite other plugins' settings
function! s:SetLSPOmnifunc() abort  " {{{
  if exists("b:is_lsp_omnifunc_set")
    return
  endif

  let b:is_lsp_omnifunc_set = 1
  let filetype_patterns = map(copy(s:lsp_filetypes), { _, filetype -> "^" . filetype . "$" })
  let filetype_pattern = '\v' . join(filetype_patterns, "|")

  if &filetype =~# filetype_pattern
    setlocal omnifunc=lsp#complete
  endif
endfunction  " }}}

function! s:ResetLSPOmnifuncSet() abort  " {{{
  if exists("b:is_lsp_omnifunc_set")
    unlet b:is_lsp_omnifunc_set
  endif
endfunction  " }}}
" }}}
" }}}

" Utility functions  " {{{
function! s:EchoErrorMsg(message) abort  " {{{
  echohl ErrorMsg
  echomsg a:message
  echohl None
endfunction  " }}}

function! OnTmux() abort  " {{{
  return exists("$TMUX")
endfunction  " }}}

function! OnRailsDir() abort  " {{{
  if exists("s:on_rails_dir")
    return s:on_rails_dir
  endif

  let s:on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:on_rails_dir
endfunction  " }}}

function! OnGitDir() abort  " {{{
  if exists("s:on_git_dir")
    return s:on_git_dir
  endif

  silent! !git status > /dev/null 2>&1
  let s:on_git_dir = !v:shell_error
  return s:on_git_dir
endfunction  " }}}

function! IsGitCommit() abort  " {{{
  if exists("s:is_git_commit")
    return s:is_git_commit
  endif

  let s:is_git_commit = argc() == 1 && argv()[0] =~# '\.git/COMMIT_EDITMSG$'
  return s:is_git_commit
endfunction  " }}}

function! IsGitHunkEdit() abort  " {{{
  if exists("s:is_git_hunk_edit")
    return s:is_git_hunk_edit
  endif

  let s:is_git_hunk_edit = argc() == 1 && argv()[0] =~# '\.git/addp-hunk-edit.diff$'
  return s:is_git_hunk_edit
endfunction  " }}}

function! RubyGemPaths() abort  " {{{
  if exists("s:ruby_gem_paths")
    return s:ruby_gem_paths
  endif

  if exists("$RUBY_GEM_PATHS")
    let s:ruby_gem_paths = split($RUBY_GEM_PATHS, '\n')
  else
    let command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
    let command = command_prefix . " -e 'print Gem.path.join(\"\\n\")'"
    let s:ruby_gem_paths = split(system(command), '\n')
  endif

  return s:ruby_gem_paths
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
  if input("execute `" . a:command . "`? [y/n] : ") !~? "y"
    echo " -> canceled."
    return 0
  endif

  return 1
endfunction  " }}}

function! RemoteCopy(text) abort  " {{{
  let text = a:text
  let text = substitute(text, '^\n\+', "", "")
  let text = substitute(text, '\n\+$', "", "")
  let text = substitute(text, '\', '\\\\', "g")

  if text =~# "\n"
    let filter = ""
  else
    let filter = " | tr -d '\\n'"
  endif

  call system("echo '" . substitute(text, "'", "'\\\\''", "g") . "'" . filter . " | ssh main 'LC_CTYPE=UTF-8 pbcopy'")

  if &columns > 50
    let text = substitute(text, '\v\n|\t', " ", "g")
    let truncated = trim(s:StringUtility().truncate(text, &columns - 30))
    echomsg "Copied: " . truncated . (trim(text) == truncated ? "" : "...")
  else
    echomsg "Copied"
  endif
endfunction  " }}}

function! CurrentFilename() abort  " {{{
  return expand("%:t")
endfunction  " }}}

function! CurrentRelativePath() abort  " {{{
  return fnamemodify(expand("%"), ":~:.")
endfunction  " }}}

function! CurrentAbsolutePath() abort  " {{{
  return fnamemodify(expand("%"), ":~")
endfunction  " }}}
" }}}

let g:no_vimrc_example          = 1
let g:no_gvimrc_example         = 1
let g:loaded_gzip               = 1
let g:loaded_tar                = 1
let g:loaded_tarPlugin          = 1
let g:loaded_zip                = 1
let g:loaded_zipPlugin          = 1
let g:loaded_rrhelper           = 1
let g:loaded_vimball            = 1
let g:loaded_vimballPlugin      = 1
let g:loaded_getscript          = 1
let g:loaded_getscriptPlugin    = 1
let g:loaded_netrw              = 1
let g:loaded_netrwPlugin        = 1
let g:loaded_netrwSettings      = 1
let g:loaded_netrwFileHandlers  = 1
let g:did_install_default_menus = 1
let g:skip_loading_mswin        = 1
let g:did_install_syntax_menu   = 1

let g:mapleader = ","

set conceallevel=2
set concealcursor=nvic
" }}}

" ----------------------------------------------
" Plugins  " {{{
" Initialize plugin manager  " {{{
if has("vim_starting")
  if !isdirectory(s:plugin_manager_path)
    echo "Installing plugin manager...."
    call system("git clone https://github.com/Shougo/dein.vim " . s:plugin_manager_path)
  endif

  let &runtimepath .= "," . s:plugin_manager_path
endif

call s:SetupPluginStart()
" }}}

" Plugins list and settings  " {{{
call s:RegisterPlugin(s:plugin_manager_path)
call s:RegisterPlugin("Shougo/vimproc", #{ build: "make" })

call s:RegisterPlugin("kg8m/.vim")

" Completion, LSP  " {{{
if s:RegisterPlugin("prabirshrestha/asyncomplete.vim")  " {{{
  let g:asyncomplete_auto_popup = 1
  let g:asyncomplete_popup_delay = 200
  let g:asyncomplete_auto_completeopt = 0
  let g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  inoremap <silent> <expr> <BS> "\<BS>" . <SID>LazyRefreshCompletion()
  inoremap <silent> <expr> .    "."     . <SID>LazyRefreshCompletion()

  function! s:LazyRefreshCompletion() abort  " {{{
    call s:ClearCompletionTimer()
    call s:StartCompletionTimer()
    return ""
  endfunction  " }}}

  function! s:StartCompletionTimer() abort  " {{{
    let s:my_completion_refresh_timer = timer_start(200, { -> call("s:ForceRefreshCompletion", []) })
  endfunction  " }}}

  function! s:ClearCompletionTimer() abort  " {{{
    if exists("s:my_completion_refresh_timer")
      call timer_stop(s:my_completion_refresh_timer)
      unlet s:my_completion_refresh_timer
    endif
  endfunction  " }}}

  function! s:ForceRefreshCompletion() abort  " {{{
    call asyncomplete#_force_refresh()
    call s:ClearCompletionTimer()
  endfunction  " }}}

  augroup MyToggleAsyncomplete  " {{{
    autocmd!
    autocmd FileType unite let b:asyncomplete_enable = 0
  augroup END  " }}}

  " Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  " Inspired by machakann/asyncomplete-ezfilter.vim's asyncomplete#preprocessor#ezfilter#filter
  " Fuzzy matcher is mattn's idea
  " cf. LSP's sources are named "asyncomplete_lsp_{original source name}"
  " cf. asyncomplete sources except for LSPs are named "asyncomplete_source_xxx"
  function! s:AsyncompleteSortedFilter(ctx, matches) abort  " {{{
    let sorted_items = []
    let base_matcher = escape(a:ctx.base, '~"\.^$[]*')
    let fuzzy_matcher = "^" . join(map(split(base_matcher, '\zs'), "printf('[\\x%02x].*', char2nr(v:val))"), '')

    for [source_name, matches] in sort(items(a:matches), { a, b -> a[0] > b[0] ? 1 : -1 })
      call extend(sorted_items, filter(matches.items, { index, item -> item.word =~? fuzzy_matcher }))
    endfor

    call asyncomplete#preprocess_complete(a:ctx, sorted_items)
  endfunction  " }}}
  let g:asyncomplete_preprocessor = [function("s:AsyncompleteSortedFilter")]

  function! s:ConfigPluginOnPostSource_asyncomplete() abort  " {{{
    if get(b:, "asyncomplete_enable", 1)
      call asyncomplete#enable_for_buffer()
    endif
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy: 1,
     \   on_i: 1,
     \   hook_post_source: function("s:ConfigPluginOnPostSource_asyncomplete"),
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-buffer.vim")  " {{{
  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L29
  let s:asyncomplete_buffer_events = [
    \   "BufWinEnter",
    \   "BufWritePost",
    \   "CursorHold",
    \   "CursorHoldI",
    \   "InsertLeave",
    \   "TextChanged",
    \ ]

  augroup MyConfigAsyncompleteBuffer  " {{{
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
          \   name: "asyncomplete_source_02_buffer",
          \   whitelist: ["*"],
          \   completor: function("asyncomplete#sources#buffer#completor"),
          \   events: s:asyncomplete_buffer_events,
          \   on_event: function("s:AsyncompleteBufferOnEvent"),
          \ }))
  augroup END  " }}}

  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
  function! s:AsyncompleteBufferOnEvent(...) abort  " {{{
    if !exists("s:asyncomplete_buffer_sid")
      call s:SetupAsyncompleteBufferRefreshKeywords()
    endif

    call s:AsyncompleteBufferRefreshKeywords()
  endfunction  " }}}

  function! s:SetupAsyncompleteBufferRefreshKeywords() abort  " {{{
    for scriptname in split(execute(":scriptnames"), '\n')
      if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
        let s:asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
        break
      endif
    endfor

    if exists("s:asyncomplete_buffer_sid")
      let s:AsyncompleteBufferRefreshKeywords = function("<SNR>" . s:asyncomplete_buffer_sid . "_refresh_keywords")
    else
      if exists("s:AsyncompleteBufferRefreshKeywords")
        return
      endif

      function! s:AsyncompleteBufferCannotRefreshKeywords() abort
        call s:EchoErrorMsg("Cannot refresh keywords because asyncomplete-buffer.vim's SID is not found.")
      endfunction
      let s:AsyncompleteBufferRefreshKeywords = function("AsyncompleteBufferCannotRefreshKeywords")
    endif
  endfunction  " }}}

  function! s:ActivateAsyncompleteBuffer() abort  " {{{
    " Trigger one of the s:asyncomplete_buffer_events
    doautocmd TextChanged
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_asyncomplete_buffer() abort  " {{{
    call s:ActivateAsyncompleteBuffer()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: "asyncomplete.vim",
     \   hook_post_source: function("s:ConfigPluginOnPostSource_asyncomplete_buffer"),
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-file.vim")  " {{{
  augroup MyConfigAsyncompleteFile  " {{{
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
          \   name: "asyncomplete_source_file",
          \   whitelist: ["*"],
          \   completor: function("asyncomplete#sources#file#completor"),
          \ }))
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-neosnippet.vim")  " {{{
  augroup MyConfigAsyncompleteNeosnippet  " {{{
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options(#{
          \   name: "asyncomplete_source_01_neosnippet",
          \   whitelist: ["*"],
          \   completor: function("asyncomplete#sources#neosnippet#completor"),
          \ }))
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: ["asyncomplete.vim", "neosnippet"],
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-tags.vim")  " {{{
  augroup MyConfigAsyncompleteTags  " {{{
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options(#{
          \   name: "asyncomplete_source_tags",
          \   whitelist: ["*"],
          \   completor: function("asyncomplete#sources#tags#completor"),
          \ }))
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-lsp.vim")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: ["asyncomplete.vim", "vim-lsp"],
     \ })
endif  " }}}

if s:RegisterPlugin("Shougo/neosnippet")  " {{{
  function! s:ConfigPluginOnSource_neosnippet() abort  " {{{
    call s:DefineCompletionMappings()

    let g:neosnippet#snippets_directory = [
      \   s:PluginInfo(".vim").path . "/snippets",
      \ ]
    let g:neosnippet#disable_runtime_snippets = #{
      \   _: 1,
      \ }

    augroup MyNeoSnippetClearMarkers  " {{{
      autocmd!
      autocmd InsertLeave * NeoSnippetClearMarkers
    augroup END  " }}}

    function! s:SetupNeosnippetContextual() abort  " {{{
      let dir = s:PluginInfo(".vim").path . "/snippets/"
      let g:neosnippet_contextual#contexts = get(g:, "neosnippet_contextual#contexts", {})

      if !has_key(g:neosnippet_contextual#contexts, "ruby")
        let g:neosnippet_contextual#contexts.ruby = []
      endif

      if OnRailsDir()
        let g:neosnippet_contextual#contexts.ruby += [
          \   #{ pattern: '^app/controllers', snippets: [dir . "ruby-rails.snip",    dir . "ruby-rails-controller.snip"] },
          \   #{ pattern: '^app/models',      snippets: [dir . "ruby-rails.snip",    dir . "ruby-rails-model.snip"] },
          \   #{ pattern: '^db/migrate',      snippets: [dir . "ruby-rails.snip",    dir . "ruby-rails-migration.snip"] },
          \   #{ pattern: '_test\.rb$',       snippets: [dir . "ruby-minitest.snip", dir . "ruby-rails.snip", dir . "ruby-rails-test.snip", dir . "ruby-rails-minitest.snip"] },
          \   #{ pattern: '_spec\.rb$',       snippets: [dir . "ruby-rspec.snip",    dir . "ruby-rails.snip", dir . "ruby-rails-test.snip", dir . "ruby-rails-rspec.snip"] },
          \ ]
      else
        let g:neosnippet_contextual#contexts.ruby += [
          \   #{ pattern: '_test\.rb$', snippets: [dir . "ruby-minitest.snip"] },
          \   #{ pattern: '_spec\.rb$', snippets: [dir . "ruby-rspec.snip"] },
          \ ]
      endif

      function! s:SourceContextualSnippets(filetype) abort  " {{{
        let contexts = get(g:neosnippet_contextual#contexts, a:filetype, [])
        let filepath = CurrentRelativePath()

        for context in contexts
          if filepath =~# context.pattern
            for snippet in context.snippets
              if filereadable(snippet)
                execute "NeoSnippetSource " . snippet
              endif
            endfor

            return
          endif
        endfor
      endfunction  " }}}

      augroup MyNeoSnippetSourceRailsSnippets  " {{{
        autocmd!
        autocmd FileType * call timer_start(300, { -> call("s:SourceContextualSnippets", [&filetype]) })
      augroup END  " }}}
    endfunction  " }}}
    call s:SetupNeosnippetContextual()
  endfunction  " }}}

  " `on_ft` for Syntaxes
  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_i:    1,
     \   on_ft:   ["snippet", "neosnippet"],
     \   depends: ".vim",
     \   hook_source: function("s:ConfigPluginOnSource_neosnippet"),
     \ })
endif  " }}}

if s:RegisterPlugin("kg8m/vim-lsp")  " {{{
  let g:lsp_diagnostics_enabled = 1
  let g:lsp_diagnostics_echo_cursor = 1
  let g:lsp_signs_enabled = 1

  let g:lsp_async_completion = 1

  let g:lsp_log_verbose = 1
  let g:lsp_log_file = expand("~/tmp/vim-lsp.log")

  augroup MyConfigVimLsp  " {{{
    autocmd!
    autocmd FileType                      * call s:ReswitchLSPGlobalConfigs()
    autocmd BufEnter,BufWinEnter,WinEnter * call s:SwitchLSPGlobalConfigs()
    autocmd User lsp_buffer_enabled         call s:SwitchLSPGlobalConfigs()
    autocmd User lsp_definition_failed      execute "tjump " . expand("<cword>")
  augroup END  " }}}

  function! s:ReswitchLSPGlobalConfigs() abort  " {{{
    if exists("b:lsp_highlight_references_enabled")
      unlet b:lsp_highlight_references_enabled
    endif

    call s:SwitchLSPGlobalConfigs()
  endfunction  " }}}

  function! s:SwitchLSPGlobalConfigs() abort  " {{{
    " References for sass is broken
    if !exists("b:lsp_highlight_references_enabled")
      let b:lsp_highlight_references_enabled = (&filetype != "sass")
    endif
    let g:lsp_highlight_references_enabled = b:lsp_highlight_references_enabled
  endfunction  " }}}

  " Register LSPs  {{{
  " yarn add bash-language-server  {{{
  call s:RegisterLSP(#{
     \   name: "bash-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "bash-language-server start"] },
     \   whitelist: ["sh", "zsh"],
     \ })
  " }}}

  " yarn add vscode-css-languageserver-bin  {{{
  call s:RegisterLSP(#{
     \   name: "css-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "css-languageserver --stdio"] },
     \   whitelist: ["css", "less", "sass", "scss"],
     \   workspace_config: #{
     \     css:  #{ linkt: #{ validProperties: [] } },
     \     less: #{ linkt: #{ validProperties: [] } },
     \     sass: #{ linkt: #{ validProperties: [] } },
     \     scss: #{ linkt: #{ validProperties: [] } },
     \   },
     \ })
  " }}}

  " go get -u golang.org/x/tools/gopls  {{{
  call s:RegisterLSP(#{
     \   name: "gopls",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "gopls -mode stdio"] },
     \   whitelist: ["go"],
     \   workspace_config: #{
     \     gopls: #{
     \       completeUnimported: 1,
     \     },
     \   },
     \ })
  " }}}

  " yarn add vscode-html-languageserver-bin  {{{
  call s:RegisterLSP(#{
     \   name: "html-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "html-languageserver --stdio"] },
     \   initialization_options: #{ embeddedLanguages: #{ css: 1, html: 1 } },
     \   whitelist: ["html"],
     \ })
  " }}}

  " yarn add vscode-json-languageserver-bin  {{{
  call s:RegisterLSP(#{
     \   name: "json-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "json-languageserver --stdio"] },
     \   whitelist: ["json"],
     \ })
  " }}}

  " gem install solargraph  {{{
  call s:RegisterLSP(#{
     \   name: "solargraph",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "solargraph stdio"] },
     \   whitelist: ["ruby"],
     \ })
  " }}}

  " yarn add sql-language-server  {{{
  call s:RegisterLSP(#{
     \   name: "sql-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "sql-language-server up --method stdio"] },
     \   whitelist: ["sql"],
     \ })
  " }}}

  " yarn add typescript-language-server typescript  {{{
  call s:RegisterLSP(#{
     \   name: "typescript-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "typescript-language-server --stdio"] },
     \   whitelist: ["typescript", "javascript", "typescript.tsx", "javascript.jsx"],
     \ })
  " }}}

  " yarn add vim-language-server  {{{
  call s:RegisterLSP(#{
     \   name: "vim-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "vim-language-server --stdio"] },
     \   initialization_options: #{ vimruntime: $VIMRUNTIME, runtimepath: &runtimepath },
     \   whitelist: ["vim"],
     \ })
  " }}}

  " yarn add vue-language-server  {{{
  " cf. https://github.com/sublimelsp/LSP-vue/blob/master/LSP-vue.sublime-settings
  call s:RegisterLSP(#{
     \   name: "vue-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "vls"] },
     \   initialization_options: #{
     \     config: #{
     \       vetur: #{
     \         completion: #{
     \           autoImport: 0,
     \           tagCasing: "kebab",
     \           useScaffoldSnippets: 0
     \         },
     \         format: #{
     \           defaultFormatter: #{
     \             js: "none",
     \             ts: "none"
     \           },
     \           defaultFormatterOptions: {},
     \           scriptInitialIndent: 0,
     \           styleInitialIndent: 0,
     \           options: {}
     \         },
     \         useWorkspaceDependencies: 0,
     \         validation: #{
     \           script: 1,
     \           style: 1,
     \           template: 1
     \         }
     \       },
     \       css: {},
     \       emmet: {},
     \       stylusSupremacy: {},
     \       html: #{
     \         suggest: {}
     \       },
     \       javascript: #{
     \         format: {}
     \       },
     \       typescript: #{
     \         format: {}
     \       }
     \     }
     \   },
     \   whitelist: ["vue"],
     \   executable_name: "vls",
     \ })
  " }}}
  " }}}

  function! s:ConfigPluginOnPostSource_lsp() abort  " {{{
    call lsp#enable()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_i:    1,
     \   on_cmd:  ["LspDefinition", "LspRename", "LspStatus"],
     \   on_ft:   get(s:, "lsp_filetypes", []),
     \   depends: "async.vim",
     \   hook_post_source: function("s:ConfigPluginOnPostSource_lsp"),
     \ })

  if s:RegisterPlugin("prabirshrestha/async.vim")  " {{{
    call s:ConfigPlugin(#{
       \   lazy: 1,
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("thomasfaingnaert/vim-lsp-snippets")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_source: "neosnippet",
     \ })

  if s:RegisterPlugin("thomasfaingnaert/vim-lsp-neosnippet")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:      1,
       \   on_source: "vim-lsp-snippets",
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("hrsh7th/vim-vsnip")  " {{{
  function! s:ConfigPluginOnSource_vim_vsnip() abort  " {{{
    call s:DefineCompletionMappings()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      1,
     \   on_func:   "vsnip#",
     \   on_source: "vim-lsp",
     \   hook_source: function("s:ConfigPluginOnSource_vim_vsnip"),
     \ })

  if s:RegisterPlugin("hrsh7th/vim-vsnip-integ")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:      1,
       \   on_source: "vim-vsnip",
       \ })
  endif  " }}}
endif  " }}}

function! s:DefineCompletionMappings() abort  " {{{
  inoremap <expr><Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  imap     <expr><Cr>    <SID>CrForInsertMode()

  function! s:CrForInsertMode() abort  " {{{
    if vsnip#available(1)
      return "\<Plug>(vsnip_expand_or_jump)"
    else
      if neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
      else
        return pumvisible() ? asyncomplete#close_popup() : "\<Cr>"
      endif
    endif
  endfunction  " }}}
endfunction  " }}}
" }}}

if s:RegisterPlugin("dense-analysis/ale", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:airline#extensions#ale#enabled = 0
  let g:ale_completion_enabled = 0
  let g:ale_disable_lsp = 1
  let g:ale_echo_msg_format = "[%linter%][%severity%] %code: %%s"
  let g:ale_fix_on_save = 0
  let g:ale_lint_on_enter = 1
  let g:ale_lint_on_filetype_changed = 1
  let g:ale_lint_on_insert_leave = 0
  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_open_list = 0

  " go get github.com/golangci/golangci-lint/cmd/golangci-lint
  " go get golang.org/x/tools/cmd/goimports
  let g:ale_linters = #{
    \   go:         ["golangci-lint", "govet"],
    \   javascript: ["eslint"],
    \   ruby:       ["ruby", "rubocop"],
    \   typescript: ["eslint"],
    \ }
  let g:ale_fixers = #{
    \   go:         ["goimports"],
    \   javascript: ["prettier", "eslint"],
    \   ruby:       ["rubocop"],
    \   typescript: ["prettier", "eslint"],
    \ }

  augroup MyConfigAleFixOnSave  " {{{
    autocmd!
    autocmd FileType go let b:ale_fix_on_save = 1
    autocmd FileType javascript,typescript let b:ale_fix_on_save = !!$FIX_ON_SAVE_JS
    autocmd FileType ruby let b:ale_fix_on_save = !!$FIX_ON_SAVE_RUBY
  augroup END  " }}}

  let g:ale_go_golangci_lint_package = 1

  " yarn add eslint_d
  if executable("eslint_d")
    let g:ale_javascript_eslint_use_global = 1
    let g:ale_javascript_eslint_executable = "eslint_d"
  endif

  " gem install rubocop-daemon
  " And add rubocop-daemon-wrapper to $PATH
  if executable("rubocop-daemon") && executable("rubocop-daemon-wrapper")
    let g:ale_ruby_rubocop_executable = "rubocop-daemon-wrapper"
  endif
endif  " }}}

call s:RegisterPlugin("pearofducks/ansible-vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("hotwatermorning/auto-git-diff", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("vim-scripts/autodate.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%(' .
                              \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                              \   '\%(最終更新日\?\)\|' .
                              \   '\%(更新日\)' .
                              \ '\):'
  let g:autodate_keyword_post = '\.$'
endif  " }}}

if s:RegisterPlugin("tyru/caw.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  nmap gc <Plug>(caw:hatpos:toggle)
  vmap gc <Plug>(caw:hatpos:toggle)

  let g:caw_no_default_keymappings = 1
  let g:caw_hatpos_skip_blank_line = 1

  augroup MySetCawSpecialCommentMarkers  " {{{
    autocmd!
    autocmd FileType gemfile let b:caw_oneline_comment = "#"
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: [["nv", "<Plug>(caw:"]],
     \ })
endif  " }}}

call s:RegisterPlugin("Shougo/context_filetype.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("spolu/dwm.vim")  " {{{
  nnoremap <C-w>n       :<C-u>call DWM_New()<Cr>
  nnoremap <C-w>c       :<C-u>call DWM_Close()<Cr>
  nnoremap <C-w><Space> :<C-u>call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = 0

  function! s:ConfigPluginOnPostSource_dwm() abort  " {{{
    " Disable DWM's default behavior on buffer loaded
    augroup dwm
      autocmd!
    augroup END
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_func: ["DWM_New", "DWM_Close", "DWM_AutoEnter", "DWM_Stack"],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_dwm"),
     \ })
endif  " }}}

if s:RegisterPlugin("LeafCage/foldCC", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:foldCCtext_enable_autofdc_adjuster = 1
  let g:foldCCtext_maxchars = 120
  set foldtext=FoldCCtext()
endif  " }}}

if s:RegisterPlugin("junegunn/fzf.vim", #{ if: executable("fzf") })  " {{{
  let g:fzf_command_prefix = "Fzf"
  let g:fzf_buffers_jump = 1
  let g:fzf_action = #{ ctrl-o: "vsplit" }
  let g:fzf_layout = #{ up: "~50%" }

  nnoremap <Leader><Leader>f     :FzfFiles<Cr>
  nnoremap <Leader><Leader>v     :FzfGFiles?<Cr>
  nnoremap <Leader><Leader>b     :FzfBuffers<Cr>
  nnoremap <Leader><Leader>g     :FzfRg<Space>
  vnoremap <Leader><Leader>g     "gy:FzfRg<Space><C-r>"
  nnoremap <Leader><Leader>l     :FzfLines<Cr>
  nnoremap <Leader><Leader>m     :FzfMarks<Cr>
  nnoremap <Leader><Leader>w     :FzfWindows<Cr>
  nnoremap <Leader><Leader>h     :FzfHistory<Cr>
  nnoremap <Leader><Leader><S-h> :FzfHelptags<Cr>
  nnoremap <Leader><Leader>y     :FzfYankHistory<Cr>

  command! FzfYankHistory call s:FzfYankHistory()

  " https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
  " See yankround.vim
  function! s:FzfYankHistory() abort  " {{{
    let options = #{
      \   source:  s:YankList(),
      \   sink:    function("s:YankHandler"),
      \   options: ["--no-multi", "--nth=2", "--tabstop=1"],
      \ }

    call fzf#run(fzf#wrap("yank-history", options))
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   depends: "fzf",
     \   on_cmd: [
     \     "FzfFiles",
     \     "FzfGFiles?",
     \     "FzfBuffers",
     \     "FzfRg",
     \     "FzfLines",
     \     "FzfMarks",
     \     "FzfWindows",
     \     "FzfHistory",
     \     "FzfHelptags",
     \   ],
     \ })

  if s:RegisterPlugin("junegunn/fzf")  " {{{
    call s:ConfigPlugin(#{
      \   lazy: 1,
      \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("kg8m/gundo.vim")  " {{{
  nnoremap <F5> :<C-u>GundoToggle<Cr>

  " http://d.hatena.ne.jp/heavenshell/20120218/1329532535
  let g:gundo_auto_preview = 0
  let g:gundo_prefer_python3 = 1

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: "GundoToggle",
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
    " Overwrite default mappings
    call s:DefineHowMuchMappings()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: [["v", "<Plug>AutoCalc"]],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_HowMuch"),
     \ })
endif  " }}}

if s:RegisterPlugin("nishigori/increment-activator")  " {{{
  let g:increment_activator_filetype_candidates = #{
    \   _: [
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
    \ }
endif  " }}}

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
    \ ]
endif  " }}}

if s:RegisterPlugin("othree/javascript-libraries-syntax.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:used_javascript_libs = join([
    \   "angularjs",
    \   "backbone",
    \   "chai",
    \   "jasmine",
    \   "jquery",
    \   "react",
    \   "underscore",
    \   "vue",
    \ ], ",")
endif  " }}}

if s:RegisterPlugin("itchyny/lightline.vim")  " {{{
  " http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2
  let s:lightline_elements = #{
    \   left: [
    \     ["mode", "paste"],
    \     ["bufnum", "filename"],
    \     ["filetype", "fileencoding", "fileformat"],
    \     ["lineinfo_with_percent"],
    \   ],
    \   right: [
    \   ],
    \ }
  let g:lightline = #{
    \   active: s:lightline_elements,
    \   inactive: s:lightline_elements,
    \   component: #{
    \     bufnum: "#%n",
    \     lineinfo_with_percent: "%l/%L(%p%%) : %v",
    \   },
    \   component_function: #{
    \     filename: "Lightline_Filepath",
    \   },
    \   colorscheme: "kg8m",
    \ }

  function! Lightline_Filepath() abort  " {{{
    let readonly_symbol = s:Lightline_ReadonlySymbol()
    let modified_symbol = s:Lightline_ModifiedSymbol()

    return (readonly_symbol != "" ? readonly_symbol . " " : "") .
         \ (
         \   &filetype == "vimfiler" ? vimfiler#get_status_string() :
         \   &filetype == "unite" ? unite#get_status_string() :
         \   CurrentFilename() != "" ? (
         \     winwidth(0) >= 100 ? CurrentRelativePath() : CurrentFilename()
         \   ) : "[No Name]"
         \ ) .
         \ (modified_symbol != "" ? " " . modified_symbol : "")
  endfunction  " }}}

  function! s:Lightline_ReadonlySymbol() abort  " {{{
    return &filetype !~? 'help\|vimfiler\|gundo' && &readonly ? "X" : ""
  endfunction  " }}}

  function! s:Lightline_ModifiedSymbol() abort  " {{{
    return &filetype =~? 'help\|vimfiler\|gundo' ? "" : &modified ? "+" : &modifiable ? "" : "-"
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("AndrewRadev/linediff.vim")  " {{{
  let g:linediff_second_buffer_command = "rightbelow vertical new"

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: "Linediff",
     \ })
endif  " }}}

call s:RegisterPlugin("kg8m/moin.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("tyru/open-browser.vim")  " {{{
  nmap <Leader>o <Plug>(openbrowser-open)
  vmap <Leader>o <Plug>(openbrowser-open)

  let g:openbrowser_browser_commands = [
    \   #{
    \     name: "ssh",
    \     args: "ssh main 'open '\\''{uri}'\\'''",
    \   }
    \ ]

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_cmd:  ["OpenBrowserSearch", "OpenBrowser"],
     \   on_func: "openbrowser#open",
     \   on_map:  [["nv", "<Plug>(openbrowser-open)"]],
     \ })
endif  " }}}

if s:RegisterPlugin("tyru/operator-camelize.vim")  " {{{
  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: [
     \     ["v", "<Plug>(operator-camelize)"],
     \     ["v", "<Plug>(operator-decamelize)"]
     \   ],
     \ })
endif  " }}}

call s:RegisterPlugin("mechatroner/rainbow_csv", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("chrisbra/Recover.vim")

if s:RegisterPlugin("vim-scripts/sequence")  " {{{
  vmap <Leader>+ <Plug>SequenceV_Increment
  vmap <Leader>- <Plug>SequenceV_Decrement
  nmap <Leader>+ <Plug>SequenceN_Increment
  nmap <Leader>- <Plug>SequenceN_Decrement

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: [["vn", "<Plug>Sequence"]],
     \ })
endif  " }}}

if s:RegisterPlugin("AndrewRadev/splitjoin.vim")  " {{{
  nnoremap <Leader>J :<C-u>SplitjoinJoin<Cr>
  nnoremap <Leader>S :<C-u>SplitjoinSplit<Cr>

  let g:splitjoin_split_mapping       = ""
  let g:splitjoin_join_mapping        = ""
  let g:splitjoin_ruby_trailing_comma = 1
  let g:splitjoin_ruby_hanging_args   = 0

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
     \ })
endif  " }}}

call s:RegisterPlugin("vim-scripts/sudo.vim")

if s:RegisterPlugin("leafgarland/typescript-vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:typescript_indent_disable = 1
endif  " }}}

if s:RegisterPlugin("Shougo/unite.vim")  " {{{
  nnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  vnoremap <Leader>us :<C-u>Unite menu:shortcuts<Cr>
  nnoremap <Leader>ug :<C-u>Unite -no-quit -winheight=30% -buffer-name=grep grep:./::
  vnoremap <Leader>ug "gy:<C-u>Unite -no-quit -winheight=30% -buffer-name=grep grep:./::<C-r>"
  nnoremap <Leader>uy :<C-u>Unite yankround -default-action=append<Cr>
  nnoremap <Leader>ub :<C-u>Unite buffer<Cr>

  " See also ctags settings
  nnoremap g[ :<C-u>Unite jump<Cr>

  augroup MyConfigUnite  " {{{
    autocmd!
    autocmd FileType unite call s:ConfigForUniteBuffer()
  augroup END  " }}}

  function! s:ConfigForUniteBuffer() abort  " {{{
    call s:EnableHighlightingCursorline()
    call s:DisableUniteDefaultMappings()
  endfunction  " }}}

  function! s:EnableHighlightingCursorline() abort  " {{{
    setlocal cursorlineopt=both
  endfunction  " }}}

  function! s:DisableUniteDefaultMappings() abort  " {{{
    if mapcheck("<S-n>", "n")
      nunmap <buffer> <S-n>
    endif
  endfunction  " }}}

  if OnRailsDir()  " {{{
    nnoremap <Leader>ur :<C-u>Unite -start-insert rails/

    function! s:DefineOreOreUniteCommandsForRails() abort  " {{{
      let s:unite_rails_definitions = #{
        \   assets: #{
        \     path:    ["app/assets/**,app/javascripts/**,public/**", "*"],
        \     to_word: ["^\./", ""],
        \     ignore:  '\v<public/packs(-test)?/',
        \   },
        \   config: #{
        \     path:    ["config/**", "*"],
        \     to_word: ["^\./config/", ""],
        \   },
        \   gems: #{
        \     path:    [join(RubyGemPaths(), ","), "gems/**/*"],
        \     to_word: ['\(' . join(RubyGemPaths(), '\|') . '\)/gems/', ""],
        \   },
        \   initializers: #{
        \     path:    ["config/initializers/**", "*"],
        \     to_word: ["^\./config/initializers/", ""],
        \   },
        \   javascripts: #{
        \     path:    ["app/**,public/**", "*.{js,ts,vue}"],
        \     to_word: ["^\./", ""],
        \     ignore:  '\v<public/packs(-test)?/',
        \   },
        \   lib: #{
        \     path:    ["lib/**", "*"],
        \     to_word: ["^\./lib/", ""],
        \   },
        \   public: #{
        \     path:    ["public/**", "*"],
        \     to_word: ["^\./public/", ""],
        \     ignore:  '\v<public/packs(-test)?/',
        \   },
        \   script: #{
        \     path:    ["script/**", "*"],
        \     to_word: ["^\./script/", ""],
        \   },
        \   spec: #{
        \     path:    ["spec/**,test/**", "*"],
        \     to_word: ['^\./', ""],
        \   },
        \   stylesheets: #{
        \     path:    ["app/**,public/**", "*.{css,sass,scss}"],
        \     to_word: ["^\./", ""],
        \     ignore:  '\v<public/packs(-test)?/',
        \   },
        \   test: #{
        \     path:    ["spec/**,test/**", "*"],
        \     to_word: ['^\./', ""],
        \   },
        \ }
      let s:unite_rails_definitions["db/migrates"] = #{
        \   path:    ["db/migrate", "*"],
        \   to_word: ["^db/migrate/", ""],
        \ }

      for app_dir in globpath("app", "*", 0, 1)
        if isdirectory(app_dir)
          let name = fnamemodify(app_dir, ":t")

          if !has_key(s:unite_rails_definitions, name)
            let s:unite_rails_definitions[name] = #{
              \   path:    [app_dir . "/**", "*"],
              \   to_word: ['^\./' . app_dir, ""],
              \ }
          endif
        endif
      endfor

      for test_dir in globpath("spec,test", "*", 0, 1)
        if isdirectory(test_dir)
          let s:unite_rails_definitions[test_dir] = #{
            \   path:    [test_dir . "/**", "*"],
            \   to_word: ['^\./' . test_dir, ""],
            \ }
        endif
      endfor

      if exists("g:unite_rails_extra_definitions")
        for name in keys(g:unite_rails_extra_definitions)
          let s:unite_rails_definitions[name] = g:unite_rails_extra_definitions[name]
        endfor
      endif

      for name in keys(s:unite_rails_definitions)
        let source = #{ name: "rails/" . name }
        function! source.gather_candidates(args, context) abort  " {{{
          let name = substitute(a:context.source_name, "^rails/", "", "")
          let definition = s:unite_rails_definitions[name]
          let files = globpath(definition.path[0], definition.path[1], 0, 1)
          let files = filter(files, { index, value -> filereadable(value) })

          if has_key(definition, "ignore")
            let files = filter(files, { index, value -> value !~# definition.ignore })
          endif

          return map(sort(files), '#{
               \   word: substitute(v:val, definition.to_word[0], definition.to_word[1], ""),
               \   kind: "file",
               \   action__path: v:val,
               \ }')
        endfunction  " }}}
        call unite#define_source(source)
      endfor

      let s:sorted_unite_rails_keys = sort(keys(s:unite_rails_definitions))

      if !exists("g:unite_source_menu_menus")
        let g:unite_source_menu_menus = {}
      endif

      let g:unite_source_menu_menus.rails = #{
        \   description: "Open files for Rails"
        \ }
      let g:unite_source_menu_menus.rails.command_candidates = map(
        \   copy(s:sorted_unite_rails_keys),
        \   { key, val -> ["Unite rails/" . val, "Unite -start-insert rails/" . val] }
        \ )

      let source = #{ name: "rails" }
      function! source.gather_candidates(args, context) abort  " {{{
        return map(copy(s:sorted_unite_rails_keys), '#{
             \   word: "Unite rails/" . v:val,
             \   kind: "command",
             \   action__command: "Unite -start-insert rails/" . v:val,
             \ }')
      endfunction  " }}}
      call unite#define_source(source)

      if !exists("g:unite_source_alias_aliases")
        let g:unite_source_alias_aliases = {}
      endif
      let g:unite_source_alias_aliases["rails/"] = #{ source: "rails" }
    endfunction  " }}}

    augroup MySetupOreOreUniteCommandsForRails  " {{{
      autocmd!
      autocmd VimEnter * call timer_start(300, { -> call("s:DefineOreOreUniteCommandsForRails", []) })
    augroup END  " }}}
  endif  " }}}

  function! s:ConfigPluginOnSource_unite() abort  " {{{
    let g:unite_winheight = "100%"

    if executable("rg")
      let g:unite_source_grep_command       = "rg"
      let g:unite_source_grep_recursive_opt = ""
      let g:unite_source_grep_default_opts  = "--color never --no-heading --line-number"
    elseif executable("ag")
      let g:unite_source_grep_command       = "ag"
      let g:unite_source_grep_recursive_opt = ""
      let g:unite_source_grep_default_opts  = "--nocolor --nogroup --nopager --hidden --workers=1"
    elseif executable("ack")
      let g:unite_source_grep_command       = "ack"
      let g:unite_source_grep_recursive_opt = ""
      let g:unite_source_grep_default_opts  = "--nocolor --nogroup --nopager"
    endif

    let g:unite_source_grep_search_word_highlight = "Special"

    call unite#custom#source("buffer", "sorters", "sorter_word")
    call unite#custom#source("grep", "max_candidates", 10000)

    function! s:SetupUniteShortcut() abort  " {{{
      " http://d.hatena.ne.jp/osyo-manga/20130225/1361794133
      " http://d.hatena.ne.jp/tyru/20120110/prompt
      if !exists("g:unite_source_menu_menus")
        let g:unite_source_menu_menus = {}
      endif
      let g:unite_source_menu_menus.shortcuts = #{
        \   description: "My Shortcuts"
        \ }

      " http://nanasi.jp/articles/vim/hz_ja_vim.html
      let g:unite_source_menu_menus.shortcuts.candidates = [
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
        \   ["[Manipulate File] Convert to HTML",                         "colorscheme h2u_white | TOhtml"],
        \   ["[Manipulate File] Replace/Sed Texts of All Buffers [Edit]", "bufdo set eventignore-=Syntax | %s/{foo}/{bar}/gce | update"],
        \   ["[Manipulate File] Transform to New Ruby Hash Syntax",       "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
        \   ["[Manipulate File] Transform to Old Ruby Hash Syntax",       "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],
        \
        \   ["[Copy] filename",          "call RemoteCopy(CurrentFilename())"],
        \   ["[Copy] relative filepath", "call RemoteCopy(CurrentRelativePath())"],
        \   ["[Copy] absolute filepath", "call RemoteCopy(CurrentAbsolutePath())"],
        \
        \   ["[Autoformat] Format Source Codes",         "Autoformat"],
        \
        \   ["[Diff] Linediff",       "'<,'>Linediff"],
        \   ["[Diff] DirDiff [Edit]", "DirDiff {dir1} {dir2}"],
        \
        \   ["[CSV] Align CSV columns with whitespaces",                      "RainbowAlign"],
        \   ["[CSV] Remove leading and trailing whitespaces from all fields", "RainbowShrink"],
        \
        \   ["[Unite plugin] giti/status",          "Unite giti/status"],
        \   ["[Unite] resume [Edit]",                 "UniteResume {buffer-name}"],
        \
        \   ["[Help] autocommand-events", "help autocommand-events"],
        \ ]

      " Show formatted candidates, for example:
      "   [Plugins] Resume Update Plugins            --  `UniteResume update_plugins`
      "
      "   [String Utility] All to Hankaku            --  `'<,'>Hankaku`
      "   [String Utility] Alphanumerics to Hankaku  --  `'<,'>HzjaConvert han_eisu`
      "   ...
      function! s:FormatUniteShortcuts() abort  " {{{
        function! s:UniteShortcutsPrefix(word) abort  " {{{
          return substitute(a:word, '\v^\[([^]]+)\].*$', '\1', "")
        endfunction  " }}}

        function! s:UniteShortcutsWordPadding(word) abort  " {{{
          return repeat(" ", s:max_unite_shortcuts_word_length - strlen(a:word))
        endfunction  " }}}

        function! s:GroupUniteShortcuts() abort  " {{{
          let first_candidate      = g:unite_source_menu_menus.shortcuts.candidates[0]
          let temporary_prefix     = s:UniteShortcutsPrefix(first_candidate[0])
          let temporary_candidates = []

          for candidate in g:unite_source_menu_menus.shortcuts.candidates
            let prefix = s:UniteShortcutsPrefix(candidate[0])

            if prefix != temporary_prefix
              call add(temporary_candidates, ["", ""])
              let temporary_prefix = prefix
            endif

            call add(temporary_candidates, candidate)
          endfor

          let g:unite_source_menu_menus.shortcuts.candidates = temporary_candidates
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
            return #{ word: "", kind: "" }
          else
            return #{
                 \   word: word . s:UniteShortcutsWordPadding(word) . "  --  `" . value . "`",
                 \   kind: "command",
                 \   action__command: value,
                 \ }
          endif
        endfunction  " }}}
      endfunction  " }}}
      call s:FormatUniteShortcuts()
    endfunction  " }}}
    call s:SetupUniteShortcut()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_cmd:  "Unite",
     \   on_func: "unite#",
     \   hook_source: function("s:ConfigPluginOnSource_unite"),
     \ })

  if s:RegisterPlugin("Shougo/neomru.vim")  " {{{
    call s:ConfigPlugin(#{
       \   lazy: 0,
       \ })

    nnoremap <Leader>uh :<C-u>Unite neomru/file<Cr>

    let g:neomru#time_format     = "%Y/%m/%d %H:%M:%S"
    let g:neomru#filename_format = ":~:."
    let g:neomru#file_mru_limit  = 1000
  endif  " }}}

  if s:RegisterPlugin("kg8m/unite-dwm")  " {{{
    augroup MyDWMMappings  " {{{
      autocmd!
      autocmd FileType unite call s:DefineMyUniteDWMMappings()
    augroup END  " }}}

    function! s:DefineMyUniteDWMMappings() abort  " {{{
      nnoremap <buffer><expr> <C-o> unite#do_action("dwm_open")
      inoremap <buffer><expr> <C-o> unite#do_action("dwm_open")
    endfunction  " }}}

    call s:ConfigPlugin(#{
       \   lazy:  1,
       \   on_ft: ["unite", "vimfiler"],
       \ })
  endif  " }}}

  if s:RegisterPlugin("kg8m/unite-mark")  " {{{
    nnoremap <Leader>um :<C-u>Unite mark<Cr>
    nnoremap <silent> m :<C-u>call AutoMark()<Cr>

    function! s:ConfigPluginOnSource_unite_mark() abort  " {{{
      " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
      let s:mark_increment_keys = [
        \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        \ ]
      let g:unite_source_mark_marks = join(s:mark_increment_keys, "")
      let s:mark_increment_key_regexp = "^[" . g:unite_source_mark_marks . "]$"

      function! AutoMark() abort  " {{{
        let mark_increment_key = s:DetectMarkIncrementKey()

        if mark_increment_key =~# s:mark_increment_key_regexp
          echo "Already marked to " . mark_increment_key
          return
        endif

        if !exists("s:mark_increment_index")
          let s:mark_increment_index = 0
        else
          let s:mark_increment_index = (s:mark_increment_index + 1) % len(s:mark_increment_keys)
        endif

        execute "mark " . s:mark_increment_keys[s:mark_increment_index]
        echo "Marked to " . s:mark_increment_keys[s:mark_increment_index]
      endfunction  " }}}

      function! s:DetectMarkIncrementKey() abort  " {{{
        let detected_mark_key   = 0
        let current_filepath    = expand("%")
        let current_line_number = line(".")

        for mark_key in s:mark_increment_keys
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

      execute "delmarks " . join(s:mark_increment_keys, "")
    endfunction  " }}}

    call s:ConfigPlugin(#{
       \   lazy:      1,
       \   on_func:   "AutoMark",
       \   on_source: "unite.vim",
       \   hook_source: function("s:ConfigPluginOnSource_unite_mark"),
       \ })
  endif  " }}}

  if s:RegisterPlugin("kg8m/vim-unite-giti", #{ if: OnGitDir() })  " {{{
    nnoremap <Leader>uv :<C-u>Unite giti/status<Cr>

    let g:giti_log_default_line_count = 1000

    function! s:ConfigPluginOnPostSource_vim_unite_giti() abort  " {{{
      function! s:AddActionsToUniteGiti() abort  " {{{
        let kind = unite#kinds#giti#status#define()
        let kind.action_table.delete = #{
          \   description:         "delete/remove directories/files",
          \   is_selectable:       1,
          \   is_invalidate_cache: 1,
          \ }
        let kind.action_table.intent_to_add = #{
          \   description:         "add --intent-to-add",
          \   is_selectable:       1,
          \   is_invalidate_cache: 1,
          \ }

        function! kind.action_table.delete.func(candidates) abort  " {{{
          let files   = map(copy(a:candidates), "v:val.action__path")
          let command = printf("yes | rm -r %s", join(files))

          call ExecuteWithConfirm(command)
        endfunction  " }}}

        function! kind.action_table.intent_to_add.func(candidates) abort  " {{{
          let files   = map(copy(a:candidates), "v:val.action__path")
          let command = printf("add --intent-to-add %s", join(files))

          return giti#system(command)
        endfunction  " }}}
      endfunction  " }}}
      call s:AddActionsToUniteGiti()
    endfunction  " }}}

    call s:ConfigPlugin(#{
       \   lazy:      1,
       \   on_source: "unite.vim",
       \   hook_post_source: function("s:ConfigPluginOnPostSource_vim_unite_giti"),
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("h1mesuke/vim-alignta")  " {{{
  call s:ConfigPlugin(#{
     \   lazy: 0,
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

if s:RegisterPlugin("FooSoft/vim-argwrap")  " {{{
  nnoremap <Leader>a :ArgWrap<Cr>

  let g:argwrap_padded_braces = "{"

  augroup MyConfigArgwrap  " {{{
    autocmd!
    autocmd FileType eruby let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType ruby  let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType vim   let b:argwrap_tail_comma_braces = "[{" | let b:argwrap_line_prefix = '\'
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: "ArgWrap",
     \ })
endif  " }}}

if s:RegisterPlugin("haya14busa/vim-asterisk")  " {{{
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
endif  " }}}

if s:RegisterPlugin("Chiel92/vim-autoformat", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif  " }}}

if s:RegisterPlugin("itchyny/vim-autoft", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:autoft_enable = 0
  let g:autoft_config = [
    \   #{ filetype: "html",       pattern: '<\%(!DOCTYPE\|html\|head\|script\)' },
    \   #{ filetype: "javascript", pattern: '\%(^\s*\<var\>\s\+[a-zA-Z]\+\)\|\%(function\%(\s\+[a-zA-Z]\+\)\?\s*(\)' },
    \   #{ filetype: "c",          pattern: '^\s*#\s*\%(include\|define\)\>' },
    \   #{ filetype: "sh",         pattern: '^#!.*\%(\<sh\>\|\<bash\>\)\s*$' },
    \ ]
endif  " }}}

if s:RegisterPlugin("kg8m/vim-blockle")  " {{{
  let g:blockle_mapping = ",b"
endif  " }}}

if s:RegisterPlugin("jkramer/vim-checkbox", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup MyConfigCheckbox
    autocmd!
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<Cr>
  augroup END

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: "ToggleCB",
     \ })
endif  " }}}

if s:RegisterPlugin("t9md/vim-choosewin")  " {{{
  nmap <C-w>f <Plug>(choosewin)

  let g:choosewin_overlay_enable          = 0
  let g:choosewin_overlay_clear_multibyte = 0
  let g:choosewin_blink_on_land           = 0
  let g:choosewin_statusline_replace      = 1
  let g:choosewin_tabline_replace         = 0

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: "<Plug>(choosewin)",
     \ })
endif  " }}}

call s:RegisterPlugin("hail2u/vim-css-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("hail2u/vim-css3-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("kg8m/vim-dirdiff", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:DirDiffExcludes   = "CVS,*.class,*.exe,.*.swp,*.git,db/development_structure.sql,log,tags,tmp"
  let g:DirDiffIgnore     = "Id:,Revision:,Date:"
  let g:DirDiffSort       = 1
  let g:DirDiffIgnoreCase = 0
  let g:DirDiffForceLang  = "C"

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: "DirDiff",
     \ })
endif  " }}}

if s:RegisterPlugin("easymotion/vim-easymotion")  " {{{
  nmap <Leader>f <Plug>(easymotion-overwin-f2)
  xmap <Leader>f <Plug>(easymotion-bd-f2)
  omap <Leader>f <Plug>(easymotion-bd-f2)

  " Replace default `f`
  nmap f <Plug>(easymotion-fl)
  xmap f <Plug>(easymotion-fl)
  omap f <Plug>(easymotion-fl)
  nmap F <Plug>(easymotion-Fl)
  xmap F <Plug>(easymotion-Fl)
  omap F <Plug>(easymotion-Fl)

  " http://haya14busa.com/vim-lazymotion-on-speed/
  let g:EasyMotion_do_mapping  = 0
  let g:EasyMotion_do_shade    = 0
  let g:EasyMotion_startofline = 0
  let g:EasyMotion_smartcase   = 1
  let g:EasyMotion_use_upper   = 1
  let g:EasyMotion_keys        = "FJKLASDHGUIONMEREWCX,.;/ZQP"
  let g:EasyMotion_use_migemo  = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_skipfoldedline   = 0
endif  " }}}

call s:RegisterPlugin("thinca/vim-ft-diff_fold", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("thinca/vim-ft-help_fold")
call s:RegisterPlugin("muz/vim-gemfile", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("kana/vim-gf-user")

if s:RegisterPlugin("tpope/vim-git")  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup MyDisableVimGitDefaultConfigs  " {{{
    autocmd!
    autocmd FileType gitcommit let b:did_ftplugin = 1
  augroup END  " }}}
endif  " }}}

" Use LSP for completion and going to definition
" Use ale for linting/formatting codes
" Use vim-go's highlightings, foldings, and commands/functions
if s:RegisterPlugin("fatih/vim-go")  " {{{
  let g:go_code_completion_enabled = 0
  let g:go_fmt_autosave = 0
  let g:go_doc_keywordprg_enabled = 0
  let g:go_def_mapping_enabled = 0
  let g:go_gopls_enabled = 0

  let g:go_highlight_array_whitespace_error = 1
  let g:go_highlight_chan_whitespace_error = 1
  let g:go_highlight_extra_types = 1
  let g:go_highlight_space_tab_error = 1
  let g:go_highlight_trailing_whitespace_error = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_function_parameters = 1
  let g:go_highlight_function_calls = 1
  let g:go_highlight_types = 1
  let g:go_highlight_fields = 1
  let g:go_highlight_build_constraints = 1
  let g:go_highlight_generate_tags = 1
  let g:go_highlight_string_spellcheck = 1
  let g:go_highlight_format_strings = 1
  let g:go_highlight_variable_declarations = 1
  let g:go_highlight_variable_assignments = 1

  augroup MyVimGo  " {{{
    autocmd!
    autocmd FileType go call s:SetupVimGo()
  augroup END  " }}}

  function! s:SetupVimGo() abort  " {{{
    setlocal foldmethod=syntax
    call s:SetupGoMappings()
  endfunction  " }}}

  if OnTmux()  " {{{
    function! s:SetupGoMappings() abort  " {{{
      nnoremap <buffer> <leader>r :write<Cr>:call VimuxRunCommand("go run -race <C-r>%")<Cr>
    endfunction  " }}}
  else
    function! s:SetupGoMappings() abort  " {{{
      nnoremap <buffer> <leader>r :write<Cr>:GoRun -race %<Cr>
    endfunction  " }}}
  endif  " }}}

  call s:ConfigPlugin(#{
     \   lazy:  1,
     \   on_ft: "go",
     \ })
endif  " }}}

call s:RegisterPlugin("tpope/vim-haml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

" text object for indentation: i
call s:RegisterPlugin("michaeljsmith/vim-indent-object")

if s:RegisterPlugin("elzr/vim-json", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vim_json_syntax_conceal = 0
endif  " }}}

if s:RegisterPlugin("rcmdnk/vim-markdown", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vim_markdown_override_foldtext = 0
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_no_extensions_in_markdown = 1
  let g:vim_markdown_autowrite = 1
  let g:vim_markdown_folding_level = 10

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   depends: "vim-markdown-quote-syntax",
     \   on_ft:   "markdown",
     \ })
endif  " }}}

if s:RegisterPlugin("joker1007/vim-markdown-quote-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:markdown_quote_syntax_filetypes = #{
    \    css:  #{ start: '\%(css\|scss\|sass\)' },
    \    haml: #{ start: "haml" },
    \    xml:  #{ start: "xml" },
    \ }

  call s:ConfigPlugin(#{
     \   lazy:  1,
     \   on_ft: "markdown",
     \ })
endif  " }}}

if s:RegisterPlugin("andymass/vim-matchup")  " {{{
  let g:matchup_matchparen_status_offscreen = 0
endif  " }}}

if s:RegisterPlugin("kana/vim-operator-replace")  " {{{
  nmap r <Plug>(operator-replace)
  vmap r <Plug>(operator-replace)

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-replace)"]],
     \ })
endif  " }}}

if s:RegisterPlugin("rhysd/vim-operator-surround")  " {{{
  nmap <silent><Leader>sa <Plug>(operator-surround-append)aw
  nmap <silent><Leader>sd <Plug>(operator-surround-delete)a
  nmap <silent><Leader>sr <Plug>(operator-surround-replace)a
  vmap <silent><Leader>sa <Plug>(operator-surround-append)
  vmap <silent><Leader>sd <Plug>(operator-surround-delete)a
  vmap <silent><Leader>sr <Plug>(operator-surround-replace)a

  function! s:ConfigPluginOnSource_vim_operator_surround() abort  " {{{
    let g:operator#surround#blocks = #{ -: [] }

    " Some pairs don't work as `keys` if they require IME's `henkan`
    " But they works as `block`
    let configs = [
      \   #{ block: ["[ ", " ]"], keys: [" [", " ]"] },
      \   #{ block: ["( ", " )"], keys: ["("] },
      \   #{ block: ["{ ", " }"], keys: ["{"] },
      \   #{ block: ["[ ", " ]"], keys: ["["] },
      \   #{ block: ["（", "）"] },
      \   #{ block: ["［", "］"] },
      \   #{ block: ["「", "」"] },
      \   #{ block: ["『", "』"] },
      \   #{ block: ["〈", "〉"] },
      \   #{ block: ["《", "》"] },
      \   #{ block: ["【", "】"] },
      \   #{ block: ["“", "”"] },
      \   #{ block: ["‘", "’"] },
      \ ]

    for config in configs
      let keys = has_key(config, "keys") ? config.keys : config.block
      call add(g:operator#surround#blocks["-"], #{
        \   block: config.block, motionwise: ["char", "line", "block"], keys: keys
        \ })
    endfor
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-surround-"]],
     \   hook_source: function("s:ConfigPluginOnSource_vim_operator_surround"),
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-operator-user")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_func: "operator#user#define",
     \ })
endif  " }}}

if s:RegisterPlugin("thinca/vim-prettyprint")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_cmd:  ["PrettyPrint", "PP"],
     \   on_func: ["PrettyPrint", "PP"],
     \ })
endif  " }}}

if s:RegisterPlugin("thinca/vim-qfreplace")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:  1,
     \   on_ft: ["unite", "quickfix"]
     \ })
endif  " }}}

if s:RegisterPlugin("tpope/vim-rails", #{ if: OnRailsDir() && !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  call s:ConfigPlugin(#{
     \   lazy: 0,
     \ })

  " http://fg-180.katamayu.net/archives/2006/09/02/125150
  let g:rails_level = 4

  if !exists("g:rails_projections")
    let g:rails_projections = {}
  endif

  let g:rails_projections["script/*.rb"] = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["script/*"]    = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["test/script/*_test.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }
  let g:rails_projections["spec/script/*_spec.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }

  if !exists("g:rails_path_additions")
    let g:rails_path_additions = []
  endif

  let g:rails_path_additions += [
    \   "spec/support",
    \ ]

  augroup MySetupRails
    autocmd!
    autocmd BufEnter,BufWinEnter,WinEnter * if RailsDetect() | call rails#buffer_setup() | endif
  augroup END
endif  " }}}

call s:RegisterPlugin("tpope/vim-repeat")

if s:RegisterPlugin("vim-ruby/vim-ruby", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  " See vim-gemfile
  augroup MyPreventVimRubyFromChangingSettings  " {{{
    autocmd!
    autocmd BufEnter Gemfile set filetype=Gemfile
  augroup END  " }}}

  " Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
  augroup MyUnletRubyNoExpensive  " {{{
    autocmd!
    autocmd FileType ruby if exists("b:ruby_no_expensive") | unlet b:ruby_no_expensive | endif
  augroup END  " }}}

  let g:no_ruby_maps = 1

  call s:ConfigPlugin(#{
     \   lazy: 0,
     \ })
endif  " }}}

if s:RegisterPlugin("joker1007/vim-ruby-heredoc-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:ruby_heredoc_syntax_filetypes = #{
    \   haml: #{ start: "HAML" },
    \   ruby: #{ start: "RUBY" },
    \ }
endif  " }}}

" See also vim-startify's settings
if s:RegisterPlugin("xolox/vim-session", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:session_directory         = getcwd() . "/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = 0

  set sessionoptions=buffers,folds

  augroup MyExtendPluginSession  " {{{
    autocmd!
    autocmd BufWritePost * silent call s:SaveSession()
    autocmd BufWritePost * silent call s:CleanUpSession()
  augroup END  " }}}

  function! s:SaveSession() abort  " {{{
    call s:RestoreFoldmethod()
    execute "SaveSession " . s:SessionName()
  endfunction  " }}}

  function! s:SessionName() abort  " {{{
    let name = @%
    let name = substitute(name, "/", "+=", "g")
    let name = substitute(name, '^\.', "_", "")

    return name
  endfunction  " }}}

  function! s:CleanUpSession() abort  " {{{
    execute "!/usr/bin/env find '" . g:session_directory . "' -name '*.vim' -mtime +10 -delete"
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   depends: ["vim-misc"],
     \ })

  call s:RegisterPlugin("xolox/vim-misc")
endif  " }}}

" See vim-session's settings
if s:RegisterPlugin("mhinz/vim-startify", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  function! s:ConfigPluginOnSource_vim_startify() abort  " {{{
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
      \   #{ p: "call UpdatePlugins()" },
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
      \   "  Vim version: " . v:version,
      \   "",
      \ ]

    let g:startify_custom_header = g:startify_custom_header + [
      \   "  LSPs: ",
      \ ]
    for lsp in s:lsps
      let g:startify_custom_header = g:startify_custom_header + [
        \   "  " . (lsp.available ? "👼 " : "👿 ") . lsp.name,
        \ ]
    endfor

    let g:startify_custom_header = g:startify_custom_header + [""]
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_vim_startify() abort  " {{{
    highlight StartifyFile   ctermfg=255
    highlight StartifyHeader ctermfg=255
    highlight StartifyPath   ctermfg=245
    highlight StartifySlash  ctermfg=245
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:     1,
     \   on_event: "VimEnter",
     \   hook_source:      function("s:ConfigPluginOnSource_vim_startify"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_vim_startify"),
     \ })
endif  " }}}

if s:RegisterPlugin("kopischke/vim-stay", #{ if: !IsGitCommit() })  " {{{
  set viewoptions=cursor,folds
endif  " }}}

call s:RegisterPlugin("tpope/vim-surround")

if s:RegisterPlugin("janko/vim-test", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  nnoremap <Leader>T :write<Cr>:TestFile<Cr>
  nnoremap <Leader>t :write<Cr>:TestNearest<Cr>

  if OnTmux()
    function! MyVimTestVimuxStrategy(command) abort  " {{{
      " Just execute the command without echo it
      call VimuxRunCommand(a:command)
    endfunction  " }}}

    let g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    let g:test#custom_strategies.vimux = function("MyVimTestVimuxStrategy")
    let g:test#strategy = "vimux"
  endif

  let g:test#preserve_screen = 1

  let g:test#go#gotest#options = "-race"
  let g:test#ruby#bundle_exec = 0

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_cmd: ["TestFile", "TestNearest"],
     \ })
endif  " }}}

" text object for quotations: q
if s:RegisterPlugin("deris/vim-textobj-enclosedsyntax")  " {{{
  call s:ConfigPlugin(#{
     \   depends: ["vim-textobj-user"],
     \ })
endif  " }}}

" text object for Japanese braces: j
if s:RegisterPlugin("kana/vim-textobj-jabraces")  " {{{
  call s:ConfigPlugin(#{
     \   depends: ["vim-textobj-user"],
     \ })

  let g:textobj_jabraces_no_default_key_mappings = 1
endif  " }}}

" text object fo last search pattern: /
if s:RegisterPlugin("kana/vim-textobj-lastpat")  " {{{
  call s:ConfigPlugin(#{
     \   depends: ["vim-textobj-user"],
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

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   depends: ["vim-textobj-user"],
     \   on_map:  [["ov", "<Plug>(textobj-multitextobj-"]],
     \   hook_source: function("s:ConfigPluginOnSource_vim_textobj_multitextobj"),
     \ })
endif  " }}}

" text object for Ruby blocks (not only `do-end` nor `{}`): r
if s:RegisterPlugin("rhysd/vim-textobj-ruby")  " {{{
  call s:ConfigPlugin(#{
     \   depends: ["vim-textobj-user"],
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-textobj-user")  " {{{
  function! s:ConfigPluginOnSource_vim_textobj_user() abort
    " Some kakkos are not defined because they require IME's `henkan` and don't work
    " - #{ pair: ["｛", "｝"], name: "bracket" },
    " - #{ pair: ["『", "』"], name: "double-kakko" },
    " - #{ pair: ["【", "】"], name: "sumi-kakko" },
    " - #{ pair: ["〈", "〉"], name: "yama-kakko" },
    " - #{ pair: ["《", "》"], name: "double-yama-kakko" },
    let jbrace_specs = [
      \   #{ pair: ["（", "）"], name: "paren" },
      \   #{ pair: ["［", "］"], name: "brace" },
      \   #{ pair: ["「", "」"], name: "kakko" },
      \   #{ pair: ["“", "”"], name: "double-quotation" },
      \   #{ pair: ["‘", "’"], name: "single-quotation" },
      \ ]

    let jbrace_config = {}
    for spec in jbrace_specs
      let jbrace_config[spec["name"]] = #{
        \   pattern:  spec["pair"],
        \   select-a: ["a" . spec["pair"][0], "a" . spec["pair"][1]],
        \   select-i: ["i" . spec["pair"][0], "i" . spec["pair"][1]],
        \ }
    endfor
    call textobj#user#plugin("myjabraces", jbrace_config)
  endfunction

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_func: "textobj#user",
     \   hook_source: function("s:ConfigPluginOnSource_vim_textobj_user"),
     \ })
endif  " }}}

call s:RegisterPlugin("tmux-plugins/vim-tmux", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("cespare/vim-toml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("posva/vim-vue", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("thinca/vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup MyHighlightZenkakuSpace  " {{{
    autocmd!
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if s:RegisterPlugin("Shougo/vimfiler", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vimfiler_ignore_pattern = ['^\.git$', '^\.DS_Store$']

  nnoremap <Leader>e :<C-u>VimFilerBufferDir -force-quit<Cr>

  function! s:ConfigPluginOnSource_vimfiler() abort  " {{{
    call vimfiler#custom#profile("default", "context", #{
       \   safe: 0,
       \   split_action: "dwm_open",
       \ })
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_func: "VimFilerBufferDir",
     \   hook_source: function("s:ConfigPluginOnSource_vimfiler"),
     \ })
endif  " }}}

if s:RegisterPlugin("benmills/vimux", #{ if: OnTmux() && !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  function! s:ConfigPluginOnSource_vimux() abort  " {{{
    let g:VimuxHeight     = 30
    let g:VimuxUseNearest = 1

    augroup MyVimux  " {{{
      autocmd!
      autocmd VimLeavePre * :VimuxCloseRunner
    augroup END  " }}}
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_vimux() abort  " {{{
    " Overwrite function: Always use current pane's next one
    "   Original function:
    "     function! _VimuxNearestIndex()
    "       let views = split(_VimuxTmux("list-"._VimuxRunnerType()."s"), "\n")
    "
    "       for view in views
    "         if match(view, "(active)") == -1
    "           return split(view, ":")[0]
    "         endif
    "       endfor
    "
    "       return -1
    "     endfunction
    " Don't assing by `let func = << trim VIM`, that doesn't work
    let func =<< trim VIM
      function! _VimuxNearestIndex() abort
        let views = split(_VimuxTmux("list-" . _VimuxRunnerType() . "s"), "\n")
        let index = len(views) - 1

        while index >= 0
          let view = views[index]

          if match(view, "(active)") != -1
            if index == len(views) - 1
              return -1
            else
              return split(views[index + 1], ":")[0]
            endif
          endif

          let index = index - 1
        endwhile
      endfunction
    VIM

    execute join(func, "\n")
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    1,
     \   on_cmd:  "VimuxCloseRunner",
     \   on_func: "VimuxRunCommand",
     \   hook_source:      function("s:ConfigPluginOnSource_vimux"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_vimux"),
     \ })
endif  " }}}

if s:RegisterPlugin("vim-jp/vital.vim")  " {{{
  " https://github.com/vim-jp/vital.vim/blob/master/doc/vital/Async/Promise.txt
  function! s:ReadStd(channel, part) abort  " {{{
    let out = []
    while ch_status(a:channel, #{ part: a:part }) =~# 'open\|buffered'
      call add(out, ch_read(a:channel, #{ part: a:part }))
    endwhile
    return join(out, "\n")
  endfunction  " }}}

  function! s:SystemAsync(cmd) abort  " {{{
    return s:Promise().new({ resolve, reject -> job_start(a:cmd, #{
         \   drop:     "never",
         \   close_cb: { ch -> "do nothing" },
         \   exit_cb:  { ch, code -> code ? reject(s:ReadStd(ch, "err")) : resolve(s:ReadStd(ch, "out")) },
         \ }) })
  endfunction  " }}}

  function! s:Promise() abort  " {{{
    if !exists("s:__Promise__")
      let s:__Promise__ = vital#vital#import("Async.Promise")
    endif

    return s:__Promise__
  endfunction  " }}}

  function! s:StringUtility() abort  " {{{
    if !exists("s:__StringUtility__")
      let s:__StringUtility__ = vital#vital#import("Data.String")
    endif

    return s:__StringUtility__
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("simeji/winresizer")  " {{{
  let g:winresizer_start_key = "<C-w><C-e>"

  call s:ConfigPlugin(#{
     \   lazy:   1,
     \   on_map: [["n", g:winresizer_start_key]],
     \ })
endif  " }}}

call s:RegisterPlugin("stephpy/vim-yaml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("pedrohdz/vim-yaml-folds", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("othree/yajs.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup MyJavaScriptFold  " {{{
    autocmd!
    autocmd FileType javascript setlocal foldmethod=syntax
  augroup END  " }}}
endif  " }}}

if s:RegisterPlugin("LeafCage/yankround.vim")  " {{{
  let g:yankround_max_history = 100

  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap <S-p> <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)

  " https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
  " For fzf.vim
  function! s:YankList() abort  " {{{
    return map(copy(g:_yankround_cache), { index, _ -> s:FormatYankItem(index) })
  endfunction  " }}}

  function! s:FormatYankItem(index) abort  " {{{
    let [text, _]  = yankround#_get_cache_and_regtype(a:index)
    return printf("%3d\t%s", a:index, text)
  endfunction  " }}}

  function! s:YankHandler(yank_item) abort  " {{{
    let old_reg = [getreg('"'), getregtype('"')]
    let index = matchlist(a:yank_item, '\v^\s*(\d+)\t')[1]
    let [text, regtype] = yankround#_get_cache_and_regtype(index)
    call setreg('"', text, regtype)

    try
      execute 'normal! ""p'
    finally
      call setreg('"', old_reg[0], old_reg[1])
    endtry
  endfunction  " }}}
endif  " }}}

" Colorschemes
if s:RegisterPlugin("tomasr/molokai")  " {{{
  let g:molokai_original = 1

  function! s:OverwriteSyntax() abort  " {{{
    if has("gui_running")
      highlight DiffChange   guifg=#FFFFFF guibg=#4C4745
      highlight DiffFile     guifg=#A6E22E               gui=bold
      highlight FoldColumn   guifg=#6a7678 guibg=#000000
      highlight Folded       guifg=#6a7678 guibg=#000000
      highlight IncSearch    guifg=#FFFFFF guibg=#F92672
      highlight PmenuSel     guifg=#000000 guibg=#808080
      highlight Search       guifg=#FFFFFF guibg=#F92672
      highlight Underlined   guifg=#AAAAAA               gui=underline
      highlight VisualNOS                  guibg=#403D3D gui=bold
      highlight Visual                     guibg=#403D3D gui=bold
      highlight Normal       guifg=#F8F8F2 guibg=#000000
      highlight Comment      guifg=#AAAAAA
      highlight CursorLine                 guibg=#1F1E19
      highlight CursorColumn               guibg=#1F1E19
    else
      highlight Normal                    ctermbg=NONE
      highlight DiffAdd                   ctermbg=23
      highlight DiffChange   ctermfg=NONE ctermbg=234
      highlight DiffFile     ctermfg=118              cterm=bold
      highlight DiffText                  ctermbg=240  cterm=bold
      highlight FoldColumn   ctermfg=67   ctermbg=NONE
      highlight Folded       ctermfg=67   ctermbg=NONE
      highlight IncSearch    ctermfg=255  ctermbg=161
      highlight Search       ctermfg=255  ctermbg=161
      highlight Underlined   ctermfg=247               cterm=underline
      highlight VisualNOS                 ctermbg=238  cterm=bold
      highlight Visual                    ctermbg=235  cterm=bold
      highlight Comment      ctermfg=247
      highlight CursorColumn              ctermbg=234
      highlight ColorColumn               ctermbg=234
      highlight LineNr       ctermfg=250  ctermbg=234
    endif
  endfunction  " }}}
endif  " }}}
" }}}

" Finish plugin manager initialization  " {{{
call s:SetupPluginEnd()

" Disable filetype before enabling filetype
" https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if s:InstallablePluginExists()
  call s:InstallPlugins()
endif
" }}}
" }}}

" ----------------------------------------------
" General looks  " {{{
colorscheme molokai
call s:OverwriteSyntax()

" https://qiita.com/Bakudankun/items/649aa6d8b9eccc1712b5
augroup MyBlurInactiveWindow  " {{{
  autocmd!
  autocmd ColorScheme * highlight NormalNC ctermbg=234 guibg=#3B3A32
  autocmd WinEnter,BufWiNEnter * set wincolor=
  autocmd WinLeave,BufWiNLeave * set wincolor=NormalNC
augroup END  " }}}

set showmatch
set matchtime=1
set number
set noshowmode
set showcmd
set redrawtime=5000
set scrolloff=15
set wrap
set display+=lastline
set diffopt+=context:10
set list
set listchars=tab:>\ ,eol:\ ,trail:_
set cursorline
set cursorlineopt=number
set completeopt=menu,menuone,popup,noinsert,noselect
set pumheight=20

" Cursor shapes
let &t_SI = "\e[6 q"  " |
let &t_EI = "\e[2 q"  " ▍

" https://teratail.com/questions/24046
augroup MyLimitLargeFileSyntax  " {{{
  autocmd!
  autocmd Syntax * if line("$") > 10000 | syntax sync minlines=1000 | endif
augroup END  " }}}
" }}}

" ----------------------------------------------
" Spaces, Indents  " {{{
set tabstop=2
set shiftwidth=2
set softtabstop=-1
set noshiftround
set textwidth=0
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start
set nofixeol

if !IsGitCommit() && !IsGitHunkEdit()  " {{{
  augroup MySetupExpandtab  " {{{
    autocmd!
    autocmd FileType neosnippet set noexpandtab
  augroup END  " }}}

  augroup MySetupFormatoptions  " {{{
    autocmd!
    " Lazily set formatoptions to overwrite others
    autocmd FileType * call timer_start(300, { -> call("s:SetupFormatoptions", []) })
  augroup END  " }}}

  function! s:SetupFormatoptions() abort  " {{{
    " Formatoptions:
    "   t: Auto-wrap text using textwidth.
    "   c: Auto-wrap comments using textwidth, inserting the current comment leader automatically.
    "   r: Automatically insert the current comment leader after hitting <Enter> in Insert mode.
    "   o: Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
    "   q: Allow formatting of comments with "gq".
    "   a: Automatic formatting of paragraphs. Every time text is inserted or deleted the paragraph will be reformatted.
    "   2: When formatting text, use the indent of the second line of a paragraph for the rest of the paragraph, instead of the indent of the first line.
    "   b: Like 'v', but only auto-wrap if you enter a blank at or before the wrap margin.
    "   l: Long lines are not broken in insert mode: When a line was longer than textwidth when the insert command started, Vim does not.
    "   M: When joining lines, don't insert a space before or after a multi-byte character.  Overrules the 'B' flag.
    "   j: Where it makes sense, remove a comment leader when joining lines.
    setlocal fo+=roq2lMj
    setlocal fo-=t fo-=c fo-=a fo-=b  " `fo-=tcab` doesn't work

    if &filetype =~# '\v^(text|markdown|moin)$'
      setlocal fo-=r fo-=o
    endif
  endfunction  " }}}

  augroup MySetupCinkeys  " {{{
    autocmd!
    autocmd FileType text,markdown,moin setlocal cinkeys-=:
  augroup END  " }}}

  " Folding  " {{{
  " Frequently used keys:
  "   zo: Open current fold
  "   zc: Close current fold
  "   zR: Open all folds
  "   zM: Close all folds
  "   zx: Recompute all folds
  "   z[: Move to start of current fold
  "   z]: Move to end of current fold
  "   zj: Move to start of next fold
  "   zk: Move to end of previous fold
  nnoremap z[ [z
  nnoremap z] ]z
  vnoremap z[ [z
  vnoremap z] ]z

  set foldmethod=marker
  set foldopen=hor
  set foldminlines=0
  set foldcolumn=3
  set fillchars=vert:\|

  augroup MySetupFoldings  " {{{
    autocmd!
    autocmd FileType neosnippet setlocal foldmethod=marker
    autocmd FileType vim        setlocal foldmethod=marker
    autocmd FileType haml       setlocal foldmethod=indent
    autocmd FileType gitcommit,qfreplace setlocal nofoldenable

    " http://d.hatena.ne.jp/gnarl/20120308/1331180615
    autocmd InsertEnter * call s:SwitchToManualFolding()
  augroup END  " }}}

  function! s:SwitchToManualFolding() abort  " {{{
    if !exists("w:last_fdm")
      let w:last_fdm = &foldmethod
      setlocal foldmethod=manual
    endif
  endfunction  " }}}

  function! s:RestoreFoldmethod() abort  " {{{
    if exists("w:last_fdm")
      let &foldmethod = w:last_fdm
      unlet w:last_fdm
    endif
  endfunction  " }}}
  " }}}

  augroup MyUpdateFiletypeAfterSave  " {{{
    autocmd!
    autocmd BufWritePre * if &filetype ==# "" || exists("b:ftdetect") | unlet! b:ftdetect | filetype detect | endif
  augroup END  " }}}
endif  " }}}
" }}}

" ----------------------------------------------
" Search  " {{{
set hlsearch
set ignorecase
set smartcase
set incsearch

" Show search count message when searching
set shortmess-=S

nnoremap <Leader>/ :<C-u>nohlsearch<Cr>

" Enable very magic
nnoremap / /\v
" }}}

" ----------------------------------------------
" Controls  " {{{
set restorescreen
set mouse=
set belloff=all

" Smoothen screen drawing; wait procedures' completion
set lazyredraw
set ttyfast

" Backup, Recover
set nobackup

" Double slash:    fullpath like `%home%admin%.vimrc.swp`
" Sinble/no slash: only filename like `.vimrc.swp`
let s:swapdir = $HOME . "/tmp/.vimswap//"
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir, "p")
endif
let &directory = s:swapdir

" Undo
set hidden
set undofile

let s:undodir = $HOME . "/tmp/.vimundo"
if !isdirectory(s:undodir)
  call mkdir(s:undodir, "p")
endif
let &undodir = s:undodir

set wildmenu
set wildmode=list:longest,full

" Time to wait for a key code or mapped key sequence
set timeoutlen=3000

" Support Japanese kakkos
set matchpairs+=（:）,「:」,『:』,｛:｝,［:］,〈:〉,《:》,【:】,〔:〕,“:”,‘:’

" Ctags  " {{{
if OnRailsDir() && !IsGitCommit() && !IsGitHunkEdit()  " {{{
  augroup MySetupCtags  " {{{
    autocmd!
    autocmd VimEnter     * silent call s:CreateAllCtags()
    autocmd BufWritePost * silent call s:CreateCtags(".")
    autocmd VimLeavePre  * silent call s:CleanupCtags()
  augroup END  " }}}

  function! s:SetupTags() abort  " {{{
    for ruby_gem_path in RubyGemPaths()
      if isdirectory(ruby_gem_path)
        let &tags .= "," . ruby_gem_path . "/tags"
      endif
    endfor
  endfunction  " }}}

  function! s:CreateAllCtags() abort  " {{{
    call s:SetupTags()

    for directory in ["."] + RubyGemPaths()
      call s:CreateCtagsAsync(directory)
    endfor
  endfunction  " }}}

  function! s:CreateCtagsAsync(directory) abort  " {{{
    call timer_start(300, { -> call("s:CreateCtags", [a:directory]) })
  endfunction  " }}}

  function! s:CreateCtags(directory) abort  " {{{
    if isdirectory(a:directory)
      let tags_file = a:directory . "/tags"
      let lock_file = a:directory . "/tags.lock"
      let temp_file = a:directory . "/tags.temp"

      if !filereadable(lock_file)
        let setup_command    = "touch " . lock_file
        let replace_command  = "mv -f " . temp_file . " " . tags_file
        let teardown_command = "rm -f " . lock_file

        let ctags_options = "--tag-relative=yes --recurse=yes --sort=yes -f " . temp_file

        if a:directory != "."
          let ctags_options .= " --exclude=test --exclude=spec --languages=ruby"
        endif

        let ctags_command = "ctags " . ctags_options . " " . a:directory

        call s:SystemAsync(setup_command)
               \.then({ -> s:SystemAsync(ctags_command) })
               \.then({ -> s:SystemAsync(replace_command) })
               \.then({ -> s:SystemAsync(teardown_command) })
      endif
    endif
  endfunction  " }}}

  function! s:CleanupCtags() abort  " {{{
    for directory in ["."] + RubyGemPaths()
      if filereadable(directory . "/tags.lock")
        call delete(directory . "/tags.lock")
      endif

      if filereadable(directory . "/tags.temp")
        call delete(directory . "/tags.temp")
      endif
    endfor
  endfunction  " }}}
endif  " }}}

" See also vim-lsp and unite.vim settings
nnoremap g] :tjump <C-r>=expand("<cword>")<Cr><Cr>
vnoremap g] "gy:tjump <C-r>"<Cr>
" }}}

" Auto reload
augroup MyCheckTimeHook  " {{{
  autocmd!
  autocmd InsertEnter,InsertLeave,CursorHold,WinEnter,BufWinEnter * silent! checktime
augroup END  " }}}

set whichwrap=b,s,h,l,<,>,[,],~
set maxmempattern=5000

if !IsGitCommit() && !IsGitHunkEdit()  " {{{
  " http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
  augroup MyCheckTypo  " {{{
    autocmd!
    autocmd BufWriteCmd *[,*] call s:WriteCheckTypo(expand("<afile>"))
  augroup END  " }}}

  function! s:WriteCheckTypo(file) abort  " {{{
    let writecmd = "write" . (v:cmdbang ? "!" : "") . " " . a:file

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
endif  " }}}
" }}}

" ----------------------------------------------
" Commands  " {{{
" http://vim-users.jp/2009/05/hack17/
command! -nargs=1 -complete=file Rename f <args> | call delete(expand("#")) | write
" }}}

" ----------------------------------------------
" Keymappings  " {{{
nnoremap <Leader>v :<C-u>vsplit<Cr>
nnoremap <Leader>h :<C-u>split<Cr>

vnoremap <Leader>y "yy:<C-u>call RemoteCopy(@")<Cr>

function! s:RemoveTrailingWhitespaces() abort  " {{{
  let position = getpos(".")
  keeppatterns '<,'>s/\s\+$//ge
  call setpos(".", position)
endfunction  " }}}
vnoremap <Leader>w :<C-u>call <SID>RemoveTrailingWhitespaces()<Cr>

" Prevent unconscious operation (<Nul> == <C-Space>)
inoremap <C-w> <Esc><C-w>
inoremap <Nul> <C-Space>
tnoremap <Nul> <C-Space>

" Increment/Decrement
nmap + <C-a>
nmap - <C-x>

" Exchange pasting with adjusting indentations or not
" Disable exchanging because sometimes indentation is bad
" nnoremap p ]p
" nnoremap <S-p> ]<S-p>
" nnoremap ]p p
" nnoremap ]<S-p> <S-p>

" Moving in INSERT mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>

cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

inoremap <C-f> <PageDown>
inoremap <C-b> <PageUp>

" Insert a checkbox `[ ]` on markdown
augroup MyConfigInsertCheckbox
  autocmd!
  autocmd FileType markdown inoremap <buffer> <C-]> [<Space>]<Space>
augroup END
" }}}

" ----------------------------------------------
" GUI settings  " {{{
if has("gui_running")
  gui
  set guioptions=none

  " set guifont=Osaka-Mono:h14
  set guifont=SFMono-Regular:h12

  set transparency=20
  set imdisable

  " Always show tabline
  set showtabline=2

  " Save window's size and position  " {{{
  " http://vim-users.jp/2010/01/hack120/
  let s:old_save_window_info_filepath = expand("~/.vimwinpos")
  let s:save_window_info_filepath = expand("~/.vim/gui-window-info")

  if filereadable(s:old_save_window_info_filepath)
    call rename(s:old_save_window_info_filepath, s:save_window_info_filepath)
  endif

  augroup MySaveWindowSize  " {{{
    autocmd!
    autocmd VimLeavePre * call s:SaveWindowSize()

    function! s:SaveWindowSize() abort  " {{{
      let options = [
        \   "set columns=" . &columns,
        \   "set lines=" . &lines,
        \   "winpos " . getwinposx() . " " . getwinposy(),
        \ ]

      call writefile(options, s:save_window_info_filepath)
    endfunction  " }}}
  augroup END  " }}}

  if has("vim_starting") && filereadable(s:save_window_info_filepath)
    execute "source" s:save_window_info_filepath
  endif
  " }}}
endif
" }}}

" ----------------------------------------------
" External sources  " {{{
if filereadable($HOME . "/.vimrc.local")
  source $HOME/.vimrc.local
endif
" }}}
