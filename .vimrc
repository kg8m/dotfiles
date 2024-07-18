vim9script

# Profile  # {{{
# 1. Enable following profile commands (`profile start ...`)
# 2. Do something you are concerned with
# 3. Disable and finish profiling by `:profile pause | noautocmd qall!`
# 4. Check ~/tmp/vim-profile.log

# profile start ~/tmp/vim-profile.log
# profile func *
# profile file *
# }}}

# ----------------------------------------------
# Initialize  # {{{
# Set initial variables/options  # {{{
const my_config_dirpath = $"{$XDG_CONFIG_HOME}/vim"
&runtimepath ..= $",{my_config_dirpath}"
&runtimepath ..= $",{my_config_dirpath}/after"

g:mapleader = ","

const use_editorconfig = filereadable(".editorconfig")
# }}}
# }}}

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util.vim"

# ----------------------------------------------
# Plugins  # {{{
# Default plugins  # {{{
plugin.DisableDefaults()
# }}}

# Initialize plugin manager  # {{{
plugin.InitManager()
# }}}

# Plugins list and settings  # {{{
# Watching
plugin.Register("Shougo/dpp.vim", { if: false })

# Completion, LSP  # {{{
if plugin.Register("prabirshrestha/asyncomplete.vim")
  import autoload "kg8m/plugin/asyncomplete.vim"
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,

    hook_source:      () => asyncomplete.OnSource(),
    hook_post_source: () => asyncomplete.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/asyncomplete-buffer.vim")
  import autoload "kg8m/plugin/asyncomplete/buffer.vim" as asyncompleteBuffer
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteBuffer.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/asyncomplete-file.vim")
  import autoload "kg8m/plugin/asyncomplete/file.vim" as asyncompleteFile
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteFile.OnPostSource(),
  })
endif

if plugin.Register("kg8m/asyncomplete-mocword.vim")
  import autoload "kg8m/plugin/asyncomplete/mocword.vim" as asyncompleteMocword
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteMocword.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/asyncomplete-neosnippet.vim")
  import autoload "kg8m/plugin/asyncomplete/neosnippet.vim" as asyncompleteNeosnippet
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteNeosnippet.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/asyncomplete-lsp.vim")
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
  })
endif

if plugin.Register("kitagry/asyncomplete-tabnine.vim", { if: util.IsTabnineAvailable(), build: "./install.sh" })
  import autoload "kg8m/plugin/asyncomplete/tabnine.vim" as asyncompleteTabnine
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteTabnine.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/asyncomplete-tags.vim")
  import autoload "kg8m/plugin/asyncomplete/tags.vim" as asyncompleteTags
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],

    hook_post_source: () => asyncompleteTags.OnPostSource(),
  })
endif

if plugin.Register("Shougo/neosnippet.vim")
  import autoload "kg8m/plugin/neosnippet.vim"
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],

    # for Syntaxes
    on_ft: ["snippet", "neosnippet"],

    on_start: true,

    hook_source:      () => neosnippet.OnSource(),
    hook_post_source: () => neosnippet.OnPostSource(),
  })
endif

if plugin.Register("prabirshrestha/vim-lsp")
  import autoload "kg8m/plugin/lsp.vim"
  import autoload "kg8m/plugin/lsp/servers.vim" as lspServers

  lspServers.Register()

  plugin.Configure({
    lazy:  true,
    on_ft: lspServers.Filetypes(),

    hook_source: () => lsp.OnSource(),
  })

  # Watching
  plugin.Register("mattn/vim-lsp-settings", { if: false })
  plugin.Register("tsuyoshicho/vim-efm-langserver-settings", { if: false })
endif

if plugin.Register("hrsh7th/vim-vsnip")
  import autoload "kg8m/plugin/vsnip.vim"
  plugin.Configure({
    lazy: true,
    on_event: ["InsertEnter"],

    hook_post_source: () => vsnip.OnPostSource(),
  })

  if plugin.Register("hrsh7th/vim-vsnip-integ")
    plugin.Configure({
      lazy:      true,
      on_source: ["vim-vsnip"],
    })
  endif
endif
# }}}

# Watching
plugin.Register("dense-analysis/ale", { if: false })

plugin.Register("pearofducks/ansible-vim")

