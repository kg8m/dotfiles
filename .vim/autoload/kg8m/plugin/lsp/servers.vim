vim9script

final s:named_configs: dict<dict<any>>           = {}
final s:filetyped_configs: dict<list<dict<any>>> = {}
final s:availabilities: dict<bool>               = {}

final s:cache = {}

const JS_FILETYPES   = ["javascript", "typescript"]
const SH_FILETYPES   = ["sh", "zsh"]
const YAML_FILETYPES = ["eruby.yaml", "yaml", "yaml.ansible"]

var s:is_ready = false

def kg8m#plugin#lsp#servers#register(): void
  s:register_bash_language_server()
  s:register_css_language_server()
  s:register_efm_langserver()
  s:register_golangci_lint_langserver()
  s:register_gopls()
  s:register_html_language_server()
  s:register_json_language_server()
  s:register_solargraph()
  s:register_sqls()
  s:register_typescript_language_server()
  s:register_vim_language_server()
  s:register_vue_language_server()
  s:register_yaml_language_server()

  augroup my_vimrc
    autocmd FileType * timer_start(100, (_) => s:activate_servers(&filetype))

    autocmd User lsp_register_server      timer_start(100, (_) => lsp#activate())
    autocmd User after_lsp_buffer_enabled s:overwrite_capabilities()
  augroup END

  timer_start(1000, (_) => s:ready())
enddef

# yarn add bash-language-server
def s:register_bash_language_server(): void
  s:register({
    name: "bash-language-server",
    allowlist: SH_FILETYPES,
  })
enddef

def s:activate_bash_language_server(): void
  s:activate("bash-language-server", {
    cmd: (_) => ["bash-language-server", "start"],
  })
enddef

# yarn add vscode-langservers-extracted
def s:register_css_language_server(): void
  s:register({
    name: "css-language-server",
    allowlist: ["css", "less", "scss"],
    executable_name: "vscode-css-language-server",
  })
enddef

def s:activate_css_language_server(): void
  # css-language-server doesn't work when editing `.sass` file.
  s:activate("css-language-server", {
    cmd: (_) => ["vscode-css-language-server", "--stdio"],
    config: { refresh_pattern: kg8m#plugin#completion#refresh_pattern("css") },
    workspace_config: {
      css:  { lint: { validProperties: [] } },
      less: { lint: { validProperties: [] } },
      scss: { lint: { validProperties: [] } },
    },
    executable_name: "vscode-css-language-server",
  })
enddef

# go install github.com/mattn/efm-langserver
def s:register_efm_langserver(): void
  s:register({
    name: "efm-langserver",

    # cf. .config/efm-langserver/config.yaml
    allowlist: [
      "css", "eruby", "gitcommit", "go", "html", "json", "make", "markdown", "ruby", "vim",
    ] + JS_FILETYPES + SH_FILETYPES + YAML_FILETYPES,
  })
enddef

def s:activate_efm_langserver(): void
  s:activate("efm-langserver", {
    cmd: (_) => ["efm-langserver"],
  })
enddef

# go install github.com/nametake/golangci-lint-langserver
def s:register_golangci_lint_langserver(): void
  s:register({
    name: "golangci-lint-langserver",
    cmd: (_) => ["golangci-lint-langserver"],
    initialization_options: {
      command: ["golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"],
    },
    allowlist: ["go"],
  })
enddef

def s:activate_golangci_lint_langserver(): void
  s:activate("golangci-lint-langserver", {
    cmd: (_) => ["golangci-lint-langserver"],
    initialization_options: {
      command: ["golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"],
    },
  })
enddef

# go install golang.org/x/tools/gopls
def s:register_gopls(): void
  s:register({
    name: "gopls",
    allowlist: ["go"],
  })
enddef

def s:activate_gopls(): void
  s:activate("gopls", {
    cmd: (_) => ["gopls", "-mode", "stdio"],
    initialization_options: {
      analyses: {
        fillstruct: true,
      },
      completeUnimported: true,
      completionDocumentation: true,
      deepCompletion: true,
      hoverKind: "SynopsisDocumentation",
      matcher: "fuzzy",
      staticcheck: true,
      usePlaceholders: true,
    },
  })
enddef

# yarn add vscode-langservers-extracted
def s:register_html_language_server(): void
  s:register({
    name: "html-language-server",
    allowlist: ["eruby", "html"],
    executable_name: "vscode-html-language-server",
  })
enddef

def s:activate_html_language_server(): void
  s:activate("html-language-server", {
    cmd: (_) => ["vscode-html-language-server", "--stdio"],
    initialization_options: { embeddedLanguages: { css: true, javascript: true } },
    config: { refresh_pattern: kg8m#plugin#completion#refresh_pattern("html") },
  })
enddef

# yarn add vscode-langservers-extracted
def s:register_json_language_server(): void
  s:register({
    name: "json-language-server",
    allowlist: ["json"],
    executable_name: "vscode-json-language-server",
  })
enddef

def s:activate_json_language_server(): void
  s:activate("json-language-server", {
    cmd: (_) => ["vscode-json-language-server", "--stdio"],
    config: { refresh_pattern: kg8m#plugin#completion#refresh_pattern("json") },
    workspace_config: {
      json: {
        format: { enable: true },
        schemas: s:schemas(),
      },
    },
  })
enddef

# gem install solargraph
def s:register_solargraph(): void
  s:register({
    name: "solargraph",
    allowlist: ["ruby"],
  })
enddef

def s:activate_solargraph(): void
  s:activate("solargraph", {
    cmd: (_) => ["solargraph", "stdio"],

    # cf. https://github.com/castwide/vscode-solargraph/blob/master/package.json
    initialization_options: {
      autoformat: false,
      checkGemVersion: true,
      completion: true,
      definitions: true,
      diagnostics: true,
      formatting: false,
      hover: true,
      logLevel: "info",
      references: true,
      rename: true,
      symbols: true,
      useBundler: filereadable("Gemfile.lock"),
    },

    document_format: false,
  })
enddef

# go install github.com/lighttiger2505/sqls
def s:register_sqls(): void
  s:register({
    name: "sqls",
    allowlist: ["sql"],
  })
enddef

def s:activate_sqls(): void
  s:activate("sqls", {
    cmd: (_) => ["sqls"],
    workspace_config: {
      sqls: {
        connections: get(g:, "sqls_connections", []),
      },
    },
  })
enddef

# yarn add typescript-language-server typescript
def s:register_typescript_language_server(): void
  s:register({
    name: "typescript-language-server",
    allowlist: JS_FILETYPES,
  })
enddef

def s:activate_typescript_language_server(): void
  s:activate("typescript-language-server", {
    cmd: (_) => ["typescript-language-server", "--stdio"],
    document_format: false,
  })
enddef

# yarn add vim-language-server
def s:register_vim_language_server(): void
  s:register({
    name: "vim-language-server",
    allowlist: ["vim"],
  })
enddef

def s:activate_vim_language_server(): void
  s:activate("vim-language-server", {
    cmd: (_) => ["vim-language-server", "--stdio"],
    initialization_options: {
      iskeyword: &iskeyword,
      vimruntime: $VIMRUNTIME,
      runtimepath: kg8m#plugin#all_runtimepath(),
      diagnostic: { enable: true },
      indexes: {
        runtimepath: true,
        gap: 100,
        count: 3,
      },
      suggest: {
        fromVimruntime: true,
        fromRuntimepath: true,
      },
    },
    root_uri: (_) => lsp#utils#path_to_uri(expand("~")),
  })
enddef

# yarn add vue-language-server
def s:register_vue_language_server(): void
  s:register({
    name: "vue-language-server",
    allowlist: ["vue"],
    executable_name: "vls",
  })
enddef

def s:activate_vue_language_server(): void
  s:activate("vue-language-server", {
    cmd: (_) => ["vls"],

    # cf. https://github.com/sublimelsp/LSP-vue/blob/master/LSP-vue.sublime-settings
    initialization_options: {
      config: {
        vetur: {
          completion: {
            autoImport: false,
            tagCasing: "kebab",
            useScaffoldSnippets: false,
          },
          format: {
            defaultFormatter: {
              js: "",
              ts: "",
            },
            defaultFormatterOptions: {},
            scriptInitialIndent: false,
            styleInitialIndent: false,
          },
          useWorkspaceDependencies: false,
          validation: {
            script: true,
            style: true,
            template: true,
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
  })
enddef

# yarn add yaml-language-server
def s:register_yaml_language_server(): void
  s:register({
    name: "yaml-language-server",
    allowlist: YAML_FILETYPES,
  })
enddef

def s:activate_yaml_language_server(): void
  s:activate("yaml-language-server", {
    cmd: (_) => ["yaml-language-server", "--stdio"],
    workspace_config: {
      yaml: {
        completion: true,
        customTags: [],
        format: { enable: true },
        hover: true,
        schemas: {},
        schemaStore: { enable: true },
        validate: true,
      },
    },
  })
enddef

def s:register(config: dict<any>): void
  var executable_name: string

  if has_key(config, "executable_name")
    executable_name = config.executable_name
    remove(config, "executable_name")
  else
    executable_name = config.name
  endif

  if executable(executable_name)
    s:named_configs[config.name] = config

    for filetype in config.allowlist
      if !has_key(s:filetyped_configs, filetype)
        s:filetyped_configs[filetype] = []
      endif

      add(s:filetyped_configs[filetype], config)
    endfor

    s:availabilities[config.name] = true
  else
    s:availabilities[config.name] = false
  endif
enddef

def s:activate_servers(filetype: string): void
  if !has_key(s:filetyped_configs, filetype)
    return
  endif

  if !has_key(s:cache, "activated")
    s:cache.activated = {}
  endif

  if has_key(s:cache.activated, filetype)
    return
  endif

  s:cache.activated[filetype] = true

  # https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
  lsp#enable()

  for config in kg8m#plugin#lsp#servers#configs(filetype)
    if has_key(config, "activated")
      continue
    endif

    # Call `s:activate_gopls`, `s:activate_solargraph`, `s:activate_typescript_language_server`, and so on.
    execute printf("s:activate_%s()", substitute(config.name, '-', "_", "g"))
  endfor
enddef

def s:activate(name: string, extra_config: dict<any>): void
  final base_config = s:named_configs[name]
  base_config.activated = true

  final config = extend(base_config, extra_config)->copy()

  if !has_key(config, "root_uri")
    extend(config, { root_uri: (_) => lsp#utils#path_to_uri(getcwd()) })
  endif

  # Delay because some servers don't work just after Vim starts with editing files. For example, no completion
  # candidates are provided.
  const delay = s:is_ready ? 0 : 1000

  timer_start(delay, (_) => lsp#register_server(config))
enddef

def s:ready(): void
  s:is_ready = true
enddef

def kg8m#plugin#lsp#servers#configs(filetype: string = ""): list<dict<any>>
  if filetype ==# ""
    return values(s:named_configs)
  else
    return get(s:filetyped_configs, filetype, [])
  endif
enddef

def kg8m#plugin#lsp#servers#names(filetype: string = ""): list<string>
  if filetype ==# ""
    return keys(s:named_configs)
  else
    return get(s:filetyped_configs, filetype, [])->mapnew((_, config) => config.name)
  endif
enddef

def kg8m#plugin#lsp#servers#filetypes(): list<string>
  return keys(s:filetyped_configs)
enddef

def kg8m#plugin#lsp#servers#candidate_names(): list<string>
  return keys(s:availabilities)
enddef

def kg8m#plugin#lsp#servers#is_available(server_name: string): bool
  return get(s:availabilities, server_name, false)
enddef

def s:schemas(): list<any>
  if !has_key(s:cache, "lsp_schemas_json")
    const filepath = kg8m#plugin#get_info("vim-lsp-settings").path .. "/data/catalog.json"
    const json     = filepath->readfile()->join("\n")->json_decode()

    s:cache.lsp_schemas_json = json.schemas
  endif

  return s:cache.lsp_schemas_json
enddef

def kg8m#plugin#lsp#servers#are_all_running(): bool
  for server_name in kg8m#plugin#lsp#servers#names(&filetype)
    if lsp#get_server_status(server_name) !=# "running"
      return false
    endif
  endfor

  return true
enddef

# Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
# formatting from language servers which have capability of document formatting. I want to do formatting by
# efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
# language server which has capability of document formatting.
def s:overwrite_capabilities(): void
  for config in kg8m#plugin#lsp#servers#configs(&filetype)
    if get(config, "document_format", true) !=# false
      continue
    endif

    final capabilities = lsp#get_server_capabilities(config.name)

    if has_key(capabilities, "documentFormattingProvider")
      capabilities.documentFormattingProvider = false
    endif
  endfor
enddef
