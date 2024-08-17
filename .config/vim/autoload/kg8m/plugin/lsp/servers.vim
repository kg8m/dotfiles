vim9script

# Some server specific configurations are thanks to https://github.com/mattn/vim-lsp-settings.

import autoload "kg8m/configure/filetypes/javascript.vim" as jsConfig
import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/completion.vim"
import autoload "kg8m/plugin/lsp/document_format.vim"
import autoload "kg8m/util/filetypes/javascript.vim" as jsUtil
import autoload "kg8m/util/logger.vim"

final named_configs: dict<dict<any>>           = {}
final filetyped_configs: dict<list<dict<any>>> = {}

final cache = {}

const CSS_FILETYPES  = ["css", "scss"]
const JSON_FILETYPES = ["json", "jsonc"]
const JS_FILETYPES   = jsConfig.JS_FILETYPES
const SH_FILETYPES   = ["sh", "zsh"]
const TS_FILETYPES   = jsConfig.TS_FILETYPES
const YAML_FILETYPES = ["eruby.yaml", "yaml", "yaml.ansible"]

var is_ready = false

export def Register(): void
  RegisterBashLanguageServer()
  RegisterClangd()
  RegisterCssLanguageServer()
  RegisterDeno()
  RegisterEfmLangserver()
  RegisterEfmLangserverForHeavyTools()
  RegisterGolangciLintLangserver()
  RegisterGopls()
  RegisterHtmlLanguageServer()
  RegisterJsonLanguageServer()
  RegisterLuaLanguageServer()
  RegisterRubocop()
  RegisterRubyLanguageServer()
  RegisterRubyLsp()
  RegisterSolargraph()
  RegisterSqls()
  RegisterSteep()
  RegisterTailwindcssLanguageServer()
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

    document_format_priority: document_format.MIN_PRIORITY,
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
      # Use Stylelint for unknown at rules.
      css:  { lint: { unknownAtRules: "ignore" } },
      less: { lint: { unknownAtRules: "ignore" } },
      scss: { lint: { unknownAtRules: "ignore" } },
    },
  }
enddef

def RegisterDeno(): void
  RegisterServer({
    name: "deno",
    allowlist: TS_FILETYPES,
    extra_config: () => ExtraConfigForDeno(),

    available: jsUtil.ShouldUseDeno(),
  })
enddef