# Show diff in Git's interactive rebase
plugin.Register("hotwatermorning/auto-git-diff", { if: util.IsGitRebase() })

if plugin.Register("girishji/autosuggest.vim")
  plugin.Configure({
    lazy:     true,
    on_event: ["CmdlineEnter"],
    hook_post_source: () => {
      # Remove the delay because it sometimes annoys my command-line operations.
      g:AutoSuggestSetup({ cmd: { delay: 0 } })
    },
  })
endif

if plugin.Register("kat0h/bufpreview.vim", { if: !util.IsGitTmpEdit() })
  plugin.Configure({
    lazy:    true,
    on_cmd:  ["PreviewMarkdown"],
    depends: ["denops.vim"],
    build:   "deno task prepare",
  })
endif

if plugin.Register("tyru/caw.vim", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/caw.vim"

  map <expr> gc caw.Run()

  plugin.Configure({
    lazy: true,

    hook_source: () => caw.OnSource(),
  })
endif

if plugin.Register("rhysd/conflict-marker.vim")
  import autoload "kg8m/plugin/conflict_marker.vim" as conflictMarker

  augroup vimrc-plugin-conflict_marker
    autocmd!
    autocmd FileType * conflictMarker.SetupBuffer()
    autocmd User all_on_start_plugins_sourced conflictMarker.NotifyActivated()
  augroup END

  plugin.Configure({
    lazy:   true,
    on_map: { n: "<Plug>(conflict-marker-" },

    hook_source: () => conflictMarker.OnSource(),
  })
endif

if plugin.Register("Shougo/context_filetype.vim")
  import autoload "kg8m/configure/filetypes/javascript.vim" as jsConfig

  const for_js = [
    { start: '\<html`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "html" },
    { start: '\<css`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
    { start: '\v<styled%(\(.+\)|\.\w+)`$',  end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
  ]

  # For caw.vim and so on
  g:context_filetype#filetypes = {}
  for filetype in jsConfig.JS_FILETYPES + jsConfig.TS_FILETYPES
    g:context_filetype#filetypes[filetype] = for_js
  endfor
endif

plugin.Register("Milly/deno-protocol.vim")

if plugin.Register("vim-denops/denops.vim", { lazy: true })
  g:denops_disable_version_check = true

  if $DENOPS_DEBUG ==# "1"
    g:denops#debug = true
    g:denops#trace = true
  endif
endif

if plugin.Register("gamoutatsumi/dps-ghosttext.vim", { if: $USE_GHOST_TEXT ==# "1" })
  import autoload "kg8m/plugin/ghosttext.vim"
  plugin.Configure({
    lazy:    true,
    on_cmd:  ["GhostStart"],
    depends: ["denops.vim"],

    hook_source: () => ghosttext.OnSource(),
  })
endif

if plugin.Register("spolu/dwm.vim", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/dwm.vim"

  nnoremap <C-w>n       :call DWM_New()<CR>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<CR>

  plugin.Configure({
    lazy:    true,
    on_cmd:  ["DWMOpen"],
    on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],

    hook_source:      () => dwm.OnSource(),
    hook_post_source: () => dwm.OnPostSource(),
  })
endif

if plugin.Register("editorconfig/editorconfig-vim", { if: !util.IsGitTmpEdit() && use_editorconfig })
  g:EditorConfig_preserve_formatoptions = true
endif

if plugin.Register("junegunn/fzf.vim", { if: executable("fzf") })
  import autoload "kg8m/plugin/fzf.vim"
  import autoload "kg8m/plugin/fzf/files.vim"        as fzfFiles
  import autoload "kg8m/plugin/fzf/git_files.vim"    as fzfGitFiles
  import autoload "kg8m/plugin/fzf/buffers.vim"      as fzfBuffers
  import autoload "kg8m/plugin/fzf/buffer_lines.vim" as fzfBufferLines
  import autoload "kg8m/plugin/fzf/marks.vim"        as fzfMarks
  import autoload "kg8m/plugin/fzf/history.vim"      as fzfHistory
  import autoload "kg8m/plugin/fzf/helptags.vim"     as fzfHelptags
  import autoload "kg8m/plugin/fzf/yank_history.vim" as fzfYankHistory
  import autoload "kg8m/plugin/fzf/grep.vim"         as fzfGrep
  import autoload "kg8m/plugin/fzf/shortcuts.vim"    as fzfShortcuts
  import autoload "kg8m/plugin/fzf/jumplist.vim"     as fzfJumplist
  import autoload "kg8m/plugin/fzf/rails.vim"        as fzfRails
  import autoload "kg8m/plugin/fzf/rails_routes.vim" as fzfRailsRoutes
  import autoload "kg8m/plugin/fzf_tjump.vim"        as fzfTjump

  # See also vim-fzf-tjump's mappings
  nnoremap <silent> <Leader><Leader>f <ScriptCmd>fzfFiles.Run()<CR>
  nnoremap <silent> <Leader><Leader>v <ScriptCmd>fzfGitFiles.Run()<CR>
  nnoremap <silent> <Leader><Leader>b <ScriptCmd>fzfBuffers.Run()<CR>
  nnoremap <silent> <Leader><Leader>l <ScriptCmd>fzfBufferLines.Run()<CR>
  nnoremap <silent> <Leader><Leader>m <ScriptCmd>fzfMarks.Run()<CR>
  nnoremap <silent> <Leader><Leader>h <ScriptCmd>fzfHistory.Run()<CR>
  nnoremap <silent> <Leader><Leader>H <ScriptCmd>fzfHelptags.Run()<CR>
  nnoremap <silent> <Leader><Leader>y <ScriptCmd>fzfYankHistory.Run()<CR>
  nnoremap <silent> <Leader><Leader>g <ScriptCmd>fzfGrep.EnterCommand()<CR>
  xnoremap <silent> <Leader><Leader>g "zy<ScriptCmd>fzfGrep.EnterCommand(@z)<CR>
  xnoremap <silent> <Leader><Leader>G "zy<ScriptCmd>fzfGrep.EnterCommand(@z, { word_boundary: true })<CR>
  noremap  <silent> <Leader><Leader>s <ScriptCmd>fzfShortcuts.Run("")<CR>
  noremap  <silent> <Leader><Leader>a <ScriptCmd>fzfShortcuts.Run("SimpleAlign ")<CR>
  nnoremap <silent> <Leader><Leader>[ <ScriptCmd>fzfJumplist.Back()<CR>
  nnoremap <silent> <Leader><Leader>] <ScriptCmd>fzfJumplist.Forward()<CR>
  nnoremap <silent> <Leader><Leader>r <ScriptCmd>fzfRails.EnterCommand()<CR>
  nnoremap <silent> <Leader><Leader>R <ScriptCmd>fzfRailsRoutes.Run()<CR>

  plugin.Configure({
    lazy:     true,
    on_start: true,
    depends:  ["fzf"],

    hook_source: () => fzf.OnSource(),
  })

  # Add to runtimepath (and use its Vim scripts) but don't use its binary.
  # Use fzf binary already installed instead.
  plugin.Register("junegunn/fzf", { lazy: true })

  if plugin.Register("kg8m/vim-fzf-tjump")
    nnoremap <Leader><Leader>t :FzfTjump<Space>
    xnoremap <Leader><Leader>t "zy:FzfTjump<Space><C-r>z

    map g] <Plug>(fzf-tjump)

    plugin.Configure({
      lazy:    true,
      on_cmd:  ["FzfTjump"],
      on_map:  { nx: "<Plug>(fzf-tjump)" },
      depends: ["fzf.vim", "vim-parallel-auto-ctags"],

      hook_source: () => fzfTjump.OnSource(),
    })
  endif
endif

if plugin.Register("lambdalisue/vim-gin", { if: !util.IsGitTmpEdit() })
  g:gin_diff_default_args = ["++processor=delta"]

  augroup vimrc-plugin-gin
    autocmd!
    # Regular `gf` doesn’t work due to some reason.
    autocmd FileType gin-diff nnoremap <buffer> gf :execute "edit" expand("<cfile>")<CR>
  augroup END

  plugin.Configure({
    lazy:    true,
    on_cmd:  ["GinDiff", "GinEdit", "GinPatch"],
    depends: ["denops.vim"],
  })
endif

if plugin.Register("tweekmonster/helpful.vim")
  plugin.Configure({
    lazy:   true,
    on_cmd: ["HelpfulVersion"],
  })
endif

if plugin.Register("Yggdroot/indentLine", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/indent_line.vim" as indentLine
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source: () => indentLine.OnSource(),
  })
endif

if plugin.Register("othree/javascript-libraries-syntax.vim", { if: !util.IsGitTmpEdit() })
  g:used_javascript_libs = "jquery,react,vue"
endif

if plugin.Register("fuenor/JpFormat.vim")
  import autoload "kg8m/plugin/jpformat.vim"
  plugin.Configure({
    lazy:   true,
    on_map: { x: "gq" },

    hook_source: () => jpformat.OnSource(),
  })
endif

if plugin.Register("lambdalisue/vim-kensaku")
  plugin.Configure({
    lazy: true,
    depends: ["denops.vim"],
  })
endif

if plugin.Register("cohama/lexima.vim")
  import autoload "kg8m/plugin/lexima.vim"
  plugin.Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,

    hook_source:      () => lexima.OnSource(),
    hook_post_source: () => lexima.OnPostSource(),
  })
endif

if plugin.Register("itchyny/lightline.vim")
  import autoload "kg8m/plugin/lightline.vim"
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source:      () => lightline.OnSource(),
    hook_post_source: () => lightline.OnPostSource(),
  })
