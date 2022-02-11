vim9script

final s:named_configs: dict<dict<any>>           = {}
final s:filetyped_configs: dict<list<dict<any>>> = {}

final s:cache = {}

const JS_FILETYPES   = ["javascript", "javascriptreact", "typescript", "typescriptreact"]
const SH_FILETYPES   = ["sh", "zsh"]
const YAML_FILETYPES = ["eruby.yaml", "yaml", "yaml.ansible"]

var s:is_ready = false

export def Register(): void
  RegisterBashLanguageServer()
  RegisterClangd()
  RegisterCssLanguageServer()
  RegisterEfmLangserver()
  RegisterGolangciLintLangserver()
  RegisterGopls()
  RegisterHtmlLanguageServer()
  RegisterJsonLanguageServer()
  RegisterRubyLanguageServer()
  RegisterSolargraph()
  RegisterSqls()
  RegisterSteep()
  RegisterTerraformLsp()
  RegisterTypeprof()
  RegisterTypescriptLanguageServer()
  RegisterVimLanguageServer()
  RegisterVueLanguageServer()
  RegisterYamlLanguageServer()

  augroup vimrc-plugin-lsp-servers
    autocmd!
    autocmd FileType * timer_start(100, (_) => ActivateServers(&filetype))

    autocmd User lsp_register_server      timer_start(100, (_) => lsp#activate())
    autocmd User after_lsp_buffer_enabled OverwriteCapabilities()
    autocmd User after_lsp_buffer_enabled CheckExitedServers()
  augroup END

  timer_start(1000, (_) => Ready())
enddef

# yarn add bash-language-server
def RegisterBashLanguageServer(): void
  RegisterServer({
    name: "BashLanguageServer",
    allowlist: SH_FILETYPES,
    executable: "bash-language-server",
  })
enddef

def ActivateBashLanguageServer(): void
  Activate("BashLanguageServer", {
    cmd: (_) => ["bash-language-server", "start"],
  })
enddef

def RegisterClangd(): void
  RegisterServer({
    name: "Clangd",
    allowlist: ["c"],
    executable: "clangd",
  })
enddef

def ActivateClangd(): void
  Activate("Clangd", {
    cmd: (_) => ["clangd"],
  })
enddef

# yarn add vscode-langservers-extracted
def RegisterCssLanguageServer(): void
  RegisterServer({
    name: "CssLanguageServer",
    allowlist: ["css", "less", "scss"],
    executable: "vscode-css-language-server",
  })
enddef

def ActivateCssLanguageServer(): void
  # css-language-server doesn't work when editing `.sass` file.
  Activate("CssLanguageServer", {
    cmd: (_) => ["vscode-css-language-server", "--stdio"],
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("css") },
    workspace_config: {
      css:  { lint: { validProperties: [] } },
      less: { lint: { validProperties: [] } },
      scss: { lint: { validProperties: [] } },
    },
  })
enddef

# go install github.com/mattn/efm-langserver
def RegisterEfmLangserver(): void
  RegisterServer({
    name: "EfmLangserver",

    # cf. .config/efm-langserver/config.yaml
    allowlist: [
      "css", "eruby", "gitcommit", "html", "json", "make", "markdown", "ruby", "sql",
    ] + JS_FILETYPES + SH_FILETYPES + YAML_FILETYPES,

    executable: "efm-langserver",
  })
enddef

def ActivateEfmLangserver(): void
  Activate("EfmLangserver", {
    cmd: (_) => ["efm-langserver"],
  })
enddef

# go install github.com/nametake/golangci-lint-langserver
def RegisterGolangciLintLangserver(): void
  RegisterServer({
    name: "GolangciLintLangserver",
    allowlist: ["go"],
    executable: "golangci-lint-langserver",
  })
enddef

def ActivateGolangciLintLangserver(): void
  Activate("GolangciLintLangserver", {
    cmd: (_) => ["golangci-lint-langserver"],
    initialization_options: {
      command: ["golangci-lint", "run", "--enable-all", "--out-format", "json"],
    },
  })
enddef

# go install golang.org/x/tools/gopls
def RegisterGopls(): void
  RegisterServer({
    name: "Gopls",
    allowlist: ["go"],
    executable: "gopls",
  })
enddef

def ActivateGopls(): void
  Activate("Gopls", {
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

    organize_imports: true,
  })
enddef

# yarn add vscode-langservers-extracted
def RegisterHtmlLanguageServer(): void
  RegisterServer({
    name: "HtmlLanguageServer",
    allowlist: ["eruby", "html"],
    executable: "vscode-html-language-server",
  })
enddef

