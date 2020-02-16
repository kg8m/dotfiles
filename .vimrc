" ----------------------------------------------
" Initialize  " {{{
" Set initial variables/options  " {{{
let s:vim_root_path       = expand($HOME . "/.vim")
let s:plugins_path        = expand(s:vim_root_path . "/plugins")
let s:plugin_manager_path = expand(s:plugins_path . "/repos/github.com/Shougo/dein.vim")

let g:no_vimrc_example          = v:true
let g:no_gvimrc_example         = v:true
let g:loaded_gzip               = v:true
let g:loaded_tar                = v:true
let g:loaded_tarPlugin          = v:true
let g:loaded_zip                = v:true
let g:loaded_zipPlugin          = v:true
let g:loaded_rrhelper           = v:true
let g:loaded_vimball            = v:true
let g:loaded_vimballPlugin      = v:true
let g:loaded_getscript          = v:true
let g:loaded_getscriptPlugin    = v:true
let g:loaded_netrw              = v:true
let g:loaded_netrwPlugin        = v:true
let g:loaded_netrwSettings      = v:true
let g:loaded_netrwFileHandlers  = v:true
let g:skip_loading_mswin        = v:true
let g:did_install_syntax_menu   = v:true

" MacVim's features, e.g., Command+v, are broken if setting this
" let g:did_install_default_menus = v:true

let g:mapleader = ","

set fileformats=unix,dos,mac
set ambiwidth=double
scriptencoding utf-8
" }}}

" Reset my autocommands
augroup my_vimrc  " {{{
  autocmd!
augroup END  " }}}

" ----------------------------------------------
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

function! s:RegisterPlugin(plugin_name, options = {}) abort  " {{{
  let enabled = v:true

  if has_key(a:options, "if")
    if !a:options["if"]
      " Don't load but fetch the plugin
      let a:options["rtp"] = ""
      call remove(a:options, "if")
      let enabled = v:false
    endif
  else
    " Sometimes dein doesn't add runtimepath if no options given
    let a:options["if"] = v:true
  endif

  call dein#add(a:plugin_name, a:options)
  return dein#tap(fnamemodify(a:plugin_name, ":t")) && enabled
endfunction  " }}}

function! s:ConfigPlugin(arg, options = {}) abort  " {{{
  return dein#config(a:arg, a:options)
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
  if !has_key(s:, "lsps")
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

    call add(s:lsps, #{ name: a:config.name, available: v:true })
  else
    call add(s:lsps, #{ name: a:config.name, available: v:false })
  endif
endfunction  " }}}

function! s:EnableLSPs() abort  " {{{
  for config in s:lsp_configs
    if has_key(config, "initialization_options") && type(config.initialization_options) == v:t_func
      let config.initialization_options = config.initialization_options()
    endif

    if has_key(config, "workspace_config") && type(config.workspace_config) == v:t_func
      let config.workspace_config = config.workspace_config()
    endif

    call lsp#register_server(config)
  endfor
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
  if has_key(s:, "on_rails_dir")
    return s:on_rails_dir
  endif

  let s:on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:on_rails_dir
endfunction  " }}}

function! OnGitDir() abort  " {{{
  if has_key(s:, "on_git_dir")
    return s:on_git_dir
  endif

  silent! !git status > /dev/null 2>&1
  let s:on_git_dir = !v:shell_error
  return s:on_git_dir
endfunction  " }}}

function! IsGitCommit() abort  " {{{
  if has_key(s:, "is_git_commit")
    return s:is_git_commit
  endif

  let s:is_git_commit = argc() == 1 && argv()[0] =~# '\.git/COMMIT_EDITMSG$'
  return s:is_git_commit
endfunction  " }}}

function! IsGitHunkEdit() abort  " {{{
  if has_key(s:, "is_git_hunk_edit")
    return s:is_git_hunk_edit
  endif

  let s:is_git_hunk_edit = argc() == 1 && argv()[0] =~# '\.git/addp-hunk-edit\.diff$'
  return s:is_git_hunk_edit
endfunction  " }}}

function! RubyGemPaths() abort  " {{{
  if has_key(s:, "ruby_gem_paths")
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
    call s:EchoErrorMsg(result)
  endif
endfunction  " }}}

function! ConfirmCommand(command) abort  " {{{
  if input("execute `" . a:command . "`? [y/n] : ") !~? "y"
    echo " -> canceled."
    return v:false
  endif

  return v:true
endfunction  " }}}

function! RemoteCopy(text) abort  " {{{
  let text = a:text
  let text = substitute(text, '^\n\+', "", "")
  let text = substitute(text, '\n\+$', "", "")
  let text = substitute(text, '\', '\\\\', "g")
  let text = substitute(text, "'", "'\\\\''", "g")

  if text =~# "\n"
    let filter = ""
  else
    let filter = " | tr -d '\\n'"
  endif

  call system("echo '" . text . "'" . filter . " | ssh main 'LC_CTYPE=UTF-8 pbcopy'")

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
" }}}

" ----------------------------------------------
" Plugins  " {{{
" Initialize plugin manager  " {{{
if !isdirectory(s:plugin_manager_path)
  echo "Installing plugin manager..."
  call system("git clone https://github.com/Shougo/dein.vim " . s:plugin_manager_path)
endif

let &runtimepath .= "," . s:plugin_manager_path

call s:SetupPluginStart()
" }}}

" Plugins list and settings  " {{{
call s:RegisterPlugin(s:plugin_manager_path)
call s:RegisterPlugin("kg8m/.vim")

" Completion, LSP  " {{{
if s:RegisterPlugin("prabirshrestha/asyncomplete.vim")  " {{{
  let g:asyncomplete_auto_popup = v:true
  let g:asyncomplete_popup_delay = 50
  let g:asyncomplete_auto_completeopt = v:false
  let g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  augroup my_vimrc  " {{{
  augroup END  " }}}

  " Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  " Inspired by machakann/asyncomplete-ezfilter.vim's asyncomplete#preprocessor#ezfilter#filter
  " Fuzzy matcher is mattn's idea
  " cf. LSP sources are named "asyncomplete_lsp_{original source name}"
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

  " Asynchronous refresh completion  " {{{
  function! s:DefineRefreshCompletionAsyncMappings() abort  " {{{
    inoremap <silent> <expr> <BS> "\<BS>" . <SID>RefreshCompletionAsync()
    inoremap <silent> <expr> .    "."     . <SID>RefreshCompletionAsync()
  endfunction  " }}}

  function! s:RefreshCompletionAsync() abort  " {{{
    call s:ClearCompletionTimer()
    call s:StartCompletionTimer()
    return ""
  endfunction  " }}}

  function! s:StartCompletionTimer() abort  " {{{
    " OPTIMIZE: Use function instead of lambda for performance
    let s:completion_refresh_timer = timer_start(200, function("s:ForceRefreshCompletion"))
  endfunction  " }}}

  function! s:ClearCompletionTimer() abort  " {{{
    if has_key(s:, "completion_refresh_timer")
      call timer_stop(s:completion_refresh_timer)
      unlet s:completion_refresh_timer
    endif
  endfunction  " }}}

  function! s:ForceRefreshCompletion(timer) abort  " {{{
    call asyncomplete#_force_refresh()
    call s:ClearCompletionTimer()
  endfunction  " }}}
  " }}}

  function! s:ConfigPluginOnPostSource_asyncomplete() abort  " {{{
    call timer_start(0, { -> s:DefineRefreshCompletionAsyncMappings() })

    if get(b:, "asyncomplete_enable", v:true)
      call asyncomplete#enable_for_buffer()
    endif
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy: v:true,
     \   on_i: v:true,
     \   hook_post_source: function("s:ConfigPluginOnPostSource_asyncomplete"),
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-buffer.vim")  " {{{
  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L29
  let s:asyncomplete_buffer_events = [
    \   "BufWinEnter",
    \   "TextChanged",
    \   "TextChangedI",
    \   "TextChangedP",
    \ ]

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call timer_start(0, { -> s:SetupAsyncompleteBuffer() })
  augroup END  " }}}

  function! s:SetupAsyncompleteBuffer() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
       \   name: "asyncomplete_source_02_buffer",
       \   whitelist: ["*"],
       \   completor: function("asyncomplete#sources#buffer#completor"),
       \   events: s:asyncomplete_buffer_events,
       \   on_event: function("s:AsyncompleteBufferOnEventAsync"),
       \ }))

    call s:ActivateAsyncompleteBuffer()
  endfunction  " }}}

  function! s:AsyncompleteBufferOnEventAsync(...) abort  " {{{
    call s:AsyncompleteBufferOnEventClearTimer()
    call s:AsyncompleteBufferOnEventStartTimer()
  endfunction  " }}}

  function! s:AsyncompleteBufferOnEventStartTimer() abort  " {{{
    " OPTIMIZE: Use function instead of lambda for performance
    let s:asyncomplete_buffer_on_event_timer = timer_start(200, function("s:AsyncompleteBufferOnEvent"))
  endfunction  " }}}

  function! s:AsyncompleteBufferOnEventClearTimer() abort  " {{{
    if has_key(s:, "asyncomplete_buffer_on_event_timer")
      call timer_stop(s:asyncomplete_buffer_on_event_timer)
      unlet s:asyncomplete_buffer_on_event_timer
    endif
  endfunction  " }}}

  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
  function! s:AsyncompleteBufferOnEvent(timer) abort  " {{{
    if !has_key(s:, "asyncomplete_buffer_sid")
      call s:SetupAsyncompleteBufferRefreshKeywords()
    endif

    call s:AsyncompleteBufferRefreshKeywords()
    call s:AsyncompleteBufferOnEventClearTimer()
  endfunction  " }}}

  function! s:SetupAsyncompleteBufferRefreshKeywords() abort  " {{{
    for scriptname in split(execute("scriptnames"), '\n')
      if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
        let s:asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
        break
      endif
    endfor

    if has_key(s:, "asyncomplete_buffer_sid")
      let s:AsyncompleteBufferRefreshKeywords = function("<SNR>" . s:asyncomplete_buffer_sid . "_refresh_keywords")
    else
      if has_key(s:, "AsyncompleteBufferRefreshKeywords")
        return
      endif

      function! s:AsyncompleteBufferCannotRefreshKeywords() abort
        call s:EchoErrorMsg("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
      endfunction
      let s:AsyncompleteBufferRefreshKeywords = function("AsyncompleteBufferCannotRefreshKeywords")
    endif
  endfunction  " }}}

  function! s:ActivateAsyncompleteBuffer() abort  " {{{
    " Trigger one of the s:asyncomplete_buffer_events
    " Don't use `TextChangedI` or `TextChangedP` because they cause asyncomplete.vim's error about previous_position
    doautocmd TextChanged
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-file.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteFile()
  augroup END  " }}}

  function! s:SetupAsyncompleteFile() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
       \   name: "asyncomplete_source_file",
       \   whitelist: ["*"],
       \   completor: function("asyncomplete#sources#file#completor"),
       \ }))
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-neosnippet.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteNeosnippet()
  augroup END  " }}}

  function! s:SetupAsyncompleteNeosnippet() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options(#{
       \   name: "asyncomplete_source_01_neosnippet",
       \   whitelist: ["*"],
       \   completor: function("asyncomplete#sources#neosnippet#completor"),
       \ }))
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-tags.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteTags()
  augroup END  " }}}

  function! s:SetupAsyncompleteTags() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options(#{
       \   name: "asyncomplete_source_tags",
       \   whitelist: ["*"],
       \   completor: function("asyncomplete#sources#tags#completor"),
       \ }))
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("prabirshrestha/asyncomplete-lsp.vim")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if s:RegisterPlugin("Shougo/neosnippet")  " {{{
  function! s:ConfigPluginOnSource_neosnippet() abort  " {{{
    call s:DefineCompletionMappings()

    let g:neosnippet#snippets_directory = [
      \   s:PluginInfo(".vim").path . "/snippets",
      \ ]
    let g:neosnippet#disable_runtime_snippets = #{
      \   _: v:true,
      \ }

    augroup my_vimrc  " {{{
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

      function! s:SourceContextualSnippets() abort  " {{{
        if has_key(b:, "neosnippet_contextual_sourced")
          return
        endif

        let b:neosnippet_contextual_sourced = v:true
        let contexts = get(g:neosnippet_contextual#contexts, &filetype, [])
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

      augroup my_vimrc  " {{{
        execute "autocmd FileType " . join(keys(g:neosnippet_contextual#contexts), ",") . " call timer_start(50, { -> s:SourceContextualSnippets() })"
      augroup END  " }}}
    endfunction  " }}}
    call s:SetupNeosnippetContextual()
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_neosnippet() abort  " {{{
    call timer_start(0, { -> s:SourceContextualSnippets() })
  endfunction  " }}}

  " `on_ft` for Syntaxes
  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_ft:     ["snippet", "neosnippet"],
     \   on_func:   "neosnippet#",
     \   on_source: "asyncomplete.vim",
     \   depends:   ".vim",
     \   hook_source:      function("s:ConfigPluginOnSource_neosnippet"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_neosnippet"),
     \ })
endif  " }}}

if s:RegisterPlugin("kg8m/vim-lsp")  " {{{
  let g:lsp_diagnostics_enabled     = v:true
  let g:lsp_diagnostics_echo_cursor = v:true
  let g:lsp_signs_enabled           = v:true
  let g:lsp_fold_enabled            = v:false

  let g:lsp_async_completion = v:true

  let g:lsp_log_verbose = v:true
  let g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc  " {{{
    autocmd User lsp_setup          call s:EnableLSPs()
    autocmd User lsp_buffer_enabled call s:OnLSPBufferEnabled()

    autocmd FileType                      * call s:ReswitchLSPGlobalConfigs()
    autocmd BufEnter,BufWinEnter,WinEnter * call s:SwitchLSPGlobalConfigs()

    autocmd User lsp_definition_failed execute "tjump " . expand("<cword>")
  augroup END  " }}}

  function! s:OnLSPBufferEnabled() abort  " {{{
    setlocal omnifunc=lsp#complete
    nmap <buffer> g] <Plug>(lsp-definition)

    call s:SwitchLSPGlobalConfigs()
    let b:lsp_buffer_enabled = 1
  endfunction  " }}}

  function! s:ReswitchLSPGlobalConfigs() abort  " {{{
    if has_key(b:, "lsp_highlight_references_enabled")
      unlet b:lsp_highlight_references_enabled
    endif

    call s:SwitchLSPGlobalConfigs()
  endfunction  " }}}

  function! s:SwitchLSPGlobalConfigs() abort  " {{{
    " References for sass is broken
    if !has_key(b:, "lsp_highlight_references_enabled")
      let b:lsp_highlight_references_enabled = (&filetype != "sass")
    endif
    let g:lsp_highlight_references_enabled = b:lsp_highlight_references_enabled
  endfunction  " }}}

  function! s:LSPSchemasJson() abort  " {{{
    if !has_key(s:, "lsp_schemas_json")
      let s:lsp_schemas_json = json_decode(join(readfile(s:PluginInfo("vim-lsp-settings").path . "/data/catalog.json"), "\n"))["schemas"]
    endif

    return s:lsp_schemas_json
  endfunction  " }}}

  " Register LSPs  " {{{
  " yarn add bash-language-server  " {{{
  call s:RegisterLSP(#{
     \   name: "bash-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "bash-language-server start"] },
     \   whitelist: ["sh", "zsh"],
     \ })
  " }}}

  " yarn add vscode-css-languageserver-bin  " {{{
  call s:RegisterLSP(#{
     \   name: "css-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "css-languageserver --stdio"] },
     \   whitelist: ["css", "less", "sass", "scss"],
     \   workspace_config: #{
     \     css:  #{ lint: #{ validProperties: [] } },
     \     less: #{ lint: #{ validProperties: [] } },
     \     sass: #{ lint: #{ validProperties: [] } },
     \     scss: #{ lint: #{ validProperties: [] } },
     \   },
     \ })
  " }}}

  " go get -u golang.org/x/tools/gopls  " {{{
  call s:RegisterLSP(#{
     \   name: "gopls",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "gopls -mode stdio"] },
     \   initialization_options: #{
     \     completeUnimported: v:true,
     \     completionDocumentation: v:true,
     \     deepCompletion: v:true,
     \     hoverKind: "SynopsisDocumentation",
     \     matcher: "fuzzy",
     \     staticcheck: v:true,
     \     usePlaceholders: v:true,
     \   },
     \   whitelist: ["go"],
     \ })
  " }}}

  " yarn add vscode-html-languageserver-bin  " {{{
  call s:RegisterLSP(#{
     \   name: "html-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "html-languageserver --stdio"] },
     \   initialization_options: #{ embeddedLanguages: #{ css: v:true, javascript: v:true } },
     \   whitelist: ["html"],
     \ })
  " }}}

  " yarn add vscode-json-languageserver-bin  " {{{
  call s:RegisterLSP(#{
     \   name: "json-languageserver",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "json-languageserver --stdio"] },
     \   whitelist: ["json"],
     \   workspace_config: { -> #{
     \     json: #{
     \       format: #{ enable: v:true },
     \       schemas: s:LSPSchemasJson(),
     \    },
     \   } },
     \ })
  " }}}

  " gem install solargraph  " {{{
  call s:RegisterLSP(#{
     \   name: "solargraph",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "solargraph stdio"] },
     \   initialization_options: #{ diagnostics: "true" },
     \   whitelist: ["ruby"],
     \ })
  " }}}

  " yarn add sql-language-server  " {{{
  call s:RegisterLSP(#{
     \   name: "sql-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "sql-language-server up --method stdio"] },
     \   whitelist: ["sql"],
     \ })
  " }}}

  " yarn add typescript-language-server typescript  " {{{
  call s:RegisterLSP(#{
     \   name: "typescript-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "typescript-language-server --stdio"] },
     \   initialization_options: #{ diagnostics: "true" },
     \   whitelist: ["typescript", "javascript", "typescriptreact", "javascriptreact", "typescript.tsx", "javascript.jsx"],
     \ })
  " }}}

  " yarn add vim-language-server  " {{{
  call s:RegisterLSP(#{
     \   name: "vim-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "vim-language-server --stdio"] },
     \   initialization_options: { -> #{ vimruntime: $VIMRUNTIME, runtimepath: &runtimepath } },
     \   whitelist: ["vim"],
     \ })
  " }}}

  " yarn add vue-language-server  " {{{
  " cf. https://github.com/sublimelsp/LSP-vue/blob/master/LSP-vue.sublime-settings
  call s:RegisterLSP(#{
     \   name: "vue-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "vls"] },
     \   initialization_options: #{
     \     config: #{
     \       vetur: #{
     \         completion: #{
     \           autoImport: v:false,
     \           tagCasing: "kebab",
     \           useScaffoldSnippets: v:false,
     \         },
     \         format: #{
     \           defaultFormatter: #{
     \             js: "",
     \             ts: "",
     \           },
     \           defaultFormatterOptions: {},
     \           scriptInitialIndent: v:false,
     \           styleInitialIndent: v:false,
     \         },
     \         useWorkspaceDependencies: v:false,
     \         validation: #{
     \           script: v:true,
     \           style: v:true,
     \           template: v:true,
     \         },
     \         dev: #{ logLevel: "DEBUG" },
     \       },
     \       css: {},
     \       emmet: {},
     \       stylusSupremacy: {},
     \       html: #{ suggest: {} },
     \       javascript: #{ format: {} },
     \       typescript: #{ format: {} },
     \     },
     \   },
     \   whitelist: ["vue"],
     \   executable_name: "vls",
     \ })
  " }}}

  " yarn add yaml-language-server  " {{{
  call s:RegisterLSP(#{
     \   name: "yaml-language-server",
     \   cmd: { server_info -> [&shell, &shellcmdflag, "yaml-language-server --stdio"] },
     \   whitelist: ["yaml"],
     \ })
  " }}}
  " }}}

  function! s:ConfigPluginOnPostSource_lsp() abort  " {{{
    " https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
    call lsp#enable()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_cmd:  ["LspDefinition", "LspRename", "LspStatus"],
     \   on_ft:   get(s:, "lsp_filetypes", []),
     \   depends: "async.vim",
     \   hook_post_source: function("s:ConfigPluginOnPostSource_lsp"),
     \ })

  if s:RegisterPlugin("prabirshrestha/async.vim")  " {{{
    call s:ConfigPlugin(#{
       \   lazy: v:true,
       \ })
  endif  " }}}

  if s:RegisterPlugin("mattn/vim-lsp-settings", #{ if: v:false })  " {{{
    call s:ConfigPlugin(#{
       \   lazy:      v:true,
       \   on_source: "vim-lsp",
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("thomasfaingnaert/vim-lsp-snippets")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_source: "vim-lsp",
     \ })

  if s:RegisterPlugin("thomasfaingnaert/vim-lsp-neosnippet")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:      v:true,
       \   on_source: "vim-lsp-snippets",
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("hrsh7th/vim-vsnip")  " {{{
  function! s:ConfigPluginOnSource_vim_vsnip() abort  " {{{
    call s:DefineCompletionMappings()
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:      v:true,
     \   on_func:   "vsnip#",
     \   on_source: "vim-lsp",
     \   hook_source: function("s:ConfigPluginOnSource_vim_vsnip"),
     \ })

  if s:RegisterPlugin("hrsh7th/vim-vsnip-integ")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:      v:true,
       \   on_source: "vim-vsnip",
       \ })
  endif  " }}}
endif  " }}}

function! s:DefineCompletionMappings() abort  " {{{
  if has_key(s:, "completion_mappings_defined")
    return
  endif

  let s:completion_mappings_defined = v:true

  inoremap <expr><Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  imap     <expr><Cr>    <SID>CrForInsertMode()

  function! s:CrForInsertMode() abort  " {{{
    if vsnip#available(1)
      return "\<Plug>(vsnip_expand_or_jump)"
    elseif neosnippet#expandable_or_jumpable()
      return "\<Plug>(neosnippet_expand_or_jump)"
    else
      return pumvisible() ? asyncomplete#close_popup() : "\<Cr>"
    endif
  endfunction  " }}}
endfunction  " }}}
" }}}

if s:RegisterPlugin("dense-analysis/ale", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:airline#extensions#ale#enabled = v:false
  let g:ale_completion_enabled         = v:false
  let g:ale_disable_lsp                = v:true
  let g:ale_echo_msg_format            = "[%linter%][%severity%] %code: %%s"
  let g:ale_fix_on_save                = v:false
  let g:ale_lint_on_enter              = v:true
  let g:ale_lint_on_filetype_changed   = v:true
  let g:ale_lint_on_insert_leave       = v:false
  let g:ale_lint_on_save               = v:true
  let g:ale_lint_on_text_changed       = v:false
  let g:ale_open_list                  = v:false

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
    \   javascript: ["eslint"],
    \   ruby:       ["rubocop"],
    \   typescript: ["eslint"],
    \ }

  augroup my_vimrc  " {{{
    autocmd FileType go                    let b:ale_fix_on_save = v:true
    autocmd FileType javascript,typescript let b:ale_fix_on_save = !!$FIX_ON_SAVE_JS
    autocmd FileType ruby                  let b:ale_fix_on_save = !!$FIX_ON_SAVE_RUBY
  augroup END  " }}}

  let g:ale_go_golangci_lint_package = v:true

  " yarn add eslint_d
  if executable("eslint_d")
    let g:ale_javascript_eslint_use_global = v:true
    let g:ale_javascript_eslint_executable = "eslint_d"
  endif

  " gem install rubocop-daemon
  " And add rubocop-daemon-wrapper to $PATH
  if executable("rubocop-daemon") && executable("rubocop-daemon-wrapper")
    let g:ale_ruby_rubocop_executable = "rubocop-daemon-wrapper"
  endif
endif  " }}}

call s:RegisterPlugin("pearofducks/ansible-vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

" Show diff in Git's interactive rebase
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
  map gc <Plug>(caw:hatpos:toggle)

  let g:caw_no_default_keymappings = v:true
  let g:caw_hatpos_skip_blank_line = v:true

  augroup my_vimrc  " {{{
    autocmd FileType gemfile let b:caw_oneline_comment = "#"
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(caw:"]],
     \ })
endif  " }}}

call s:RegisterPlugin("Shougo/context_filetype.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("spolu/dwm.vim")  " {{{
  nnoremap <C-w>n       :call DWM_New()<Cr>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = v:false

  " For fzf.vim
  command! -nargs=1 -complete=file DWMOpen call <SID>DWMOpen(<q-args>)

  function! s:DWMOpen(filepath) abort  " {{{
    if bufexists(a:filepath)
      let winnr = bufwinnr(a:filepath)

      if winnr == -1
        call DWM_Stack(1)
        split
        execute "edit " . a:filepath
        call DWM_AutoEnter()
      else
        execute winnr . "wincmd w"
        call DWM_AutoEnter()
      endif
    else
      if bufname("%") != ""
        call DWM_New()
      endif

      execute "edit " . a:filepath
    endif
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_dwm() abort  " {{{
    " Disable DWM's default behavior on buffer loaded
    augroup dwm
      autocmd!
    augroup END
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_dwm"),
     \ })
endif  " }}}

if s:RegisterPlugin("LeafCage/foldCC", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:foldCCtext_enable_autofdc_adjuster = v:true
  let g:foldCCtext_maxchars = 120
  set foldtext=FoldCCtext()
endif  " }}}

if s:RegisterPlugin("junegunn/fzf.vim", #{ if: executable("fzf") })  " {{{
  let g:fzf_command_prefix = "Fzf"
  let g:fzf_buffers_jump   = v:true
  let g:fzf_layout         = #{ up: "~70%" }

  " See dwm.vim
  let g:fzf_action = #{ ctrl-o: "DWMOpen" }

  nnoremap <Leader><Leader>f :FzfFiles<Cr>
  nnoremap <Leader><Leader>v :FzfGFiles?<Cr>
  nnoremap <Leader><Leader>b :FzfBuffers<Cr>
  nnoremap <Leader><Leader>g :FzfGrep<Space>
  vnoremap <Leader><Leader>g "gy:FzfGrep<Space><C-r>"
  nnoremap <Leader><Leader>m :FzfMarks<Cr>
  nnoremap <Leader><Leader>h :call <SID>FzfHistory()<Cr>
  nnoremap <Leader><Leader>H :FzfHelptags<Cr>
  nnoremap <Leader><Leader>y :call <SID>FzfYankHistory()<Cr>
  noremap  <Leader><Leader>s :<C-u>call <SID>FzfMyShortcuts("")<Cr>
  noremap  <Leader><Leader>a :<C-u>call <SID>FzfMyShortcuts("'Alignta")<Cr>
  nnoremap <Leader><Leader>r :call <SID>SetupFzfRails()<Cr>:FzfRails<Space>

  " Grep  " {{{
  " https://github.com/junegunn/fzf.vim/blob/dc4c4c22715c060a2babd5a5187004bdecbcdea7/plugin/fzf.vim#L52
  command! -bang -nargs=* FzfGrep call fzf#vim#grep("rg " . s:FzfGrepOptions() . " " . shellescape(<q-args>), v:true, <bang>0)

  function! s:FzfGrepOptions() abort  " {{{
    let base = "--column --line-number --no-heading --color=always"

    if empty($RIPGREP_EXTRA_OPTIONS)
      return base
    else
      return base . " " . $RIPGREP_EXTRA_OPTIONS
    endif
  endfunction  " }}}
  " }}}

  " History  " {{{
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/plugin/fzf.vim#L64
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/plugin/fzf.vim#L73
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L520-L525
  function! s:FzfHistory() abort  " {{{
    let options = #{
      \   source:  s:FzfHistoryFiles(),
      \   options: ["--header-lines", !empty(expand("%")), "--prompt", "History> ", "--tabstop=5"],
      \ }

    " https://github.com/junegunn/fzf/blob/0896036266dc951ac03c451f1097171a996eb412/plugin/fzf.vim#L341-L348
    let wrapped = fzf#wrap("history-files", options)
    let wrapped.original_sink = remove(wrapped, "sink*")

    function! wrapped.temp_sink(args) abort  " {{{
      let key       = a:args[0]
      let items     = a:args[1:]
      let filepaths = map(copy(items), { _, item -> split(item, "\t")[1] })

      return self.original_sink([key] + filepaths)
    endfunction  " }}}

    let wrapped["sink*"] = remove(wrapped, "temp_sink")

    call fzf#run(wrapped)
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L457-L463
  function! s:FzfHistoryFiles() abort  " {{{
    let current  = empty(expand("%")) ? [] : [printf("[%%]\t%s", fnamemodify(expand("%"), ":~:."))]
    let buffers  = s:FzfHistoryBuffers()
    let oldfiles = s:FzfHistoryOldfiles()

    return s:ListUtility().uniq_by(current + buffers + oldfiles, { item -> split(item, "\t")[1] })
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L196-L198
  function! s:FzfHistoryBuffers() abort  " {{{
    let bufnrs        = filter(range(1, bufnr("$")), { _, bufnr -> buflisted(bufnr) && getbufvar(bufnr, "&filetype") != "qf" && len(bufname(bufnr)) })
    let sorted_bufnrs = sort(bufnrs, { lhs, rhs -> bufname(lhs) < bufname(rhs) ? -1 : 1 })

    return map(sorted_bufnrs, { _, bufnr -> printf("[%d]\t%s", bufnr, bufname(bufnr)) })
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L461
  function! s:FzfHistoryOldfiles() abort  " {{{
    let ignore_pattern = '\v\.git/COMMIT_EDITMSG$|\.git/addp-hunk-edit\.diff$'
    let filepaths      = filter(copy(v:oldfiles), { _, filepath -> filereadable(fnamemodify(filepath, ":p")) && filepath !~# ignore_pattern })

    return map(filepaths, { _, filepath -> printf("[h]\t%s", fnamemodify(filepath, ":~:.")) })
  endfunction  " }}}
  " }}}

  " Marks  " {{{
  nnoremap <silent> m :call <SID>IncrementalMark()<Cr>

  " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
  function! s:SetupIncrementalMark() abort  " {{{
    if has_key(s:, "incremental_mark_keys")
      return
    endif

    let s:incremental_mark_keys = [
      \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
      \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
      \ ]
    let s:incremental_mark_keys_pattern = "^[A-Z]$"

    execute "delmarks " . join(s:incremental_mark_keys, "")
  endfunction  " }}}

  function! s:IncrementalMark() abort  " {{{
    call s:SetupIncrementalMark()

    let incremental_mark_key = s:IncrementalMarkDetectKey()

    if incremental_mark_key =~# s:incremental_mark_keys_pattern
      echo "Already marked to " . incremental_mark_key
      return
    endif

    if !has_key(s:, "incremental_mark_index")
      let s:incremental_mark_index = 0
    else
      let s:incremental_mark_index = (s:incremental_mark_index + 1) % len(s:incremental_mark_keys)
    endif

    execute "mark " . s:incremental_mark_keys[s:incremental_mark_index]
    echo "Marked to " . s:incremental_mark_keys[s:incremental_mark_index]
  endfunction  " }}}

  function! s:IncrementalMarkDetectKey() abort  " {{{
    let detected_mark_key   = 0
    let current_filepath    = expand("%")
    let current_line_number = line(".")

    for mark_key in s:incremental_mark_keys
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
      endif
    endfor

    return detected_mark_key
  endfunction  " }}}
  " }}}

  " Yank History  " {{{
  " https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
  " See yankround.vim
  function! s:FzfYankHistory() abort  " {{{
    let options = #{
      \   source:  s:YankList(),
      \   sink:    function("s:YankHandler"),
      \   options: ["--no-multi", "--nth=2", "--prompt", "Yank> ", "--tabstop=1"],
      \ }

    call fzf#run(fzf#wrap("yank-history", options))
  endfunction  " }}}
  " }}}

  " My Shortcuts  " {{{
  function! s:FzfMyShortcuts(query) abort  " {{{
    let options = {
      \   "source":  s:FzfMyShortcutsList(),
      \   "sink":    function("s:FzfMyShortcutsHandler"),
      \   "options": ["--no-multi", "--prompt", "Shortcuts> ", "--query", a:query],
      \ }

    call fzf#run(fzf#wrap("my-shortcuts", options))
  endfunction  " }}}

  function! s:FzfMyShortcutsList() abort  " {{{
    call s:SetupFzfMyShortcuts()
    return s:fzf_my_shortcuts_list
  endfunction  " }}}

  function! s:FzfMyShortcutsHandler(item) abort  " {{{
    execute substitute(a:item, '\v.*--\s+`(.+)`$', '\1', "")
  endfunction  " }}}

  function! s:SetupFzfMyShortcuts() abort  " {{{
    if has_key(s:, "fzf_my_shortcuts_list")
      return
    endif

    function! s:FzfMyShortcutsDefineRawList() abort  " {{{
      " Hankaku/Zenkaku: http://nanasi.jp/articles/vim/hz_ja_vim.html
      let s:fzf_my_shortcuts_list = [
        \   ["[Hankaku/Zenkaku] All to Hankaku",           "'<,'>Hankaku"],
        \   ["[Hankaku/Zenkaku] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
        \   ["[Hankaku/Zenkaku] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
        \   ["[Hankaku/Zenkaku] All to Zenkaku",           "'<,'>Zenkaku"],
        \   ["[Hankaku/Zenkaku] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],
        \
        \   ["[Reload with Encoding] latin1",      "edit ++encoding=latin1 +set\\ noreadonly"],
        \   ["[Reload with Encoding] cp932",       "edit ++encoding=cp932 +set\\ noreadonly"],
        \   ["[Reload with Encoding] shift-jis",   "edit ++encoding=shift-jis +set\\ noreadonly"],
        \   ["[Reload with Encoding] iso-2022-jp", "edit ++encoding=iso-2022-jp +set\\ noreadonly"],
        \   ["[Reload with Encoding] euc-jp",      "edit ++encoding=euc-jp +set\\ noreadonly"],
        \   ["[Reload with Encoding] utf-8",       "edit ++encoding=utf-8 +set\\ noreadonly"],
        \
        \   ["[Reload by Sudo]", "edit sudo:%"],
        \
        \   ["[Set Encoding] latin1",      "set fileencoding=latin1"],
        \   ["[Set Encoding] cp932",       "set fileencoding=cp932"],
        \   ["[Set Encoding] shift-jis",   "set fileencoding=shift-jis"],
        \   ["[Set Encoding] iso-2022-jp", "set fileencoding=iso-2022-jp"],
        \   ["[Set Encoding] euc-jp",      "set fileencoding=euc-jp"],
        \   ["[Set Encoding] utf-8",       "set fileencoding=utf-8"],
        \
        \   ["[Set File Format] dos",  "set fileformat=dos"],
        \   ["[Set File Format] unix", "set fileformat=unix"],
        \   ["[Set File Format] mac",  "set fileformat=mac"],
        \
        \   ["[Copy] filename",          "call RemoteCopy(CurrentFilename())"],
        \   ["[Copy] relative filepath", "call RemoteCopy(CurrentRelativePath())"],
        \   ["[Copy] absolute filepath", "call RemoteCopy(CurrentAbsolutePath())"],
        \
        \   ["[Ruby Hash Syntax] Old to New", "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
        \   ["[Ruby Hash Syntax] New to Old", "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],
        \
        \   ["[Alignta] '=>'",       "'<,'>Alignta =>"],
        \   ["[Alignta] /\\S/",      "'<,'>Alignta \\S\\+"],
        \   ["[Alignta] /\\S/ once", "'<,'>Alignta \\S\\+/1"],
        \   ["[Alignta] '='",        "'<,'>Alignta =>\\="],
        \   ["[Alignta] ':hoge'",    "'<,'>Alignta 10 :"],
        \   ["[Alignta] 'hoge:'",    "'<,'>Alignta 00 [a-zA-Z0-9_\"']\\\\+:\\\\s"],
        \   ["[Alignta] '|'",        "'<,'>Alignta |"],
        \   ["[Alignta] ')'",        "'<,'>Alignta 0 )"],
        \   ["[Alignta] ']'",        "'<,'>Alignta 0 ]"],
        \   ["[Alignta] '}'",        "'<,'>Alignta }"],
        \
        \   ["[Autoformat] Format Source Codes", "Autoformat"],
        \
        \   ["[Diff] Linediff", "'<,'>Linediff"],
        \
        \   ["[QuickFix] Replace", "Qfreplace"],
        \ ]
    endfunction  " }}}

    function! s:FzfMyShortcutsCountMaxWordLength() abort  " {{{
      let s:fzf_my_shortcuts_max_word_length = max(
        \   map(
        \     copy(s:fzf_my_shortcuts_list),
        \     { _, item -> strlen(item[0]) }
        \   )
        \ )
    endfunction  " }}}

    function! s:FzfMyShortcutsMakeGroups() abort  " {{{
      function! s:FzfMyShortcutsGroupName(item) abort  " {{{
        return matchstr(a:item, '\v^\[[^]]+\]')
      endfunction  " }}}

      let prev_prefix = ""
      let new_list    = []

      for candidate in s:fzf_my_shortcuts_list
        let current_prefix = s:FzfMyShortcutsGroupName(candidate[0])

        if !empty(new_list) && current_prefix != prev_prefix
          call add(new_list, ["", ""])
        endif

        call add(new_list, candidate)
        let prev_prefix = current_prefix
      endfor

      let s:fzf_my_shortcuts_list = new_list
    endfunction  " }}}

    function! s:FzfMyShortcutsFormatList() abort  " {{{
      let s:fzf_my_shortcuts_list = map(
        \   s:fzf_my_shortcuts_list,
        \   function("s:FzfMyShortcutsFormatItem")
        \ )
    endfunction  " }}}

    function! s:FzfMyShortcutsFormatItem(_, item) abort  " {{{
      let [description, command] = a:item

      if empty(description)
        return ""
      else
        return description . s:FzfMyShortcutsWordPadding(description) . "  --  `" . command . "`"
      endif
    endfunction  " }}}

    function! s:FzfMyShortcutsWordPadding(item) abort  " {{{
      return repeat(" ", s:fzf_my_shortcuts_max_word_length - strlen(a:item))
    endfunction  " }}}

    call s:FzfMyShortcutsDefineRawList()
    call s:FzfMyShortcutsCountMaxWordLength()
    call s:FzfMyShortcutsMakeGroups()
    call s:FzfMyShortcutsFormatList()
  endfunction  " }}}
  " }}}

  " Rails  " {{{
  function! s:SetupFzfRails() abort  " {{{
    let s:fzf_rails_specs = #{
      \   assets: #{
      \     dir:      "{app/assets,app/javascripts,public}",
      \     excludes: ["-path 'public/packs*'"],
      \   },
      \   config: #{
      \     dir: "config",
      \   },
      \   initializers: #{
      \     dir: "config/initializers",
      \   },
      \   javascripts: #{
      \     dir:      "{app,public}",
      \     pattern:  '.*\.(jsx?|tsx?|vue)$',
      \     excludes: ["-path 'public/packs*'"],
      \   },
      \   lib: #{
      \     dir: "lib",
      \   },
      \   locales: #{
      \     dir: "config/locales",
      \   },
      \   public: #{
      \     dir:      "public",
      \     excludes: ["-path 'public/packs*'"],
      \   },
      \   script: #{
      \     dir: "script",
      \   },
      \   spec: #{
      \     dir: "{spec,test}",
      \   },
      \   stylesheets: #{
      \     dir:      "{app,public}",
      \     pattern:  '.*\.(sass|s?css)$',
      \     excludes: ["-path 'public/packs*'"],
      \   },
      \   test: #{
      \     dir: "{spec,test}",
      \   },
      \ }

    let s:fzf_rails_specs["db/migrates"] = #{ dir: "db/migrate" }

    if len(RubyGemPaths()) > 1
      let s:fzf_rails_specs["gems"] = #{ dir: "{" . join(RubyGemPaths(), ",") . "}/gems" }
    elseif len(RubyGemPaths()) == 1
      let s:fzf_rails_specs["gems"] = #{ dir: RubyGemPaths()[0] . "/gems" }
    endif

    for app_dir in globpath("app", "*", 0, 1)
      if isdirectory(app_dir)
        let s:fzf_rails_specs[app_dir] = #{ dir: app_dir }

        " e.g., `app/controllers` => `controllers`
        let alternative = fnamemodify(app_dir, ":t")

        if !has_key(s:fzf_rails_specs, alternative)
          let s:fzf_rails_specs[alternative] = #{ dir: app_dir }
        endif
      endif
    endfor

    for test_dir in globpath("spec,test", "*", 0, 1)
      if isdirectory(test_dir)
        let s:fzf_rails_specs[test_dir] = #{ dir: test_dir }

        " e.g., `test/fixtures` => `fixtures_test`
        let alternative = join(reverse(split(test_dir, "/")), "_")
        let s:fzf_rails_specs[alternative] = #{ dir: test_dir }
      endif
    endfor

    if has_key(g:, "fzf#rails#extra_specs")
      for name in keys(g:fzf#rails#extra_specs)
        if has_key(s:fzf_rails_specs, name)
          call extend(
             \   s:fzf_rails_specs[name],
             \   g:fzf#rails#extra_specs[name]
             \ )
        else
          let s:fzf_rails_specs[name] = g:fzf#rails#extra_specs[name]
        endif
      endfor
    endif

    if has_key(g:, "fzf#rails#specs_formatters")
      for Formatter in g:fzf#rails#specs_formatters
        call Formatter(s:fzf_rails_specs)
      endfor
    endif

    command! -nargs=1 -complete=customlist,s:FzfRailsTypeNames FzfRails call <SID>FzfRails(<q-args>)
    nnoremap <Leader><Leader>r :FzfRails<Space>
  endfunction  " }}}

  function! s:FzfRailsTypeNames(arglead, cmdline, curpos) abort  " {{{
    if !has_key(s:, "fzf_rails_type_names")
      let s:fzf_rails_type_names = sort(keys(s:fzf_rails_specs))
    endif

    if a:arglead == ""
      return s:fzf_rails_type_names
    else
      return filter(
           \   copy(s:fzf_rails_type_names),
           \   { _, name -> name =~# "^" . a:arglead }
           \ )
    endif
  endfunction  " }}}

  function! s:FzfRails(type) abort  " {{{
    let type_spec = s:fzf_rails_specs[a:type]

    if has("mac")
      let command = "find -E " . type_spec.dir
    else
      let command = "find " . type_spec.dir . " -regextype posix-egrep"
    endif

    if has_key(type_spec, "pattern")
      let command .= " \\( -regex '" . type_spec.pattern . "' \\)"
    endif

    if has_key(type_spec, "excludes")
      let excludes = join(type_spec.excludes, " -not ")
      let command .= " \\( -not " . excludes . " \\)"
    endif

    let command .= " -type f -not -name '.keep'"
    let command .= " | sort"

    let options = {
      \   "source":  command,
      \   "options": ["--prompt", "Rails/" . a:type . "> "],
      \ }

    call fzf#run(fzf#wrap("rails", options))
  endfunction  " }}}
  " }}}

  let s:fzf_commands = [
    \   "FzfFiles",
    \   "FzfGFiles",
    \   "FzfBuffers",
    \   "FzfMarks",
    \   "FzfHelptags",
    \ ]

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_cmd:  s:fzf_commands,
     \   on_func: "fzf#",
     \   depends: "fzf",
     \ })

  " Add to runtimepath (and use its Vim scripts) but don't use its binary
  " Use fzf binary already installed instead
  if s:RegisterPlugin("junegunn/fzf")  " {{{
    call s:ConfigPlugin(#{
       \   lazy: v:true,
       \ })
  endif  " }}}

  if s:RegisterPlugin("thinca/vim-qfreplace")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:   v:true,
       \   on_cmd: "Qfreplace",
       \ })
  endif  " }}}
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
     \   lazy:   v:true,
     \   on_map: [["v", "<Plug>AutoCalc"]],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_HowMuch"),
     \ })
endif  " }}}

if s:RegisterPlugin("Yggdroot/indentLine")  " {{{
  set concealcursor=nvic
  set conceallevel=2

  let g:indentLine_char            = "|"
  let g:indentLine_faster          = v:true
  let g:indentLine_concealcursor   = &concealcursor
  let g:indentLine_conceallevel    = &conceallevel
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
    \   "jquery",
    \   "react",
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
    \     ["lsp_status"],
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
    \     lsp_status: "Lightline_LSPStatus",
    \   },
    \   colorscheme: "kg8m",
    \ }

  function! Lightline_Filepath() abort  " {{{
    let filepath        = s:Lightline_Filepath()
    let readonly_symbol = s:Lightline_ReadonlySymbol()
    let modified_symbol = s:Lightline_ModifiedSymbol()

    return (readonly_symbol != "" ? readonly_symbol . " " : "") .
         \ filepath .
         \ (modified_symbol != "" ? " " . modified_symbol : "")
  endfunction  " }}}

  function! s:Lightline_Filepath() abort  " {{{
    if &filetype == "vimfiler"
      return vimfiler#get_status_string()
    endif

    if &filetype == "unite"
      return unite#get_status_string()
    endif

    let filename = CurrentFilename()

    if filename == ""
      return "[No Name]"
    else
      return winwidth(0) >= 100 ? CurrentRelativePath() : filename
    endif
  endfunction  " }}}

  function! s:Lightline_ReadonlySymbol() abort  " {{{
    return &filetype !~? 'help\|vimfiler\|gundo' && &readonly ? "X" : ""
  endfunction  " }}}

  function! s:Lightline_ModifiedSymbol() abort  " {{{
    return &filetype =~? 'help\|vimfiler\|gundo' ? "" : &modified ? "+" : &modifiable ? "" : "-"
  endfunction  " }}}

  function! Lightline_LSPStatus() abort  " {{{
    if !has_key(b:, "lsp_target_buffer")
      let b:lsp_target_buffer = v:false
      for filetype in get(s:, "lsp_filetypes", [])
        if &filetype == filetype
          let b:lsp_target_buffer = v:true
          break
        endif
      endfor
    endif

    if b:lsp_target_buffer
      if has_key(b:, "lsp_buffer_enabled")
        return "LSP: OK"
      else
        return "LSP: -"
      endif
    else
      return ""
    endif
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("AndrewRadev/linediff.vim")  " {{{
  let g:linediff_second_buffer_command = "rightbelow vertical new"

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_cmd: "Linediff",
     \ })
endif  " }}}

call s:RegisterPlugin("kg8m/moin.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("tyru/open-browser.vim")  " {{{
  map <Leader>o <Plug>(openbrowser-open)

  " `main` server configs in `.ssh/config` is required
  let g:openbrowser_browser_commands = [
    \   #{
    \     name: "ssh",
    \     args: "ssh main 'open '\\''{uri}'\\'''",
    \   }
    \ ]

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(openbrowser-open)"]],
     \ })
endif  " }}}

if s:RegisterPlugin("tyru/operator-camelize.vim")  " {{{
  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: [
     \     ["v", "<Plug>(operator-camelize)"],
     \     ["v", "<Plug>(operator-decamelize)"]
     \   ],
     \ })
endif  " }}}

if s:RegisterPlugin("mechatroner/rainbow_csv", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup my_vimrc  " {{{
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:  v:true,
     \   on_ft: "csv",
     \ })
endif  " }}}

call s:RegisterPlugin("chrisbra/Recover.vim")

if s:RegisterPlugin("vim-scripts/sequence")  " {{{
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: [["vn", "<Plug>Sequence"]],
     \ })
endif  " }}}

if s:RegisterPlugin("AndrewRadev/splitjoin.vim")  " {{{
  nnoremap <Leader>J :SplitjoinJoin<Cr>
  nnoremap <Leader>S :SplitjoinSplit<Cr>

  let g:splitjoin_split_mapping       = ""
  let g:splitjoin_join_mapping        = ""
  let g:splitjoin_ruby_trailing_comma = v:true
  let g:splitjoin_ruby_hanging_args   = v:false

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
     \ })
endif  " }}}

call s:RegisterPlugin("vim-scripts/sudo.vim")

if s:RegisterPlugin("leafgarland/typescript-vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:typescript_indent_disable = v:true
endif  " }}}

if s:RegisterPlugin("mbbill/undotree")  " {{{
  nnoremap <Leader>u :UndotreeToggle<Cr>

  let g:undotree_WindowLayout = 2
  let g:undotree_SplitWidth = 50
  let g:undotree_DiffpanelHeight = 30
  let g:undotree_SetFocusWhenToggle = v:true

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_cmd: "UndotreeToggle",
     \ })
endif  " }}}

if s:RegisterPlugin("Shougo/unite.vim")  " {{{
  let g:unite_winheight = "100%"

  augroup my_vimrc  " {{{
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

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_cmd:  "Unite",
     \   on_func: "unite#",
     \ })
endif  " }}}

if s:RegisterPlugin("h1mesuke/vim-alignta")  " {{{
  vnoremap <Leader>a :Alignta<Space>

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_cmd: "Alignta",
     \ })
endif  " }}}

if s:RegisterPlugin("FooSoft/vim-argwrap")  " {{{
  nnoremap <Leader>a :ArgWrap<Cr>

  let g:argwrap_padded_braces = "{"

  augroup my_vimrc  " {{{
    autocmd FileType eruby let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType ruby  let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType vim   let b:argwrap_tail_comma_braces = "[{" | let b:argwrap_line_prefix = '\'
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
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

if s:RegisterPlugin("h1mesuke/vim-benchmark", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: "benchmark#",
     \ })
endif  " }}}

if s:RegisterPlugin("jkramer/vim-checkbox", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup my_vimrc  " {{{
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<Cr>
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: "checkbox#",
     \ })
endif  " }}}

if s:RegisterPlugin("t9md/vim-choosewin")  " {{{
  nmap <C-w>f <Plug>(choosewin)

  let g:choosewin_overlay_enable          = v:false
  let g:choosewin_overlay_clear_multibyte = v:false
  let g:choosewin_blink_on_land           = v:false
  let g:choosewin_statusline_replace      = v:true
  let g:choosewin_tabline_replace         = v:false

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: "<Plug>(choosewin)",
     \ })
endif  " }}}

call s:RegisterPlugin("hail2u/vim-css3-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

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
  let g:EasyMotion_do_mapping       = v:false
  let g:EasyMotion_do_shade         = v:false
  let g:EasyMotion_startofline      = v:false
  let g:EasyMotion_smartcase        = v:true
  let g:EasyMotion_use_upper        = v:true
  let g:EasyMotion_keys             = "FKLASDHGUIONMREWCVTYBX,.;J"
  let g:EasyMotion_use_migemo       = v:true
  let g:EasyMotion_enter_jump_first = v:true
  let g:EasyMotion_skipfoldedline   = v:false

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: "<Plug>(easymotion-",
     \ })
endif  " }}}

call s:RegisterPlugin("thinca/vim-ft-diff_fold", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("thinca/vim-ft-help_fold")
call s:RegisterPlugin("muz/vim-gemfile", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("kana/vim-gf-user")

if s:RegisterPlugin("tpope/vim-git")  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup my_vimrc  " {{{
    autocmd FileType gitcommit let b:did_ftplugin = v:true
  augroup END  " }}}
endif  " }}}

" Use LSP for completion and going to definition
" Use ale for linting/formatting codes
" Use vim-go's highlightings, foldings, and commands/functions
if s:RegisterPlugin("fatih/vim-go")  " {{{
  let g:go_code_completion_enabled = v:false
  let g:go_fmt_autosave            = v:false
  let g:go_doc_keywordprg_enabled  = v:false
  let g:go_def_mapping_enabled     = v:false
  let g:go_gopls_enabled           = v:false

  let g:go_highlight_array_whitespace_error    = v:true
  let g:go_highlight_chan_whitespace_error     = v:true
  let g:go_highlight_extra_types               = v:true
  let g:go_highlight_space_tab_error           = v:true
  let g:go_highlight_trailing_whitespace_error = v:true
  let g:go_highlight_operators                 = v:true
  let g:go_highlight_functions                 = v:true
  let g:go_highlight_function_parameters       = v:true
  let g:go_highlight_function_calls            = v:true
  let g:go_highlight_types                     = v:true
  let g:go_highlight_fields                    = v:true
  let g:go_highlight_build_constraints         = v:true
  let g:go_highlight_generate_tags             = v:true
  let g:go_highlight_string_spellcheck         = v:true
  let g:go_highlight_format_strings            = v:true
  let g:go_highlight_variable_declarations     = v:true
  let g:go_highlight_variable_assignments      = v:true

  augroup my_vimrc  " {{{
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
     \   lazy:  v:true,
     \   on_ft: "go",
     \ })
endif  " }}}

call s:RegisterPlugin("tpope/vim-haml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

" Text object for indentation: i
call s:RegisterPlugin("michaeljsmith/vim-indent-object")

if s:RegisterPlugin("elzr/vim-json", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vim_json_syntax_conceal = v:false
endif  " }}}

if s:RegisterPlugin("rcmdnk/vim-markdown", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vim_markdown_override_foldtext         = v:false
  let g:vim_markdown_no_default_key_mappings   = v:true
  let g:vim_markdown_conceal                   = v:false
  let g:vim_markdown_no_extensions_in_markdown = v:true
  let g:vim_markdown_autowrite                 = v:true
  let g:vim_markdown_folding_level             = 10

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   depends: "vim-markdown-quote-syntax",
     \   on_ft:   "markdown",
     \ })

  if s:RegisterPlugin("joker1007/vim-markdown-quote-syntax")  " {{{
    let g:markdown_quote_syntax_filetypes = #{
      \    css:  #{ start: '\%(css\|scss\|sass\)' },
      \    haml: #{ start: "haml" },
      \    xml:  #{ start: "xml" },
      \ }

    call s:ConfigPlugin(#{
       \   lazy: v:true,
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("andymass/vim-matchup")  " {{{
  let g:matchup_matchparen_status_offscreen = v:false
endif  " }}}

if s:RegisterPlugin("kana/vim-operator-replace")  " {{{
  map r <Plug>(operator-replace)

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-replace)"]],
     \ })
endif  " }}}

if s:RegisterPlugin("rhysd/vim-operator-surround")  " {{{
  nmap <silent><Leader>sa <Plug>(operator-surround-append)aw
  vmap <silent><Leader>sa <Plug>(operator-surround-append)
  map  <silent><Leader>sd <Plug>(operator-surround-delete)a
  map  <silent><Leader>sr <Plug>(operator-surround-replace)a

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
     \   lazy:    v:true,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-surround-"]],
     \   hook_source: function("s:ConfigPluginOnSource_vim_operator_surround"),
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-operator-user")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: "operator#user#define",
     \ })
endif  " }}}

if s:RegisterPlugin("thinca/vim-prettyprint")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_cmd:  ["PrettyPrint", "PP"],
     \   on_func: ["PrettyPrint", "PP"],
     \ })
endif  " }}}

if s:RegisterPlugin("tpope/vim-rails", #{ if: OnRailsDir() && !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  call s:ConfigPlugin(#{
     \   lazy: v:false,
     \ })

  " http://fg-180.katamayu.net/archives/2006/09/02/125150
  let g:rails_level = 4

  if !has_key(g:, "rails_projections")
    let g:rails_projections = {}
  endif

  let g:rails_projections["script/*.rb"] = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["script/*"]    = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["test/script/*_test.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }
  let g:rails_projections["spec/script/*_spec.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }

  if !has_key(g:, "rails_path_additions")
    let g:rails_path_additions = []
  endif

  let g:rails_path_additions += [
    \   "spec/support",
    \ ]
endif  " }}}

call s:RegisterPlugin("tpope/vim-repeat")

if s:RegisterPlugin("vim-ruby/vim-ruby", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup my_vimrc  " {{{
    " vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile set filetype=Gemfile

    " Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby if has_key(b:, "ruby_no_expensive") | unlet b:ruby_no_expensive | endif
  augroup END  " }}}

  let g:no_ruby_maps = v:true

  call s:ConfigPlugin(#{
     \   lazy: v:false,
     \ })
endif  " }}}

if s:RegisterPlugin("joker1007/vim-ruby-heredoc-syntax", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  " Default: JS, SQL, HTML
  let g:ruby_heredoc_syntax_filetypes = #{
    \   haml: #{ start: "HAML" },
    \   ruby: #{ start: "RUBY" },
    \ }

  call s:ConfigPlugin(#{
     \   lazy:  v:true,
     \   on_ft: "ruby",
     \ })
endif  " }}}

" See also vim-startify's settings
if s:RegisterPlugin("xolox/vim-session", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:session_directory         = getcwd() . "/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = v:false

  set sessionoptions=buffers,folds

  augroup my_vimrc  " {{{
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
     \   lazy:    v:true,
     \   on_cmd:  "SaveSession",
     \   depends: "vim-misc",
     \ })

  if s:RegisterPlugin("xolox/vim-misc")  " {{{
    call s:ConfigPlugin(#{
       \   lazy: v:true,
       \ })
  endif  " }}}
endif  " }}}

" See vim-session's settings
if s:RegisterPlugin("mhinz/vim-startify", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  function! s:ConfigPluginOnSource_vim_startify() abort  " {{{
    let g:startify_session_dir         = g:session_directory
    let g:startify_session_persistence = v:false
    let g:startify_session_sort        = v:true

    let g:startify_enable_special = v:true
    let g:startify_change_to_dir  = v:false
    let g:startify_relative_path  = v:true
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
     \   lazy:     v:true,
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

  let g:test#preserve_screen = v:true

  let g:test#go#gotest#options = "-race"
  let g:test#ruby#bundle_exec = v:false

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_cmd: ["TestFile", "TestNearest"],
     \ })
