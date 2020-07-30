" Profile  " {{{
" 1. Enable following profile commands (`profile start ...`)
" 2. Do something you are concerned with
" 3. Disable and finish profiling by `:profile pause | noautocmd qall!`
" 4. Check ~/tmp/vim-profile.log

" profile start ~/tmp/vim-profile.log
" profile func *
" profile file *
" }}}

" ----------------------------------------------
" Initialize  " {{{
" Set initial variables/options  " {{{
let s:vim_root_path   = expand($HOME . "/.vim")
let s:plugins_path    = expand(s:vim_root_path . "/plugins")
let s:my_utility_path = expand(s:plugins_path . "/repos/github.com/kg8m/.vim")

if !isdirectory(s:my_utility_path)
  echo "Downloading my utility repository..."
  call system("git clone https://github.com/kg8m/.vim " . s:my_utility_path)
endif

let &runtimepath .= "," . s:my_utility_path

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

" https://github.com/rhysd/dogfiles/blob/af9e4947a3d99ee47a53ab297c2e1442a30856b4/vimrc#L18-L22
function! s:get_SID() abort
  return matchstr(expand("<sfile>"), '<SNR>\d\+_\zeget_SID$')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID
" }}}

" Reset my autocommands
augroup my_vimrc  " {{{
  autocmd!
augroup END  " }}}
" }}}

" ----------------------------------------------
" Plugins  " {{{
" Initialize plugin manager  " {{{
call kg8m#plugin#init_manager(s:plugins_path)
" }}}

" Plugins list and settings  " {{{
call kg8m#plugin#register(s:my_utility_path)

" Completion, LSP  " {{{
if kg8m#plugin#register("prabirshrestha/asyncomplete.vim")  " {{{
  let g:asyncomplete_auto_popup = v:true
  let g:asyncomplete_popup_delay = 50
  let g:asyncomplete_auto_completeopt = v:false
  let g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  " Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  function! s:AsyncompletePrioritySortedFuzzyFilter(options, matches) abort  " {{{
    let sorted_items = []
    let startcols    = []

    let match_pattern = s:CompletionRefreshPattern(get(b:, "lsp_buffer_enabled", v:false) ? &filetype : "_")
    let base_matcher  = matchstr(a:options.base, match_pattern)

    " Special thanks: mattn
    let fuzzy_matcher = join(map(split(base_matcher, '\zs'), "printf('[\\x%02x].*', char2nr(v:val))"), '')

    let sorter_context = #{
      \   matcher:  base_matcher,
      \   priority: 0,
      \   cache:    {},
      \ }

    for [source_name, source_matches] in items(a:matches)
      if empty(base_matcher)
        let sorted_items += source_matches.items
      else
        let original_length = len(sorted_items)

        " Language server sources have no priority
        let sorter_context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

        for item in source_matches.items
          if item.word =~? fuzzy_matcher
            let item.priority = s:AsyncompleteItemPriority(item, sorter_context)
            let sorted_items += [item]
          endif
        endfor

        if len(sorted_items) !=# original_length
          let startcols += [source_matches.startcol]
        endif
      endif
    endfor

    if !empty(base_matcher)
      call sort(sorted_items, { lhs, rhs -> lhs.priority - rhs.priority })
    endif

    " https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
    let a:options["startcol"] = min(startcols)

    call asyncomplete#preprocess_complete(a:options, sorted_items)
  endfunction  " }}}

  function! s:AsyncompleteItemPriority(item, context) abort  " {{{
    let word = a:item.word

    if !has_key(a:context.cache, word)
      if word =~? "^" . a:context.matcher
        let a:context.cache[word] = 2
      elseif word =~? a:context.matcher
        let a:context.cache[word] = 3
      else
        let a:context.cache[word] = 5
      endif
    endif

    return a:context.cache[word] * a:context.priority
  endfunction  " }}}
  let g:asyncomplete_preprocessor = [function("s:AsyncompletePrioritySortedFuzzyFilter")]

  " Refresh completion  " {{{
  function! s:DefineRefreshCompletionMappings() abort  " {{{
    inoremap <silent> <expr> <BS> "\<BS>" . <SID>RefreshCompletion()
    inoremap <silent> <expr> .    "."     . <SID>RefreshCompletion()
  endfunction  " }}}

  function! s:RefreshCompletion() abort  " {{{
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
    call timer_start(0, { -> s:DefineRefreshCompletionMappings() })

    if get(b:, "asyncomplete_enable", v:true)
      call asyncomplete#enable_for_buffer()
    endif
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy: v:true,
     \   on_i: v:true,
     \   hook_post_source: function("s:ConfigPluginOnPostSource_asyncomplete"),
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-buffer.vim")  " {{{
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
       \   name: "asyncomplete_source_buffer",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#buffer#completor"),
       \   events: s:asyncomplete_buffer_events,
       \   on_event: function("s:AsyncompleteBufferOnEventAsync"),
       \   priority: 2,
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
        call kg8m#util#echo_error_msg("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
      endfunction
      let s:AsyncompleteBufferRefreshKeywords = function("AsyncompleteBufferCannotRefreshKeywords")
    endif
  endfunction  " }}}

  function! s:ActivateAsyncompleteBuffer() abort  " {{{
    " Trigger one of the s:asyncomplete_buffer_events
    " Don't use `TextChangedI` or `TextChangedP` because they cause asyncomplete.vim's error about previous_position
    doautocmd TextChanged
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-file.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteFile()
  augroup END  " }}}

  function! s:SetupAsyncompleteFile() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
       \   name: "asyncomplete_source_file",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#file#completor"),
       \   priority: 3,
       \ }))
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-neosnippet.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteNeosnippet()
  augroup END  " }}}

  function! s:SetupAsyncompleteNeosnippet() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options(#{
       \   name: "asyncomplete_source_neosnippet",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#neosnippet#completor"),
       \   priority: 1,
       \ }))
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("high-moctane/asyncomplete-nextword.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteNextword()
  augroup END  " }}}

  function! s:SetupAsyncompleteNextword() abort  " {{{
    " Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
    call asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options(#{
       \   name: "asyncomplete_source_nextword",
       \   allowlist: ["*"],
       \   args: ["-n", "10000"],
       \   completor: function("asyncomplete#sources#nextword#completor"),
       \   priority: 3,
       \ }))
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   depends:   "async.vim",
     \   on_source: "asyncomplete.vim",
     \ })

  if kg8m#plugin#register("prabirshrestha/async.vim")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy: v:true,
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-tags.vim")  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:SetupAsyncompleteTags()
  augroup END  " }}}

  function! s:SetupAsyncompleteTags() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options(#{
       \   name: "asyncomplete_source_tags",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#tags#completor"),
       \   priority: 3,
       \ }))
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-lsp.vim")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("Shougo/neosnippet")  " {{{
  function! s:ConfigPluginOnSource_neosnippet() abort  " {{{
    call s:DefineCompletionMappings()

    let g:neosnippet#snippets_directory = [
      \   kg8m#plugin#get_info(".vim").path . "/snippets",
      \ ]
    let g:neosnippet#disable_runtime_snippets = #{
      \   _: v:true,
      \ }

    augroup my_vimrc  " {{{
      autocmd InsertLeave * NeoSnippetClearMarkers
    augroup END  " }}}

    function! s:SetupNeosnippetContextual() abort  " {{{
      let dir = kg8m#plugin#get_info(".vim").path . "/snippets/"
      let g:neosnippet_contextual#contexts = get(g:, "neosnippet_contextual#contexts", {})

      if !has_key(g:neosnippet_contextual#contexts, "ruby")
        let g:neosnippet_contextual#contexts.ruby = []
      endif

      if kg8m#util#on_rails_dir()
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
        let filepath = kg8m#util#current_relative_path()

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
  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_ft:     ["snippet", "neosnippet"],
     \   on_func:   "neosnippet#",
     \   on_source: "asyncomplete.vim",
     \   depends:   ".vim",
     \   hook_source:      function("s:ConfigPluginOnSource_neosnippet"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_neosnippet"),
     \ })
endif  " }}}

if kg8m#plugin#register("kg8m/vim-lsp")  " {{{
  let g:lsp_diagnostics_enabled          = v:true
  let g:lsp_diagnostics_echo_cursor      = v:false
  let g:lsp_diagnostics_float_cursor     = v:true
  let g:lsp_signs_enabled                = v:true
  let g:lsp_highlight_references_enabled = v:true
  let g:lsp_fold_enabled                 = v:false

  let g:lsp_async_completion = v:true

  let g:lsp_log_verbose = v:true
  let g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc  " {{{
    autocmd User lsp_setup          call kg8m#plugin#lsp#enable()
    autocmd User lsp_buffer_enabled call s:OnLSPBufferEnabled()

    autocmd FileType * call s:ResetLSPTargetBuffer()

    autocmd User lsp_definition_failed FzfTjump
  augroup END  " }}}

  function! s:OnLSPBufferEnabled() abort  " {{{
    let b:asyncomplete_refresh_pattern = s:CompletionRefreshPattern(&filetype)
    setlocal omnifunc=lsp#complete
    nmap <buffer> g] <Plug>(lsp-definition)
    nmap <buffer> <S-h> <Plug>(lsp-hover)

    let b:lsp_buffer_enabled = v:true
  endfunction  " }}}

  function! s:IsLSPTargetBuffer() abort  " {{{
    if !has_key(b:, "lsp_target_buffer")
      let b:lsp_target_buffer = v:false
      for filetype in kg8m#plugin#lsp#get_filetypes()
        if &filetype ==# filetype
          let b:lsp_target_buffer = v:true
          break
        endif
      endfor
    endif

    return b:lsp_target_buffer
  endfunction  " }}}

  function! s:ResetLSPTargetBuffer() abort  " {{{
    if has_key(b:, "lsp_target_buffer")
      unlet b:lsp_target_buffer
    endif
  endfunction  " }}}

  function! s:LSPSchemasJson() abort  " {{{
    if !has_key(s:, "lsp_schemas_json")
      let s:lsp_schemas_json = json_decode(join(readfile(kg8m#plugin#get_info("vim-lsp-settings").path . "/data/catalog.json"), "\n"))["schemas"]
    endif

    return s:lsp_schemas_json
  endfunction  " }}}

  " Register LSPs  " {{{
  " yarn add bash-language-server  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "bash-language-server",
     \   cmd: { server_info -> ["bash-language-server", "start"] },
     \   allowlist: ["sh", "zsh"],
     \ })
  " }}}

  " yarn add vscode-css-languageserver-bin  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "css-languageserver",
     \   cmd: { server_info -> ["css-languageserver", "--stdio"] },
     \   allowlist: ["css", "less", "scss"],
     \   config: { -> #{ refresh_pattern: s:CompletionRefreshPattern("css") } },
     \   workspace_config: #{
     \     css:  #{ lint: #{ validProperties: [] } },
     \     less: #{ lint: #{ validProperties: [] } },
     \     scss: #{ lint: #{ validProperties: [] } },
     \   },
     \ })
  " }}}

  " go get github.com/mattn/efm-langserver  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "efm-langserver",
     \   cmd: { server_info -> ["efm-langserver"] },
     \   allowlist: [
     \     "eruby", "json", "make", "markdown", "vim",
     \     "eruby.yaml", "yaml",
     \     "sh", "zsh",
     \   ],
     \ })
  " }}}

  " go get github.com/nametake/golangci-lint-langserver  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "golangci-lint-langserver",
     \   cmd: { server_info -> ["golangci-lint-langserver"] },
     \   initialization_options: #{
     \     command: ["golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"],
     \   },
     \   allowlist: ["go"],
     \ })
  " }}}

  " go get golang.org/x/tools/gopls  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "gopls",
     \   cmd: { server_info -> ["gopls", "-mode", "stdio"] },
     \   initialization_options: #{
     \     analyses: #{
     \       fillstruct: v:true,
     \     },
     \     completeUnimported: v:true,
     \     completionDocumentation: v:true,
     \     deepCompletion: v:true,
     \     hoverKind: "SynopsisDocumentation",
     \     matcher: "fuzzy",
     \     staticcheck: v:true,
     \     usePlaceholders: v:true,
     \   },
     \   allowlist: ["go"],
     \ })
  " }}}

  " yarn add vscode-html-languageserver-bin  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "html-languageserver",
     \   cmd: { server_info -> ["html-languageserver", "--stdio"] },
     \   initialization_options: #{ embeddedLanguages: #{ css: v:true, javascript: v:true } },
     \   allowlist: ["html"],
     \   config: { -> #{ refresh_pattern: s:CompletionRefreshPattern("html") } },
     \ })
  " }}}

  " yarn add vscode-json-languageserver-bin  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "json-languageserver",
     \   cmd: { server_info -> ["json-languageserver", "--stdio"] },
     \   allowlist: ["json"],
     \   config: { -> #{ refresh_pattern: s:CompletionRefreshPattern("json") } },
     \   workspace_config: { -> #{
     \     json: #{
     \       format: #{ enable: v:true },
     \       schemas: s:LSPSchemasJson(),
     \    },
     \   } },
     \ })
  " }}}

  " gem install solargraph  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "solargraph",
     \   cmd: { server_info -> ["solargraph", "stdio"] },
     \   initialization_options: #{ diagnostics: "true" },
     \   allowlist: ["ruby"],
     \ })
  " }}}

  " go get github.com/lighttiger2505/sqls  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "sqls",
     \   cmd: { server_info -> ["sqls"] },
     \   allowlist: ["sql"],
     \   workspace_config: { -> #{
     \     sqls: #{
     \       connections: get(g:, "sqls_connections", []),
     \     },
     \   } },
     \ })
  " }}}

  " yarn add typescript-language-server typescript  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "typescript-language-server",
     \   cmd: { server_info -> ["typescript-language-server", "--stdio"] },
     \   initialization_options: #{ diagnostics: "true" },
     \   allowlist: ["typescript", "javascript", "typescriptreact", "javascriptreact", "typescript.tsx", "javascript.jsx"],
     \ })
  " }}}

  " yarn add vim-language-server  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "vim-language-server",
     \   cmd: { server_info -> ["vim-language-server", "--stdio"] },
     \   initialization_options: { -> #{ vimruntime: $VIMRUNTIME, runtimepath: &runtimepath } },
     \   root_uri: { server_info -> lsp#utils#path_to_uri($HOME) },
     \   allowlist: ["vim"],
     \ })
  " }}}

  " yarn add vue-language-server  " {{{
  " cf. https://github.com/sublimelsp/LSP-vue/blob/master/LSP-vue.sublime-settings
  call kg8m#plugin#lsp#register(#{
     \   name: "vue-language-server",
     \   cmd: { server_info -> ["vls"] },
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
     \   allowlist: ["vue"],
     \   executable_name: "vls",
     \ })
  " }}}

  " yarn add yaml-language-server  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "yaml-language-server",
     \   cmd: { server_info -> ["yaml-language-server", "--stdio"] },
     \   allowlist: ["eruby.yaml", "yaml"],
     \   workspace_config: #{
     \     yaml: #{
     \       completion: v:true,
     \       customTags: [],
     \       format: #{ enable: v:true },
     \       hover: v:true,
     \       schemas: {},
     \       schemaStore: #{ enable: v:true },
     \       validate: v:true,
     \     },
     \   },
     \ })
  " }}}
  " }}}

  function! s:ConfigPluginOnPostSource_lsp() abort  " {{{
    " https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
    call lsp#enable()
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_ft:   kg8m#plugin#lsp#get_filetypes(),
     \   depends: "asyncomplete.vim",
     \   hook_post_source: function("s:ConfigPluginOnPostSource_lsp"),
     \ })

  call kg8m#plugin#register("mattn/vim-lsp-settings", #{ if: v:false })
  call kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", #{ if: v:false })