def ActivateHtmlLanguageServer(): void
  Activate("HtmlLanguageServer", {
    cmd: (_) => ["vscode-html-language-server", "--stdio"],
    initialization_options: { embeddedLanguages: { css: true, javascript: true } },
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("html") },
  })
enddef

# yarn add vscode-langservers-extracted
def RegisterJsonLanguageServer(): void
  RegisterServer({
    name: "JsonLanguageServer",
    allowlist: ["json"],
    executable: "vscode-json-language-server",
  })
enddef

def ActivateJsonLanguageServer(): void
  Activate("JsonLanguageServer", {
    cmd: (_) => ["vscode-json-language-server", "--stdio"],
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("json") },
    workspace_config: {
      json: {
        format: { enable: false },
        schemas: Schemas(),
      },
    },
  })
enddef

# gem install ruby_language_server
def RegisterRubyLanguageServer(): void
  RegisterServer({
    name: "RubyLanguageServer",
    allowlist: ["ruby"],
    executable: "ruby_language_server",

    available: empty($RUBY_LANGUAGE_SERVER_UNAVAILABLE),
  })
enddef

def ActivateRubyLanguageServer(): void
  Activate("RubyLanguageServer", {
    cmd: (_) => ["ruby_language_server"],
    initialization_options: {
      diagnostics: "false",
    },

    document_format: false,
  })
enddef

# gem install solargraph
def RegisterSolargraph(): void
  RegisterServer({
    name: "Solargraph",
    allowlist: ["ruby"],
    executable: "solargraph",

    available: empty($SOLARGRAPH_UNAVAILABLE),
  })
enddef