endif

if plugin.Register("AndrewRadev/linediff.vim")
  plugin.Configure({
    lazy:   true,
    on_cmd: ["Linediff"],

    hook_source: () => {
      g:linediff_second_buffer_command = "rightbelow vertical new"
    },
  })
endif

plugin.Register("kg8m/moin.vim")

if plugin.Register("lambdalisue/vim-mr", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/mr.vim"

  g:mr_mrw_disabled = true
  g:mr_mrr_disabled = true
  g:mr#threshold = 10'000
  g:mr#mru#filename = $"{$XDG_DATA_HOME}/vim/mr/mru"
  g:mr#mru#predicates = [(filepath) => mr.Predicate(filepath)]
endif

plugin.Register("lambdalisue/vim-nerdfont")

if plugin.Register("tyru/open-browser.vim")
  import autoload "kg8m/plugin/open_browser.vim" as openBrowser

  map <Leader>o <Plug>(openbrowser-open)

  plugin.Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(openbrowser-open)" },

    hook_source:      () => openBrowser.OnSource(),
    hook_post_source: () => openBrowser.OnPostSource(),
  })
endif

if plugin.Register("tyru/open-browser-github.vim")
  plugin.Configure({
    lazy:    true,
    on_cmd:  ["OpenGithubFile"],
    depends: ["open-browser.vim"],

    hook_post_source: () => {
      # I don’t need these commands.
      delcommand OpenGithubCommit
      delcommand OpenGithubIssue
      delcommand OpenGithubProject
      delcommand OpenGithubPullReq
    },
  })