endif  " }}}

if kg8m#plugin#register("thomasfaingnaert/vim-lsp-snippets")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "vim-lsp",
     \ })

  if kg8m#plugin#register("thomasfaingnaert/vim-lsp-neosnippet")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy:      v:true,
       \   on_source: "vim-lsp-snippets",
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("hrsh7th/vim-vsnip")  " {{{
  function! s:ConfigPluginOnSource_vim_vsnip() abort  " {{{
    call s:DefineCompletionMappings()
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_func:   "vsnip#",
     \   on_source: "vim-lsp",
     \   hook_source: function("s:ConfigPluginOnSource_vim_vsnip"),
     \ })

  if kg8m#plugin#register("hrsh7th/vim-vsnip-integ")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy:      v:true,
       \   on_source: "vim-vsnip",
       \ })
  endif  " }}}
endif  " }}}

function! s:CompletionRefreshPattern(filetype) abort  " {{{
  if !has_key(s:, "completion_refresh_patterns")
    let css_pattern = '\v([#a-zA-Z0-9_-]+)$'
    let s:completion_refresh_patterns = #{
      \   _:    '\v(\k+)$',
      \   css:  css_pattern,
      \   html: '\v(/|\k+)$',
      \   json: '\v("\k*|\[|\k+)$',
      \   less: css_pattern,
      \   ruby: '\v(\@?\@\k*|(:)@<!:\k*|\k+)$',
      \   sass: css_pattern,
      \   scss: css_pattern,
      \   sh:  '\v([a-zA-Z0-9_-]+|\k+)$',
      \   sql: '\v( \zs\k*|[a-zA-Z0-9_-]+)$',
      \   vue: '\v([a-zA-Z0-9_-]+|/|\k+)$',
      \ }
  endif

  return get(s:completion_refresh_patterns, a:filetype, s:completion_refresh_patterns["_"])