endif  " }}}

" Text object for quotations: q
if s:RegisterPlugin("deris/vim-textobj-enclosedsyntax")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_ft:   ["ruby", "eruby"],
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

" Text object fo last search pattern: /
if s:RegisterPlugin("kana/vim-textobj-lastpat")  " {{{
  call s:ConfigPlugin(#{
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

" Text object for Ruby blocks (not only `do-end` nor `{}`): r
if s:RegisterPlugin("rhysd/vim-textobj-ruby")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_ft:   "ruby",
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

if s:RegisterPlugin("kana/vim-textobj-user")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: "textobj#user",
     \ })
endif  " }}}

call s:RegisterPlugin("tmux-plugins/vim-tmux", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("cespare/vim-toml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("posva/vim-vue", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("thinca/vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup my_vimrc  " {{{
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if s:RegisterPlugin("Shougo/vimfiler", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  let g:vimfiler_ignore_pattern = ['^\.git$', '^\.DS_Store$']

  nnoremap <Leader>e :VimFilerBufferDir -force-quit<Cr>

  function! s:ConfigPluginOnSource_vimfiler() abort  " {{{
    call vimfiler#custom#profile("default", "context", #{
       \   safe: v:false,
       \   split_action: "dwm_open",
       \ })
  endfunction  " }}}

  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   on_func: "VimFilerBufferDir",
     \   hook_source: function("s:ConfigPluginOnSource_vimfiler"),
     \ })

  if s:RegisterPlugin("kg8m/unite-dwm")  " {{{
    call s:ConfigPlugin(#{
       \   lazy:  v:true,
       \   on_ft: "vimfiler",
       \ })
  endif  " }}}
