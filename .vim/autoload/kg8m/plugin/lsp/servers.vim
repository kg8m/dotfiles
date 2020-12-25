vim9script

final s:summaries: list<dict<any>> = []
final s:configs:   list<dict<any>> = []
final s:filetypes: list<string>    = []

final s:cache = {}

const s:js_filetypes   = ["javascript", "typescript"]
const s:sh_filetypes   = ["sh", "zsh"]
const s:yaml_filetypes = ["eruby.yaml", "yaml", "yaml.ansible"]

def kg8m#plugin#lsp#servers#register(): void  # {{{
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
        schemas: s:schemas(),
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

  uniq(sort(s:filetypes))
enddef  # }}}

def kg8m#plugin#lsp#servers#enable(): void  # {{{
  for config in s:configs
    for key in ["config", "initialization_options", "workspace_config"]
      if type(get(config, key)) ==# v:t_func
        config[key] = get(config, key)()
      endif
    endfor

    lsp#register_server(config)
  endfor
enddef  # }}}

def kg8m#plugin#lsp#servers#summaries(): list<dict<any>>  # {{{
  return s:summaries
enddef  # }}}

def kg8m#plugin#lsp#servers#filetypes(): list<string>  # {{{
  return s:filetypes
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

    add(s:configs, config)
    extend(s:filetypes, config.allowlist)

    add(s:summaries, { name: config.name, available: v:true })
  else
    add(s:summaries, { name: config.name, available: v:false })
  endif
enddef  # }}}

def s:schemas(): list<any>  # {{{
  if !has_key(s:cache, "lsp_schemas_json")
    const filepath = kg8m#plugin#get_info("vim-lsp-settings").path .. "/data/catalog.json"
    const json     = filepath->readfile()->join("\n")->json_decode()
    s:cache.lsp_schemas_json = json.schemas
  endif

  return s:cache.lsp_schemas_json
enddef  # }}}