endif

if plugin.Register("tyru/operator-camelize.vim")
  xmap <Leader>C <Plug>(operator-camelize)
  xmap <Leader>c <Plug>(operator-decamelize)

  plugin.Configure({
    lazy:   true,
    on_map: { x: ["<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"] },
  })
endif

if plugin.Register("vim-python/python-syntax")
  g:python_highlight_all = true
endif

if plugin.Register("yssl/QFEnter")
  import autoload "kg8m/plugin/qfenter.vim"
  plugin.Configure({
    lazy:  true,
    on_ft: ["qf"],

    hook_source: () => qfenter.OnSource(),
  })
endif

if plugin.Register("stefandtw/quickfix-reflector.vim")
  plugin.Configure({
    lazy:  true,
    on_ft: ["qf"],
  })
endif

if plugin.Register("mechatroner/rainbow_csv", { if: !util.IsGitTmpEdit() })
  augroup vimrc-plugin-rainbow_csv
    autocmd!
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END

  plugin.Configure({
    lazy:  true,
    on_ft: ["csv"],
  })
endif

plugin.Register("lambdalisue/vim-readablefold", { if: !util.IsGitTmpEdit() })

if plugin.Register("vim-scripts/sequence")
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  plugin.Configure({
    lazy:   true,
    on_map: { x: "<Plug>Sequence" },
  })
endif

if plugin.Register("AndrewRadev/splitjoin.vim", { if: !util.IsGitTmpEdit() })
  nnoremap <Leader>J :SplitjoinJoin<CR>
  nnoremap <Leader>S :SplitjoinSplit<CR>

  plugin.Configure({
    lazy:   true,
    on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],

    hook_source: () => {
      g:splitjoin_split_mapping       = ""
      g:splitjoin_join_mapping        = ""
      g:splitjoin_ruby_trailing_comma = true
      g:splitjoin_ruby_hanging_args   = false
    },
  })
