let s:registered = []
let s:configs    = []
let s:filetypes  = []

let s:js_filetypes   = ["javascript", "typescript"]
let s:sh_filetypes   = ["sh", "zsh"]
let s:yaml_filetypes = ["eruby.yaml", "yaml", "yaml.ansible"]

function kg8m#plugin#lsp#configure() abort  " {{{
  call s:register_servers()
  call uniq(sort(s:filetypes))

  call kg8m#plugin#configure(#{
  \   lazy:  v:true,
  \   on_ft: s:filetypes,
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })

  call kg8m#plugin#register("mattn/vim-lsp-settings", #{ if: v:false, merged: v:false })
  call kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", #{ if: v:false, merged: v:false })
endfunction  " }}}

function kg8m#plugin#lsp#servers() abort  " {{{
  return s:registered
endfunction  " }}}

function kg8m#plugin#lsp#is_target_buffer() abort  " {{{
  if !has_key(b:, "lsp_target_buffer")
    let b:lsp_target_buffer = v:false
    for filetype in s:filetypes
      if &filetype ==# filetype
        let b:lsp_target_buffer = v:true
        break
      endif
    endfor
  endif

  return b:lsp_target_buffer
endfunction  " }}}

" cf. s:on_lsp_buffer_enabled()
function kg8m#plugin#lsp#is_buffer_enabled() abort  " {{{
  if has_key(b:, "lsp_buffer_enabled")
    return v:true
  else
    return s:are_all_servers_running()
  endif
endfunction  " }}}