endfunction  " }}}

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

if kg8m#plugin#register("dense-analysis/ale", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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
    \   vim:        ["vint"],
    \ }
  let g:ale_fixers = #{
    \   go:         ["goimports"],
    \   javascript: ["eslint"],
    \   ruby:       ["rubocop"],
    \   typescript: ["eslint"],
    \ }

  augroup my_vimrc  " {{{
    autocmd FileType go                    let b:ale_fix_on_save = v:true
    autocmd FileType javascript,typescript let b:ale_fix_on_save = !!$VIM_FIX_ON_SAVE_JS
    autocmd FileType ruby                  let b:ale_fix_on_save = !!$VIM_FIX_ON_SAVE_RUBY

    autocmd FileType markdown let b:ale_enabled = v:false
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

call kg8m#plugin#register("pearofducks/ansible-vim", #{ if: !kg8m#util#is_git_tmp_edit() })

" Show diff in Git's interactive rebase
call kg8m#plugin#register("hotwatermorning/auto-git-diff", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("vim-scripts/autodate.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%(' .
                              \   '\%(Last \?\%(Change\|Modified\)\)\|' .
                              \   '\%(最終更新日\?\)\|' .
                              \   '\%(更新日\)' .
                              \ '\):'
  let g:autodate_keyword_post = '\.$'
endif  " }}}

if kg8m#plugin#register("tyru/caw.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  map gc <Plug>(caw:hatpos:toggle)

  let g:caw_no_default_keymappings = v:true
  let g:caw_hatpos_skip_blank_line = v:true

  augroup my_vimrc  " {{{
    autocmd FileType Gemfile let b:caw_oneline_comment = "#"
  augroup END  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(caw:"]],
     \ })
endif  " }}}

if kg8m#plugin#register("Shougo/context_filetype.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  " For caw.vim and so on
  let g:context_filetype#filetypes = #{
    \   javascript: [
    \     #{ start: '\<html`$', end: '^\s*`', filetype: 'html' },
    \     #{ start: '\<css`$', end: '^\s*`', filetype: 'css' },
    \   ],
    \ }
endif  " }}}

if kg8m#plugin#register("spolu/dwm.vim")  " {{{
  nnoremap <C-w>n       :call DWM_New()<Cr>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = v:false

  " For fzf.vim
  command! -nargs=1 -complete=file DWMOpen call <SID>DWMOpen(<q-args>)

  function! s:DWMOpen(filepath) abort  " {{{
    if bufexists(a:filepath)
      let winnr = bufwinnr(a:filepath)

      if winnr ==# -1
        call DWM_Stack(1)
        split
        execute "edit " . a:filepath
        call DWM_AutoEnter()
      else
        execute winnr . "wincmd w"
        call DWM_AutoEnter()
      endif
    else
      if bufname("%") !=# ""
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

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_dwm"),
     \ })
endif  " }}}