endif  " }}}

if s:RegisterPlugin("Shougo/vimproc")  " {{{
  call s:ConfigPlugin(#{
     \   lazy:    v:true,
     \   build:   "make",
     \   on_func: "vimproc#",
     \ })
endif  " }}}

if s:RegisterPlugin("benmills/vimux", #{ if: OnTmux() && !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  function! s:ConfigPluginOnSource_vimux() abort  " {{{
    let g:VimuxHeight     = 30
    let g:VimuxUseNearest = v:true

    augroup my_vimrc  " {{{
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
    " Don't assign by `let func = << trim VIM`, that doesn't work
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
     \   lazy:    v:true,
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
    if !has_key(s:, "__Promise__")
      let s:__Promise__ = vital#vital#import("Async.Promise")
    endif

    return s:__Promise__
  endfunction  " }}}

  function! s:ListUtility() abort  " {{{
    if !has_key(s:, "__ListUtility__")
      let s:__ListUtility__ = vital#vital#import("Data.List")
    endif

    return s:__ListUtility__
  endfunction  " }}}

  function! s:StringUtility() abort  " {{{
    if !has_key(s:, "__StringUtility__")
      let s:__StringUtility__ = vital#vital#import("Data.String")
    endif

    return s:__StringUtility__
  endfunction  " }}}
endif  " }}}

if s:RegisterPlugin("simeji/winresizer")  " {{{
  let g:winresizer_start_key = "<C-w><C-e>"

  call s:ConfigPlugin(#{
     \   lazy:   v:true,
     \   on_map: [["n", g:winresizer_start_key]],
     \ })
