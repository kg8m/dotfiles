vim9script

final named_configs: dict<dict<any>>           = {}
final filetyped_configs: dict<list<dict<any>>> = {}

final cache = {}

const JS_FILETYPES   = ["javascript", "javascriptreact"]
const TS_FILETYPES   = ["typescript", "typescriptreact"]
const SH_FILETYPES   = ["sh", "zsh"]
const YAML_FILETYPES = ["eruby.yaml", "yaml", "yaml.ansible"]

var is_ready = false

export def Register(): void
  RegisterBashLanguageServer()
  RegisterClangd()
  RegisterCssLanguageServer()
  RegisterDeno()
  RegisterEfmLangserver()
  RegisterGolangciLintLangserver()
  RegisterGopls()
  RegisterHtmlLanguageServer()
  RegisterJsonLanguageServer()
  RegisterRubyLanguageServer()
  RegisterRubyLsp()
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

# npm install bash-language-server
def RegisterBashLanguageServer(): void
  RegisterServer({
    name: "bash-language-server",
    allowlist: SH_FILETYPES,
    extra_config: function("ExtraConfigForBashLanguageServer"),
  })
enddef

def ExtraConfigForBashLanguageServer(): dict<any>
  return {
    cmd: (_) => ["bash-language-server", "start"],
    env: NodeToolsEnv(),
  }
enddef

def RegisterClangd(): void
  RegisterServer({
    name: "clangd",
    allowlist: ["c"],
    extra_config: function("ExtraConfigForClangd"),
  })
enddef

def ExtraConfigForClangd(): dict<any>
  return {
    cmd: (_) => ["clangd"],
  }
enddef

# npm install vscode-langservers-extracted
def RegisterCssLanguageServer(): void
  RegisterServer({
    name: "css-language-server",
    allowlist: ["css", "less", "scss"],
    executable: "vscode-css-language-server",
    extra_config: function("ExtraConfigForCssLanguageServer"),
  })
enddef

def ExtraConfigForCssLanguageServer(): dict<any>
  # css-language-server doesn't work when editing `.sass` file.
  return {
    cmd: (_) => ["vscode-css-language-server", "--stdio"],
    env: NodeToolsEnv(),
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("css") },
    workspace_config: {
      css:  { lint: { validProperties: [] } },
      less: { lint: { validProperties: [] } },
      scss: { lint: { validProperties: [] } },
    },
  }
enddef

def RegisterDeno(): void
  RegisterServer({
    name: "deno",
    allowlist: TS_FILETYPES,
    extra_config: function("ExtraConfigForDeno"),

    available: $DENO_AVAILABLE ==# "1",
  })
enddef

def ExtraConfigForDeno(): dict<any>
  return {
    cmd: (_) => ["deno", "lsp"],
    initialization_options: {
      enable: true,
      lint: true,
      unstable: true,
      importMap: filereadable("import_map.json") ? "import_map.json" : v:null,
      codeLens: {
        implementations: true,
        references: true,
        referencesAllFunctions: true,
        test: true,
        testArgs: ["--allow-all"],
      },
      suggest: {
        autoImports: true,
        completeFunctionCalls: true,
        names: true,
        paths: true,
        imports: {
          autoDiscover: false,
          hosts: {
            "https://deno.land/": true,
          },
        },
      },
      config: filereadable("tsconfig.json") ? "tsconfig.json" : v:null,
      internalDebug: false,
    },

    document_format: true,
    organize_imports: true,
  }
enddef

# go install github.com/mattn/efm-langserver
def RegisterEfmLangserver(): void
  RegisterServer({
    name: "efm-langserver",

    # cf. .config/efm-langserver/config.yaml
    allowlist: [
      "Gemfile", "css", "eruby", "gitcommit", "html", "json", "make", "markdown", "ruby", "sql",
    ] + JS_FILETYPES + SH_FILETYPES + YAML_FILETYPES + (
      $DENO_AVAILABLE ==# "1" ? [] : TS_FILETYPES
    ),

    extra_config: function("ExtraConfigForEfmLangserver"),
  })
