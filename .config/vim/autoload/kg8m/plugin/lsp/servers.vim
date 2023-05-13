vim9script

# Some server specific configurations are thanks to https://github.com/mattn/vim-lsp-settings.

import autoload "kg8m/configure/filetypes/javascript.vim" as jsConfig
import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/completion.vim"
import autoload "kg8m/util/logger.vim"

final named_configs: dict<dict<any>>           = {}
final filetyped_configs: dict<list<dict<any>>> = {}

final cache = {}

const JS_FILETYPES   = jsConfig.JS_FILETYPES
const TS_FILETYPES   = jsConfig.TS_FILETYPES
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
  RegisterTerraformLs()
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
    extra_config: () => ExtraConfigForBashLanguageServer(),
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
    extra_config: () => ExtraConfigForClangd(),
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
    extra_config: () => ExtraConfigForCssLanguageServer(),
  })
enddef

def ExtraConfigForCssLanguageServer(): dict<any>
  # css-language-server doesn't work when editing `.sass` file.
  return {
    cmd: (_) => ["vscode-css-language-server", "--stdio"],
    env: NodeToolsEnv(),
    config: { refresh_pattern: completion.RefreshPattern("css") },
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
    extra_config: () => ExtraConfigForDeno(),

    available: ShouldUseDeno(),
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
      inlayHints: {
        parameterNames: {
          enabled: "all",
          suppressWhenArgumentMatchesName: true,
        },
        parameterTypes: {
          enabled: true,
        },
        variableTypes: {
          enabled: true,
          suppressWhenTypeMatchesName: true,
        },
        propertyDeclarationTypes: {
          enabled: true,
        },
        functionLikeReturnTypes: {
          enabled: true,
        },
        enumMemberValues: {
          enabled: true,
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
      "Gemfile", "css", "eruby", "gitcommit", "html", "json", "make", "markdown", "ruby", "scss", "sql", "vue",
    ] + JS_FILETYPES + SH_FILETYPES + YAML_FILETYPES + (
      ShouldUseDeno() ? [] : TS_FILETYPES
    ),

    extra_config: () => ExtraConfigForEfmLangserver(),
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
    extra_config: () => ExtraConfigForGolangciLintLangserver(),
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
    allowlist: ["go", "gomod"],
    extra_config: () => ExtraConfigForGopls(),
  })
enddef

def ExtraConfigForGopls(): dict<any>
  return {
    cmd: (_) => ["gopls", "-mode", "stdio"],
    initialization_options: {
      analyses: {
        fillstruct: true,
      },
      codelenses: {
        generate: true,
        test: true,
      },
      completeUnimported: true,
      completionDocumentation: true,
      deepCompletion: true,
      hoverKind: "SynopsisDocumentation",
      matcher: "fuzzy",
      staticcheck: true,
      "ui.inlayhint.hints": {
        assignVariableTypes: true,
        compositeLiteralFields: true,
        compositeLiteralTypes: true,
        constantValues: true,
        functionTypeParameters: true,
        parameterNames: true,
        rangeVariableTypes: true,
      },
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
    extra_config: () => ExtraConfigForHtmlLanguageServer(),
  })
enddef

def ExtraConfigForHtmlLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vscode-html-language-server", "--stdio"],
    env: NodeToolsEnv(),
    initialization_options: { embeddedLanguages: { css: true, javascript: true } },
    config: { refresh_pattern: completion.RefreshPattern("html") },
  }
enddef

# npm install vscode-langservers-extracted
def RegisterJsonLanguageServer(): void
  RegisterServer({
    name: "json-language-server",
    allowlist: ["json"],
    executable: "vscode-json-language-server",
    extra_config: () => ExtraConfigForJsonLanguageServer(),
  })
enddef

def ExtraConfigForJsonLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vscode-json-language-server", "--stdio"],
    env: NodeToolsEnv(),
    config: { refresh_pattern: completion.RefreshPattern("json") },
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
    extra_config: () => ExtraConfigForRubyLanguageServer(),

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
    extra_config: () => ExtraConfigForRubyLsp(),

    available: $RUBY_LSP_AVAILABLE !=# "0",
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
    extra_config: () => ExtraConfigForSolargraph(),

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
    extra_config: () => ExtraConfigForSqls(),
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
    allowlist: ["rbs", "ruby"],
    extra_config: () => ExtraConfigForSteep(),

    available: filereadable("Steepfile"),
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

# Install from https://github.com/hashicorp/terraform-ls/releases
def RegisterTerraformLs(): void
  RegisterServer({
    name: "terraform-ls",
    allowlist: ["terraform"],
    extra_config: () => ExtraConfigForTerraformLs(),
  })
enddef

def ExtraConfigForTerraformLs(): dict<any>
  return {
    cmd: (_) => ["terraform-ls", "serve"],
  }
enddef