endif  " }}}

call s:RegisterPlugin("stephpy/vim-yaml", #{ if: !IsGitCommit() && !IsGitHunkEdit() })
call s:RegisterPlugin("pedrohdz/vim-yaml-folds", #{ if: !IsGitCommit() && !IsGitHunkEdit() })

if s:RegisterPlugin("othree/yajs.vim", #{ if: !IsGitCommit() && !IsGitHunkEdit() })  " {{{
  augroup my_vimrc  " {{{
    autocmd FileType javascript setlocal foldmethod=syntax
  augroup END  " }}}

  call s:ConfigPlugin(#{
     \   lazy:  v:true,
     \   on_ft: "javascript",
     \ })
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
  let g:molokai_original = v:true

  augroup my_vimrc  " {{{
    autocmd ColorScheme molokai call s:OverwriteMolokai()
  augroup END  " }}}

  function! s:OverwriteMolokai() abort  " {{{
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

      highlight QuickFixLine                             gui=bold
    else
      highlight Normal                    ctermbg=NONE
      highlight DiffAdd                   ctermbg=23
      highlight DiffChange   ctermfg=NONE ctermbg=234
      highlight DiffFile     ctermfg=118               cterm=bold
      highlight DiffText                  ctermbg=240  cterm=bold
      highlight FoldColumn   ctermfg=67   ctermbg=NONE
      highlight Folded       ctermfg=67   ctermbg=NONE
      highlight IncSearch    ctermfg=255  ctermbg=161
      highlight Search       ctermfg=255  ctermbg=161
      highlight Underlined   ctermfg=247               cterm=underline
      highlight VisualNOS                 ctermbg=238  cterm=bold
      highlight Visual                    ctermbg=235  cterm=bold
      highlight Comment      ctermfg=247
      highlight CursorColumn              ctermbg=237
      highlight ColorColumn               ctermbg=237
      highlight LineNr       ctermfg=250  ctermbg=234

      highlight QuickFixLine                           cterm=bold
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

" Blur inactive windows
" https://qiita.com/Bakudankun/items/649aa6d8b9eccc1712b5
augroup my_vimrc  " {{{
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
set completeopt=menu,menuone,popup,noinsert,noselect
set pumheight=20

set cursorline
set cursorlineopt=number
augroup my_vimrc  " {{{
  autocmd FileType qf set cursorlineopt=both
augroup END  " }}}

" Cursor shapes
let &t_SI = "\e[6 q"  " vertical line
let &t_EI = "\e[2 q"  " vertical bold line

" https://teratail.com/questions/24046
augroup my_vimrc  " {{{
  autocmd Syntax * if line("$") > 10000 | syntax sync minlines=10000 | endif
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
  augroup my_vimrc  " {{{
    autocmd FileType neosnippet set noexpandtab
    autocmd FileType text,markdown,moin setlocal cinkeys-=:

    " Lazily set formatoptions to overwrite others
    autocmd FileType * call timer_start(300, { -> s:SetupFormatoptions() })

    autocmd BufWritePre * if &filetype ==# "" || has_key(b:, "ftdetect") | unlet! b:ftdetect | filetype detect | endif
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
  noremap z[ [z
  noremap z] ]z

  set foldmethod=marker
  set foldopen=hor
  set foldminlines=1
  set foldcolumn=3
  set fillchars=vert:\|

  augroup my_vimrc  " {{{
    autocmd FileType neosnippet setlocal foldmethod=marker
    autocmd FileType vim        setlocal foldmethod=marker
    autocmd FileType haml       setlocal foldmethod=indent
    autocmd FileType gitcommit,qfreplace setlocal nofoldenable

    " http://d.hatena.ne.jp/gnarl/20120308/1331180615
    autocmd InsertEnter * call s:SwitchToManualFolding()
  augroup END  " }}}

  function! s:SwitchToManualFolding() abort  " {{{
    if !has_key(w:, "last_fdm")
      let w:last_fdm = &foldmethod
      setlocal foldmethod=manual
    endif
  endfunction  " }}}

  " Call this before saving session
  function! s:RestoreFoldmethod() abort  " {{{
    if has_key(w:, "last_fdm")
      let &foldmethod = w:last_fdm
      unlet w:last_fdm
    endif
  endfunction  " }}}
  " }}}
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

nnoremap <Leader>/ :nohlsearch<Cr>

" Enable very magic
nnoremap / /\v
" }}}

" ----------------------------------------------
" Controls  " {{{
" ' => Maximum number of previously edited files for which the marks are remembered.
" < => Maximum number of lines saved for each register.
" h => Disable the effect of 'hlsearch' when loading the viminfo file.
" s => Maximum size of an item in Kbyte.
set viminfo='10000,<100,h,s10

set restorescreen
set mouse=
set belloff=all
set nostartofline

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
  augroup my_vimrc  " {{{
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
    call timer_start(300, { -> s:CreateCtags(a:directory) })
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

" See also vim-lsp settings
" g<C-]>: Jump to a tag by `:tjump`
" <C-o>:  Jump back
noremap  g] g<C-]>
nnoremap g[ <C-o>
" }}}

" Auto reload
augroup my_vimrc  " {{{
  autocmd InsertEnter,InsertLeave,CursorHold,WinEnter,BufWinEnter * silent! checktime
augroup END  " }}}

set whichwrap=b,s,h,l,<,>,[,],~
set maxmempattern=5000

if !IsGitCommit() && !IsGitHunkEdit()  " {{{
  " http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
  augroup my_vimrc  " {{{
    autocmd BufWriteCmd *[,*] call s:WriteCheckTypo(expand("<afile>"))
  augroup END  " }}}

  function! s:WriteCheckTypo(file) abort  " {{{
    let writecmd = "write" . (v:cmdbang ? "!" : "") . " " . a:file

    if a:file =~? "[qfreplace]"
      return
    endif

    let prompt = "possible typo: really want to write to '" . a:file . "'?(y/n):"
    let input = input(prompt)

    if input =~? '^y'
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
nnoremap <Leader>v :vsplit<Cr>
nnoremap <Leader>h :split<Cr>

vnoremap <Leader>y "yy:call RemoteCopy(@")<Cr>

" Open help for current word
" See `:help K`
noremap <S-h> <S-k>

function! s:RemoveTrailingWhitespaces() abort  " {{{
  let position = getpos(".")
  keeppatterns '<,'>s/\s\+$//ge
  call setpos(".", position)
endfunction  " }}}
vnoremap <Leader>w :call <SID>RemoveTrailingWhitespaces()<Cr>

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
augroup my_vimrc  " {{{
  autocmd FileType markdown inoremap <buffer> <C-]> [<Space>]<Space>
augroup END  " }}}
" }}}

" ----------------------------------------------
" GUI settings  " {{{
if has("gui_running")
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

  augroup my_vimrc  " {{{
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