if kg8m#plugin#register("junegunn/fzf.vim", #{ if: executable("fzf") })  " {{{
  let g:fzf_command_prefix = "Fzf"
  let g:fzf_buffers_jump   = v:true
  let g:fzf_layout         = #{ up: "~90%" }

  " See dwm.vim
  let g:fzf_action = #{ ctrl-o: "DWMOpen" }

  " See also vim-fzf-tjump's mappings
  nnoremap <Leader><Leader>f :FzfFiles<Cr>
  nnoremap <Leader><Leader>v :call <SID>FzfGitFiles()<Cr>
  nnoremap <Leader><Leader>b :call <SID>FzfBuffers()<Cr>
  nnoremap <Leader><Leader>l :FzfLines<Cr>
  nnoremap <Leader><Leader>g :FzfGrep<Space>
  nnoremap <Leader><Leader>G :FzfGrepForDir<Space>
  vnoremap <Leader><Leader>g "gy:FzfGrep<Space><C-r>"
  vnoremap <Leader><Leader>G "gy:FzfGrepForDir<Space><C-r>"
  nnoremap <Leader><Leader>m :FzfMarks<Cr>
  nnoremap <Leader><Leader>h :call <SID>FzfHistory()<Cr>
  nnoremap <Leader><Leader>H :FzfHelptags<Cr>
  nnoremap <Leader><Leader>y :call <SID>FzfYankHistory()<Cr>
  noremap  <Leader><Leader>s :<C-u>call <SID>FzfMyShortcuts("")<Cr>
  noremap  <Leader><Leader>a :<C-u>call <SID>FzfMyShortcuts("'Alignta ")<Cr>
  nnoremap <Leader><Leader>r :call <SID>SetupFzfRails()<Cr>:FzfRails<Space>

  augroup my_vimrc  " {{{
    autocmd FileType fzf call s:SetupFzfWindow()
  augroup END  " }}}

  function! s:SetupFzfWindow() abort  " {{{
    " Temporarily increase window height
    set winheight=999
    set winheight=1
    redraw
  endfunction  " }}}

  " Git Files: Show preview of dirty files (Fzf's `:GFiles?` doesn't show preview)  " {{{
  function! s:FzfGitFiles() abort  " {{{
    call fzf#vim#gitfiles("?", #{
       \   options: [
       \     "--preview", "git diff-or-cat {2}",
       \     "--preview-window", "right:wrap",
       \   ],
       \ })
  endfunction  " }}}
  " }}}

  " Buffers: Sort buffers in dictionary order (Fzf's `:Buffers` doesn't sort them)  " {{{
  " Also see History configs
  function! s:FzfBuffers() abort  " {{{
    let options = #{
      \   source:  s:FzfBuffersFiles(),
      \   options: [
      \     "--header-lines", !empty(expand("%")),
      \     "--prompt", "Buffers> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:wrap",
      \   ],
      \ }

    call fzf#run(fzf#wrap("buffer-files", options))
  endfunction  " }}}

  function! s:FzfBuffersFiles() abort  " {{{
    let current = empty(expand("%")) ? [] : [fnamemodify(expand("%"), s:FzfHistoryFilepathFormat())]
    let buffers = s:FzfBuffersList()

    return kg8m#util#list_module().uniq(current + buffers)
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L196-L198
  function! s:FzfBuffersList() abort  " {{{
    let bufnrs = filter(range(1, bufnr("$")), { _, bufnr -> buflisted(bufnr) && getbufvar(bufnr, "&filetype") !=# "qf" && len(bufname(bufnr)) })
    return sort(map(bufnrs, { _, bufnr -> fnamemodify(bufname(bufnr), s:FzfHistoryFilepathFormat()) }))
  endfunction  " }}}
  " }}}

  " Grep: Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)  " {{{
  " https://github.com/junegunn/fzf.vim/blob/dc4c4c22715c060a2babd5a5187004bdecbcdea7/plugin/fzf.vim#L52
  command! -nargs=+ -complete=tag FzfGrep       call s:FzfGrep(<q-args>, "")
  command! -nargs=+ -complete=tag FzfGrepForDir call s:FzfGrep(<q-args>, s:InputDirpath())

  function! s:FzfGrep(pattern, dirpath) abort  " {{{
    let pattern      = shellescape(a:pattern)
    let dirpath      = empty(a:dirpath) ? "" : shellescape(a:dirpath)
    let grep_args    = pattern . " " . dirpath
    let grep_options = s:FzfGrepOptions()
    let fzf_options  = fzf#vim#with_preview(#{ options: ["--header", "Grep: " . grep_args] }, "right:wrap")

    call fzf#vim#grep("rg " . grep_options . " " . grep_args, v:true, fzf_options)
  endfunction  " }}}

  function! s:InputDirpath() abort  " {{{
    let dirpath = input("Specify dirpath: ", "", "dir")

    if empty(dirpath)
      throw "Dirpath not specified."
    elseif !isdirectory(dirpath)
      throw "Dirpath doesn't exist."
    else
      return dirpath
    endif
  endfunction  " }}}

  function! s:FzfGrepOptions() abort  " {{{
    let base = "--column --line-number --no-heading --color=always"

    if empty($RIPGREP_EXTRA_OPTIONS)
      return base
    else
      let splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
      let escaped  = map(splitted, { _, option -> shellescape(option) })
      return base . " " . join(escaped, " ")
    endif
  endfunction  " }}}
  " }}}

  " History: Ignore some files, e.g., `.git/COMMIT_EDITMSG`, `.git/addp-hunk-edit.diff`, and so on (Fzf's `:History` doesn't ignore them)  " {{{
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/plugin/fzf.vim#L64
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/plugin/fzf.vim#L73
  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L520-L525
  function! s:FzfHistory() abort  " {{{
    let options = #{
      \   source:  s:FzfHistoryFiles(),
      \   options: [
      \     "--header-lines", !empty(expand("%")),
      \     "--prompt", "History> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:wrap",
      \   ],
      \ }

    call fzf#run(fzf#wrap("history-files", options))
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L457-L463
  function! s:FzfHistoryFiles() abort  " {{{
    let current  = empty(expand("%")) ? [] : [fnamemodify(expand("%"), s:FzfHistoryFilepathFormat())]
    let buffers  = s:FzfBuffersList()
    let oldfiles = s:FzfHistoryList()

    return kg8m#util#list_module().uniq(current + buffers + oldfiles)
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L461
  function! s:FzfHistoryList() abort  " {{{
    let filepaths = filter(copy(mr#mru#list()), { _, filepath -> filereadable(fnamemodify(filepath, ":p")) })
    return map(filepaths, { _, filepath -> fnamemodify(filepath, s:FzfHistoryFilepathFormat()) })
  endfunction  " }}}

  function! s:FzfHistoryFilepathFormat() abort  " {{{
    if !has_key(s:, "fzf_history_filepath_format")
      let s:fzf_history_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
    endif

    return s:fzf_history_filepath_format
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

        if filepath ==# current_filepath && line_number ==# current_line_number
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
  " Also see yankround.vim
  function! s:FzfYankHistory() abort  " {{{
    let options = #{
      \   source:  s:YankList(),
      \   sink:    function("s:YankHandler"),
      \   options: [
      \     "--no-multi",
      \     "--nth", "2..",
      \     "--prompt", "Yank> ",
      \     "--tabstop", "1",
      \     "--preview", s:YankPreviewCommand(),
      \     "--preview-window", "down:5:wrap",
      \   ],
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
    " Don't call `execute substitute(...)` because it causes problem if the command is Fzf's
    call feedkeys(":" . substitute(a:item, '\v.*--\s+`(.+)`$', '\1', "") . "\<Cr>")
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
        \   ["[Reload by Sudo]",     "edit suda://%"],
        \   ["[Write/save by Sudo]", "write suda://%"],
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
        \   ["[Copy] filename",          "call kg8m#util#remote_copy(kg8m#util#current_filename())"],
        \   ["[Copy] relative filepath", "call kg8m#util#remote_copy(kg8m#util#current_relative_path())"],
        \   ["[Copy] absolute filepath", "call kg8m#util#remote_copy(kg8m#util#current_absolute_path())"],
        \
        \   ["[Git] Gina patch", "call " . s:SID . "GinaPatch(expand('%'))"],
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
        \   ["[Alignta] '  # '",     "'<,'>Alignta 21 #"],
        \   ["[Alignta] '  // '",    "'<,'>Alignta 21 //"],
        \   ["[Alignta] '  #=> '",   "'<,'>Alignta 21 #=>"],
        \   ["[Alignta] '  //=> '",  "'<,'>Alignta 21 //=>"],
        \   ["[Alignta] Trac Table", "'<,'>Alignta -r =\\?||=\\?\\|||"],
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

        if !empty(new_list) && current_prefix !=# prev_prefix
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
      \   gems: #{
      \     dir: kg8m#util#rubygems_path(),
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

    if a:arglead ==# ""
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
      \   "options": [
      \     "--prompt", "Rails/" . a:type . "> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:wrap",
      \   ],
      \ }

    call fzf#run(fzf#wrap("rails", options))
  endfunction  " }}}
  " }}}

  let s:fzf_commands = [
    \   "FzfFiles",
    \   "FzfLines",
    \   "FzfMarks",
    \   "FzfHelptags",
    \ ]

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_cmd:  s:fzf_commands,
     \   on_func: "fzf#",
     \   depends: "fzf",
     \ })

  " Add to runtimepath (and use its Vim scripts) but don't use its binary
  " Use fzf binary already installed instead
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
    let g:fzf_tjump_path_to_preview_bin = kg8m#plugin#get_info("fzf.vim").path . "/bin/preview.sh"

    nnoremap <Leader><Leader>t :FzfTjump<Space>
    vnoremap <Leader><Leader>t "gy:FzfTjump<Space><C-r>"

    map g] <Plug>(fzf-tjump)

    call kg8m#plugin#configure(#{
       \   lazy:    v:true,
       \   on_cmd:  "FzfTjump",
       \   on_func: "fzf#tjump",
       \   on_map:  [["nv", "<Plug>(fzf-tjump)"]],
       \   depends: "fzf.vim",
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("lambdalisue/gina.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  function! s:GinaPatch(filepath) abort  " {{{
    let original_diffopt = &diffopt
    set diffopt+=vertical
    execute "Gina patch " . a:filepath
    let &diffopt = original_diffopt
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "Gina",
     \ })
endif  " }}}

if kg8m#plugin#register("sk1418/HowMuch")  " {{{
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

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["v", "<Plug>AutoCalc"]],
     \   hook_post_source: function("s:ConfigPluginOnPostSource_HowMuch"),
     \ })
endif  " }}}

if kg8m#plugin#register("Yggdroot/indentLine")  " {{{
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
  let g:indentLine_bufTypeExclude = [
    \   "help",
    \   "terminal",
    \ ]
endif  " }}}

if kg8m#plugin#register("othree/javascript-libraries-syntax.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:used_javascript_libs = join([
    \   "jquery",
    \   "react",
    \   "vue",
    \ ], ",")
endif  " }}}

if kg8m#plugin#register("fuenor/JpFormat.vim")  " {{{
  " Replace built-in `jq` operator
  set formatexpr=jpfmt#formatexpr()

  let JpFormatCursorMovedI = v:false
  let JpAutoJoin = v:false
  let JpAutoFormat = v:false

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: ["gq"],
     \ })
endif  " }}}

if kg8m#plugin#register("itchyny/lightline.vim")  " {{{
  " http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2
  let s:lightline_elements = #{
    \   left: [
    \     ["mode", "paste"],
    \     ["bufnum"],
    \     ["warning_filepath"], ["normal_filepath"],
    \     ["separator"],
    \     ["filetype"],
    \     ["warning_fileencoding"], ["normal_fileencoding"],
    \     ["fileformat"],
    \     ["separator"],
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
    \     separator: "|",
    \     bufnum: "#%n",
    \     lineinfo_with_percent: "%l/%L(%p%%) : %v",
    \   },
    \   component_function: #{
    \     normal_filepath:     "Lightline_NormalFilepath",
    \     normal_fileencoding: "Lightline_NormalFileencoding",
    \     lsp_status:          "Lightline_LSPStatus",
    \   },
    \   component_expand: #{
    \     warning_filepath:     "Lightline_WarningFilepath",
    \     warning_fileencoding: "Lightline_WarningFileencoding",
    \   },
    \   component_type: #{
    \     warning_filepath:     "warning",
    \     warning_fileencoding: "warning",
    \   },
    \   colorscheme: "kg8m",
    \ }

  function! Lightline_Filepath() abort  " {{{
    return (s:Lightline_IsReadonly() ? "X " : "") .
         \ s:Lightline_Filepath() .
         \ (&modified ? " +" : (&modifiable ? "" : " -"))
  endfunction  " }}}

  function! Lightline_Fileencoding() abort  " {{{
    return &fileencoding
  endfunction  " }}}

  function! s:Lightline_Filepath() abort  " {{{
    if &filetype ==# "vimfiler"
      return vimfiler#get_status_string()
    endif

    if &filetype ==# "unite"
      return unite#get_status_string()
    endif

    if &filetype ==# "qf" && has_key(w:, "quickfix_title")
      return w:quickfix_title
    endif

    let filename = kg8m#util#current_filename()

    if filename ==# ""
      return "[No Name]"
    else
      return winwidth(0) >= 100 ? kg8m#util#current_relative_path() : filename
    endif
  endfunction  " }}}

  function! s:Lightline_IsReadonly() abort  " {{{
    return &filetype !~? 'help\|vimfiler' && &readonly
  endfunction  " }}}

  function! Lightline_NormalFilepath() abort  " {{{
    return Lightline_IsIrregularFilepath() ? "" : Lightline_Filepath()
  endfunction  " }}}

  function! Lightline_NormalFileencoding() abort  " {{{
    return Lightline_IsIrregularFileencoding() ? "" : Lightline_Fileencoding()
  endfunction  " }}}

  function! Lightline_WarningFilepath() abort  " {{{
    " Use `%{...}` because component-expansion result is shared with other windows/buffers
    return "%{Lightline_IsIrregularFilepath() ? Lightline_Filepath() : ''}"
  endfunction  " }}}

  function! Lightline_WarningFileencoding() abort  " {{{
    " Use `%{...}` because component-expansion result is shared with other windows/buffers
    return "%{Lightline_IsIrregularFileencoding() ? Lightline_Fileencoding() : ''}"
  endfunction  " }}}

  function! Lightline_IsIrregularFilepath() abort  " {{{
    " `sudo:` prefix for sudo.vim, which I used to use
    return s:Lightline_IsReadonly() || kg8m#util#current_absolute_path() =~# '\v^(sudo:|suda://)'
  endfunction  " }}}

  function! Lightline_IsIrregularFileencoding() abort  " {{{
    return !empty(&fileencoding) && &fileencoding !=# "utf-8"
  endfunction  " }}}

  function! Lightline_LSPStatus() abort  " {{{
    if s:IsLSPTargetBuffer()
      if has_key(b:, "lsp_buffer_enabled")
        return "[LSP] " . s:Lightline_LSPStatusEnabledLabel()
      else
        return "[LSP] Loading..."
      endif
    else
      return ""
    endif
  endfunction  " }}}

  function! s:Lightline_LSPStatusEnabledLabel() abort  " {{{
    return "Active"
  endfunction  " }}}

  if kg8m#plugin#register("tsuyoshicho/lightline-lsp")  " {{{
    let g:lightline#lsp#indicator_error       = "E:"
    let g:lightline#lsp#indicator_warning     = "W:"
    let g:lightline#lsp#indicator_information = "I:"
    let g:lightline#lsp#indicator_hint        = "H:"

    " Overwrite to use lightline-lsp
    function! s:Lightline_LSPStatusEnabledLabel() abort  " {{{
      let error       = lightline#lsp#error()
      let error       = empty(error) ? g:lightline#lsp#indicator_error . "0" : error
      let warning     = lightline#lsp#warning()
      let warning     = empty(warning) ? g:lightline#lsp#indicator_warning . "0" : warning
      let information = lightline#lsp#information()
      let information = empty(information) ? g:lightline#lsp#indicator_information . "0" : information
      let hint        = lightline#lsp#hint()
      let hint        = empty(hint) ? g:lightline#lsp#indicator_hint . "0" : hint

      return join([error, warning, information, hint], " ")
    endfunction  " }}}
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("AndrewRadev/linediff.vim")  " {{{
  let g:linediff_second_buffer_command = "rightbelow vertical new"

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "Linediff",
     \ })