def ActivateSolargraph(): void
  Activate("Solargraph", {
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
def RegisterSqls(): void
  RegisterServer({
    name: "Sqls",
    allowlist: ["sql"],
    executable: "sqls",
  })
enddef

def ActivateSqls(): void
  Activate("Sqls", {
    cmd: (_) => ["sqls"],
    workspace_config: {
      sqls: {
        connections: get(g:, "sqls_connections", []),
      },
    },

    # sqls' document formatting is buggy.
    document_format: false,
  })
enddef

# gem install steep
# Requires Steepfile.
def RegisterSteep(): void
  RegisterServer({
    name: "Steep",
    allowlist: ["ruby"],
    executable: "steep",

    available: empty($STEEP_UNAVAILABLE),
  })
enddef

def ActivateSteep(): void
  Activate("Steep", {
    cmd: (_) => ["steep", "langserver"],
    initialization_options: {
      diagnostics: true,
    },
  })
enddef

# Install from https://github.com/juliosueiras/terraform-lsp/releases
def RegisterTerraformLsp(): void
  RegisterServer({
    name: "TerraformLsp",
    allowlist: ["terraform"],
    executable: "terraform-lsp",
  })
enddef

def ActivateTerraformLsp(): void
  Activate("TerraformLsp", {
    cmd: (_) => ["terraform-lsp"],
  })
enddef

# gem install typeprof
def RegisterTypeprof(): void
  RegisterServer({
    name: "Typeprof",
    allowlist: ["ruby"],
    executable: "typeprof",

    available: empty($TYPEPROF_UNAVAILABLE),
  })
enddef

def ActivateTypeprof(): void
  Activate("Typeprof", {
    cmd: (_) => ["typeprof", "--lsp", "--stdio"],
    initialization_options: {
      diagnostics: true,
    },
  })
enddef

# yarn add typescript-language-server typescript
def RegisterTypescriptLanguageServer(): void
  RegisterServer({
    name: "TypescriptLanguageServer",
    allowlist: JS_FILETYPES,
    executable: "typescript-language-server",
  })
enddef

def ActivateTypescriptLanguageServer(): void
  Activate("TypescriptLanguageServer", {
    cmd: (_) => ["typescript-language-server", "--stdio"],

    document_format: false,
    organize_imports: true,
  })
enddef

# yarn add vim-language-server
def RegisterVimLanguageServer(): void
  RegisterServer({
    name: "VimLanguageServer",
    allowlist: ["vim"],
    executable: "vim-language-server",
  })
enddef

def ActivateVimLanguageServer(): void
  Activate("VimLanguageServer", {
    cmd: (_) => ["vim-language-server", "--stdio"],
    initialization_options: {
      # vim-language-server uses only `:`.
      iskeyword: ":",

      vimruntime: $VIMRUNTIME,
      runtimepath: kg8m#plugin#AllRuntimepath(),
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
def RegisterVueLanguageServer(): void
  RegisterServer({
    name: "VueLanguageServer",
    allowlist: ["vue"],
    executable: "vls",
  })
enddef

def ActivateVueLanguageServer(): void
  Activate("VueLanguageServer", {
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
def RegisterYamlLanguageServer(): void
  RegisterServer({
    name: "YamlLanguageServer",
    allowlist: YAML_FILETYPES,
    executable: "yaml-language-server",
  })
enddef

def ActivateYamlLanguageServer(): void
  Activate("YamlLanguageServer", {
    cmd: (_) => ["yaml-language-server", "--stdio"],
    workspace_config: {
      yaml: {
        completion: true,
        customTags: [],
        format: { enable: false },
        hover: true,
        schemas: Schemas(),
        validate: true,
      },
    },
  })
enddef

def RegisterServer(config: dict<any>): void
  const executable = config.executable
  remove(config, "executable")

  s:named_configs[config.name] = config

  if get(config, "available", true) && executable(executable)
    for filetype in config.allowlist
      if !has_key(s:filetyped_configs, filetype)
        s:filetyped_configs[filetype] = []
      endif

      add(s:filetyped_configs[filetype], config)
    endfor

    config.available = true
  else
    config.available = false
  endif
enddef

def ActivateServers(filetype: string): void
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

  for config in Configs(filetype)
    if has_key(config, "activated")
      continue
    endif

    # Call `ActivateGopls`, `ActivateSolargraph`, `ActivateTypescriptLanguageServer`, and so on.
    execute printf("Activate%s()", config.name)
  endfor
enddef

def Activate(name: string, extra_config: dict<any>): void
  final base_config = s:named_configs[name]
  base_config.activated = true

  final config = extend(base_config, extra_config)->copy()

  if !has_key(config, "root_uri")
    extend(config, { root_uri: (_) => lsp#utils#path_to_uri(getcwd()) })
  endif

  # `rootUri` is deprecated in favour of `workspaceFolders`.
  # https://microsoft.github.io/language-server-protocol/specification
  if !has_key(config, "workspace_folders")
    extend(config, { workspace_folders: config.root_uri })
  endif

  # Delay because some servers don't work just after Vim starts with editing files. For example, no completion
  # candidates are provided.
  const delay = s:is_ready ? 0 : 1000

  timer_start(delay, (_) => lsp#register_server(config))
enddef

def Ready(): void
  s:is_ready = true
enddef

export def Configs(filetype: string = ""): list<dict<any>>
  if filetype ==# ""
    return values(s:named_configs)
  else
    return get(s:filetyped_configs, filetype, [])
  endif
enddef

export def Names(filetype: string = ""): list<string>
  if filetype ==# ""
    return keys(s:named_configs)
  else
    return get(s:filetyped_configs, filetype, [])->mapnew((_, config) => config.name)
  endif
enddef

export def Filetypes(): list<string>
  return keys(s:filetyped_configs)
enddef

export def IsAvailable(server_name: string): bool
  if has_key(s:named_configs, server_name)
    return s:named_configs[server_name].available
  else
    return false
  endif
enddef

def Schemas(): list<any>
  if !has_key(s:cache, "lsp_schemas_json")
    const filepath = kg8m#plugin#GetInfo("vim-lsp-settings").path .. "/data/catalog.json"
    const json     = filepath->readfile()->join("\n")->json_decode()

    s:cache.lsp_schemas_json = json.schemas
  endif

  return s:cache.lsp_schemas_json
enddef

export def AreAllRunningOrExited(): bool
  for server_name in Names(&filetype)
    if lsp#get_server_status(server_name) !=# "running" &&
       lsp#get_server_status(server_name) !=# "exited"
      return false
    endif
  endfor

  return true
enddef

# Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
# formatting from language servers which have capability of document formatting. I want to do formatting by
# efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
# language server which has capability of document formatting.
def OverwriteCapabilities(): void
  for config in Configs(&filetype)
    if get(config, "document_format", true) !=# false
      continue
    endif

    final capabilities = lsp#get_server_capabilities(config.name)

    if has_key(capabilities, "documentFormattingProvider")
      capabilities.documentFormattingProvider = false
      kg8m#util#logger#Info(config.name .. "'s documentFormattingProvider got forced to be disabled.")
    endif
  endfor
enddef

def CheckExitedServers(): void
  for server_name in Names(&filetype)
    if lsp#get_server_status(server_name) ==# "exited"
      final messages = [printf("%s has been exited.", server_name)]

      if empty(g:lsp_log_file)
        add(messages, "Enable `g:lsp_log_file` and check logs.")
      else
        add(messages, printf(" Check logs in %s.", shellescape(g:lsp_log_file)))
      endif

      kg8m#util#logger#Error(messages->join(" "))
    endif
  endfor
enddef