# Install from https://github.com/juliosueiras/terraform-lsp/releases
def RegisterTerraformLsp(): void
  RegisterServer({
    name: "terraform-lsp",
    allowlist: ["terraform"],
    extra_config: () => ExtraConfigForTerraformLsp(),

    available: $TERRAFORM_LSP_AVAILABLE ==# "1",
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
    extra_config: () => ExtraConfigForTypeprof(),

    available: $TYPEPROF_AVAILABLE ==# "1",
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
    allowlist: ShouldUseVueLanguageServer() ? [] : (JS_FILETYPES + (ShouldUseDeno() ? [] : TS_FILETYPES)),
    extra_config: () => ExtraConfigForTypescriptLanguageServer(),
  })
enddef

def ExtraConfigForTypescriptLanguageServer(): dict<any>
  return {
    cmd: (_) => ["typescript-language-server", "--stdio"],
    initialization_options: {
      preferences: {
        includeInlayEnumMemberValueHints: true,
        includeInlayFunctionLikeReturnTypeHints: true,
        includeInlayFunctionParameterTypeHints: true,
        includeInlayParameterNameHints: "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName: true,
        includeInlayPropertyDeclarationTypeHints: true,
        includeInlayVariableTypeHints: true,
      },
    },
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
    extra_config: () => ExtraConfigForVimLanguageServer(),
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
      runtimepath: plugin.AllRuntimepath(),
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

# npm install @volar/vue-language-server
def RegisterVueLanguageServer(): void
  RegisterServer({
    name: "vue-language-server",
    allowlist: ["vue"] + (ShouldUseVueLanguageServer() ? (JS_FILETYPES + TS_FILETYPES) : []),
    extra_config: () => ExtraConfigForVueLanguageServer(),
  })
enddef

def ExtraConfigForVueLanguageServer(): dict<any>
  return {
    cmd: (_) => ["vue-language-server", "--stdio"],
    env: NodeToolsEnv(),

    initialization_options: {
      textDocumentSync: 2,
      typescript: {
        tsdk: TypeScriptLibPath(),
      },
    },

    document_format: false,
  }
enddef

# npm install yaml-language-server
def RegisterYamlLanguageServer(): void
  RegisterServer({
    name: "yaml-language-server",
    allowlist: YAML_FILETYPES,
    extra_config: () => ExtraConfigForYamlLanguageServer(),
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

export def IsRubyServerAvailable(): bool
  return (
    IsAvailable("ruby_language_server") ||
    IsAvailable("ruby-lsp") ||
    IsAvailable("solargraph") ||
    IsAvailable("steep") ||
    IsAvailable("typeprof")
  )
enddef

def Schemas(): list<any>
  if !has_key(cache, "lsp_schemas_json")
    const filepath = printf("%s/data/catalog.json", plugin.GetInfo("vim-lsp-settings").path)
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
      logger.Info($"{config.name}'s documentFormattingProvider got forced to be disabled.")
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

      logger.Error(messages->join(" "))
    endif
  endfor
enddef

def ShouldUseVueLanguageServer(): bool
  if has_key(cache, "use_vue_language_server")
    return cache.use_vue_language_server
  endif

  cache.use_vue_language_server = ($VUEJS_AVAILABLE ==# "1")
  return cache.use_vue_language_server
enddef

def ShouldUseDeno(): bool
  if has_key(cache, "use_deno")
    return cache.use_deno
  endif

  cache.use_deno = ($DENO_AVAILABLE ==# "1") || OnDenoAppDir() || OnDenopsPluginDir()
  return cache.use_deno
enddef

def OnDenoAppDir(): bool
  return (
    filereadable("deno.json") ||
    filereadable("deno.jsonc") ||
    filereadable("deno.lock")
  )
enddef

def OnDenopsPluginDir(): bool
  if !isdirectory("denops")
    return false
  endif

  const common_options = "--hidden --no-ignore --max-results 1 --type file"
  const denops_file_exists = !system($"fd {common_options} --extension ts --search-path denops")->empty()

  if !denops_file_exists
    return false
  endif

  const vim_file_exists = !system($"fd {common_options} --extension vim")->empty()
  return vim_file_exists
enddef

def NodeToolsEnv(): dict<any>
  if has_key(cache, "node_tools_env")
    return cache.node_tools_env
  endif

  const latest_node_version = system("newest_version nodejs")->trim()

  cache.node_tools_env = {
    ASDF_NODEJS_VERSION: latest_node_version,
  }

  return cache.node_tools_env
enddef

def TypeScriptLibPath(): string
  const suffix = "node_modules/typescript/lib"
  const project_local_path = $"{getcwd()}/{suffix}"

  if isdirectory(project_local_path)
    return project_local_path
  else
    const node_version = NodeToolsEnv().ASDF_NODEJS_VERSION
    const global_path = $"{$ASDF_DATA_DIR}/installs/nodejs/{node_version}/lib/{suffix}"

    if isdirectory(global_path)
      return global_path
    else
      logger.Warn("TypeScript's library directory is not found.")
      return ""
    endif
  endif
enddef