endif  " }}}

call kg8m#plugin#register("kg8m/moin.vim", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("lambdalisue/mr.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:mr#threshold = 10000
endif  " }}}

if kg8m#plugin#register("tyru/open-browser.vim")  " {{{
  map <Leader>o <Plug>(openbrowser-open)

  " `main` server configs in `.ssh/config` is required
  let g:openbrowser_browser_commands = [
    \   #{
    \     name: "ssh",
    \     args: "ssh main -t 'open '\\''{uri}'\\'''",
    \   }
    \ ]

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(openbrowser-open)"]],
     \ })
endif  " }}}

if kg8m#plugin#register("tyru/operator-camelize.vim")  " {{{
  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [
     \     ["v", "<Plug>(operator-camelize)"],
     \     ["v", "<Plug>(operator-decamelize)"]
     \   ],
     \ })
endif  " }}}

if kg8m#plugin#register("mechatroner/rainbow_csv", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  augroup my_vimrc  " {{{
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:  v:true,
     \   on_ft: "csv",
     \ })
endif  " }}}

call kg8m#plugin#register("lambdalisue/readablefold.vim", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("chrisbra/Recover.vim")

if kg8m#plugin#register("lambdalisue/reword.vim")  " {{{
  cnoreabbrev <expr> Reword reword#preview#seamless()
endif  " }}}

if kg8m#plugin#register("vim-scripts/sequence")  " {{{
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["vn", "<Plug>Sequence"]],
     \ })
endif  " }}}

if kg8m#plugin#register("AndrewRadev/splitjoin.vim")  " {{{
  nnoremap <Leader>J :SplitjoinJoin<Cr>
  nnoremap <Leader>S :SplitjoinSplit<Cr>

  let g:splitjoin_split_mapping       = ""
  let g:splitjoin_join_mapping        = ""
  let g:splitjoin_ruby_trailing_comma = v:true
  let g:splitjoin_ruby_hanging_args   = v:false

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
     \ })
