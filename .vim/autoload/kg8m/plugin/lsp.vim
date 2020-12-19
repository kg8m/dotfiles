vim9script

final s:cache = {
  registered: [],
  configs:    [],
  filetypes:  [],
}

const s:js_filetypes   = ["javascript", "typescript"]
const s:sh_filetypes   = ["sh", "zsh"]
const s:yaml_filetypes = ["eruby.yaml", "yaml", "yaml.ansible"]

var s:is_initialized = v:false

def kg8m#plugin#lsp#configure(): void  # {{{
  s:register_servers()
  uniq(sort(s:cache.filetypes))

  kg8m#plugin#configure({
    lazy:  v:true,
    on_ft: s:cache.filetypes,
    hook_source:      function("s:on_source"),
    hook_post_source: function("s:on_post_source"),
  })

  kg8m#plugin#register("mattn/vim-lsp-settings", { if: v:false, merged: v:false })
  kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", { if: v:false, merged: v:false })
enddef  # }}}

def kg8m#plugin#lsp#servers(): list<dict<any>>  # {{{
  return s:cache.registered
enddef  # }}}

def kg8m#plugin#lsp#is_target_buffer(): bool  # {{{
  if !has_key(b:, "lsp_target_buffer")
    b:lsp_target_buffer = v:false

    for filetype in s:cache.filetypes
      if &filetype ==# filetype
        b:lsp_target_buffer = v:true
        break
      endif
    endfor
  endif

  return b:lsp_target_buffer
enddef  # }}}

# cf. s:on_lsp_buffer_enabled()
def kg8m#plugin#lsp#is_buffer_enabled(): bool  # {{{
  if has_key(b:, "lsp_buffer_enabled")
    return v:true
  else
    return s:are_all_servers_running()
  endif
enddef  # }}}