def ExtraConfigForDeno(): dict<any>
  return {
    cmd: (_) => ["deno", "lsp"],
    workspace_config: {
      deno: {
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
      typescript: {
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
      },
    },

    # I want to use Deno as a formatter for Deno files.
    document_format_priority: document_format.MAX_PRIORITY,

    organize_imports: true,
  }
enddef

# go install github.com/mattn/efm-langserver
def RegisterEfmLangserver(): void
  RegisterServer({
    name: "efm-langserver",

    # cf. .config/efm-langserver/config.yaml
    allowlist: [
      "Gemfile", "eruby", "gitcommit", "html", "lua", "make", "markdown", "ruby", "slim", "sql", "vue",
    ] + CSS_FILETYPES + JS_FILETYPES + JSON_FILETYPES + SH_FILETYPES + TS_FILETYPES + YAML_FILETYPES,

    extra_config: () => ExtraConfigForEfmLangserver(),
  })
enddef

def ExtraConfigForEfmLangserver(): dict<any>
  return {
    cmd: (_) => ["efm-langserver"],

    # I want to use efm-langserver as a formatter in most cases.
    document_format_priority: document_format.HIGH_PRIORITY,
  }
enddef

def RegisterEfmLangserverForHeavyTools(): void
  RegisterServer({
    name: "efm-langserver-for-heavy-tools",

    # cf. .config/efm-langserver/config-heavy.yaml
    allowlist: ["eruby", "ruby", "slim"],

    executable: "efm-langserver",
    extra_config: () => ExtraConfigForEfmLangserverForHeavyTools(),
  })
enddef

def ExtraConfigForEfmLangserverForHeavyTools(): dict<any>
  return {
    cmd: (_) => ["efm-langserver", "-c", $"{$XDG_CONFIG_HOME}/efm-langserver/config-heavy.yaml"],
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
    capabilities: {
      textDocument: {
        documentSymbol: {
          hierarchicalDocumentSymbolSupport: true,
        },
      }
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
    allowlist: ["json", "jsonc"],
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

def RegisterLuaLanguageServer(): void
  RegisterServer({
    name: "lua-language-server",
    allowlist: ["lua"],
    extra_config: () => ExtraConfigForLuaLanguageServer(),
  })
enddef

def ExtraConfigForLuaLanguageServer(): dict<any>
  return {
    cmd: (_) => ["lua-language-server"],
    workspace_config: {
      Lua: {
        color: {
          mode: "Semantic",
        },
        completion: {
          callSnippet: "Disable",
          enable: true,
          keywordSnippet: "Replace",
        },
        develop: {
          debuggerPort: 11412,
          debuggerWait: false,
          enable: false,
        },
        diagnostics: {
          enable: true,
          globals: "",
          severity: {},
        },
        hover: {
          enable: true,
          viewNumber: true,
          viewString: true,
          viewStringMax: 1000,
        },
        runtime: {
          # Extract `Lua 5.4` if `lua -v` shows `Lua 5.4.6  Copyright (C) 1994-2023 Lua.org, PUC-Rio`.
          version: system("lua -v")->matchstr('\v^\zsLua \d+\.\d+\ze'),
        },
        signatureHelp: {
          enable: true,
        },
        workspace: {
          ignoreDir: [],
          maxPreload: 1000,
          preloadFileSize: 100,
          useGitIgnore: true,
        },
      },
    },
  }
enddef

# gem install rubocop
# cf. .config/vim/autoload/kg8m/util/daemons.vim
def RegisterRubocop(): void
  if $USE_RUBOCOP_LSP !=# "0" && filereadable(".rubocop.yml")
    RegisterServer({
      name: "rubocop",

      # Don’t use LSP mode RuboCop for Markdown files because formatting them from STDIN source isn’t supported.
      # Use RuboCop via efm-langserver for Markdown files.
      # cf. .config/efm-langserver/rubocop_wrapper.sh
      allowlist: ["Gemfile", "ruby"],

      extra_config: () => ExtraConfigForRubocop(),
    })
  endif
enddef

def ExtraConfigForRubocop(): dict<any>
  return {
    cmd: (_) => ["rubocop", "--lsp"],

    # I want to use RuboCop as a formatter for Ruby files.
    document_format_priority: document_format.MAX_PRIORITY,
  }
enddef

# gem install ruby_language_server
def RegisterRubyLanguageServer(): void
  RegisterServer({
    name: "ruby_language_server",
    allowlist: ["ruby"],
    extra_config: () => ExtraConfigForRubyLanguageServer(),

    available: $USE_RUBY_LANGUAGE_SERVER ==# "1",
  })
enddef

def ExtraConfigForRubyLanguageServer(): dict<any>
  return {
    cmd: (_) => ["ruby_language_server"],
    initialization_options: {
      diagnostics: "false",
    },

    document_format_priority: document_format.MIN_PRIORITY,
  }
enddef

# gem install ruby-lsp
def RegisterRubyLsp(): void
  RegisterServer({
    name: "ruby-lsp",
    allowlist: ["ruby"],
    extra_config: () => ExtraConfigForRubyLsp(),

    available: $USE_RUBY_LSP !=# "0",
  })
enddef

def ExtraConfigForRubyLsp(): dict<any>
  return {
    cmd: (_) => ["ruby-lsp", "stdio"],
    initialization_options: {
      diagnostics: true,
    },

    document_format_priority: document_format.MIN_PRIORITY,
  }
enddef

# gem install solargraph
def RegisterSolargraph(): void
  RegisterServer({
    name: "solargraph",
    allowlist: ["ruby"],
    extra_config: () => ExtraConfigForSolargraph(),

    available: $USE_SOLARGRAPH !=# "0",
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

    document_format_priority: document_format.MIN_PRIORITY,
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
    document_format_priority: document_format.MIN_PRIORITY,
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

# npm install @tailwindcss/language-server
def RegisterTailwindcssLanguageServer(): void
  RegisterServer({
    name: "tailwindcss-language-server",
    allowlist: ["css", "html", "slim"] + JS_FILETYPES + TS_FILETYPES,
    extra_config: () => ExtraConfigForTailwindcssLanguageServer(),

    available: !jsUtil.ShouldUseDeno(),
  })
enddef

def ExtraConfigForTailwindcssLanguageServer(): dict<any>
  return {
    cmd: (_) => ["tailwindcss-language-server", "--stdio"],
    env: NodeToolsEnv(),

    document_hover: false,
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

    available: $USE_TERRAFORM_LSP ==# "1",
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

    available: $USE_TYPEPROF ==# "1",
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
    allowlist: ShouldUseVueLanguageServer() ? [] : (JS_FILETYPES + (jsUtil.ShouldUseDeno() ? [] : TS_FILETYPES)),
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

    document_format_priority: document_format.MIN_PRIORITY,
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

    document_format_priority: document_format.MIN_PRIORITY,
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

# Disable some language servers’ capabilities because vim-lsp randomly selects only 1 language server to do something
# from language servers which have capability.
def OverwriteCapabilities(): void
  if !has_key(cache, "capabilities_overwritten")
    cache.capabilities_overwritten = {}
  endif

  if has_key(cache.capabilities_overwritten, &filetype)
    return
  endif

  cache.capabilities_overwritten[&filetype] = true

  for config in Configs(&filetype)
    if get(config, "document_hover", true) ==# false
      final capabilities = lsp#get_server_capabilities(config.name)

      if has_key(capabilities, "hoverProvider")
        capabilities.hoverProvider = false
        logger.Info($"{config.name}’s hoverProvider got forced to be disabled.")
      endif
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

  cache.use_vue_language_server = ($USE_VUEJS ==# "1")
  return cache.use_vue_language_server
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