endif  " }}}

call kg8m#plugin#register("lambdalisue/suda.vim")

if kg8m#plugin#register("iberianpig/tig-explorer.vim")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: ["Tig", "TigBlame", "TigStatus"],
     \ })
endif  " }}}

if kg8m#plugin#register("leafgarland/typescript-vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:typescript_indent_disable = v:true
endif  " }}}

if kg8m#plugin#register("mbbill/undotree")  " {{{
  nnoremap <Leader>u :UndotreeToggle<Cr>

  let g:undotree_WindowLayout = 2
  let g:undotree_SplitWidth = 50
  let g:undotree_DiffpanelHeight = 30
  let g:undotree_SetFocusWhenToggle = v:true

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "UndotreeToggle",
     \ })
endif  " }}}

if kg8m#plugin#register("Shougo/unite.vim")  " {{{
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

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_cmd:  "Unite",
     \   on_func: "unite#",
     \ })
endif  " }}}

if kg8m#plugin#register("h1mesuke/vim-alignta")  " {{{
  vnoremap <Leader>a :Alignta<Space>

  " Don't load lazily because `Alignta` command doesn't work on load
  call kg8m#plugin#configure(#{
     \   lazy:   v:false,
     \   on_cmd: "Alignta",
     \ })
endif  " }}}

if kg8m#plugin#register("FooSoft/vim-argwrap")  " {{{
  nnoremap <Leader>a :ArgWrap<Cr>

  let g:argwrap_padded_braces = "{"

  augroup my_vimrc  " {{{
    autocmd FileType eruby let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType ruby  let b:argwrap_tail_comma_braces = "[{"
    autocmd FileType vim   let b:argwrap_tail_comma_braces = "[{" | let b:argwrap_line_prefix = '\'
  augroup END  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "ArgWrap",
     \ })
endif  " }}}

if kg8m#plugin#register("haya14busa/vim-asterisk")  " {{{
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
endif  " }}}

if kg8m#plugin#register("Chiel92/vim-autoformat", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif  " }}}

if kg8m#plugin#register("h1mesuke/vim-benchmark", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "benchmark#",
     \ })
endif  " }}}

if kg8m#plugin#register("jkramer/vim-checkbox", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  augroup my_vimrc  " {{{
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<Cr>
  augroup END  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "checkbox#",
     \ })
endif  " }}}

if kg8m#plugin#register("t9md/vim-choosewin")  " {{{
  nmap <C-w>f <Plug>(choosewin)

  let g:choosewin_overlay_enable          = v:false
  let g:choosewin_overlay_clear_multibyte = v:false
  let g:choosewin_blink_on_land           = v:false
  let g:choosewin_statusline_replace      = v:true
  let g:choosewin_tabline_replace         = v:false

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: "<Plug>(choosewin)",
     \ })
endif  " }}}

call kg8m#plugin#register("hail2u/vim-css3-syntax", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("easymotion/vim-easymotion")  " {{{
  nmap <expr> <Leader>f <SID>EasyMotionWithoutMigemo("easymotion-overwin-f2")
  xmap <expr> <Leader>f <SID>EasyMotionWithoutMigemo("easymotion-bd-f2")
  omap <expr> <Leader>f <SID>EasyMotionWithoutMigemo("easymotion-bd-f2")

  " Replace default `f`
  nmap <expr> f <SID>EasyMotionWithMigemo("easymotion-fl")
  xmap <expr> f <SID>EasyMotionWithMigemo("easymotion-fl")
  omap <expr> f <SID>EasyMotionWithMigemo("easymotion-fl")
  nmap <expr> F <SID>EasyMotionWithMigemo("easymotion-Fl")
  xmap <expr> F <SID>EasyMotionWithMigemo("easymotion-Fl")
  omap <expr> F <SID>EasyMotionWithMigemo("easymotion-Fl")

  " http://haya14busa.com/vim-lazymotion-on-speed/
  let g:EasyMotion_do_mapping       = v:false
  let g:EasyMotion_do_shade         = v:false
  let g:EasyMotion_startofline      = v:false
  let g:EasyMotion_smartcase        = v:true
  let g:EasyMotion_use_upper        = v:true
  let g:EasyMotion_keys             = "FKLASDHGUIONMREWCVTYBX,.;J"
  let g:EasyMotion_enter_jump_first = v:true
  let g:EasyMotion_skipfoldedline   = v:false

  function! s:EasyMotionWithMigemo(map) abort  " {{{
    let g:EasyMotion_use_migemo = v:true
    return "\<Plug>(" . a:map . ")"
  endfunction  " }}}

  function! s:EasyMotionWithoutMigemo(map) abort  " {{{
    let g:EasyMotion_use_migemo = v:false
    return "\<Plug>(" . a:map . ")"
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: "<Plug>(easymotion-",
     \ })
endif  " }}}

if kg8m#plugin#register("lambdalisue/vim-findent")  " {{{
  let g:findent#enable_messages = v:false
  let g:findent#enable_warnings = v:false

  augroup my_vimrc  " {{{
    autocmd FileType * Findent
  augroup END  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "Findent",
     \ })
endif  " }}}

call kg8m#plugin#register("thinca/vim-ft-diff_fold", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("thinca/vim-ft-help_fold")
call kg8m#plugin#register("muz/vim-gemfile", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("kana/vim-gf-user")

if kg8m#plugin#register("tpope/vim-git")  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup my_vimrc  " {{{
    autocmd FileType gitcommit let b:did_ftplugin = v:true
  augroup END  " }}}
endif  " }}}

" Use LSP for completion and going to definition
" Use ale for linting/formatting codes
" Use vim-go's highlightings, foldings, and commands/functions
if kg8m#plugin#register("fatih/vim-go")  " {{{
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

  if kg8m#util#on_tmux()  " {{{
    function! s:SetupGoMappings() abort  " {{{
      nnoremap <buffer> <leader>r :write<Cr>:call VimuxRunCommand("go run -race <C-r>%")<Cr>
    endfunction  " }}}
  else
    function! s:SetupGoMappings() abort  " {{{
      nnoremap <buffer> <leader>r :write<Cr>:GoRun -race %<Cr>
    endfunction  " }}}
  endif  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:  v:true,
     \   on_ft: "go",
     \ })
endif  " }}}

call kg8m#plugin#register("tpope/vim-haml", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("machakann/vim-highlightedundo")  " {{{
  nmap u     <Plug>(highlightedundo-undo)
  nmap <C-r> <Plug>(highlightedundo-redo)

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["n", "<Plug>(highlightedundo-"]],
     \ })
endif  " }}}

" Text object for indentation: i
call kg8m#plugin#register("michaeljsmith/vim-indent-object")

if kg8m#plugin#register("osyo-manga/vim-jplus")  " {{{
  nmap J <Plug>(jplus)
  vmap J <Plug>(jplus)

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(jplus)"]],
     \ })
endif  " }}}

if kg8m#plugin#register("elzr/vim-json", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:vim_json_syntax_conceal = v:false
endif  " }}}

if kg8m#plugin#register("rcmdnk/vim-markdown", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:vim_markdown_override_foldtext         = v:false
  let g:vim_markdown_no_default_key_mappings   = v:true
  let g:vim_markdown_conceal                   = v:false
  let g:vim_markdown_no_extensions_in_markdown = v:true
  let g:vim_markdown_autowrite                 = v:true
  let g:vim_markdown_folding_level             = 10

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   depends: "vim-markdown-quote-syntax",
     \   on_ft:   "markdown",
     \ })

  if kg8m#plugin#register("joker1007/vim-markdown-quote-syntax")  " {{{
    let g:markdown_quote_syntax_filetypes = #{
      \    css:  #{ start: '\%(css\|scss\|sass\)' },
      \    haml: #{ start: "haml" },
      \    xml:  #{ start: "xml" },
      \ }

    call kg8m#plugin#configure(#{
       \   lazy: v:true,
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("andymass/vim-matchup")  " {{{
  let g:matchup_matchparen_status_offscreen = v:false