endif

if plugin.Register("lambdalisue/vim-suda")
  plugin.Configure({
    lazy:   true,
    on_cmd: ["SudaRead"],
  })
endif

if plugin.Register("mbbill/undotree")
  nnoremap <Leader>u :UndotreeToggle<CR>

  plugin.Configure({
    lazy:   true,
    on_cmd: ["UndotreeToggle"],

    hook_source: () => {
      g:undotree_WindowLayout       = 2
      g:undotree_SplitWidth         = 50
      g:undotree_DiffpanelHeight    = 30
      g:undotree_SetFocusWhenToggle = true
    },
  })
endif

# Legacy Vim script version for my development.
if plugin.Register("kg8m/vim-simple-align", { name: "vim-simple-align-legacy", if: false })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if plugin.Register("kg8m/vim-simple-align", { rev: "vim9" })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if plugin.Register("FooSoft/vim-argwrap", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/argwrap.vim"

  nnoremap <Leader>a :ArgWrap<CR>

  plugin.Configure({
    lazy:   true,
    on_cmd: ["ArgWrap"],

    hook_source: () => argwrap.OnSource(),
  })
endif

if plugin.Register("haya14busa/vim-asterisk")
  import autoload "kg8m/plugin/asterisk.vim"

  map <expr> *  asterisk.WithNotify("<Plug>(asterisk-z*)")
  map <expr> #  asterisk.WithNotify("<Plug>(asterisk-z#)")
  map <expr> g* asterisk.WithNotify("<Plug>(asterisk-gz*)")
  map <expr> g# asterisk.WithNotify("<Plug>(asterisk-gz#)")

  plugin.Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(asterisk-" },
  })
endif

plugin.Register("h1mesuke/vim-benchmark")

if plugin.Register("jkramer/vim-checkbox", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/checkbox.vim"

  augroup vimrc-plugin-checkbox
    autocmd!
    autocmd FileType markdown,moin noremap <buffer><silent> ch :call <SID>checkbox.Run()<CR>
  augroup END

  plugin.Configure({
    lazy: true,
  })
endif

if plugin.Register("alvan/vim-closetag")
  import autoload "kg8m/plugin/closetag.vim"
  plugin.Configure({
    lazy:  true,
    on_ft: closetag.FILETYPES,

    hook_source:      () => closetag.OnSource(),
    hook_post_source: () => closetag.OnPostSource(),
  })
endif

plugin.Register("hail2u/vim-css3-syntax", { if: !util.IsGitTmpEdit() })

if plugin.Register("kg8m/vim-detect-indent", { if: !use_editorconfig })
  g:detect_indent#detect_once      = false
  g:detect_indent#ignore_filetypes = ["", "gitcommit", "startify"]

  # Don't include `nofile` because a buffer generated by dps-ghosttext.vim has `nofile` buftype.
  g:detect_indent#ignore_buftypes = ["quickfix", "terminal"]

  plugin.Configure({
    # Don't load lazily because keystrokes are snatched on its load.
    lazy: false,

    depends: ["denops.vim"],
  })
endif

if plugin.Register("wsdjeg/vim-fetch")
  augroup vimrc-plugin-fetch
    autocmd!
    autocmd VimEnter * {
      # Disable vim-fetch's `gF` mappings because it conflicts with other plugins
      nmap gF <Plug>(gf-user-gF)
      xmap gF <Plug>(gf-user-gF)
    }
  augroup END
endif

plugin.Register("thinca/vim-ft-diff_fold")
plugin.Register("thinca/vim-ft-help_fold")

if plugin.Register("muz/vim-gemfile")
  import autoload "kg8m/plugin/gemfile.vim"
  augroup vimrc-plugin-gemfile
    autocmd!

    # Execute lazily for overwriting default configs.
    autocmd FileType Gemfile timer_start(100, (_) => gemfile.SetupBuffer())
  augroup END
endif

if plugin.Register("kana/vim-gf-user")
  gf#user#extend("kg8m#plugin#gf_user#VimAutoload", 1000)

  if util.OnRailsDir()
    gf#user#extend("kg8m#plugin#gf_user#RailsFiles", 1000)
  endif
endif

if plugin.Register("tpope/vim-git", { if: util.IsGitCommit() })
  augroup vimrc-plugin-git
    autocmd!

    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END
endif

plugin.Register("tpope/vim-haml")

if plugin.Register("itchyny/vim-histexclude")
  import autoload "kg8m/plugin/histexclude.vim"

  nnoremap <expr> : histexclude.Run()

  plugin.Configure({
    lazy: true,

    hook_source: () => histexclude.OnSource(),
  })
endif

if plugin.Register("obcat/vim-hitspop")
  import autoload "kg8m/plugin/hitspop.vim"
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source: () => hitspop.OnSource(),
  })