def s:register_servers(): void  # {{{
  # yarn add bash-language-server  # {{{
  # Syntax errors sometimes occur when editing zsh file
  s:register({
    name: "bash-language-server",
    cmd: { server_info -> ["bash-language-server", "start"] },
    allowlist: s:sh_filetypes,
  })
  # }}}

  # yarn add vscode-langservers-extracted  # {{{
  # css-languageserver doesn't work when editing .sass file
  s:register({
    name: "css-language-server",
    cmd: { server_info -> ["vscode-css-language-server", "--stdio"] },
    allowlist: ["css", "less", "scss"],
    config: { -> { refresh_pattern: kg8m#plugin#completion#refresh_pattern("css") } },
    workspace_config: {
      css:  { lint: { validProperties: [] } },
      less: { lint: { validProperties: [] } },
      scss: { lint: { validProperties: [] } },
    },
    executable_name: "vscode-css-language-server",
  })
  # }}}

  # go get github.com/mattn/efm-langserver  # {{{
  # cf. .config/efm-langserver/config.yaml
  s:register({
    name: "efm-langserver",
    cmd: { server_info -> ["efm-langserver"] },
    allowlist: [
      "css", "eruby", "go", "html", "json", "make", "markdown", "ruby", "vim",
    ] + s:js_filetypes + s:sh_filetypes + s:yaml_filetypes,
  })
  # }}}

  # go get github.com/nametake/golangci-lint-langserver  # {{{
  s:register({
    name: "golangci-lint-langserver",
    cmd: { server_info -> ["golangci-lint-langserver"] },
    initialization_options: {
      command: ["golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"],
    },
    allowlist: ["go"],
  })
  # }}}

  # go get golang.org/x/tools/gopls  # {{{
  s:register({
    name: "gopls",
    cmd: { server_info -> ["gopls", "-mode", "stdio"] },
    initialization_options: {
      analyses: {
        fillstruct: v:true,
      },
      completeUnimported: v:true,
      completionDocumentation: v:true,
      deepCompletion: v:true,
      hoverKind: "SynopsisDocumentation",
      matcher: "fuzzy",
      staticcheck: v:true,
      usePlaceholders: v:true,
    },
    allowlist: ["go"],
  })
  # }}}

  # yarn add vscode-langservers-extracted  # {{{
  s:register({
    name: "html-language-server",
    cmd: { server_info -> ["vscode-html-language-server", "--stdio"] },
    initialization_options: { embeddedLanguages: { css: v:true, javascript: v:true } },
    allowlist: ["eruby", "html"],
    config: { -> { refresh_pattern: kg8m#plugin#completion#refresh_pattern("html") } },
    executable_name: "vscode-html-language-server",
  })
  # }}}

  # yarn add vscode-langservers-extracted  # {{{
  s:register({
    name: "json-language-server",
    cmd: { server_info -> ["vscode-json-language-server", "--stdio"] },
    allowlist: ["json"],
    config: { -> { refresh_pattern: kg8m#plugin#completion#refresh_pattern("json") } },
    workspace_config: { -> {
      json: {
        format: { enable: v:true },
        schemas: s:schemas_json(),
     },
    } },
    executable_name: "vscode-json-language-server",
  })
  # }}}

  # gem install solargraph  # {{{
  # initialization_options: https://github.com/castwide/vscode-solargraph/blob/master/package.json
  s:register({
    name: "solargraph",
    cmd: { server_info -> ["solargraph", "stdio"] },
    initialization_options: { -> {
      autoformat: v:false,
      checkGemVersion: v:true,
      completion: v:true,
      definitions: v:true,
      diagnostics: v:true,
      formatting: v:false,
      hover: v:true,
      logLevel: "info",
      references: v:true,
      rename: v:true,
      symbols: v:true,
      useBundler: filereadable("Gemfile.lock"),
    } },
    allowlist: ["ruby"],
  })
  # }}}

  # go get github.com/lighttiger2505/sqls  # {{{
  s:register({
    name: "sqls",
    cmd: { server_info -> ["sqls"] },
    allowlist: ["sql"],
    workspace_config: { -> {
      sqls: {
        connections: get(g:, "sqls_connections", []),
      },
    } },
  })
  # }}}

  # yarn add typescript-language-server typescript  # {{{
  s:register({
    name: "typescript-language-server",
    cmd: { server_info -> ["typescript-language-server", "--stdio"] },
    allowlist: s:js_filetypes,
  })
  # }}}

  # yarn add vim-language-server  # {{{
  s:register({
    name: "vim-language-server",
    cmd: { server_info -> ["vim-language-server", "--stdio"] },
    initialization_options: { -> {
      iskeyword: &iskeyword,
      vimruntime: $VIMRUNTIME,
      runtimepath: kg8m#plugin#all_runtimepath(),
      diagnostic: { enable: v:true },
      indexes: {
        runtimepath: v:true,
        gap: 100,
        count: 3,
      },
      suggest: {
        fromVimruntime: v:true,
        fromRuntimepath: v:true,
      },
    } },
    root_uri: { server_info -> lsp#utils#path_to_uri(expand("~")) },
    allowlist: ["vim"],
  })
  # }}}

  # yarn add vue-language-server  # {{{
  # cf. https://github.com/sublimelsp/LSP-vue/blob/master/LSP-vue.sublime-settings
  s:register({
    name: "vue-language-server",
    cmd: { server_info -> ["vls"] },
    initialization_options: {
      config: {
        vetur: {
          completion: {
            autoImport: v:false,
            tagCasing: "kebab",
            useScaffoldSnippets: v:false,
          },
          format: {
            defaultFormatter: {
              js: "",
              ts: "",
            },
            defaultFormatterOptions: {},
            scriptInitialIndent: v:false,
            styleInitialIndent: v:false,
          },
          useWorkspaceDependencies: v:false,
          validation: {
            script: v:true,
            style: v:true,
            template: v:true,
          },
          dev: { logLevel: "DEBUG" },
        },
        css: {},
        emmet: {},
        stylusSupremacy: {},
        html: { suggest: {} },
        javascript: { format: {} },
        typescript: { format: {} },
      },
    },
    allowlist: ["vue"],
    executable_name: "vls",
  })
  # }}}

  # yarn add yaml-language-server  # {{{
  # Syntax errors sometimes occur when editing eruby.yaml file
  s:register({
    name: "yaml-language-server",
    cmd: { server_info -> ["yaml-language-server", "--stdio"] },
    allowlist: s:yaml_filetypes,
    workspace_config: {
      yaml: {
        completion: v:true,
        customTags: [],
        format: { enable: v:true },
        hover: v:true,
        schemas: {},
        schemaStore: { enable: v:true },
        validate: v:true,
      },
    },
  })
  # }}}
enddef  # }}}

def s:register(config: dict<any>): void  # {{{
  var executable_name: string

  if has_key(config, "executable_name")
    executable_name = config.executable_name
    remove(config, "executable_name")
  else
    executable_name = config.name
  endif

  if executable(executable_name)
    if !has_key(config, "root_uri")
      extend(config, { root_uri: { server_info -> lsp#utils#path_to_uri(getcwd()) } })
    endif

    add(s:cache.configs, config)
    extend(s:cache.filetypes, config.allowlist)

    add(s:cache.registered, { name: config.name, available: v:true })
  else
    add(s:cache.registered, { name: config.name, available: v:false })
  endif
enddef  # }}}

def s:enable_servers(): void  # {{{
  var config: dict<any>

  for c in s:cache.configs
    config = c

    for key in ["config", "initialization_options", "workspace_config"]
      if type(get(config, key)) ==# v:t_func
        config[key] = get(config, key)()
      endif
    endfor

    lsp#register_server(config)
  endfor
enddef  # }}}

# Depend on vim-fzf-tjump
def s:subscribe_stream(): void  # {{{
  lsp#callbag#pipe(
    lsp#stream(),
    lsp#callbag#filter(function("s:is_definition_failed_stream")),
    lsp#callbag#subscribe({ next: function("s:definition_fallback") }),
  )
enddef  # }}}

def s:is_definition_failed_stream(x: dict<any>): bool  # {{{
  return has_key(x, "request") && get(x.request, "method", "") ==# "textDocument/definition" &&
    has_key(x, "response") && empty(get(x.response, "result", []))
enddef  # }}}

def s:definition_fallback(x: dict<any>): void  # {{{
  # Use timer and delay execution because it is too early.
  # Manually source vim-fzf-tjump because dein.vim's `on_func` feature is not available.
  # Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
  if !kg8m#plugin#is_sourced("vim-fzf-tjump")
    kg8m#plugin#source("vim-fzf-tjump")
  endif

  timer_start(0, { -> fzf_tjump#jump() })
enddef  # }}}

def s:on_lsp_buffer_enabled(): void  # {{{
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

  s:overwrite_capabilities()

  if s:is_definition_supported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  augroup my_vimrc  # {{{
    autocmd InsertLeave <buffer> timer_start(100, { -> s:document_format({ sync: v:false }) })
    autocmd BufWritePre <buffer> s:document_format({ sync: v:true })
  augroup END  # }}}

  # cf. kg8m#plugin#lsp#is_buffer_enabled()
  b:lsp_buffer_enabled = v:true
enddef  # }}}

def s:reset_target_buffer(): void  # {{{
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
enddef  # }}}

def s:are_all_servers_running(): bool  # {{{
  for server_name in lsp#get_allowed_servers()
    if lsp#get_server_status(server_name) !=# "running"
      return v:false
    endif
  endfor

  return v:true
enddef  # }}}

# Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
# formatting from language servers which have capability of document formatting. I want to do formatting by
# efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
# language server which has capability of document formatting.
def s:overwrite_capabilities(): void  # {{{
  if &filetype !~# '\v^(go|javascript|ruby|typescript)$'
    return
  endif

  if !s:are_all_servers_running()
    kg8m#util#echo_error_msg("Cannot to overwrite language servers' capabilities because some of them are not running")
    return
  endif

  for server_name in lsp#get_allowed_servers()->filter("v:val !=# 'efm-langserver'")
    var capabilities = lsp#get_server_capabilities(server_name)

    if has_key(capabilities, "documentFormattingProvider")
      capabilities.documentFormattingProvider = v:false
    endif
  endfor
enddef  # }}}

def s:is_definition_supported(): bool  # {{{
  if !s:are_all_servers_running()
    kg8m#util#echo_error_msg("Cannot to judge whether definition is supported or not because some of them are not running")
    return v:false
  endif

  for server_name in lsp#get_allowed_servers()
    var capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", v:false)
      return v:true
    endif
  endfor

  return v:false
enddef  # }}}

def s:document_format(options = {}): void  # {{{
  if get(options, "sync", v:true)
    silent LspDocumentFormatSync
  else
    if &modified && mode() ==# "n"
      silent LspDocumentFormat
    endif
  endif
enddef  # }}}

def s:schemas_json(): list<any>  # {{{
  if !has_key(s:cache, "lsp_schemas_json")
    const filepath = kg8m#plugin#get_info("vim-lsp-settings").path .. "/data/catalog.json"
    const json     = filepath->readfile()->join("\n")->json_decode()
    s:cache.lsp_schemas_json = json.schemas
  endif

  return s:cache.lsp_schemas_json
enddef  # }}}

def s:on_source(): void  # {{{
  if s:is_initialized
    return
  endif

  g:lsp_diagnostics_enabled          = v:true
  g:lsp_diagnostics_echo_cursor      = v:false
  g:lsp_diagnostics_float_cursor     = v:true
  g:lsp_signs_enabled                = v:true
  g:lsp_highlight_references_enabled = v:true
  g:lsp_fold_enabled                 = v:false
  g:lsp_semantic_enabled             = v:true

  g:lsp_async_completion = v:true

  g:lsp_log_verbose = v:true
  g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc  # {{{
    autocmd User lsp_setup          s:enable_servers()
    autocmd User lsp_setup          s:subscribe_stream()
    autocmd User lsp_buffer_enabled s:on_lsp_buffer_enabled()

    autocmd FileType * s:reset_target_buffer()
  augroup END  # }}}

  s:is_initialized = v:true
enddef  # }}}

def s:on_post_source(): void  # {{{
  # https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
  lsp#enable()
enddef  # }}}