enddef

def ExtraConfigForEfmLangserver(): dict<any>
  return {
    cmd: (_) => ["efm-langserver"],
  }
enddef

# go install github.com/nametake/golangci-lint-langserver
def RegisterGolangciLintLangserver(): void
  RegisterServer({
    name: "golangci-lint-langserver",
    allowlist: ["go"],
    extra_config: function("ExtraConfigForGolangciLintLangserver"),
  })
enddef

def ExtraConfigForGolangciLintLangserver(): dict<any>
  return {
    cmd: (_) => ["golangci-lint-langserver"],
    initialization_options: {
      command: ["golangci-lint", "run", "--enable-all", "--out-format", "json"],
    },
  }
enddef

# go install golang.org/x/tools/gopls
def RegisterGopls(): void
  RegisterServer({
    name: "gopls",
    allowlist: ["go"],
    extra_config: function("ExtraConfigForGopls"),
  })
enddef

def ExtraConfigForGopls(): dict<any>
  return {
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
  }
enddef

# npm install vscode-langservers-extracted
def RegisterHtmlLanguageServer(): void
  RegisterServer({
    name: "html-language-server",
    allowlist: ["eruby", "html"],
    executable: "vscode-html-language-server",
    extra_config: function("ExtraConfigForHtmlLanguageServer"),
  })
enddef

def ExtraConfigForHtmlLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vscode-html-language-server", "--stdio"],
    env: NodeToolsEnv(),
    initialization_options: { embeddedLanguages: { css: true, javascript: true } },
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("html") },
  }
enddef

# npm install vscode-langservers-extracted
def RegisterJsonLanguageServer(): void
  RegisterServer({
    name: "json-language-server",
    allowlist: ["json"],
    executable: "vscode-json-language-server",
    extra_config: function("ExtraConfigForJsonLanguageServer"),
  })
enddef

def ExtraConfigForJsonLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vscode-json-language-server", "--stdio"],
    env: NodeToolsEnv(),
    config: { refresh_pattern: kg8m#plugin#completion#RefreshPattern("json") },
    workspace_config: {
      json: {
        format: { enable: false },
        schemas: Schemas(),
      },
    },
  }
enddef

# gem install ruby_language_server
def RegisterRubyLanguageServer(): void
  RegisterServer({
    name: "ruby_language_server",
    allowlist: ["ruby"],
    extra_config: function("ExtraConfigForRubyLanguageServer"),

    available: $RUBY_LANGUAGE_SERVER_AVAILABLE ==# "1",
  })
enddef

def ExtraConfigForRubyLanguageServer(): dict<any>
  return {
    cmd: (_) => ["ruby_language_server"],
    initialization_options: {
      diagnostics: "false",
    },

    document_format: false,
  }
enddef

# gem install ruby-lsp
def RegisterRubyLsp(): void
  RegisterServer({
    name: "ruby-lsp",
    allowlist: ["ruby"],
    extra_config: function("ExtraConfigForRubyLsp"),

    available: $RUBY_LSP_AVAILABLE ==# "1",
  })
enddef

def ExtraConfigForRubyLsp(): dict<any>
  return {
    cmd: (_) => ["ruby-lsp", "stdio"],
    initialization_options: {
      diagnostics: true,
    },
  }
enddef

# gem install solargraph
def RegisterSolargraph(): void
  RegisterServer({
    name: "solargraph",
    allowlist: ["ruby"],
    extra_config: function("ExtraConfigForSolargraph"),

    available: $SOLARGRAPH_AVAILABLE !=# "0",
  })
enddef

def ExtraConfigForSolargraph(): dict<any>
  return {
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
  }
enddef

# go install github.com/lighttiger2505/sqls
def RegisterSqls(): void
  RegisterServer({
    name: "sqls",
    allowlist: ["sql"],
    extra_config: function("ExtraConfigForSqls"),
  })