endif

if plugin.Register("git@github.com:kg8m/vim-hz_ja-extracted")
  plugin.Configure({
    lazy:   true,
    on_cmd: ["Hankaku", "HzjaConvert", "Zenkaku"],

    hook_source: () => {
      g:hz_ja_extracted_default_commands = true
      g:hz_ja_extracted_default_mappings = false
    },
  })
endif

# Text object for (Japanese) sentence: s
if plugin.Register("deton/jasentence.vim")
  plugin.Configure({
    lazy:   true,
    on_map: { nv: ["(", ")"], o: "s" },

    hook_source: () => {
      g:jasentence_endpat = '[。．？！!?]\+'
    },
  })
endif

plugin.Register("bfrg/vim-jq")

if plugin.Register("elzr/vim-json")
  g:vim_json_syntax_conceal = false
endif

plugin.Register("MaxMEllon/vim-jsx-pretty")

if plugin.Register("andymass/vim-matchup")
  import autoload "kg8m/plugin/matchup.vim"
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source: () => matchup.OnSource(),
  })
endif

if plugin.Register("mattn/vim-molder", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/molder.vim"

  nnoremap <silent> <Leader>e <ScriptCmd>molder.Run()<CR>

  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source: () => molder.OnSource(),
  })
endif

plugin.Register("kana/vim-operator-user")

if plugin.Register("kg8m/vim-parallel-auto-ctags", { if: util.IsCtagsAvailable() && !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/parallel_auto_ctags.vim" as parallelAutoCtags
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source:      () => parallelAutoCtags.OnSource(),
    hook_post_source: () => parallelAutoCtags.OnPostSource(),
  })
endif

if plugin.Register("thinca/vim-prettyprint", { if: !util.IsGitTmpEdit() })
  plugin.Configure({
    # Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work.
    lazy: false,
  })
endif

if plugin.Register("lambdalisue/vim-protocol", { if: !util.IsGitTmpEdit() })
  plugin.Configure({
    lazy:    true,
    on_path: ['^https\?://'],
  })
endif

if plugin.Register("tpope/vim-rails", { if: !util.IsGitTmpEdit() && util.OnRailsDir() })
  # For Rails engines.
  if !filereadable("config/environment.rb")
    augroup vimrc-rails
      autocmd!
      autocmd BufNewFile,BufRead * b:rails_root = getcwd()
    augroup END
  endif

  if !has_key(g:, "rails_path_additions")
    g:rails_path_additions = []
  endif

  if isdirectory("spec/support")
    g:rails_path_additions += [
      "spec/support",
    ]
  endif

  plugin.Configure({
    # Don't load lazily because some features don't work.
    lazy: false,
  })
endif

plugin.Register("jlcrochet/vim-rbs")
plugin.Register("tpope/vim-repeat")

if plugin.Register("vim-ruby/vim-ruby")
  g:no_ruby_maps = true

  # For performance: vim-ruby searches Ruby directories and sets the `path` option but the feature is a bit slow and
  # unnecessary for me.
  g:ruby_path = ""

  augroup vimrc-plugin-ruby
    autocmd!

    # vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile set filetype=Gemfile

    # Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby unlet! b:ruby_no_expensive
  augroup END
endif