endif  " }}}

if kg8m#plugin#register("kana/vim-operator-replace")  " {{{
  map r <Plug>(operator-replace)

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-replace)"]],
     \ })
endif  " }}}

if kg8m#plugin#register("rhysd/vim-operator-surround")  " {{{
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

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-surround-"]],
     \   hook_source: function("s:ConfigPluginOnSource_vim_operator_surround"),
     \ })
endif  " }}}

if kg8m#plugin#register("kana/vim-operator-user")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "operator#user#define",
     \ })
endif  " }}}

if kg8m#plugin#register("kg8m/vim-parallel-auto-ctags", #{ if: kg8m#util#on_rails_dir() && !kg8m#util#is_git_tmp_edit() })  " {{{
  let &tags .= "," . kg8m#util#rubygems_path() . "/../tags"

  let g:parallel_auto_ctags#options      = ["--fields=n", "--tag-relative=yes", "--recurse=yes", "--sort=yes", "--exclude=.vim-sessions"]
  let g:parallel_auto_ctags#entry_points = #{
    \   pwd:  #{
    \     path:    ".",
    \     options: g:parallel_auto_ctags#options + ["--exclude=node_modules", "--exclude=vendor/bundle", "--languages=-rspec"],
    \     events:  ["VimEnter", "BufWritePost"],
    \     silent:  v:false,
    \   },
    \   gems: #{
    \     path:    kg8m#util#rubygems_path() . "/..",
    \     options: g:parallel_auto_ctags#options + ["--exclude=test", "--exclude=spec", "--languages=ruby"],
    \     events:  ["VimEnter"],
    \     silent:  v:false,
    \   },
    \ }
endif  " }}}

if kg8m#plugin#register("thinca/vim-prettyprint")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_cmd:  ["PrettyPrint", "PP"],
     \   on_func: ["PrettyPrint", "PP"],
     \ })
endif  " }}}

if kg8m#plugin#register("tpope/vim-rails", #{ if: kg8m#util#on_rails_dir() && !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#configure(#{
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

call kg8m#plugin#register("tpope/vim-repeat")

if kg8m#plugin#register("vim-ruby/vim-ruby", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  augroup my_vimrc  " {{{
    " vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile set filetype=Gemfile

    " Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby if has_key(b:, "ruby_no_expensive") | unlet b:ruby_no_expensive | endif
  augroup END  " }}}

  let g:no_ruby_maps = v:true

  call kg8m#plugin#configure(#{
     \   lazy: v:false,
     \ })
endif  " }}}

if kg8m#plugin#register("joker1007/vim-ruby-heredoc-syntax", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  " Default: JS, SQL, HTML
  let g:ruby_heredoc_syntax_filetypes = #{
    \   haml: #{ start: "HAML" },
    \   ruby: #{ start: "RUBY" },
    \ }

  call kg8m#plugin#configure(#{
     \   lazy:  v:true,
     \   on_ft: "ruby",
     \ })
endif  " }}}

" See also vim-startify's settings
if kg8m#plugin#register("xolox/vim-session", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:session_directory         = getcwd() . "/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = v:false

  set sessionoptions=buffers,folds

  " Prevent vim-session's `tabpage_filter()` from removing inactive buffers
  set sessionoptions+=tabpages

  augroup my_vimrc  " {{{
    autocmd BufWritePost * silent call s:SaveSession()
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

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_cmd:  "SaveSession",
     \   depends: "vim-misc",
     \ })

  if kg8m#plugin#register("xolox/vim-misc")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy: v:true,
       \ })
  endif  " }}}
endif  " }}}

" See vim-session's settings
if kg8m#plugin#register("mhinz/vim-startify", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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
      \   #{ p: "call kg8m#plugin#update_all()" },
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
      \   "  Vim version: " . v:versionlong,
      \   "",
      \ ]

    let g:startify_custom_header = g:startify_custom_header + [
      \   "  LSPs: ",
      \ ]
    for lsp in kg8m#plugin#lsp#get_registered()
      let g:startify_custom_header = g:startify_custom_header + [
        \   "  " . (lsp.available ? "👼 " : "👿 ") . lsp.name,
        \ ]
    endfor

    let g:startify_custom_header = g:startify_custom_header + [""]
  endfunction  " }}}

  function! s:ConfigPluginOnPostSource_vim_startify() abort  " {{{
    highlight StartifyFile   guifg=#FFFFFF
    highlight StartifyHeader guifg=#FFFFFF
    highlight StartifyPath   guifg=#777777
    highlight StartifySlash  guifg=#777777
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:     v:true,
     \   on_event: "VimEnter",
     \   hook_source:      function("s:ConfigPluginOnSource_vim_startify"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_vim_startify"),
     \ })
endif  " }}}

if kg8m#plugin#register("kopischke/vim-stay", #{ if: !kg8m#util#is_git_commit() })  " {{{
  set viewoptions=cursor,folds
endif  " }}}

call kg8m#plugin#register("tpope/vim-surround")

if kg8m#plugin#register("janko/vim-test", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  nnoremap <Leader>T :write<Cr>:TestFile<Cr>
  nnoremap <Leader>t :write<Cr>:TestNearest<Cr>

  if kg8m#util#on_tmux()
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

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: ["TestFile", "TestNearest"],
     \ })
endif  " }}}

" Text object for quotations: q
if kg8m#plugin#register("deris/vim-textobj-enclosedsyntax")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_ft:   ["ruby", "eruby"],
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

" Text object fo last search pattern: /
if kg8m#plugin#register("kana/vim-textobj-lastpat")  " {{{
  call kg8m#plugin#configure(#{
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

" Text object for Ruby blocks (not only `do-end` nor `{}`): r
if kg8m#plugin#register("rhysd/vim-textobj-ruby")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_ft:   "ruby",
     \   depends: "vim-textobj-user",
     \ })
endif  " }}}

if kg8m#plugin#register("kana/vim-textobj-user")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "textobj#user",
     \ })
endif  " }}}

call kg8m#plugin#register("tmux-plugins/vim-tmux", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("cespare/vim-toml", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("posva/vim-vue", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("thinca/vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup my_vimrc  " {{{
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if kg8m#plugin#register("Shougo/vimfiler", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:vimfiler_ignore_pattern = ['^\.git$', '^\.DS_Store$']

  nnoremap <Leader>e :VimFilerBufferDir -force-quit<Cr>

  function! s:ConfigPluginOnSource_vimfiler() abort  " {{{
    call vimfiler#custom#profile("default", "context", #{
       \   safe: v:false,
       \   split_action: "dwm_open",
       \ })
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "VimFilerBufferDir",
     \   hook_source: function("s:ConfigPluginOnSource_vimfiler"),
     \ })

  if kg8m#plugin#register("kg8m/unite-dwm")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy:  v:true,
       \   on_ft: "vimfiler",
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("Shougo/vimproc")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   build:   "make",
     \   on_func: "vimproc#",
     \ })
endif  " }}}

if kg8m#plugin#register("benmills/vimux", #{ if: kg8m#util#on_tmux() && !kg8m#util#is_git_tmp_edit() })  " {{{
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
            if index ==# len(views) - 1
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

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_cmd:  "VimuxCloseRunner",
     \   on_func: "VimuxRunCommand",
     \   hook_source:      function("s:ConfigPluginOnSource_vimux"),
     \   hook_post_source: function("s:ConfigPluginOnPostSource_vimux"),
     \ })
endif  " }}}

" See `kg8m#util#xxx_module()`
call kg8m#plugin#register("vim-jp/vital.vim")