enddef

def ExtraConfigForSqls(): dict<any>
  return {
    cmd: (_) => ["sqls"],
    workspace_config: {
      sqls: {
        connections: get(g:, "sqls_connections", []),
      },
    },

    # sqls' document formatting is buggy.
    document_format: false,
  }
enddef

# gem install steep
# Requires Steepfile.
def RegisterSteep(): void
  RegisterServer({
    name: "steep",
    allowlist: ["ruby"],
    extra_config: function("ExtraConfigForSteep"),

    available: $STEEP_AVAILABLE ==# "1",
  })
enddef

def ExtraConfigForSteep(): dict<any>
  return {
    cmd: (_) => ["steep", "langserver"],
    initialization_options: {
      diagnostics: true,
    },
  }
enddef

# Install from https://github.com/juliosueiras/terraform-lsp/releases
def RegisterTerraformLsp(): void
  RegisterServer({
    name: "terraform-lsp",
    allowlist: ["terraform"],
    extra_config: function("ExtraConfigForTerraformLsp"),
  })
enddef

def ExtraConfigForTerraformLsp(): dict<any>
  return {
    cmd: (_) => ["terraform-lsp"],
  }
enddef

# gem install typeprof
def RegisterTypeprof(): void
  RegisterServer({
    name: "typeprof",
    allowlist: ["ruby"],
    extra_config: function("ExtraConfigForTypeprof"),

    available: $TYPEPROF_AVAILABLE !=# "0",
  })
enddef

def ExtraConfigForTypeprof(): dict<any>
  return {
    cmd: (_) => ["typeprof", "--lsp", "--stdio"],
    initialization_options: {
      diagnostics: true,
    },
  }
enddef

# npm install typescript-language-server typescript
def RegisterTypescriptLanguageServer(): void
  RegisterServer({
    name: "typescript-language-server",
    allowlist: JS_FILETYPES + TS_FILETYPES,
    extra_config: function("ExtraConfigForTypescriptLanguageServer"),

    available: $DENO_AVAILABLE !=# "1",
  })
enddef

def ExtraConfigForTypescriptLanguageServer(): dict<any>
  return {
    cmd: (_) => ["typescript-language-server", "--stdio"],
    env: NodeToolsEnv(),

    document_format: false,
    organize_imports: true,
  }
enddef

# npm install vim-language-server
def RegisterVimLanguageServer(): void
  RegisterServer({
    name: "vim-language-server",
    allowlist: ["vim"],
    extra_config: function("ExtraConfigForVimLanguageServer"),
  })
enddef

def ExtraConfigForVimLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vim-language-server", "--stdio"],
    env: NodeToolsEnv(),
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
  }
enddef

# npm install vls
def RegisterVueLanguageServer(): void
  RegisterServer({
    name: "vls",
    allowlist: ["vue"],
    extra_config: function("ExtraConfigForVueLanguageServer"),
  })
enddef

def ExtraConfigForVueLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vls"],
    env: NodeToolsEnv(),

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
  }
enddef

# npm install yaml-language-server
def RegisterYamlLanguageServer(): void
  RegisterServer({
    name: "yaml-language-server",
    allowlist: YAML_FILETYPES,
    extra_config: function("ExtraConfigForYamlLanguageServer"),
  })
enddef

def ExtraConfigForYamlLanguageServer(): dict<any>
  return {
    cmd: (_) => ["yaml-language-server", "--stdio"],
    env: NodeToolsEnv(),
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
  }
enddef

def RegisterServer(config: dict<any>): void
  const executable = get(config, "executable", config.name)

  named_configs[config.name] = config

  if get(config, "available", true) && executable(executable)
    for filetype in config.allowlist
      if !has_key(filetyped_configs, filetype)
        filetyped_configs[filetype] = []
      endif

      add(filetyped_configs[filetype], config)
    endfor

    config.available = true
  else
    config.available = false
  endif
