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
let s:my_utility_path = expand("~/dotfiles/.vim")
let &runtimepath .= ","..s:my_utility_path
let &runtimepath .= ","..s:my_utility_path.."/after"

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

" MacVim's features, e.g., `Command` + `v` to paste, are broken if setting this
" let g:did_install_default_menus = v:true

let g:mapleader = ","

set fileformats=unix,dos,mac
set ambiwidth=double
scriptencoding utf-8

let g:kg8m = {}
let s:kg8m = {}
function! s:kg8m() abort  " {{{
  return s:kg8m
endfunction  " }}}
" }}}

" Reset my autocommands
augroup my_vimrc  " {{{
  autocmd!
augroup END  " }}}
" }}}

" ----------------------------------------------
" Plugins  " {{{
" Initialize plugin manager  " {{{
call kg8m#plugin#init_manager()
" }}}

" Plugins list and settings  " {{{
" Completion, LSP  " {{{
if kg8m#plugin#register("prabirshrestha/asyncomplete.vim")  " {{{
  let s:asyncomplete = {}

  let g:asyncomplete_auto_popup = v:true
  let g:asyncomplete_popup_delay = 50
  let g:asyncomplete_auto_completeopt = v:false
  let g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  " Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  function! s:asyncomplete.priority_sorted_fuzzy_filter(options, matches) abort  " {{{
    let match_pattern = s:kg8m.completion_refresh_pattern(s:lsp.is_target_buffer() && s:lsp.is_buffer_enabled() ? &filetype : "_")
    let base_matcher  = matchstr(a:options.base, match_pattern)

    let items     = []
    let startcols = []

    if !empty(base_matcher)
      let sorter_context = #{
        \   matcher:  base_matcher,
        \   priority: 0,
        \   cache:    {},
        \ }

      for [source_name, source_matches] in items(a:matches)
        let original_length = len(items)

        " Language server sources have no priority
        let sorter_context.priority = get(asyncomplete#get_source_info(source_name), "priority", 0) + 2

        let items += matchfuzzy(
          \   source_matches.items, sorter_context.matcher,
          \   #{ text_cb: { item -> s:asyncomplete.matchfuzzy_text_cb(item, sorter_context) } }
          \ )

        if len(items) !=# original_length
          let startcols += [source_matches.startcol]
        endif
      endfor

      call sort(items, s:asyncomplete.sorter)
    endif

    " https://github.com/prabirshrestha/asyncomplete.vim/blob/1f8d8ed26acd23d6bf8102509aca1fc99130087d/autoload/asyncomplete.vim#L474
    let a:options["startcol"] = min(startcols)

    call asyncomplete#preprocess_complete(a:options, items)
  endfunction  " }}}

  function! s:asyncomplete.matchfuzzy_text_cb(item, sorter_context) abort  " {{{
    let a:item.priority = s:asyncomplete.item_priority(a:item, a:sorter_context)
    return a:item.word
  endfunction  " }}}

  function! s:asyncomplete.item_priority(item, context) abort  " {{{
    let word = a:item.word

    if !has_key(a:context.cache, word)
      if word =~? "^"..a:context.matcher
        let a:context.cache[word] = 2
      elseif word =~? a:context.matcher
        let a:context.cache[word] = 3
      else
        let a:context.cache[word] = 5
      endif
    endif

    return a:context.cache[word] * a:context.priority
  endfunction  " }}}

  function! s:asyncomplete.sorter(lhs, rhs) abort  " {{{
    return a:lhs.priority - a:rhs.priority
  endfunction  " }}}
  let g:asyncomplete_preprocessor = [s:asyncomplete.priority_sorted_fuzzy_filter]

  " Refresh completion  " {{{
  function! s:asyncomplete.define_refresh_completion_mappings() abort  " {{{
    call s:kg8m.define_bs_mapping_to_refresh_completion()
  endfunction  " }}}

  function! s:asyncomplete.refresh_completion() abort  " {{{
    call s:asyncomplete.clear_completion_timer()
    call s:asyncomplete.start_completion_timer()
    return ""
  endfunction  " }}}

  function! s:asyncomplete.start_completion_timer() abort  " {{{
    " OPTIMIZE: Use function instead of lambda for performance
    let s:completion_refresh_timer = timer_start(200, s:asyncomplete.force_refresh_completion)
  endfunction  " }}}

  function! s:asyncomplete.clear_completion_timer() abort  " {{{
    if has_key(s:, "completion_refresh_timer")
      call timer_stop(s:completion_refresh_timer)
      unlet s:completion_refresh_timer
    endif
  endfunction  " }}}

  function! s:asyncomplete.force_refresh_completion(timer) abort  " {{{
    call asyncomplete#_force_refresh()
    call s:asyncomplete.clear_completion_timer()
  endfunction  " }}}
  " }}}

  function! s:asyncomplete.set_refresh_pattern() abort  " {{{
    if !has_key(b:, "asyncomplete_refresh_pattern")
      let b:asyncomplete_refresh_pattern = s:kg8m.completion_refresh_pattern(&filetype)
    endif
  endfunction  " }}}

  function! s:asyncomplete.on_source() abort  " {{{
    augroup my_vimrc  " {{{
      autocmd BufWinEnter,FileType * call s:asyncomplete.set_refresh_pattern()
    augroup END  " }}}
  endfunction  " }}}

  function! s:asyncomplete.on_post_source() abort  " {{{
    call timer_start(0, { -> s:asyncomplete.define_refresh_completion_mappings() })

    if get(b:, "asyncomplete_enable", v:true)
      call asyncomplete#enable_for_buffer()
    endif
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy: v:true,
     \   on_i: v:true,
     \   hook_source:      s:asyncomplete.on_source,
     \   hook_post_source: s:asyncomplete.on_post_source,
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-buffer.vim")  " {{{
  let s:asyncomplete_buffer = {}

  " Call asyncomplete-buffer.vim's function to refresh keywords (`s:refresh_keywords`) on some events not only
  " `BufWinEnter` in order to include keywords added after `BufWinEnter` in completion candidates
  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L29
  let s:asyncomplete_buffer_events = [
    \   "BufWinEnter",
    \   "TextChanged",
    \   "TextChangedI",
    \   "TextChangedP",
    \ ]

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call timer_start(0, { -> s:asyncomplete_buffer.setup() })
  augroup END  " }}}

  function! s:asyncomplete_buffer.setup() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
       \   name: "buffer",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#buffer#completor"),
       \   events: s:asyncomplete_buffer_events,
       \   on_event: s:asyncomplete_buffer.on_event_async,
       \   priority: 2,
       \ }))

    call s:asyncomplete_buffer.activate()
  endfunction  " }}}

  function! s:asyncomplete_buffer.on_event_async(...) abort  " {{{
    call s:asyncomplete_buffer.on_event_clear_timer()
    call s:asyncomplete_buffer.on_event_start_timer()
  endfunction  " }}}

  function! s:asyncomplete_buffer.on_event_start_timer() abort  " {{{
    " OPTIMIZE: Use function instead of lambda for performance
    let s:asyncomplete_buffer.on_event_timer = timer_start(200, s:asyncomplete_buffer.on_event)
  endfunction  " }}}

  function! s:asyncomplete_buffer.on_event_clear_timer() abort  " {{{
    if has_key(s:asyncomplete_buffer, "on_event_timer")
      call timer_stop(s:asyncomplete_buffer.on_event_timer)
      unlet s:asyncomplete_buffer.on_event_timer
    endif
  endfunction  " }}}

  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
  function! s:asyncomplete_buffer.on_event(timer) abort  " {{{
    if !has_key(s:asyncomplete_buffer, "refresh_keywords")
      call s:asyncomplete_buffer.setup_refresh_keywords()
    endif

    call s:asyncomplete_buffer.refresh_keywords()
    call s:asyncomplete_buffer.on_event_clear_timer()
  endfunction  " }}}

  function! s:asyncomplete_buffer.setup_refresh_keywords() abort  " {{{
    for scriptname in split(execute("scriptnames"), '\n')
      if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
        let s:asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
        break
      endif
    endfor

    if has_key(s:, "asyncomplete_buffer_sid")
      let s:asyncomplete_buffer.refresh_keywords = function("<SNR>"..s:asyncomplete_buffer_sid.."_refresh_keywords")
    else
      if has_key(s:asyncomplete_buffer, "refresh_keywords")
        return
      endif

      function! s:asyncomplete_buffer.cannot_refresh_keywords() abort
        call kg8m#util#echo_error_msg("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
      endfunction
      let s:asyncomplete_buffer.refresh_keywords = s:asyncomplete_buffer.cannot_refresh_keywords
    endif
  endfunction  " }}}

  function! s:asyncomplete_buffer.activate() abort  " {{{
    " Trigger one of the s:asyncomplete_buffer_events
    " Don't use `TextChangedI` or `TextChangedP` because they cause asyncomplete.vim's error about previous_position
    doautocmd <nomodeline> TextChanged
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-file.vim")  " {{{
  let s:asyncomplete_file = {}

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:asyncomplete_file.setup()
  augroup END  " }}}

  function! s:asyncomplete_file.setup() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
       \   name: "file",
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
  let s:asyncomplete_neosnippet = {}

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:asyncomplete_neosnippet.setup()
  augroup END  " }}}

  function! s:asyncomplete_neosnippet.setup() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options(#{
       \   name: "neosnippet",
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
  let s:asyncomplete_nextword = {}

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:asyncomplete_nextword.setup()
  augroup END  " }}}

  function! s:asyncomplete_nextword.setup() abort  " {{{
    " Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
    call asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options(#{
       \   name: "nextword",
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

if kg8m#plugin#register("kitagry/asyncomplete-tabnine.vim", #{ if: !kg8m#util#is_git_tmp_edit(), build: "./install.sh" })  " {{{
  let s:asyncomplete_tabnine = {}

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:asyncomplete_tabnine.setup()
  augroup END  " }}}

  function! s:asyncomplete_tabnine.setup() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options(#{
       \   name: "tabnine",
       \   allowlist: ["*"],
       \   completor: function("asyncomplete#sources#tabnine#completor"),
       \   priority: 0,
       \ }))
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-tags.vim")  " {{{
  let s:asyncomplete_tags = {}

  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:asyncomplete_tags.setup()
  augroup END  " }}}

  function! s:asyncomplete_tags.setup() abort  " {{{
    call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options(#{
       \   name: "tags",
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

if kg8m#plugin#register("prabirshrestha/asyncomplete-lsp.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_source: "asyncomplete.vim",
     \ })
endif  " }}}

if kg8m#plugin#register("Shougo/neosnippet")  " {{{
  let s:neosnippet = {}

  function! s:neosnippet.on_source() abort  " {{{
    call s:kg8m.define_completion_mappings()

    let g:neosnippet#snippets_directory = [
      \   s:my_utility_path.."/snippets",
      \ ]
    let g:neosnippet#disable_runtime_snippets = #{
      \   _: v:true,
      \ }

    augroup my_vimrc  " {{{
      autocmd InsertLeave * NeoSnippetClearMarkers
    augroup END  " }}}

    function! s:neosnippet.setup_contextual() abort  " {{{
      let dir = s:my_utility_path.."/snippets/"
      let g:neosnippet_contextual#contexts = get(g:, "neosnippet_contextual#contexts", {})

      if !has_key(g:neosnippet_contextual#contexts, "ruby")
        let g:neosnippet_contextual#contexts.ruby = []
      endif

      if kg8m#util#on_rails_dir()
        let g:neosnippet_contextual#contexts.ruby += [
          \   #{ pattern: '^app/controllers', snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-controller.snip"] },
          \   #{ pattern: '^app/models',      snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-model.snip"] },
          \   #{ pattern: '^db/migrate',      snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-migration.snip"] },
          \   #{ pattern: '_test\.rb$',       snippets: [dir.."ruby-minitest.snip", dir.."ruby-rails.snip", dir.."ruby-rails-test.snip", dir.."ruby-rails-minitest.snip"] },
          \   #{ pattern: '_spec\.rb$',       snippets: [dir.."ruby-rspec.snip",    dir.."ruby-rails.snip", dir.."ruby-rails-test.snip", dir.."ruby-rails-rspec.snip"] },
          \ ]
      else
        let g:neosnippet_contextual#contexts.ruby += [
          \   #{ pattern: '_test\.rb$', snippets: [dir.."ruby-minitest.snip"] },
          \   #{ pattern: '_spec\.rb$', snippets: [dir.."ruby-rspec.snip"] },
          \ ]
      endif

      function! s:neosnippet.source_contextual_snippets() abort  " {{{
        let contexts = get(g:neosnippet_contextual#contexts, &filetype, [])
        let filepath = kg8m#util#current_relative_path()

        for context in contexts
          if filepath =~# context.pattern
            for snippet in context.snippets
              if filereadable(snippet)
                execute "NeoSnippetSource "..snippet
              endif
            endfor

            return
          endif
        endfor
      endfunction  " }}}

      augroup my_vimrc  " {{{
        execute "autocmd FileType "..join(keys(g:neosnippet_contextual#contexts), ",").." call timer_start(50, { -> s:neosnippet.source_contextual_snippets() })"
      augroup END  " }}}
    endfunction  " }}}
    call s:neosnippet.setup_contextual()
  endfunction  " }}}

  function! s:neosnippet.on_post_source() abort  " {{{
    call timer_start(0, { -> s:neosnippet.source_contextual_snippets() })
  endfunction  " }}}

  " `on_ft` for Syntaxes
  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_ft:     ["snippet", "neosnippet"],
     \   on_func:   "neosnippet#",
     \   on_source: "asyncomplete.vim",
     \   hook_source:      s:neosnippet.on_source,
     \   hook_post_source: s:neosnippet.on_post_source,
     \ })
endif  " }}}

if kg8m#plugin#register("prabirshrestha/vim-lsp")  " {{{
  let s:lsp = {}

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
    autocmd User lsp_setup          call s:lsp.subscribe_stream()
    autocmd User lsp_buffer_enabled call s:lsp.on_lsp_buffer_enabled()

    autocmd FileType * call s:lsp.reset_target_buffer()
  augroup END  " }}}

  function! s:lsp.subscribe_stream() abort  " {{{
    call lsp#callbag#pipe(
       \   lsp#stream(),
       \   lsp#callbag#filter({ x -> s:lsp.is_definition_failed_stream(x) }),
       \   lsp#callbag#subscribe(#{ next: { -> fzf_tjump#jump() } }),
       \ )
  endfunction  " }}}

  function! s:lsp.is_definition_failed_stream(x) abort  " {{{
    return has_key(a:x, "request") && get(a:x.request, "method", "") ==# "textDocument/definition" &&
         \ has_key(a:x, "response") && empty(get(a:x.response, "result", []))
  endfunction  " }}}

  function! s:lsp.on_lsp_buffer_enabled() abort  " {{{
    if get(b:, "lsp_buffer_enabled", v:false)
      return
    endif

    if !s:lsp.are_all_servers_running()
      return
    endif

    setlocal omnifunc=lsp#complete
    nmap <buffer> g] <Plug>(lsp-definition)
    nmap <buffer> <S-h> <Plug>(lsp-hover)

    call s:lsp.overwrite_capabilities()

    augroup my_vimrc  " {{{
      autocmd InsertLeave <buffer> call timer_start(100, { -> s:lsp.document_format(#{ sync: v:false }) })
      autocmd BufWritePre <buffer> call s:lsp.document_format(#{ sync: v:true })
    augroup END  " }}}

    " cf. s:lsp.is_buffer_enabled()
    let b:lsp_buffer_enabled = v:true
  endfunction  " }}}

  " cf. s:lsp.on_lsp_buffer_enabled()
  function! s:lsp.is_buffer_enabled() abort  " {{{
    if has_key(b:, "lsp_buffer_enabled")
      return v:true
    else
      return s:lsp.are_all_servers_running()
    endif
  endfunction  " }}}

  function! s:lsp.are_all_servers_running() abort  " {{{
    for server_name in lsp#get_allowed_servers()
      if lsp#get_server_status(server_name) !=# "running"
        return v:false
      endif
    endfor

    return v:true
  endfunction  " }}}

  function! s:lsp.is_target_buffer() abort  " {{{
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

  function! s:lsp.reset_target_buffer() abort  " {{{
    if has_key(b:, "lsp_target_buffer")
      unlet b:lsp_target_buffer
    endif
  endfunction  " }}}

  " Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
  " formatting from language servers which have capability of document formatting. I want to do formatting by
  " efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
  " language server which has capability of document formatting.
  function! s:lsp.overwrite_capabilities() abort  " {{{
    if &filetype !~# '\v^(go|javascript|ruby|typescript)$'
      return
    endif

    if !s:lsp.are_all_servers_running()
      call kg8m#util#echo_error_msg("Cannot to overwrite language servers' capabilities because some of them are not running")
      return
    endif

    for server_name in lsp#get_allowed_servers()->filter({ -> v:val !=# "efm-langserver" })
      let capabilities = lsp#get_server_capabilities(server_name)

      if has_key(capabilities, "documentFormattingProvider")
        let capabilities.documentFormattingProvider = v:false
      endif
    endfor
  endfunction  " }}}

  function! s:lsp.document_format(options = {}) abort  " {{{
    if get(a:options, "sync", v:true)
      silent LspDocumentFormatSync
    else
      if &modified && mode() ==# "n"
        silent LspDocumentFormat
      endif
    endif
  endfunction  " }}}

  function! s:lsp.schemas_json() abort  " {{{
    if !has_key(s:, "lsp_schemas_json")
      let filepath = kg8m#plugin#get_info("vim-lsp-settings").path.."/data/catalog.json"
      let json     = filepath->readfile()->join("\n")->json_decode()
      let s:lsp_schemas_json = json.schemas
    endif

    return s:lsp_schemas_json
  endfunction  " }}}

  " Register LSPs  " {{{
  " yarn add bash-language-server  " {{{
  " Syntax errors sometimes occur when editing zsh file
  call kg8m#plugin#lsp#register(#{
     \   name: "bash-language-server",
     \   cmd: { server_info -> ["bash-language-server", "start"] },
     \   allowlist: ["sh", "zsh"],
     \ })
  " }}}

  " yarn add vscode-langservers-extracted  " {{{
  " css-languageserver doesn't work when editing .sass file
  call kg8m#plugin#lsp#register(#{
     \   name: "css-language-server",
     \   cmd: { server_info -> ["vscode-css-language-server", "--stdio"] },
     \   allowlist: ["css", "less", "scss"],
     \   config: { -> #{ refresh_pattern: s:kg8m.completion_refresh_pattern("css") } },
     \   workspace_config: #{
     \     css:  #{ lint: #{ validProperties: [] } },
     \     less: #{ lint: #{ validProperties: [] } },
     \     scss: #{ lint: #{ validProperties: [] } },
     \   },
     \   executable_name: "vscode-css-language-server",
     \ })
  " }}}

  " go get github.com/mattn/efm-langserver  " {{{
  " cf. .config/efm-langserver/config.yaml
  call kg8m#plugin#lsp#register(#{
     \   name: "efm-langserver",
     \   cmd: { server_info -> ["efm-langserver"] },
     \   allowlist: [
     \     "eruby", "go", "json", "make", "markdown", "ruby", "vim",
     \     "eruby.yaml", "yaml",
     \     "javascript", "typescript",
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

  " yarn add vscode-langservers-extracted  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "html-language-server",
     \   cmd: { server_info -> ["vscode-html-language-server", "--stdio"] },
     \   initialization_options: #{ embeddedLanguages: #{ css: v:true, javascript: v:true } },
     \   allowlist: ["eruby", "html"],
     \   config: { -> #{ refresh_pattern: s:kg8m.completion_refresh_pattern("html") } },
     \   executable_name: "vscode-html-language-server",
     \ })
  " }}}

  " yarn add vscode-langservers-extracted  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "json-language-server",
     \   cmd: { server_info -> ["vscode-json-language-server", "--stdio"] },
     \   allowlist: ["json"],
     \   config: { -> #{ refresh_pattern: s:kg8m.completion_refresh_pattern("json") } },
     \   workspace_config: { -> #{
     \     json: #{
     \       format: #{ enable: v:true },
     \       schemas: s:lsp.schemas_json(),
     \    },
     \   } },
     \   executable_name: "vscode-json-language-server",
     \ })
  " }}}

  " gem install solargraph  " {{{
  " initialization_options: https://github.com/castwide/vscode-solargraph/blob/master/package.json
  call kg8m#plugin#lsp#register(#{
     \   name: "solargraph",
     \   cmd: { server_info -> ["solargraph", "stdio"] },
     \   initialization_options: { -> #{
     \     autoformat: v:false,
     \     checkGemVersion: v:true,
     \     completion: v:true,
     \     definitions: v:true,
     \     diagnostics: v:true,
     \     formatting: v:false,
     \     hover: v:true,
     \     logLevel: "info",
     \     references: v:true,
     \     rename: v:true,
     \     symbols: v:true,
     \     useBundler: filereadable("Gemfile.lock"),
     \   } },
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
     \   allowlist: ["typescript", "javascript"],
     \ })
  " }}}

  " yarn add vim-language-server  " {{{
  call kg8m#plugin#lsp#register(#{
     \   name: "vim-language-server",
     \   cmd: { server_info -> ["vim-language-server", "--stdio"] },
     \   initialization_options: { -> #{
     \     iskeyword: &iskeyword,
     \     vimruntime: $VIMRUNTIME,
     \     runtimepath: kg8m#plugin#all_runtimepath(),
     \     diagnostic: #{ enable: v:true },
     \     indexes: #{
     \       runtimepath: v:true,
     \       gap: 100,
     \       count: 3,
     \     },
     \     suggest: #{
     \       fromVimruntime: v:true,
     \       fromRuntimepath: v:true,
     \     },
     \   } },
     \   root_uri: { server_info -> lsp#utils#path_to_uri(expand("~")) },
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
  " Syntax errors sometimes occur when editing eruby.yaml file
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

  function! s:lsp.on_post_source() abort  " {{{
    " https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
    call lsp#enable()
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_ft:   kg8m#plugin#lsp#get_filetypes(),
     \   depends: "asyncomplete.vim",
     \   hook_post_source: s:lsp.on_post_source,
     \ })

  call kg8m#plugin#register("mattn/vim-lsp-settings", #{ if: v:false })
  call kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", #{ if: v:false })
endif  " }}}

if kg8m#plugin#register("hrsh7th/vim-vsnip")  " {{{
  let s:vsnip = {}

  function! s:vsnip.on_source() abort  " {{{
    call s:kg8m.define_completion_mappings()
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:      v:true,
     \   on_func:   "vsnip#",
     \   on_source: "vim-lsp",
     \   hook_source: s:vsnip.on_source,
     \ })

  if kg8m#plugin#register("hrsh7th/vim-vsnip-integ")  " {{{
    call kg8m#plugin#configure(#{
       \   lazy:      v:true,
       \   on_source: "vim-vsnip",
       \ })
  endif  " }}}
endif  " }}}

function! s:kg8m.completion_refresh_pattern(filetype) abort  " {{{
  if !has_key(s:, "completion_refresh_patterns")
    let css_pattern = '\v([.#a-zA-Z0-9_-]+)$'
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
" }}}

call kg8m#plugin#register("dense-analysis/ale", #{ if: v:false })
call kg8m#plugin#register("pearofducks/ansible-vim", #{ if: !kg8m#util#is_git_tmp_edit() })

" Show diff in Git's interactive rebase
call kg8m#plugin#register("hotwatermorning/auto-git-diff", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("vim-scripts/autodate.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%('..
                              \   '\%(Last \?\%(Change\|Modified\)\)\|'..
                              \   '\%(最終更新日\?\)\|'..
                              \   '\%(更新日\)'..
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
  let s:context_filetype = {}
  let s:context_filetype.filetypes = {}
  let s:context_filetype.filetypes.for_js = [
    \   #{ start: '\<html`$', end: '^\s*`', filetype: 'html' },
    \   #{ start: '\<css`$', end: '^\s*`', filetype: 'css' },
    \ ]

  " For caw.vim and so on
  let g:context_filetype#filetypes = #{
    \   javascript: s:context_filetype.filetypes.for_js,
    \   typescript: s:context_filetype.filetypes.for_js,
    \ }
endif  " }}}

if kg8m#plugin#register("spolu/dwm.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:dwm = {}

  nnoremap <C-w>n       :call DWM_New()<Cr>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = v:false

  " For fzf.vim
  command! -nargs=1 -complete=file DWMOpen call s:dwm.open(<q-args>)

  function! s:dwm.open(filepath) abort  " {{{
    if bufexists(a:filepath)
      let winnr = bufwinnr(a:filepath)

      if winnr ==# -1
        call DWM_Stack(1)
        split
        execute "edit "..a:filepath
        call DWM_AutoEnter()
      else
        execute winnr.."wincmd w"
        call DWM_AutoEnter()
      endif
    else
      if bufname("%") !=# ""
        call DWM_New()
      endif

      execute "edit "..a:filepath
    endif
  endfunction  " }}}

  function! s:dwm.on_post_source() abort  " {{{
    " Disable DWM's default behavior on buffer loaded
    augroup dwm
      autocmd!
    augroup END
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
     \   hook_post_source: s:dwm.on_post_source,
     \ })
endif  " }}}

call kg8m#plugin#register("editorconfig/editorconfig-vim", #{ if: !kg8m#util#is_git_tmp_edit() && filereadable(".editorconfig") })

if kg8m#plugin#register("junegunn/fzf.vim", #{ if: !kg8m#util#is_git_tmp_edit() && executable("fzf") })  " {{{
  let s:fzf = {}
  function! s:fzf() abort  " {{{
    return s:fzf
  endfunction  " }}}

  let g:fzf_command_prefix = "Fzf"
  let g:fzf_buffers_jump   = v:true
  let g:fzf_layout         = #{ up: "~90%" }
  let g:fzf_files_options  = [
    \   "--preview", "git diff-or-cat {1}",
    \   "--preview-window", "right:50%:wrap:nohidden",
    \ ]

  " See dwm.vim
  let g:fzf_action = #{ ctrl-o: "DWMOpen" }

  " See also vim-fzf-tjump's mappings
  nnoremap <Leader><Leader>f :FzfFiles<Cr>
  nnoremap <Leader><Leader>v :call <SID>fzf().git_files.run()<Cr>
  nnoremap <Leader><Leader>b :call <SID>fzf().buffers.run()<Cr>
  nnoremap <Leader><Leader>l :FzfBLines<Cr>
  nnoremap <Leader><Leader>g :FzfGrep<Space>
  nnoremap <Leader><Leader>G :FzfGrepForDir<Space>
  vnoremap <Leader><Leader>g "gy:FzfGrep<Space><C-r>"
  vnoremap <Leader><Leader>G "gy:FzfGrepForDir<Space><C-r>"
  nnoremap <Leader><Leader>m :FzfMarks<Cr>
  nnoremap <Leader><Leader>h :call <SID>fzf().history.run()<Cr>
  nnoremap <Leader><Leader>H :FzfHelptags<Cr>
  nnoremap <Leader><Leader>y :call <SID>fzf().yank_history.run()<Cr>
  noremap  <Leader><Leader>s :<C-u>call <SID>fzf().my_shortcuts.run("")<Cr>
  noremap  <Leader><Leader>a :<C-u>call <SID>fzf().my_shortcuts.run("'EasyAlign ")<Cr>
  nnoremap <Leader><Leader>r :call <SID>fzf().rails.setup()<Cr>:FzfRails<Space>

  augroup my_vimrc  " {{{
    autocmd FileType fzf call s:fzf.setup_window()
  augroup END  " }}}

  function! s:fzf.setup_window() abort  " {{{
    " Temporarily increase window height
    set winheight=999
    set winheight=1
    redraw
  endfunction  " }}}

  function! s:fzf.filepath_format() abort  " {{{
    if !has_key(s:, "fzf_filepath_format")
      let s:fzf_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
    endif

    return s:fzf_filepath_format
  endfunction  " }}}

  " Git Files: Show preview of dirty files (Fzf's `:GFiles?` doesn't show preview)  " {{{
  let s:fzf.git_files = {}

  function! s:fzf.git_files.run() abort  " {{{
    call fzf#vim#gitfiles("?", #{
       \   options: [
       \     "--preview", "git diff-or-cat {2}",
       \     "--preview-window", "right:50%:wrap:nohidden",
       \   ],
       \ })
  endfunction  " }}}
  " }}}

  " Buffers: Sort buffers in dictionary order (Fzf's `:Buffers` doesn't sort them)  " {{{
  " Also see History configs
  let s:fzf.buffers = {}

  function! s:fzf.buffers.run() abort  " {{{
    let options = #{
      \   source:  s:fzf.buffers.candidates(),
      \   options: [
      \     "--header-lines", !empty(expand("%")),
      \     "--prompt", "Buffers> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:50%:wrap:nohidden",
      \   ],
      \ }

    call fzf#run(fzf#wrap("buffer-files", options))
  endfunction  " }}}

  function! s:fzf.buffers.candidates() abort  " {{{
    let current = "%"->expand()->empty() ? [] : ["%"->expand()->fnamemodify(s:fzf.filepath_format())]
    let buffers = s:fzf.buffers.list()

    return kg8m#util#list_module().uniq(current + buffers)
  endfunction  " }}}

  " https://github.com/junegunn/fzf.vim/blob/ee08c8f9497a4de74c9df18bc294fbe5930f6e4d/autoload/fzf/vim.vim#L196-L198
  function! s:fzf.buffers.list() abort  " {{{
    let bufnrs = filter(range(1, bufnr("$")), { _, bufnr -> buflisted(bufnr) && getbufvar(bufnr, "&filetype") !=# "qf" && len(bufname(bufnr)) })
    return bufnrs->map({ _, bufnr -> bufnr->bufname()->fnamemodify(s:fzf.filepath_format()) })->sort()
  endfunction  " }}}
  " }}}

  " Grep: Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)  " {{{
  let s:fzf.grep = {}

  command! -nargs=+ -complete=tag FzfGrep       call s:fzf.grep.run(<q-args>, "")
  command! -nargs=+ -complete=tag FzfGrepForDir call s:fzf.grep.run(<q-args>, s:kg8m.input_dirpath())

  function! s:fzf.grep.run(pattern, dirpath) abort  " {{{
    let pattern      = shellescape(a:pattern)
    let dirpath      = empty(a:dirpath) ? "" : shellescape(a:dirpath)
    let grep_args    = pattern.." "..dirpath
    let grep_options = s:fzf.grep.options()
    let fzf_options  = #{
      \   options: [
      \     "--header", "Grep: "..grep_args,
      \     "--delimiter", ":",
      \     "--preview-window", "right:50%:wrap:nohidden:+{2}-/2",
      \     "--preview", kg8m#plugin#get_info("fzf.vim").path.."/bin/preview.sh {}",
      \   ],
      \ }

    call fzf#vim#grep("rg "..grep_options.." "..grep_args, v:true, fzf_options)
  endfunction  " }}}

  function! s:kg8m.input_dirpath() abort  " {{{
    let dirpath = input("Specify dirpath: ", "", "dir")->expand()

    if empty(dirpath)
      throw "Dirpath not specified."
    elseif !isdirectory(dirpath)
      throw "Dirpath doesn't exist."
    else
      return dirpath
    endif
  endfunction  " }}}

  function! s:fzf.grep.options() abort  " {{{
    let base = "--column --line-number --no-heading --color=always"

    if empty($RIPGREP_EXTRA_OPTIONS)
      return base
    else
      let splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
      let escaped  = map(splitted, { _, option -> shellescape(option) })
      return base.." "..join(escaped, " ")
    endif
  endfunction  " }}}
  " }}}

  " History: Ignore some files, e.g., `.git/COMMIT_EDITMSG`, `.git/addp-hunk-edit.diff`, and so on (Fzf's `:History` doesn't ignore them)  " {{{
  let s:fzf.history = {}

  function! s:fzf.history.run() abort  " {{{
    let options = #{
      \   source:  s:fzf.history.candidates(),
      \   options: [
      \     "--header-lines", !empty(expand("%")),
      \     "--prompt", "History> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:50%:wrap:nohidden",
      \   ],
      \ }

    call fzf#run(fzf#wrap("history-files", options))
  endfunction  " }}}

  function! s:fzf.history.candidates() abort  " {{{
    let current  = "%"->expand()->empty() ? [] : ["%"->expand()->fnamemodify(s:fzf.filepath_format())]
    let buffers  = s:fzf.buffers.list()  " for renamed files by `:Rename`, opened files by `vim foo bar baz`, and so on
    let oldfiles = s:fzf.history.list()

    return kg8m#util#list_module().uniq(current + buffers + oldfiles)
  endfunction  " }}}

  function! s:fzf.history.list() abort  " {{{
    let filepaths = mr#mru#list()->copy()->filter("v:val->filereadable()")
    return filepaths->map("v:val->fnamemodify(s:fzf.filepath_format())")
  endfunction  " }}}
  " }}}

  " Marks  " {{{
  let s:fzf.marks = {}

  nnoremap <silent> m :call <SID>fzf().marks.increment()<Cr>

  " http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
  function! s:fzf.marks.setup() abort  " {{{
    if has_key(s:, "incremental_mark_keys")
      return
    endif

    let s:incremental_mark_keys = [
      \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
      \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
      \ ]
    let s:incremental_mark_keys_pattern = "^[A-Z]$"

    execute "delmarks "..join(s:incremental_mark_keys, "")
  endfunction  " }}}

  function! s:fzf.marks.increment() abort  " {{{
    call s:fzf.marks.setup()

    let incremental_mark_key = s:fzf.marks.detect_key()

    if incremental_mark_key =~# s:incremental_mark_keys_pattern
      echo "Already marked to "..incremental_mark_key
      return
    endif

    if !has_key(s:, "incremental_mark_index")
      let s:incremental_mark_index = 0
    else
      let s:incremental_mark_index = (s:incremental_mark_index + 1) % len(s:incremental_mark_keys)
    endif

    execute "mark "..s:incremental_mark_keys[s:incremental_mark_index]
    echo "Marked to "..s:incremental_mark_keys[s:incremental_mark_index]
  endfunction  " }}}

  function! s:fzf.marks.detect_key() abort  " {{{
    let detected_mark_key   = 0
    let current_filepath    = expand("%")
    let current_line_number = line(".")

    for mark_key in s:incremental_mark_keys
      let position = getpos("'"..mark_key)

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
  let s:fzf.yank_history = {}

  function! s:fzf.yank_history.run() abort  " {{{
    call s:fzf.yank_history.setup()

    let options = #{
      \   source:  s:fzf.yank_history.candidates(),
      \   sink:    s:fzf.yank_history.handler,
      \   options: [
      \     "--no-multi",
      \     "--nth", "2..",
      \     "--prompt", "Yank> ",
      \     "--tabstop", "1",
      \     "--preview", s:yankround.preview_command(),
      \     "--preview-window", "down:5:wrap:nohidden",
      \   ],
      \ }

    call fzf#run(fzf#wrap("yank-history", options))
  endfunction  " }}}

  function! s:fzf.yank_history.setup() abort  " {{{
    if has_key(s:fzf.yank_history, "handler")
      return
    endif

    let s:fzf.yank_history.handler = s:yankround.handler
  endfunction  " }}}

  function! s:fzf.yank_history.candidates() abort  " {{{
    return s:yankround.list()
  endfunction  " }}}
  " }}}

  " My Shortcuts  " {{{
  let s:fzf.my_shortcuts = {}

  function! s:fzf.my_shortcuts.run(query) abort  " {{{
    let options = {
      \   "source":  s:fzf.my_shortcuts.candidates(),
      \   "sink":    s:fzf.my_shortcuts.handler,
      \   "options": ["--no-multi", "--prompt", "Shortcuts> ", "--query", a:query],
      \ }

    call fzf#run(fzf#wrap("my-shortcuts", options))
  endfunction  " }}}

  function! s:fzf.my_shortcuts.candidates() abort  " {{{
    call s:fzf.my_shortcuts.setup()
    return s:fzf_my_shortcuts_list
  endfunction  " }}}

  function! s:fzf.my_shortcuts.handler(item) abort  " {{{
    " Don't call `execute substitute(...)` because it causes problem if the command is Fzf's
    let command = substitute(a:item, '\v.*--\s+`(.+)`$', '\1', "")
    call feedkeys(":"..command.."\<Cr>")
  endfunction  " }}}

  function! s:fzf.my_shortcuts.setup() abort  " {{{
    if has_key(s:, "fzf_my_shortcuts_list")
      return
    endif

    function! s:fzf.my_shortcuts.define_raw_list() abort  " {{{
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
        \   ["[Git] Gina patch",                                 "call "..expand("<SID>").."gina().patch(expand('%'))"],
        \   ["[Git] Apply the patch/hunk to the another side",   "'<,'>diffput"],
        \   ["[Git] Apply the patch/hunk from the another side", "'<,'>diffget"],
        \
        \   ["[Ruby Hash Syntax] Old to New", "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
        \   ["[Ruby Hash Syntax] New to Old", "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],
        \
        \   ["[EasyAlign] '='",                  "'<,'>EasyAlign ="],
        \   ["[EasyAlign] '=>'",                 "'<,'>EasyAlign =>"],
        \   ["[EasyAlign] ' '",                  "'<,'>EasyAlign \\"],
        \   ["[EasyAlign] ' ' repeated",         "'<,'>EasyAlign *\\"],
        \   ["[EasyAlign] 'hoge:'",              "'<,'>EasyAlign :"],
        \   ["[EasyAlign] '|' repeated (table)", "'<,'>EasyAlign *|"],
        \
        \   ["[Autoformat] Format Source Codes", "Autoformat"],
        \
        \   ["[Diff] Linediff", "'<,'>Linediff"],
        \
        \   ["[QuickFix] Replace", "Qfreplace"],
        \ ]
    endfunction  " }}}

    function! s:fzf.my_shortcuts.count_max_word_length() abort  " {{{
      let s:fzf_my_shortcuts_max_word_length =
        \   s:fzf_my_shortcuts_list
        \     ->copy()
        \     ->map({ _, item -> item[0]->strlen() })
        \     ->max()
    endfunction  " }}}

    function! s:fzf.my_shortcuts.make_groups() abort  " {{{
      function! s:fzf.my_shortcuts_group_name(item) abort  " {{{
        return matchstr(a:item, '\v^\[[^]]+\]')
      endfunction  " }}}

      let prev_prefix = ""
      let new_list    = []

      for candidate in s:fzf_my_shortcuts_list
        let current_prefix = s:fzf.my_shortcuts_group_name(candidate[0])

        if !empty(new_list) && current_prefix !=# prev_prefix
          call add(new_list, ["", ""])
        endif

        call add(new_list, candidate)
        let prev_prefix = current_prefix
      endfor

      let s:fzf_my_shortcuts_list = new_list
    endfunction  " }}}

    function! s:fzf.my_shortcuts.format_list() abort  " {{{
      let s:fzf_my_shortcuts_list =
        \   s:fzf_my_shortcuts_list
        \     ->map(s:fzf.my_shortcuts_format_item)
    endfunction  " }}}

    function! s:fzf.my_shortcuts_format_item(_, item) abort  " {{{
      let [description, command] = a:item

      if empty(description)
        return ""
      else
        return description..s:fzf.my_shortcuts_word_padding(description).."  --  `"..command.."`"
      endif
    endfunction  " }}}

    function! s:fzf.my_shortcuts_word_padding(item) abort  " {{{
      return repeat(" ", s:fzf_my_shortcuts_max_word_length - strlen(a:item))
    endfunction  " }}}

    call s:fzf.my_shortcuts.define_raw_list()
    call s:fzf.my_shortcuts.count_max_word_length()
    call s:fzf.my_shortcuts.make_groups()
    call s:fzf.my_shortcuts.format_list()
  endfunction  " }}}
  " }}}

  " Rails  " {{{
  let s:fzf.rails = {}

  function! s:fzf.rails.setup() abort  " {{{
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

    command! -nargs=1 -complete=customlist,s:fzf_rails_type_names FzfRails call <SID>fzf().rails.run(<q-args>)
    nnoremap <Leader><Leader>r :FzfRails<Space>
  endfunction  " }}}

  " Proxy because `command`'s `-complete` doesn't accept `s:fzf.rails.type_names`
  function! s:fzf_rails_type_names(arglead, cmdline, curpos) abort  " {{{
    return s:fzf.rails.type_names(a:arglead, a:cmdline, a:curpos)
  endfunction  " }}}

  function! s:fzf.rails.type_names(arglead, cmdline, curpos) abort  " {{{
    if !has_key(s:, "fzf_rails_type_names")
      let s:fzf_rails_type_names = s:fzf_rails_specs->keys()->sort()
    endif

    if a:arglead ==# ""
      return s:fzf_rails_type_names
    else
      return filter(
           \   copy(s:fzf_rails_type_names),
           \   { _, name -> name =~# "^"..a:arglead }
           \ )
    endif
  endfunction  " }}}

  function! s:fzf.rails.run(type) abort  " {{{
    let type_spec = s:fzf_rails_specs[a:type]

    if executable("gfind")
      let command = "gfind "..type_spec.dir.." -regextype posix-egrep"
    elseif has("mac")
      let command = "find -E "..type_spec.dir
    else
      let command = "find "..type_spec.dir.." -regextype posix-egrep"
    endif

    if has_key(type_spec, "pattern")
      let command .= " \\( -regex '"..type_spec.pattern.."' \\)"
    endif

    if has_key(type_spec, "excludes")
      let excludes = join(type_spec.excludes, " -not ")
      let command .= " \\( -not "..excludes.." \\)"
    endif

    let command .= " -type f -not -name '.keep'"
    let command .= " | sort"

    let options = {
      \   "source":  command,
      \   "options": [
      \     "--prompt", "Rails/"..a:type.."> ",
      \     "--preview", "git cat {}",
      \     "--preview-window", "right:50%:wrap:nohidden",
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
    let g:fzf_tjump_path_to_preview_bin = kg8m#plugin#get_info("fzf.vim").path.."/bin/preview.sh"

    nnoremap <Leader><Leader>t :FzfTjump<Space>
    vnoremap <Leader><Leader>t "gy:FzfTjump<Space><C-r>"

    map g] <Plug>(fzf-tjump)

    call kg8m#plugin#configure(#{
       \   lazy:    v:true,
       \   on_cmd:  "FzfTjump",
       \   on_func: ["fzf_tjump#"],
       \   on_map:  [["nv", "<Plug>(fzf-tjump)"]],
       \   depends: "fzf.vim",
       \ })
  endif  " }}}
endif  " }}}

if kg8m#plugin#register("lambdalisue/gina.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:gina = {}
  function! s:gina() abort  " {{{
    return s:gina
  endfunction  " }}}

  function! s:gina.patch(filepath) abort  " {{{
    let original_diffopt = &diffopt

    try
      set diffopt+=vertical
      execute "Gina patch --oneside "..a:filepath
    finally
      let &diffopt = original_diffopt
    endtry
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "Gina",
     \ })
endif  " }}}

if kg8m#plugin#register("Yggdroot/indentLine", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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
  let s:jpformat = {}

  function! s:jpformat.on_source() abort  " {{{
    let s:jpformat.formatexpr = "jpfmt#formatexpr()"

    function! s:jpformat.set_formatexpr() abort  " {{{
      if has_key(b:, "jpformat_formatexpr_set")
        return
      endif

      if &formatexpr !=# s:jpformat.formatexpr
        " Replace built-in `jq` operator
        let &formatexpr = s:jpformat.formatexpr
      endif

      let b:jpformat_formatexpr_set = v:true
    endfunction  " }}}
    call s:jpformat.set_formatexpr()

    let JpFormatCursorMovedI = v:false
    let JpAutoJoin = v:false
    let JpAutoFormat = v:false

    augroup my_vimrc  " {{{
      " Overwrite formatexpr
      autocmd OptionSet formatexpr call timer_start(200, { -> s:jpformat.set_formatexpr() })
    augroup END  " }}}
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: ["gq"],
     \   hook_source: s:jpformat.on_source,
     \ })
endif  " }}}

if kg8m#plugin#register("cohama/lexima.vim")  " {{{
  let s:lexima = {}

  let g:lexima_ctrlh_as_backspace = v:true

  function! s:lexima.add_rules_for_default() abort  " {{{
    for pair in kg8m#util#japanese_matchpairs()
      " `「` when
      "
      "   |
      "
      " then
      "
      "   「|」
      call lexima#add_rule(#{ char: pair[0], input_after: pair[1] })

      " `」` when
      "
      "   |」
      "
      " then
      "
      "   」|
      call lexima#add_rule(#{ char: pair[1], at: '\%#'..pair[1], leave: 1 })

      " `<BS>` when
      "
      "   「|」
      "
      " then
      "
      "   |
      "
      " Use `"<BS><Del>"` instead of `delete: 1` option because the option doesn't work
      call lexima#add_rule(#{ char: "<BS>", at: join(pair, '\%#'), input: "<BS><Del>" })
    endfor
  endfunction  " }}}

  function! s:lexima.add_rules_for_eruby() abort  " {{{
    " `<Space>` when
    "
    "   <%|
    "
    " then
    "
    "   <% | %>
    call lexima#add_rule(#{ char: "<Space>", at: '<%\%#', input_after: "<Space>%>", filetype: "eruby" })

    " `<Space>` when
    "
    "   <%|... %>
    "
    " then
    "
    "   <% |... %>
    call lexima#add_rule(#{ char: "<Space>", at: '<%\%#.*%>', leave: 1, filetype: "eruby" })

    " `<Space>` when
    "
    "   <%=|
    "
    " or
    "
    "   <%=something|
    "
    " then
    "
    "   <%= | %>
    "
    " or
    "
    "   <%=something | %>
    call lexima#add_rule(#{ char: "<Space>", at: '<%=\S*\%#', input_after: "<Space>%>", filetype: "eruby" })

    " `<Space>` when
    "
    "   <%=|... %>
    "
    " or
    "
    "   <%=something|... %>
    "
    " then
    "
    "   <%= |... %>
    "
    " or
    "
    "   <%=something ... %>
    call lexima#add_rule(#{ char: "<Space>", at: '<%=\S*\%#.*%>', leave: 1, filetype: "eruby" })
  endfunction  " }}}

  function! s:lexima.add_rules_for_markdown() abort  " {{{
    " `<Space>` when
    "
    "   [|]
    "
    " then
    "
    "   [ ] |
    call lexima#add_rule(#{ char: "<Space>", at: '\[\%#]', input: "<Space><Right><Space>", filetype: "markdown" })

    " `<Cr>` when
    "
    "   ```|```
    "
    " then
    "
    "   ```
    "   |
    "   ```
    call lexima#add_rule(#{ char: "<Cr>", at: '```\%#```', input_after: "<Cr>", filetype: "markdown" })

    " `<Cr>` when
    "
    "   ```foo|```
    "
    " then
    "
    "   ```foo
    "   |
    "   ```
    call lexima#add_rule(#{ char: "<Cr>", at: '```[a-z]\+\%#```', input_after: "<Cr>", filetype: "markdown" })
  endfunction  " }}}

  function! s:lexima.add_rules_for_vim() abort  " {{{
    " `"` when
    "
    "   ...|
    "
    " then
    "
    "   ..."|"
    "
    " NOTE: Always write comments at the beginning of line (indentation is allowed)
    call lexima#add_rule(#{ char: '"', at: '\S.*\%#', input_after: '"', filetype: "vim" })
  endfunction  " }}}

  function! s:lexima.on_post_source() abort  " {{{
    call s:lexima.add_rules_for_default()
    call s:lexima.add_rules_for_eruby()
    call s:lexima.add_rules_for_markdown()
    call s:lexima.add_rules_for_vim()

    call s:kg8m.define_cr_mapping_for_insert_mode()
    call s:kg8m.define_bs_mapping_for_insert_mode()
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy: v:true,
     \   on_i: v:true,
     \   hook_post_source: s:lexima.on_post_source,
     \ })
endif  " }}}

if kg8m#plugin#register("itchyny/lightline.vim")  " {{{
  let s:lightline = {}
  let g:kg8m.lightline = {}

  " http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2
  let s:lightline_elements = #{
    \   left: [
    \     ["mode", "paste"],
    \     ["warning_filepath"], ["normal_filepath"],
    \     ["separator"],
    \     ["filetype"],
    \     ["warning_fileencoding"], ["normal_fileencoding"],
    \     ["fileformat"],
    \     ["separator"],
    \     ["lineinfo_with_percent"],
    \     ["search_count"],
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
    \     lineinfo_with_percent: "%l/%L(%p%%) : %v",
    \   },
    \   component_function: #{
    \     normal_filepath:     "g:kg8m.lightline.normal_filepath",
    \     normal_fileencoding: "g:kg8m.lightline.normal_fileencoding",
    \     lsp_status:          "g:kg8m.lightline.lsp_status",
    \   },
    \   component_expand: #{
    \     warning_filepath:     "g:kg8m.lightline.warning_filepath",
    \     warning_fileencoding: "g:kg8m.lightline.warning_fileencoding",
    \     search_count:         "g:kg8m.lightline.search_count",
    \   },
    \   component_type: #{
    \     warning_filepath:     "warning",
    \     warning_fileencoding: "warning",
    \   },
    \   colorscheme: "kg8m",
    \ }

  function! g:kg8m.lightline.filepath() abort  " {{{
    return (s:lightline.is_readonly() ? "X " : "")
         \   ..s:lightline.filepath()
         \   ..(&modified ? " +" : (&modifiable ? "" : " -"))
  endfunction  " }}}

  function! g:kg8m.lightline.fileencoding() abort  " {{{
    return &fileencoding
  endfunction  " }}}

  function! s:lightline.filepath() abort  " {{{
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

  function! s:lightline.is_readonly() abort  " {{{
    return &filetype !=# "help" && &readonly
  endfunction  " }}}

  function! g:kg8m.lightline.normal_filepath() abort  " {{{
    return g:kg8m.lightline.is_irregular_filepath() ? "" : g:kg8m.lightline.filepath()
  endfunction  " }}}

  function! g:kg8m.lightline.normal_fileencoding() abort  " {{{
    return g:kg8m.lightline.is_irregular_fileencoding() ? "" : g:kg8m.lightline.fileencoding()
  endfunction  " }}}

  function! g:kg8m.lightline.warning_filepath() abort  " {{{
    " Use `%{...}` because component-expansion result is shared with other windows/buffers
    return "%{g:kg8m.lightline.is_irregular_filepath() ? g:kg8m.lightline.filepath() : ''}"
  endfunction  " }}}

  function! g:kg8m.lightline.warning_fileencoding() abort  " {{{
    " Use `%{...}` because component-expansion result is shared with other windows/buffers
    return "%{g:kg8m.lightline.is_irregular_fileencoding() ? g:kg8m.lightline.fileencoding() : ''}"
  endfunction  " }}}

  function! g:kg8m.lightline.is_irregular_filepath() abort  " {{{
    " `sudo:` prefix for sudo.vim, which I used to use
    return s:lightline.is_readonly() || kg8m#util#current_absolute_path() =~# '\v^(sudo:|suda://)'
  endfunction  " }}}

  function! g:kg8m.lightline.is_irregular_fileencoding() abort  " {{{
    return !empty(&fileencoding) && &fileencoding !=# "utf-8"
  endfunction  " }}}

  function! g:kg8m.lightline.search_count() abort  " {{{
    " Use `%{...}` because component-expansion result is shared with other windows/buffers
    return "%{v:hlsearch ? g:kg8m.lightline.search_count_if_searching() : ''}"
  endfunction  " }}}

  function! g:kg8m.lightline.search_count_if_searching() abort  " {{{
    let counts = searchcount()

    " 0: search was fully completed
    if counts.incomplete ==# 0
      let current = counts.current
      let total   = counts.total
    else
      let current = counts.current <# counts.maxcount ? counts.current : "?"
      let total   = counts.maxcount.."+"
    endif

    return "["..current.."/"..total.."]"
  endfunction  " }}}

  function! g:kg8m.lightline.lsp_status() abort  " {{{
    if s:lsp.is_target_buffer()
      if s:lsp.is_buffer_enabled()
        return s:lightline.lsp_status_buffer_enabled()
      else
        return "[LSP] Loading..."
      endif
    else
      return ""
    endif
  endfunction  " }}}

  function! s:lightline.lsp_status_buffer_enabled() abort  " {{{
    return "[LSP] Active"
  endfunction  " }}}

  if kg8m#plugin#register("tsuyoshicho/lightline-lsp")  " {{{
    let g:lightline#lsp#indicator_error       = "E:"
    let g:lightline#lsp#indicator_warning     = "W:"
    let g:lightline#lsp#indicator_information = "I:"
    let g:lightline#lsp#indicator_hint        = "H:"

    " Overwrite
    let s:lightline_elements.right += [
      \   ["lsp_status_for_attention"],
      \ ]
    call extend(g:lightline.component_expand, #{
       \   lsp_status_for_attention: "g:kg8m.lightline.lsp_status_for_attention",
       \ })
    call extend(g:lightline.component_type, #{
       \   lsp_status_for_attention: "warning",
       \ })

    " Overwrite
    function! s:lightline.lsp_status_buffer_enabled() abort  " {{{
      let stats = s:lightline.lsp_status_stats()
      return stats.is_attendable ? "" : stats.counts
    endfunction  " }}}

    function! g:kg8m.lightline.lsp_status_for_attention() abort  " {{{
      " Use `%{...}` because component-expansion result is shared with other windows/buffers
      return "%{g:kg8m.lightline.lsp_status_for_attention_detail()}"
    endfunction  " }}}

    function! g:kg8m.lightline.lsp_status_for_attention_detail() abort  " {{{
      if !s:lsp.is_target_buffer() || !s:lsp.is_buffer_enabled()
        return ""
      endif

      let stats = s:lightline.lsp_status_stats()
      return stats.is_attendable ? stats.counts : ""
    endfunction  " }}}

    function! s:lightline.lsp_status_stats() abort  " {{{
      let error       = lightline#lsp#error()
      let warning     = lightline#lsp#warning()
      let information = lightline#lsp#information()
      let hint        = lightline#lsp#hint()

      let is_attendable = !(empty(error) && empty(warning))

      let error       = empty(error)       ? g:lightline#lsp#indicator_error      .."0" : error
      let warning     = empty(warning)     ? g:lightline#lsp#indicator_warning    .."0" : warning
      let information = empty(information) ? g:lightline#lsp#indicator_information.."0" : information
      let hint        = empty(hint)        ? g:lightline#lsp#indicator_hint       .."0" : hint

      return #{ counts: join([error, warning, information, hint], " "), is_attendable: is_attendable }
    endfunction  " }}}

    " Don't load lazily because the `component_expand` doesn't work
    call kg8m#plugin#configure(#{
       \   lazy: v:false,
       \ })
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

if kg8m#plugin#register("lambdalisue/reword.vim")  " {{{
  cnoreabbrev <expr> Reword reword#live#start()
endif  " }}}

if kg8m#plugin#register("vim-scripts/sequence")  " {{{
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["vn", "<Plug>Sequence"]],
     \ })
endif  " }}}

if kg8m#plugin#register("AndrewRadev/splitjoin.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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

if kg8m#plugin#register("Shougo/unite.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:unite = {}

  let g:unite_winheight = "100%"

  augroup my_vimrc  " {{{
    autocmd FileType unite call s:unite.config_for_unite_buffer()
  augroup END  " }}}

  function! s:unite.config_for_unite_buffer() abort  " {{{
    call s:unite.enable_highlighting_cursorline()
    call s:unite.disable_default_mappings()
  endfunction  " }}}

  function! s:unite.enable_highlighting_cursorline() abort  " {{{
    setlocal cursorlineopt=both
  endfunction  " }}}

  function! s:unite.disable_default_mappings() abort  " {{{
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

if kg8m#plugin#register("FooSoft/vim-argwrap", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: [["nv", "<Plug>(asterisk-"]],
     \ })
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

if kg8m#plugin#register("t9md/vim-choosewin", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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

if kg8m#plugin#register("junegunn/vim-easy-align", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  vnoremap <Leader>a :EasyAlign<Space>

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "EasyAlign",
     \ })
endif  " }}}

if kg8m#plugin#register("easymotion/vim-easymotion")  " {{{
  let s:easymotion = {}
  function! s:easymotion() abort  " {{{
    return s:easymotion
  endfunction  " }}}

  map <Leader>f <Plug>(easymotion-bd-fn)

  " Replace default `f` and `F`
  map f <Plug>(easymotion-fl)
  map F <Plug>(easymotion-Fl)

  let g:EasyMotion_keys               = "FKLASDHGUIONMREWCVTYBX,.;J"
  let g:EasyMotion_startofline        = v:false
  let g:EasyMotion_do_shade           = v:false
  let g:EasyMotion_do_mapping         = v:false
  let g:EasyMotion_smartcase          = v:true
  let g:EasyMotion_use_migemo         = v:true
  let g:EasyMotion_use_upper          = v:true
  let g:EasyMotion_enter_jump_first   = v:true
  let g:EasyMotion_add_search_history = v:false

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_map: "<Plug>(easymotion-",
     \ })
endif  " }}}

if kg8m#plugin#register("lambdalisue/vim-findent")  " {{{
  let s:findent = {}

  let g:findent#enable_messages = v:false
  let g:findent#enable_warnings = v:false

  augroup my_vimrc  " {{{
    autocmd FileType * call s:findent.run()
  augroup END  " }}}

  function! s:findent.run() abort  " {{{
    if &filetype !=# "gitcommit"
      Findent
    endif
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:   v:true,
     \   on_cmd: "Findent",
     \ })
endif  " }}}

call kg8m#plugin#register("thinca/vim-ft-diff_fold", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("thinca/vim-ft-help_fold")
call kg8m#plugin#register("muz/vim-gemfile", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("kana/vim-gf-user")

if kg8m#plugin#register("tpope/vim-git", #{ if: kg8m#util#is_git_commit() })  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup my_vimrc  " {{{
    autocmd FileType gitcommit let b:did_ftplugin = v:true
  augroup END  " }}}
endif  " }}}

" Use LSP for completion, linting/formatting codes, and jumping to definition.
" Use vim-go's highlightings, foldings, and commands.
if kg8m#plugin#register("fatih/vim-go", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:go = {}

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
    autocmd FileType go call s:go.setup()
  augroup END  " }}}

  function! s:go.setup() abort  " {{{
    setlocal foldmethod=syntax

    if kg8m#util#on_tmux()  " {{{
      nnoremap <buffer> <leader>r :write<Cr>:call VimuxRunCommand("go run -race <C-r>%")<Cr>
    else
      nnoremap <buffer> <leader>r :write<Cr>:GoRun -race %<Cr>
    endif  " }}}
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy:  v:true,
     \   on_ft: "go",
     \ })
endif  " }}}

call kg8m#plugin#register("tpope/vim-haml", #{ if: !kg8m#util#is_git_tmp_edit() })

" Text object for indentation: i
call kg8m#plugin#register("michaeljsmith/vim-indent-object")

if kg8m#plugin#register("osyo-manga/vim-jplus")  " {{{
  " Remove line-connectors with `J`
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
  let s:matchup = {}

  let g:matchup_no_version_check = v:true
  let g:matchup_transmute_enabled = v:true
  let g:matchup_matchparen_status_offscreen = v:false
  let g:matchup_matchparen_deferred = v:true

  " Fade highlighting because it is noisy when editing HTML codes in JavaScript's template literal like html`...`
  let g:matchup_matchparen_deferred_fade_time = 500

  let g:matchup_matchpref = #{
    \   html:  #{ tagnameonly: v:true },
    \   eruby: #{ tagnameonly: v:true },
    \ }

  augroup my_vimrc  " {{{
    autocmd ColorScheme * call s:matchup.overwrite_colors()
  augroup END  " }}}

  function! s:matchup.overwrite_colors() abort  " {{{
    " Original `highlight default link MatchParenCur MatchParen` is too confusing because current parenthesis looks as
    " same as matched one.
    highlight default link MatchParenCur Cursor
  endfunction  " }}}
endif  " }}}

if kg8m#plugin#register("mattn/vim-molder", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:molder_show_hidden = v:true

  nmap <Leader>e :edit %:h<Cr>

  augroup my_vimrc  " {{{
    " Cancel molder
    autocmd FileType molder nnoremap <buffer> q     <C-o>
    autocmd FileType molder nnoremap <buffer> <C-c> <C-o>
  augroup END  " }}}
endif  " }}}

if kg8m#plugin#register("kana/vim-operator-replace")  " {{{
  map r <Plug>(operator-replace)

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   depends: ["vim-operator-user"],
     \   on_map:  [["nv", "<Plug>(operator-replace)"]],
     \ })
endif  " }}}

if kg8m#plugin#register("kana/vim-operator-user")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_func: "operator#user#define",
     \ })
endif  " }}}

if kg8m#plugin#register("kg8m/vim-parallel-auto-ctags", #{ if: kg8m#util#on_rails_dir() && !kg8m#util#is_git_tmp_edit() })  " {{{
  let &tags .= ","..kg8m#util#rubygems_path().."/../tags"

  let g:parallel_auto_ctags#options      = ["--fields=n", "--tag-relative=yes", "--recurse=yes", "--sort=yes", "--exclude=.vim-sessions"]
  let g:parallel_auto_ctags#entry_points = #{
    \   pwd:  #{
    \     path:    ".",
    \     options: g:parallel_auto_ctags#options + ["--exclude=node_modules", "--exclude=vendor/bundle", "--languages=-rspec"],
    \     events:  ["VimEnter", "BufWritePost"],
    \     silent:  v:false,
    \   },
    \   gems: #{
    \     path:    kg8m#util#rubygems_path().."/..",
    \     options: g:parallel_auto_ctags#options + ["--exclude=test", "--exclude=spec", "--languages=ruby"],
    \     events:  ["VimEnter"],
    \     silent:  v:false,
    \   },
    \ }
endif  " }}}

if kg8m#plugin#register("thinca/vim-prettyprint", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  " Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work
  call kg8m#plugin#configure(#{
     \   lazy: v:false,
     \ })
endif  " }}}

if kg8m#plugin#register("lambdalisue/vim-protocol", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  " Disable netrw.vim
  let g:loaded_netrw             = v:true
  let g:loaded_netrwPlugin       = v:true
  let g:loaded_netrwSettings     = v:true
  let g:loaded_netrwFileHandlers = v:true

  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   on_path: '^https\?://',
     \ })
endif  " }}}

if kg8m#plugin#register("tpope/vim-rails", #{ if: !kg8m#util#is_git_tmp_edit() && kg8m#util#on_rails_dir() })  " {{{
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

  if isdirectory("spec/support")
    let g:rails_path_additions += [
      \   "spec/support",
      \ ]
  endif

  " Don't load lazily because some features don't work
  call kg8m#plugin#configure(#{
     \   lazy: v:false,
     \ })
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
     \   lazy:  v:true,
     \   on_ft: "ruby",
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

if kg8m#plugin#register("machakann/vim-sandwich")  " {{{
  let s:sandwich = {}

  let g:sandwich_no_default_key_mappings = v:true
  let g:operator_sandwich_no_default_key_mappings = v:true

  vmap <Leader>sa <Plug>(operator-sandwich-add)
  nmap <Leader>sd <Plug>(operator-sandwich-delete)<Plug>(textobj-sandwich-query-a)
  nmap <Leader>sr <Plug>(operator-sandwich-replace)<Plug>(textobj-sandwich-query-a)

  nmap . <Plug>(operator-sandwich-dot)

  function! s:sandwich.on_post_source() abort  " {{{
    let common_options         = #{ nesting: v:true, match_syntax: v:true }
    let common_add_options     = extend(#{ kind: ["add", "replace"], action: ["add"] }, common_options)
    let common_delete_options  = extend(#{ kind: ["delete", "replace", "textobj"], action: ["delete"], regex: v:true }, common_options)
    let common_zenkaku_options = extend(#{ kind: ["add", "delete", "replace", "textobj"], action: ["add", "delete"] }, common_options)
    let g:sandwich#recipes =
      \   deepcopy(g:sandwich#default_recipes) +
      \   [
      \      extend(#{ buns: ["( ", " )"], input: ["("] }, common_add_options),
      \      extend(#{ buns: ["[ ", " ]"], input: ["["] }, common_add_options),
      \      extend(#{ buns: ["{ ", " }"], input: ["{"] }, common_add_options),
      \      extend(#{ buns: ['[(（]\s*', '\s*[)）]'], input: ["(", ")"] }, common_delete_options),
      \      extend(#{ buns: ['[[［]\s*', '\s*[\]］]'], input: ["[", "]"] }, common_delete_options),
      \      extend(#{ buns: ['[{｛]\s*', '\s*[}｝]'], input: ["{", "}"] }, common_delete_options),
      \   ] + (
      \     kg8m#util#japanese_matchpairs()
      \       ->map({ _, pair -> extend(#{ buns: pair, input: pair }, common_zenkaku_options) })
      \   )
  endfunction  " }}}

  call kg8m#plugin#configure(#{
     \   lazy: v:true,
     \   on_map:  [["nv", "<Plug>(operator-sandwich-"]],
     \   hook_source: s:sandwich.on_post_source,
     \ })
endif  " }}}

" See also vim-startify's settings
if kg8m#plugin#register("xolox/vim-session", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:session = {}

  let g:session_directory         = getcwd().."/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = v:false

  set sessionoptions=buffers,folds

  " Prevent vim-session's `tabpage_filter()` from removing inactive buffers
  set sessionoptions+=tabpages

  augroup my_vimrc  " {{{
    autocmd BufWritePost * silent call s:session.save()
  augroup END  " }}}

  function! s:session.save() abort  " {{{
    call s:kg8m.restore_foldmethod()
    execute "SaveSession "..s:session.name()
  endfunction  " }}}

  function! s:session.name() abort  " {{{
    let name =
      \   "%"
      \     ->expand()
      \     ->fnamemodify(":p")
      \     ->substitute("/", "+=", "g")
      \     ->substitute('^\.', "_", "")

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
  let s:startify = {}

  let g:startify_session_dir         = g:session_directory
  let g:startify_session_number      = 10
  let g:startify_session_persistence = v:false
  let g:startify_session_sort        = v:true

  let g:startify_enable_special = v:true
  let g:startify_change_to_dir  = v:false
  let g:startify_relative_path  = v:true
  let g:startify_lists          = [
    \   #{ type: "commands",  header: ["My commands:"] },
    \   #{ type: "bookmarks", header: ["My bookmarks:"] },
    \   #{ type: "sessions",  header: ["My sessions:"] },
    \   #{ type: "files",     header: ["Recently opened files:"] },
    \   #{ type: "dir",       header: ["Recently modified files in the current directory:"] },
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
    \   "  Vim version: "..v:versionlong,
    \   "",
    \ ]

  let g:startify_custom_header = g:startify_custom_header + [
    \   "  LSPs: ",
    \ ]
  for lsp in kg8m#plugin#lsp#get_registered()
    let g:startify_custom_header = g:startify_custom_header + [
      \   "  "..(lsp.available ? "👼 " : "👿 ")..lsp.name,
      \ ]
  endfor

  let g:startify_custom_header = g:startify_custom_header + [""]

  augroup my_vimrc  " {{{
    autocmd ColorScheme * call s:startify.overwrite_colors()
  augroup END  " }}}

  function! s:startify.overwrite_colors() abort  " {{{
    highlight StartifyFile   guifg=#FFFFFF
    highlight StartifyHeader guifg=#FFFFFF
    highlight StartifyPath   guifg=#777777
    highlight StartifySlash  guifg=#777777
  endfunction  " }}}
endif  " }}}

if kg8m#plugin#register("kopischke/vim-stay", #{ if: !kg8m#util#is_git_commit() })  " {{{
  set viewoptions=cursor,folds

  augroup my_vimrc  " {{{
    autocmd User BufStaySavePre call s:kg8m.restore_foldmethod()
  augroup END  " }}}
endif  " }}}

if kg8m#plugin#register("janko/vim-test", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:test = {}

  nnoremap <Leader>T :write<Cr>:TestFile<Cr>
  nnoremap <Leader>t :write<Cr>:TestNearest<Cr>

  if kg8m#util#on_tmux()
    function! s:test.my_vimux_strategy(command) abort  " {{{
      " Just execute the command without echo it
      call VimuxRunCommand(a:command)
    endfunction  " }}}

    let g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    let g:test#custom_strategies.vimux = s:test.my_vimux_strategy
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

call kg8m#plugin#register("cespare/vim-toml", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("posva/vim-vue", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("thinca/vim-zenspace")  " {{{
  let g:zenspace#default_mode = "on"

  augroup my_vimrc  " {{{
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endif  " }}}

if kg8m#plugin#register("Shougo/vimproc")  " {{{
  call kg8m#plugin#configure(#{
     \   lazy:    v:true,
     \   build:   "make",
     \   on_func: "vimproc#",
     \ })
endif  " }}}

if kg8m#plugin#register("benmills/vimux", #{ if: kg8m#util#on_tmux() && !kg8m#util#is_git_tmp_edit() })  " {{{
  let s:vimux = {}

  function! s:vimux.on_source() abort  " {{{
    let g:VimuxHeight     = 30
    let g:VimuxUseNearest = v:true

    augroup my_vimrc  " {{{
      autocmd VimLeavePre * :VimuxCloseRunner
    augroup END  " }}}
  endfunction  " }}}

  function! s:vimux.on_post_source() abort  " {{{
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
        let views = split(_VimuxTmux("list-".._VimuxRunnerType().."s"), "\n")
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
     \   hook_source:      s:vimux.on_source,
     \   hook_post_source: s:vimux.on_post_source,
     \ })
endif  " }}}

" See `kg8m#util#xxx_module()`
call kg8m#plugin#register("vim-jp/vital.vim")

if kg8m#plugin#register("simeji/winresizer", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
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
  let g:htl_all_templates = v:false

  call kg8m#plugin#configure(#{
     \   depends: "vim-javascript",
     \ })

  call kg8m#plugin#register("pangloss/vim-javascript")
endif  " }}}

if kg8m#plugin#register("LeafCage/yankround.vim")  " {{{
  let s:yankround = {}

  let g:yankround_max_history = 500

  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap <S-p> <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)

  " https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
  " For fzf.vim
  function! s:yankround.list() abort  " {{{
    return map(copy(g:_yankround_cache), { index, _ -> s:yankround.format_item(index) })
  endfunction  " }}}

  function! s:yankround.format_item(index) abort  " {{{
    let [text, _]  = yankround#_get_cache_and_regtype(a:index)

    " Avoid shell's syntax error in fzf's preview
    let text = substitute(text, "\n", "\\\\n", "g")

    return printf("%3d\t%s", a:index, text)
  endfunction  " }}}

  function! s:yankround.preview_command() abort  " {{{
    let command  = "echo {}"
    let command .= " | sed -e 's/^ *[0-9]\\{1,\\}\t//' -e 's/\\\\/\\\\\\\\/g'"
    let command .= " | head -n5"

    return command
  endfunction  " }}}

  function! s:yankround.handler(yank_item) abort  " {{{
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
  let s:molokai = {}

  let g:molokai_original = v:true

  augroup my_vimrc  " {{{
    autocmd ColorScheme molokai call s:molokai.overwrite()
  augroup END  " }}}

  function! s:molokai.overwrite() abort  " {{{
    highlight Comment       guifg=#AAAAAA
    highlight ColorColumn                  guibg=#1F1E19
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
 "\   Dark Blue, Dark Magenta, Dark Cyan,  Light GrEy,
 "\   Dark Grey, Red,          Green,      YellOw,
 "\   Blue,      Magenta,      Cyan,       White,
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
  autocmd WinEnter,BufWinEnter * set wincolor=
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
set signcolumn=number

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
set colorcolumn=+1
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start
set fixendofline

let g:html_indent_script1 = "inc"
let g:html_indent_style1  = "inc"

augroup my_vimrc  " {{{
  autocmd FileType neosnippet set noexpandtab
  autocmd FileType markdown,moin set colorcolumn=
  autocmd FileType text,markdown,moin setlocal cinkeys-=:

  " Lazily set formatoptions to overwrite others
  autocmd FileType * call s:kg8m.setup_formatoptions()
  autocmd FileType * call timer_start(300, { -> s:kg8m.setup_formatoptions() })

  autocmd BufWritePre * if &filetype ==# "" || has_key(b:, "ftdetect") | unlet! b:ftdetect | filetype detect | endif
augroup END  " }}}

function! s:kg8m.setup_formatoptions() abort  " {{{
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

  if &filetype =~# '\v^(gitcommit|markdown|moin|text)$'
    setlocal fo-=r fo-=o
  endif
endfunction  " }}}

augroup my_vimrc  " {{{
  autocmd WinEnter,BufEnter,SessionLoadPost * call s:kg8m.dim_inactive_windows()
  autocmd VimResized                        * call s:kg8m.dim_inactive_windows(#{ force: v:true })
augroup END  " }}}

function! s:kg8m.dim_inactive_windows(options = {}) abort  " {{{
  let current_winnr = winnr()
  let last_winnr    = winnr("$")

  if last_winnr > 1
    let color_columns = range(1, &columns)->join(",")
  endif

  for winnr in range(1, last_winnr)
    if winnr ==# current_winnr
      if has_key(w:, "original_colorcolumn")
        let &colorcolumn = w:original_colorcolumn
        unlet w:original_colorcolumn
      endif
    else
      if getwinvar(winnr, "original_colorcolumn", v:null) ==# v:null
        call setwinvar(winnr, "original_colorcolumn", getwinvar(winnr, "&colorcolumn"))
        call setwinvar(winnr, "&colorcolumn", color_columns)
      else
        if get(a:options, "force", v:false)
          call setwinvar(winnr, "&colorcolumn", color_columns)
        endif
      endif
    endif
  endfor
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
  autocmd BufEnter addp-hunk-edit.diff setlocal nofoldenable

  " http://d.hatena.ne.jp/gnarl/20120308/1331180615
  autocmd InsertEnter * call s:kg8m.switch_to_manual_folding()
augroup END  " }}}

function! s:kg8m.switch_to_manual_folding() abort  " {{{
  if !has_key(w:, "last_fdm")
    let w:last_fdm = &foldmethod
    setlocal foldmethod=manual
  endif
endfunction  " }}}

" Call this before saving session
function! s:kg8m.restore_foldmethod() abort  " {{{
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
" Single/no slash: only filename like `.vimrc.swp`
let s:swapdir = expand("~/tmp/.vimswap//")
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir, "p")
endif
let &directory = s:swapdir

" Undo
set hidden
set undofile

let s:undodir = expand("~/tmp/.vimundo")
if !isdirectory(s:undodir)
  call mkdir(s:undodir, "p")
endif
let &undodir = s:undodir

set wildmenu
set wildmode=list:longest,full

" Time to wait for a key code or mapped key sequence
set timeoutlen=3000

" Support Japanese kakkos
let &matchpairs .= ","..(kg8m#util#japanese_matchpairs()->map({ _, pair -> pair->join(":") })->join(","))

" Auto reload
augroup my_vimrc  " {{{
  autocmd VimEnter * call timer_start(1000, { -> s:kg8m.checktime() })
augroup END  " }}}

function! s:kg8m.checktime() abort  " {{{
  if has_key(s:, "checktime_timer")
    call timer_stop(s:checktime_timer)
    unlet s:checktime_timer
  endif

  try
    " `checktime` is not available in Command Line mode
    if !getcmdwintype()->empty()
      return
    endif

    checktime
  " Sometimes `checktime` raise an error
  "   - e.g., E565: "Not allowed to change text or change window" when using vim-sandwich
  catch /^Vim\%((\a\+)\)\=:E565:/
    " Do nothing
  finally
    let s:checktime_timer = timer_start(1000, { -> s:kg8m.checktime() })
  endtry
endfunction  " }}}

set whichwrap=b,s,h,l,<,>,[,],~
set maxmempattern=5000

" A comma separated list of these words:
"   - block:   Allow virtual editing in Visual block mode.
"   - insert:  Allow virtual editing in Insert mode.
"   - all:     Allow virtual editing in all modes.
"   - onemore: Allow the cursor to move just past the end of the line.
set virtualedit=block

if !kg8m#util#is_git_tmp_edit()  " {{{
  " http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
  augroup my_vimrc  " {{{
    autocmd BufWriteCmd *[,*] call s:kg8m.write_check_typo(expand("<afile>"))
  augroup END  " }}}

  function! s:kg8m.write_check_typo(file) abort  " {{{
    let writecmd = "write"..(v:cmdbang ? "!" : "").." "..a:file

    if a:file =~? "[qfreplace]"
      return
    endif

    let prompt = "possible typo: really want to write to '"..a:file.."'?(y/n):"
    let input = input(prompt)

    if input =~? '^y'
      execute writecmd
    endif
  endfunction  " }}}

  augroup my_vimrc  " {{{
    autocmd BufWritePost .eslintrc.*,package.json call kg8m#javascript#restart_eslint_d()
    autocmd BufWritePost .rubocop.yml             call kg8m#ruby#restart_rubocop_daemon()
  augroup END  " }}}
endif  " }}}
" }}}

" ----------------------------------------------
" Commands  " {{{
" http://vim-users.jp/2009/05/hack17/
command! -nargs=1 -complete=file Rename f <args> | call delete(expand("#")) | write

" Show counts (h v_g_CTRL-G)
command! -nargs=0 -range Stats call feedkeys("g\<C-g>")
command! -nargs=0 -range Counts Stats
" }}}

" ----------------------------------------------
" Keymappings  " {{{
" Mapping Functions  " {{{
function! s:kg8m.define_cr_mapping_for_insert_mode() abort  " {{{
  imap <silent><expr> <Cr> <SID>kg8m().cr_for_insert_mode()
endfunction  " }}}

function! s:kg8m.define_bs_mapping_for_insert_mode() abort  " {{{
  inoremap <silent><expr> <BS> <SID>kg8m().bs_for_insert_mode()
endfunction  " }}}

function! s:kg8m.define_bs_mapping_to_refresh_completion() abort  " {{{
  call s:kg8m.define_bs_mapping_for_insert_mode()
endfunction  " }}}

function! s:kg8m.define_completion_mappings() abort  " {{{
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

  call s:kg8m.define_cr_mapping_for_insert_mode()
endfunction  " }}}

function! s:kg8m.cr_for_insert_mode() abort  " {{{
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif vsnip#available(1)
    return "\<Plug>(vsnip-expand-or-jump)"
  else
    if pumvisible()
      return asyncomplete#close_popup()
    else
      return lexima#expand("<Cr>", "i")
    endif
  endif
endfunction  " }}}

function! s:kg8m.bs_for_insert_mode() abort  " {{{
  return lexima#expand("<BS>", "i")..s:asyncomplete.refresh_completion()
endfunction  " }}}
" }}}

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

function! s:kg8m.remove_trailing_whitespaces() abort  " {{{
  let position = getpos(".")
  keeppatterns '<,'>s/\s\+$//ge
  call setpos(".", position)
endfunction  " }}}
vnoremap <Leader>w :call <SID>kg8m().remove_trailing_whitespaces()<Cr>

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
" Disable exchanging because indentation is sometimes bad
" nnoremap p ]p
" nnoremap <S-p> ]<S-p>
" nnoremap ]p p
" nnoremap ]<S-p> <S-p>

" Moving in INSERT mode
inoremap <C-k> <Up>
inoremap <C-f> <Right>
inoremap <C-j> <Down>
inoremap <C-b> <Left>
inoremap <C-a> <Home>
inoremap <C-e> <End>
cnoremap <C-k> <Up>
cnoremap <C-f> <Right>
cnoremap <C-j> <Down>
cnoremap <C-b> <Left>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
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
    autocmd VimLeavePre * call s:kg8m.save_window_size()

    function! s:kg8m.save_window_size() abort  " {{{
      let options = [
        \   "set columns="..&columns,
        \   "set lines="..&lines,
        \   "winpos "..getwinposx().." "..getwinposy(),
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
let s:local_vimrc_path = expand("~/.vimrc.local")
if filereadable(s:local_vimrc_path)
  execute "source "..s:local_vimrc_path
endif
" }}}