if kg8m#plugin#register("simeji/winresizer")  " {{{
  let g:winresizer_start_key = "<C-w><C-e>"

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["n", g:winresizer_start_key]],
     \ })
endif  " }}}

call kg8m#plugin#register("stephpy/vim-yaml", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("pedrohdz/vim-yaml-folds", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("othree/yajs.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:  v:true,
     \   on_ft: "javascript",
     \ })
endif  " }}}

if kg8m#plugin#register("jonsmithers/vim-html-template-literals", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:htl_css_templates = v:true
  let g:htl_all_templates = v:true

  call kg8m#plugin#configure(#{
     \   depends: "vim-javascript",
     \ })

  call kg8m#plugin#register("pangloss/vim-javascript")
endif  " }}}

if kg8m#plugin#register("LeafCage/yankround.vim")  " {{{
  let g:yankround_max_history = 500

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

    " Avoid shell's syntax error in fzf's preview
    let text = substitute(text, "\n", "\\\\n", "g")

    return printf("%3d\t%s", a:index, text)
  endfunction  " }}}

  function! s:YankPreviewCommand() abort  " {{{
    let command  = "echo {}"
    let command .= " | sed -e 's/^ *[0-9]\\{1,\\}\t//'"
    let command .= " | sed -e 's/\\\\/\\\\\\\\/g'"
    let command .= " | head -n5"

    return command
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
if kg8m#plugin#register("tomasr/molokai")  " {{{
  let g:molokai_original = v:true

  augroup my_vimrc  " {{{
    autocmd ColorScheme molokai call s:OverwriteMolokai()
  augroup END  " }}}

  function! s:OverwriteMolokai() abort  " {{{
    highlight Comment       guifg=#AAAAAA
    highlight CursorColumn                 guibg=#1F1E19
    highlight CursorLine                   guibg=#1F1E19
    highlight DiffChange    guifg=#CCCCCC  guibg=#4C4745
    highlight DiffFile      guifg=#A6E22E                 gui=bold       cterm=bold
    highlight FoldColumn    guifg=#6A7678  guibg=NONE
    highlight Folded        guifg=#6A7678  guibg=NONE
    highlight Ignore        guifg=#808080  guibg=NONE
    highlight Incsearch     guifg=#FFFFFF  guibg=#F92672
    highlight LineNr        guifg=#BCBCBC  guibg=#222222
    highlight Normal        guifg=#F8F8F8  guibg=NONE
    highlight Pmenu         guifg=#66D9EF  guibg=NONE
    highlight QuickFixLine                                gui=bold       cterm=bold
    highlight Search        guifg=#FFFFFF  guibg=#F92672
    highlight SignColumn    guifg=#A6E22E  guibg=#111111
    highlight Special       guifg=#66D9EF  guibg=NONE     gui=italic
    highlight Todo          guifg=#FFFFFF  guibg=NONE     gui=bold
    highlight Underlined    guifg=#AAAAAA                 gui=underline  cterm=underline
    highlight Visual                       guibg=#403D3D  gui=bold       cterm=bold
    highlight VisualNOS                    guibg=#403D3D  gui=bold       cterm=bold

    if has("gui_running")
      " `guibg=NONE` doesn't work in GUI Vim
      highlight FoldColumn  guibg=#000000
      highlight Folded      guibg=#000000
      highlight Ignore      guibg=#000000
      highlight Normal      guibg=#000000
      highlight Pmenu       guibg=#000000
      highlight Special     guibg=#000000
      highlight Todo        guibg=#000000
    endif
  endfunction  " }}}
endif  " }}}
" }}}

" Finish plugin manager initialization  " {{{
call kg8m#plugin#finish_setup()

" Disable filetype before enabling filetype
" https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if kg8m#plugin#installable_exists()
  call kg8m#plugin#install()
endif
" }}}
" }}}

" ----------------------------------------------
" General looks  " {{{
set termguicolors
let g:terminal_ansi_colors = [
 "\   Black,     Dark Red,     Dark GreeN, Brown,
 "\   Dark Blue, Dark Magenta, Dark CYan,  Light GrEy,
 "\   Dark Grey, REd,          Green,      YellOw,
 "\   Blue,      MAgenta,      Cyan,       White,
  \   "#000000", "#EE7900",    "#BAED00",  "#EBCE00",
  \   "#00BEF3", "#BAA0F0",    "#66AED7",  "#EAEAEA",
  \   "#333333", "#FF8200",    "#C1F600",  "#FFE000",
  \   "#00C2F9", "#C6ABFF",    "#71C0ED",  "#FFFFFF",
  \ ]

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
set textwidth=120
set colorcolumn=120
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start
set nofixeol

augroup my_vimrc  " {{{
  autocmd FileType neosnippet set noexpandtab
  autocmd FileType text,markdown,moin setlocal cinkeys-=:

  " Lazily set formatoptions to overwrite others
  autocmd FileType * call s:SetupFormatoptions()
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
  "   2: When formatting text, use the indent of the second line of a paragraph for the rest of the paragraph, instead
  "      of the indent of the first line.
  "   b: Like 'v', but only auto-wrap if you enter a blank at or before the wrap margin.
  "   l: Long lines are not broken in insert mode: When a line was longer than textwidth when the insert command
  "      started, Vim does not.
  "   M: When joining lines, don't insert a space before or after a multi-byte character.  Overrules the 'B' flag.
  "   j: Where it makes sense, remove a comment leader when joining lines.
  "   ]: Respect textwidth rigorously. With this flag set, no line can be longer than textwidth, unless
  "      line-break-prohibition rules make this impossible. Mainly for CJK scripts and works only if 'encoding' is
  "      utf-8".
  setlocal fo+=roq2lMj
  setlocal fo-=t fo-=c fo-=a fo-=b  " `fo-=tcab` doesn't work

  if &encoding ==# "utf-8"
    setlocal fo+=]
  endif

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
set foldcolumn=5
set fillchars=vert:\|

augroup my_vimrc  " {{{
  autocmd FileType haml       setlocal foldmethod=indent
  autocmd FileType neosnippet setlocal foldmethod=marker
  autocmd FileType sh,zsh     setlocal foldmethod=syntax
  autocmd FileType vim        setlocal foldmethod=marker
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
set viminfo='100,<100,h,s10

set restorescreen
set mouse=
set belloff=all
set nostartofline

" This defines what bases Vim will consider for numbers when using the `CTRL-A` and `CTRL-X` commands for adding to and
" subtracting from a number respectively.
"   octal:    If included, numbers that start with a zero will be considered to be octal. Example: Using CTRL-A on "007"
"             results in "010".
"   unsigned: If included, numbers are recognized as unsigned. Thus a leading dash or negative sign won't be considered
"             as part of the number.
set nrformats-=octal
set nrformats+=unsigned

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

" Auto reload
augroup my_vimrc  " {{{
  autocmd InsertEnter,InsertLeave,CursorHold,WinEnter,BufWinEnter * silent! checktime
augroup END  " }}}

set whichwrap=b,s,h,l,<,>,[,],~
set maxmempattern=5000

if !kg8m#util#is_git_tmp_edit()  " {{{
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

" See also settings of vim-lsp and vim-fzf-tjump
" <C-o>: Jump back
nnoremap g[ <C-o>

" gF: Same as "gf", except if a number follows the file name, then the cursor is positioned on that line in the file.
" Don't use `nnoremap` because `gf` sometimes overwritten by plugins
nmap gf gF

" Copy selected to clipboard
vnoremap <Leader>y "yy:call kg8m#util#remote_copy(@")<Cr>

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
noremap <F1> <Nop>

" Increment/Decrement
nmap + <C-a>
nmap - <C-x>

" Swap <C-n>/<C-p> and <Up>/<Down> in commandline mode
" Original <Up>/<Down> respect inputted prefix
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>

" Swap pasting with adjusting indentations or not
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