if plugin.Register("joker1007/vim-ruby-heredoc-syntax", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/ruby_heredoc_syntax.vim" as rubyHeredocSyntax
  plugin.Configure({
    lazy:  true,
    on_ft: ["ruby"],

    hook_source: () => rubyHeredocSyntax.OnSource(),
  })
endif

# Text object for surrounded by a bracket-pair or same characters: S + {user input}
if plugin.Register("machakann/vim-sandwich")
  import autoload "kg8m/plugin/sandwich.vim"
  import autoload "kg8m/util/matchpairs.vim"

  xnoremap <Leader>sa <Plug>(operator-sandwich-add)

  # Operators for deleting/replacing using textobjects that automatically detect matching pairs where some same type
  # symbols are mixed up:
  #
  #                           *----------- ( ----------*
  #                           *----------- ) ----------*
  #              *---- ( ------------------------------------------*
  #                                 *---- " ----*
  #        *---------------------- " -------------------------------------*
  #   aaaaa"bbbbb（ccccc(ddddd(eeeee“ffffffffff”eeeee)ddddd)ccccc）bbbbb"aaaaa
  nnoremap <expr> <Leader>sd sandwich.OperatorDeleteExpr()
  nnoremap <expr> <Leader>sr sandwich.OperatorReplaceExpr()

  # Textobjects that automatically detect matching pairs where some same type symbols are mixed up:
  #
  #                            <--------- i( --------->
  #                            <--------- i) --------->
  #                           <---------- a( ---------->
  #                      <- i( ----------------------------->
  #                <- i( ----------------------------------------->
  #                                   <-- i" -->
  #         <-------------------- i" ------------------------------------>
  #   aaaaa"bbbbb（ccccc(ddddd(eeeee“ffffffffff”eeeee)ddddd)ccccc）bbbbb"aaaaa
  const modes = ["x", "o"]
  const a_i_types = ["a", "i"]
  for key in matchpairs.GroupedJapanesePairs()->keys()
    for key_or_another in matchpairs.KeyPairFor(key)
      for mode in modes
        for a_or_i in a_i_types
          const lhs = $"{a_or_i}{key_or_another}"
          const rhs = $"sandwich.AutoTextobjExpr({string(key_or_another)}, '{mode}', '{a_or_i}')"

          execute $"{mode}noremap <expr><silent> {lhs} {rhs}"
        endfor
      endfor
    endfor
  endfor

  nmap . <Plug>(operator-sandwich-dot)

  plugin.Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(operator-sandwich-", o: "<Plug>(textobj-sandwich-" },

    hook_source:      () => sandwich.OnSource(),
    hook_post_source: () => sandwich.OnPostSource(),
  })
endif

plugin.Register("arzg/vim-sh")

# Don’t use slim-template/vim-slim because it has some bugs.
# For example, highlighting is broken with quoteless attribute like `span(class=detect_span_class)`.
plugin.Register("delphaber/vim-slim")

if plugin.Register("mhinz/vim-startify", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/startify.vim"

  if argc() ># 0
    # `on_event: "BufWritePre"` for `SaveSession()`: Load startify before writing buffer (on `BufWritePre`) and
    # register autocmd for `BufWritePost`
    plugin.Configure({
      lazy:     true,
      on_cmd:   ["Startify"],
      on_event: ["BufWritePre"],

      hook_source:      () => startify.OnSource(),
      hook_post_source: () => startify.OnPostSource(),
    })
  else
    startify.Setup()
  endif
endif

if plugin.Register("kopischke/vim-stay", { if: !util.IsGitCommit() })
  import autoload "kg8m/configure/folding/manual.vim" as manualFolding

  set viewoptions=cursor,folds

  augroup vimrc-plugin-stay
    autocmd!
    autocmd User BufStaySavePre manualFolding.Restore()
  augroup END
endif

plugin.Register("hashivim/vim-terraform")

if plugin.Register("janko/vim-test", { if: !util.IsGitTmpEdit() })
  import autoload "kg8m/plugin/test.vim"

  nnoremap <Leader>T :write<CR><ScriptCmd>test.RunFileTest()<CR>
  nnoremap <Leader>t :write<CR><ScriptCmd>test.RunNearestTest()<CR>

  plugin.Configure({
    lazy:   true,
    on_cmd: ["TestFile", "TestNearest"],

    hook_source: () => test.OnSource(),
  })
endif

# Text object for indentation: i
plugin.Register("kana/vim-textobj-indent", { lazy: true, on_start: true })

# Text object for last search pattern: /
plugin.Register("kana/vim-textobj-lastpat", { lazy: true, on_start: true })

# Text object for string: ,s
if plugin.Register("rbtnn/vim-textobj-string", { lazy: true, on_start: true })
  g:vim_textobj_string_mapping = ",s"
endif

plugin.Register("kana/vim-textobj-user")

# Text object for word for human: ,w
plugin.Register("h1mesuke/textobj-wiw", { lazy: true, on_start: true })

# For syntaxes
plugin.Register("thinca/vim-themis")

# Watching
plugin.Register("mattn/vim-treesitter", { if: false })

plugin.Register("posva/vim-vue")

if plugin.Register("thinca/vim-zenspace")
  import autoload "kg8m/plugin/zenspace.vim"

  augroup vimrc-plugin-zenspace
    autocmd!
    autocmd ColorScheme * highlight ZenSpace gui=underline guibg=DarkGray guifg=DarkGray
  augroup END

  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source:      () => zenspace.OnSource(),
    hook_post_source: () => zenspace.OnPostSource(),
  })