enddef

def ActivateServers(filetype: string): void
  if !has_key(filetyped_configs, filetype)
    return
  endif

  if !has_key(cache, "activated")
    cache.activated = {}
  endif

  if empty(cache.activated)
    # https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
    lsp#enable()

    # Clear vim-lsp's `CompleteDone` autocommand because it inserts characters like "<SNR>123_on_complete_done_after()".
    # https://github.com/prabirshrestha/vim-lsp/blob/3d0fc4072bef08b578d4a4aa4a6f91de571e99e4/autoload/lsp.vim#L63
    # https://github.com/prabirshrestha/vim-lsp/blob/3d0fc4072bef08b578d4a4aa4a6f91de571e99e4/autoload/lsp/ui/vim/completion.vim#L5-L10
    autocmd! lsp_ui_vim_completion
  endif

  if has_key(cache.activated, filetype)
    return
  endif

  cache.activated[filetype] = true

  for config in Configs(filetype)
    if has_key(config, "activated")
      continue
    endif

    Activate(config.name, config.extra_config())
  endfor
enddef

def Activate(name: string, extra_config: dict<any>): void
  final base_config = named_configs[name]
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
  const delay = is_ready ? 0 : 1000

  timer_start(delay, (_) => lsp#register_server(config))
enddef

def Ready(): void
  is_ready = true
enddef

export def Configs(filetype: string = ""): list<dict<any>>
  if filetype ==# ""
    return values(named_configs)
  else
    return get(filetyped_configs, filetype, [])
  endif
enddef

export def Names(filetype: string = ""): list<string>
  if filetype ==# ""
    return keys(named_configs)
  else
    return get(filetyped_configs, filetype, [])->mapnew((_, config) => config.name)
  endif
enddef

export def Filetypes(): list<string>
  return keys(filetyped_configs)
enddef

export def IsAvailable(server_name: string): bool
  if has_key(named_configs, server_name)
    return named_configs[server_name].available
  else
    return false
  endif
enddef

def Schemas(): list<any>
  if !has_key(cache, "lsp_schemas_json")
    const filepath = printf("%s/data/catalog.json", kg8m#plugin#GetInfo("vim-lsp-settings").path)
    const json     = filepath->readfile()->join("\n")->json_decode()

    cache.lsp_schemas_json = json.schemas
  endif

  return cache.lsp_schemas_json
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
  if !has_key(cache, "capabilities_overwritten")
    cache.capabilities_overwritten = {}
  endif

  if has_key(cache.capabilities_overwritten, &filetype)
    return
  endif

  cache.capabilities_overwritten[&filetype] = true

  for config in Configs(&filetype)
    if get(config, "document_format", true) !=# false
      continue
    endif

    final capabilities = lsp#get_server_capabilities(config.name)

    if has_key(capabilities, "documentFormattingProvider")
      capabilities.documentFormattingProvider = false
      kg8m#util#logger#Info($"{config.name}'s documentFormattingProvider got forced to be disabled.")
    endif
  endfor
enddef

def CheckExitedServers(): void
  for server_name in Names(&filetype)
    if lsp#get_server_status(server_name) ==# "exited"
      final messages = [$"{server_name} has been exited."]

      if empty(g:lsp_log_file)
        add(messages, "Enable `g:lsp_log_file` and check logs.")
      else
        add(messages, $" Check logs in `{g:lsp_log_file}`.")
      endif

      kg8m#util#logger#Error(messages->join(" "))
    endif
  endfor
enddef

def NodeToolsEnv(): dict<any>
  if has_key(cache, "node_tools_env")
    return cache.node_tools_env
  endif

  const latest_node_version = system("asdf list nodejs | tail -n1")

  cache.node_tools_env = {
    ASDF_NODEJS_VERSION: latest_node_version,
  }

  return cache.node_tools_env
enddef