function s:register_servers() abort  " {{{
  " yarn add bash-language-server  " {{{
  " Syntax errors sometimes occur when editing zsh file
  call s:register(#{
  \   name: "bash-language-server",
  \   cmd: { server_info -> ["bash-language-server", "start"] },
  \   allowlist: s:sh_filetypes,
  \ })
  " }}}

  " yarn add vscode-langservers-extracted  " {{{
  " css-languageserver doesn't work when editing .sass file
  call s:register(#{
  \   name: "css-language-server",
  \   cmd: { server_info -> ["vscode-css-language-server", "--stdio"] },
  \   allowlist: ["css", "less", "scss"],
  \   config: { -> #{ refresh_pattern: kg8m#plugin#completion#refresh_pattern("css") } },
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
  call s:register(#{
  \   name: "efm-langserver",
  \   cmd: { server_info -> ["efm-langserver"] },
  \   allowlist: [
  \     "css", "eruby", "go", "html", "json", "make", "markdown", "ruby", "vim",
  \   ] + s:js_filetypes + s:sh_filetypes + s:yaml_filetypes,
  \ })
  " }}}

  " go get github.com/nametake/golangci-lint-langserver  " {{{
  call s:register(#{
  \   name: "golangci-lint-langserver",
  \   cmd: { server_info -> ["golangci-lint-langserver"] },
  \   initialization_options: #{
  \     command: ["golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"],
  \   },
  \   allowlist: ["go"],
  \ })
  " }}}

  " go get golang.org/x/tools/gopls  " {{{
  call s:register(#{
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
  call s:register(#{
  \   name: "html-language-server",
  \   cmd: { server_info -> ["vscode-html-language-server", "--stdio"] },
  \   initialization_options: #{ embeddedLanguages: #{ css: v:true, javascript: v:true } },
  \   allowlist: ["eruby", "html"],
  \   config: { -> #{ refresh_pattern: kg8m#plugin#completion#refresh_pattern("html") } },
  \   executable_name: "vscode-html-language-server",
  \ })
  " }}}

  " yarn add vscode-langservers-extracted  " {{{
  call s:register(#{
  \   name: "json-language-server",
  \   cmd: { server_info -> ["vscode-json-language-server", "--stdio"] },
  \   allowlist: ["json"],
  \   config: { -> #{ refresh_pattern: kg8m#plugin#completion#refresh_pattern("json") } },
  \   workspace_config: { -> #{
  \     json: #{
  \       format: #{ enable: v:true },
  \       schemas: s:schemas_json(),
  \    },
  \   } },
  \   executable_name: "vscode-json-language-server",
  \ })
  " }}}

  " gem install solargraph  " {{{
  " initialization_options: https://github.com/castwide/vscode-solargraph/blob/master/package.json
  call s:register(#{
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
  call s:register(#{
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
  call s:register(#{
  \   name: "typescript-language-server",
  \   cmd: { server_info -> ["typescript-language-server", "--stdio"] },
  \   allowlist: s:js_filetypes,
  \ })
  " }}}

  " yarn add vim-language-server  " {{{
  call s:register(#{
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
  call s:register(#{
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
  call s:register(#{
  \   name: "yaml-language-server",
  \   cmd: { server_info -> ["yaml-language-server", "--stdio"] },
  \   allowlist: s:yaml_filetypes,
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
endfunction  " }}}

function s:register(config) abort  " {{{
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

    let s:configs   += [a:config]
    let s:filetypes += a:config.allowlist

    call add(s:registered, #{ name: a:config.name, available: v:true })
  else
    call add(s:registered, #{ name: a:config.name, available: v:false })
  endif
endfunction  " }}}

function s:enable_servers() abort  " {{{
  for config in s:configs
    for key in ["config", "initialization_options", "workspace_config"]
      if has_key(config, key) && type(config[key]) ==# v:t_func
        let config[key] = config[key]()
      endif
    endfor

    call lsp#register_server(config)
  endfor
endfunction  " }}}

" Depend on vim-fzf-tjump
function s:subscribe_stream() abort  " {{{
  call lsp#callbag#pipe(
  \   lsp#stream(),
  \   lsp#callbag#filter(function("s:is_definition_failed_stream")),
  \   lsp#callbag#subscribe(#{ next: { -> fzf_tjump#jump() } }),
  \ )
endfunction  " }}}

function s:is_definition_failed_stream(x) abort  " {{{
  return has_key(a:x, "request") && get(a:x.request, "method", "") ==# "textDocument/definition" &&
  \   has_key(a:x, "response") && empty(get(a:x.response, "result", []))
endfunction  " }}}

function s:on_lsp_buffer_enabled() abort  " {{{
  if get(b:, "lsp_buffer_enabled", v:false)
    return
  endif

  if !s:are_all_servers_running()
    return
  endif

  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <Plug>(lsp-next-diagnostic)
  nmap <buffer> ge <Plug>(lsp-next-error)
  nmap <buffer> <S-h> <Plug>(lsp-hover)

  call s:overwrite_capabilities()

  if s:is_definition_supported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  augroup my_vimrc  " {{{
    autocmd InsertLeave <buffer> call timer_start(100, { -> s:document_format(#{ sync: v:false }) })
    autocmd BufWritePre <buffer> call s:document_format(#{ sync: v:true })
  augroup END  " }}}

  " cf. kg8m#plugin#lsp#is_buffer_enabled()
  let b:lsp_buffer_enabled = v:true
endfunction  " }}}

function s:reset_target_buffer() abort  " {{{
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
endfunction  " }}}

function s:are_all_servers_running() abort  " {{{
  for server_name in lsp#get_allowed_servers()
    if lsp#get_server_status(server_name) !=# "running"
      return v:false
    endif
  endfor

  return v:true
endfunction  " }}}

" Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
" formatting from language servers which have capability of document formatting. I want to do formatting by
" efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
" language server which has capability of document formatting.
function s:overwrite_capabilities() abort  " {{{
  if &filetype !~# '\v^(go|javascript|ruby|typescript)$'
    return
  endif

  if !s:are_all_servers_running()
    call kg8m#util#echo_error_msg("Cannot to overwrite language servers' capabilities because some of them are not running")
    return
  endif

  for server_name in lsp#get_allowed_servers()->filter("v:val !=# 'efm-langserver'")
    let capabilities = lsp#get_server_capabilities(server_name)

    if has_key(capabilities, "documentFormattingProvider")
      let capabilities.documentFormattingProvider = v:false
    endif
  endfor
endfunction  " }}}

function s:is_definition_supported() abort  " {{{
  if !s:are_all_servers_running()
    call kg8m#util#echo_error_msg("Cannot to judge whether definition is supported or not because some of them are not running")
    return
  endif

  for server_name in lsp#get_allowed_servers()
    let capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", v:false)
      return v:true
    endif
  endfor

  return v:false
endfunction  " }}}

function s:document_format(options = {}) abort  " {{{
  if get(a:options, "sync", v:true)
    silent LspDocumentFormatSync
  else
    if &modified && mode() ==# "n"
      silent LspDocumentFormat
    endif
  endif
endfunction  " }}}

function s:schemas_json() abort  " {{{
  if !has_key(s:, "lsp_schemas_json")
    let filepath = kg8m#plugin#get_info("vim-lsp-settings").path.."/data/catalog.json"
    let json     = filepath->readfile()->join("\n")->json_decode()
    let s:lsp_schemas_json = json.schemas
  endif

  return s:lsp_schemas_json
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:lsp_diagnostics_enabled          = v:true
  let g:lsp_diagnostics_echo_cursor      = v:false
  let g:lsp_diagnostics_float_cursor     = v:true
  let g:lsp_signs_enabled                = v:true
  let g:lsp_highlight_references_enabled = v:true
  let g:lsp_fold_enabled                 = v:false
  let g:lsp_semantic_enabled             = v:true

  let g:lsp_async_completion = v:true

  let g:lsp_log_verbose = v:true
  let g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc  " {{{
    autocmd User lsp_setup          call s:enable_servers()
    autocmd User lsp_setup          call s:subscribe_stream()
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

    autocmd FileType * call s:reset_target_buffer()
  augroup END  " }}}

endfunction  " }}}

function s:on_post_source() abort  " {{{
  " https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
  call lsp#enable()
endfunction  " }}}