endif

if plugin.Register("monkoose/vim9-stargate")
  g:stargate_chars = "FKLASDHGUIONMREWCVTYBX,;J"
  nnoremap <C-w>f :call stargate#Galaxy()<CR>
endif

# See `kg8m#util#xxx#Vital()`.
# Specify `merged: false` because `Vitalize` fails.
plugin.Register("vim-jp/vital.vim", { merged: false })

if plugin.Register("simeji/winresizer", { if: !util.IsGitTmpEdit() })
  g:winresizer_start_key = "<C-w><C-e>"

  plugin.Configure({
    lazy:   true,
    on_map: { n: g:winresizer_start_key },
  })
endif

plugin.Register("stephpy/vim-yaml", { if: !util.IsGitTmpEdit() })

# Use my fork until the PR https://github.com/pedrohdz/vim-yaml-folds/pull/7 is merged.
plugin.Register("pedrohdz/vim-yaml-folds", { if: false, name: "vim-yaml-folds-original" })
if plugin.Register("kg8m/vim-yaml-folds", { if: !util.IsGitTmpEdit(), rev: "support_custom_foldtext" })
  g:yamlfolds_use_yaml_fold_text = false
endif

if plugin.Register("jonsmithers/vim-html-template-literals", { if: !util.IsGitTmpEdit() })
  g:htl_css_templates = true
  g:htl_all_templates = false

  plugin.Configure({
    depends: ["vim-javascript"],
  })

  plugin.Register("pangloss/vim-javascript")
endif

if plugin.Register("LeafCage/yankround.vim")
  import autoload "kg8m/plugin/yankround.vim"
  plugin.Configure({
    lazy:     true,
    on_start: true,

    hook_source: () => yankround.OnSource(),
  })
endif

plugin.Register("noprompt/vim-yardoc")

# Colorschemes
if plugin.Register("tomasr/molokai")
  import autoload "kg8m/plugin/molokai.vim"

  g:molokai_original = true

  augroup vimrc-plugin-molokai
    autocmd!
    autocmd ColorScheme molokai molokai.Overwrite()
  augroup END
endif
# }}}

# Finish plugin manager initialization  # {{{
plugin.FinishSetup()

# Disable filetype before enabling filetype
# https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if plugin.InstallableExists()
  plugin.Install()
endif
# }}}
# }}}

colorscheme molokai

# ----------------------------------------------
# Non-plugin Configurations  # {{{
import autoload "kg8m/configure.vim"
import autoload "kg8m/util/dim_inactive_windows.vim" as dimInactiveWindows

configure.Backup()
configure.Colors()
configure.Column()
configure.Comments()
configure.Completion()
configure.Cursor()
configure.Folding()
configure.Formatoptions()
configure.Indent()
configure.Scroll()
configure.Search()
configure.Statusline()
configure.Undo()
dimInactiveWindows.Setup()

if !util.IsGitTmpEdit()
  import autoload "kg8m/util/auto_reload.vim" as autoReload
  import autoload "kg8m/util/check_typo.vim" as checkTypo
  import autoload "kg8m/util/daemons.vim"

  autoReload.Setup()
  checkTypo.Setup()
  daemons.Setup()
endif

configure.Commands()
configure.Mappings()
configure.Others()

if has("gui_running")
  configure.Gui()
endif
# }}}

util.SourceLocalVimrc()
