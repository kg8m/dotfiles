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

kg8m#plugin#DisableDefaults()

g:mapleader = ","

const use_editorconfig = filereadable(".editorconfig")
# }}}
# }}}

# ----------------------------------------------
# Plugins  # {{{
# Initialize plugin manager  # {{{
kg8m#plugin#InitManager()
# }}}

# Plugins list and settings  # {{{
# Completion, LSP  # {{{
if kg8m#plugin#Register("prabirshrestha/asyncomplete.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    hook_source:      function("kg8m#plugin#asyncomplete#OnSource"),
    hook_post_source: function("kg8m#plugin#asyncomplete#OnPostSource"),
  })
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-buffer.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#buffer#OnPostSource"),
  })
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-file.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#file#OnPostSource"),
  })
endif

if kg8m#plugin#Register("kg8m/asyncomplete-mocword.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#mocword#OnPostSource"),
  })
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-neosnippet.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#neosnippet#OnPostSource"),
  })
endif

# TODO: Don't use deprecated nextword.
if kg8m#plugin#Register("high-moctane/asyncomplete-nextword.vim", { if: false })
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["async.vim", "asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#nextword#OnPostSource"),
  })

  kg8m#plugin#Register("prabirshrestha/async.vim", { lazy: true })
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-lsp.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
  })
endif

if kg8m#plugin#Register("kitagry/asyncomplete-tabnine.vim", { if: kg8m#util#IsTabnineAvailable(), build: "./install.sh" })
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#tabnine#OnPostSource"),
  })
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-tags.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: function("kg8m#plugin#asyncomplete#tags#OnPostSource"),
  })
endif

if kg8m#plugin#Register("Shougo/neosnippet.vim")
  # `on_ft` for Syntaxes
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_ft:    ["snippet", "neosnippet"],
    on_start: true,
    hook_source:      function("kg8m#plugin#neosnippet#OnSource"),
    hook_post_source: function("kg8m#plugin#neosnippet#OnPostSource"),
  })
endif

if kg8m#plugin#Register("prabirshrestha/vim-lsp")
  kg8m#plugin#lsp#servers#Register()

  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: kg8m#plugin#lsp#servers#Filetypes(),
    hook_source: function("kg8m#plugin#lsp#OnSource"),
  })

  kg8m#plugin#Register("mattn/vim-lsp-settings", { if: false, merged: false })
  kg8m#plugin#Register("tsuyoshicho/vim-efm-langserver-settings", { if: false, merged: false })
endif

if kg8m#plugin#Register("hrsh7th/vim-vsnip")
  kg8m#plugin#Configure({
    lazy: true,
    on_event: ["InsertEnter"],
    hook_post_source: function("kg8m#plugin#vsnip#OnPostSource"),
  })

  if kg8m#plugin#Register("hrsh7th/vim-vsnip-integ")
    kg8m#plugin#Configure({
      lazy:      true,
      on_source: "vim-vsnip",
    })
  endif
endif
# }}}

kg8m#plugin#Register("dense-analysis/ale", { if: false, merged: false })
kg8m#plugin#Register("pearofducks/ansible-vim")

# Show diff in Git's interactive rebase
kg8m#plugin#Register("hotwatermorning/auto-git-diff", { if: kg8m#util#IsGitRebase() })

if kg8m#plugin#Register("tyru/caw.vim", { if: !kg8m#util#IsGitTmpEdit() })
  map <expr> gc kg8m#plugin#caw#Run()

  kg8m#plugin#Configure({
    lazy: true,
    hook_source: function("kg8m#plugin#caw#OnSource"),
  })
endif

if kg8m#plugin#Register("rhysd/conflict-marker.vim")
  augroup vimrc-plugin-conflict_marker
    autocmd!
    autocmd FileType * kg8m#plugin#conflict_marker#SetupBuffer()
    autocmd User all_on_start_plugins_sourced kg8m#plugin#conflict_marker#NotifyActivated()
  augroup END

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { n: "<Plug>(conflict-marker-" },
    hook_source: function("kg8m#plugin#conflict_marker#OnSource"),
  })
endif

if kg8m#plugin#Register("Shougo/context_filetype.vim")
  const for_js = [
    { start: '\<html`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "html" },
    { start: '\<css`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
    { start: '\v<styled%(\(.+\)|\.\w+)`$',  end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
  ]

  # For caw.vim and so on
  g:context_filetype#filetypes = {
    javascript: for_js,
    typescript: for_js,
    javascriptreact: for_js,
    typescriptreact: for_js,
  }
endif

if kg8m#plugin#Register("gamoutatsumi/dps-ghosttext.vim", { if: $GHOST_TEXT_AVAILABLE ==# "1" })
  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["GhostStart"],
    depends: ["denops.vim"],
    hook_source: function("kg8m#plugin#ghosttext#OnSource"),
  })
endif

if kg8m#plugin#Register("spolu/dwm.vim", { if: !kg8m#util#IsGitTmpEdit() })
  nnoremap <C-w>n       :call DWM_New()<CR>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<CR>

  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["DWMOpen"],
    on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
    hook_source:      function("kg8m#plugin#dwm#OnSource"),
    hook_post_source: function("kg8m#plugin#dwm#OnPostSource"),
  })
endif

if kg8m#plugin#Register("editorconfig/editorconfig-vim", { if: !kg8m#util#IsGitTmpEdit() && use_editorconfig })
  g:EditorConfig_preserve_formatoptions = true
endif

if kg8m#plugin#Register("junegunn/fzf.vim", { if: executable("fzf") })
  # See also vim-fzf-tjump's mappings
  nnoremap <silent> <Leader><Leader>f :call kg8m#plugin#fzf#files#Run()<CR>
  nnoremap <silent> <Leader><Leader>v :call kg8m#plugin#fzf#git_files#Run()<CR>
  nnoremap <silent> <Leader><Leader>b :call kg8m#plugin#fzf#buffers#Run()<CR>
  nnoremap <silent> <Leader><Leader>l :call kg8m#plugin#fzf#buffer_lines#Run()<CR>
  nnoremap <silent> <Leader><Leader>m :call kg8m#plugin#fzf#marks#Run()<CR>
  nnoremap <silent> <Leader><Leader>h :call kg8m#plugin#fzf#history#Run()<CR>
  nnoremap <silent> <Leader><Leader>H :call kg8m#plugin#fzf#helptags#Run()<CR>
  nnoremap <silent> <Leader><Leader>y :call kg8m#plugin#fzf#yank_history#Run()<CR>
  nnoremap <silent> <Leader><Leader>g :call kg8m#plugin#fzf#grep#EnterCommand()<CR>
  xnoremap <silent> <Leader><Leader>g "zy:call kg8m#plugin#fzf#grep#EnterCommand(@z)<CR>
  xnoremap <silent> <Leader><Leader>G "zy:call kg8m#plugin#fzf#grep#EnterCommand(@z, #{ word_boundary: v:true })<CR>
  noremap  <silent> <Leader><Leader>s <Cmd>call kg8m#plugin#fzf#shortcuts#Run("")<CR>
  noremap  <silent> <Leader><Leader>a <Cmd>call kg8m#plugin#fzf#shortcuts#Run("SimpleAlign ")<CR>
  nnoremap <silent> <Leader><Leader>[ :call kg8m#plugin#fzf#jumplist#Back()<CR>
  nnoremap <silent> <Leader><Leader>] :call kg8m#plugin#fzf#jumplist#Forward()<CR>
  nnoremap <silent> <Leader><Leader>r :call kg8m#plugin#fzf#rails#EnterCommand()<CR>

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    depends:  ["fzf"],
    hook_source: function("kg8m#plugin#fzf#OnSource"),
  })

  # Add to runtimepath (and use its Vim scripts) but don't use its binary.
  # Use fzf binary already installed instead.
  kg8m#plugin#Register("junegunn/fzf", { lazy: true })

  if kg8m#plugin#Register("kg8m/vim-fzf-tjump")
    nnoremap <Leader><Leader>t :FzfTjump<Space>
    xnoremap <Leader><Leader>t "zy:FzfTjump<Space><C-r>z

    map g] <Plug>(fzf-tjump)

    kg8m#plugin#Configure({
      lazy:    true,
      on_cmd:  "FzfTjump",
      on_map:  { nx: "<Plug>(fzf-tjump)" },
      depends: ["fzf.vim", "vim-parallel-auto-ctags"],
      hook_source: function("kg8m#plugin#fzf_tjump#OnSource"),
    })
  endif
endif

if kg8m#plugin#Register("lambdalisue/gin.vim", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["GinEdit", "GinPatch"],
    depends: ["denops.vim"],
  })
endif

if kg8m#plugin#Register("tweekmonster/helpful.vim")
  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "HelpfulVersion",
  })
endif

if kg8m#plugin#Register("Yggdroot/indentLine", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: function("kg8m#plugin#indent_line#OnSource"),
  })
endif

if kg8m#plugin#Register("othree/javascript-libraries-syntax.vim", { if: !kg8m#util#IsGitTmpEdit() })
  g:used_javascript_libs = "jquery,react,vue"
endif

if kg8m#plugin#Register("fuenor/JpFormat.vim")
  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { x: "gq" },
    hook_source: function("kg8m#plugin#jpformat#OnSource"),
  })
endif

if kg8m#plugin#Register("cohama/lexima.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    hook_source:      function("kg8m#plugin#lexima#OnSource"),
    hook_post_source: function("kg8m#plugin#lexima#OnPostSource"),
  })
endif

if kg8m#plugin#Register("itchyny/lightline.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source:      function("kg8m#plugin#lightline#OnSource"),
    hook_post_source: function("kg8m#plugin#lightline#OnPostSource"),
  })
endif

if kg8m#plugin#Register("AndrewRadev/linediff.vim")
  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "Linediff",
    hook_source: () => {
      g:linediff_second_buffer_command = "rightbelow vertical new"
    },
  })
endif

kg8m#plugin#Register("kg8m/moin.vim")

if kg8m#plugin#Register("lambdalisue/mr.vim", { if: !kg8m#util#IsGitTmpEdit() })
  g:mr_mrw_disabled = true
  g:mr_mrr_disabled = true
  g:mr#threshold = 10'000
  g:mr#mru#filename = $"{$XDG_DATA_HOME}/vim/mr/mru"
  g:mr#mru#predicates = [function("kg8m#plugin#mr#Predicate")]
endif

if kg8m#plugin#Register("tyru/open-browser.vim")
  map <Leader>o <Plug>(openbrowser-open)

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(openbrowser-open)" },
    hook_source: function("kg8m#plugin#open_browser#OnSource"),
  })
endif

if kg8m#plugin#Register("tyru/operator-camelize.vim")
  xmap <Leader>C <Plug>(operator-camelize)
  xmap <Leader>c <Plug>(operator-decamelize)

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { x: ["<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"] },
  })
endif

if kg8m#plugin#Register("yssl/QFEnter")
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "qf",
    hook_source: function("kg8m#plugin#qfenter#OnSource"),
  })
endif

if kg8m#plugin#Register("stefandtw/quickfix-reflector.vim")
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "qf",
  })
endif

if kg8m#plugin#Register("mechatroner/rainbow_csv", { if: !kg8m#util#IsGitTmpEdit() })
  augroup vimrc-plugin-rainbow_csv
    autocmd!
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END

  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "csv",
  })
endif

kg8m#plugin#Register("lambdalisue/readablefold.vim", { if: !kg8m#util#IsGitTmpEdit() })

if kg8m#plugin#Register("vim-scripts/sequence")
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { x: "<Plug>Sequence" },
  })
endif

if kg8m#plugin#Register("AndrewRadev/splitjoin.vim", { if: !kg8m#util#IsGitTmpEdit() })
  nnoremap <Leader>J :SplitjoinJoin<CR>
  nnoremap <Leader>S :SplitjoinSplit<CR>

  kg8m#plugin#Configure({
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

kg8m#plugin#Register("lambdalisue/suda.vim")

if kg8m#plugin#Register("leafgarland/typescript-vim")
  g:typescript_indent_disable = true
endif

if kg8m#plugin#Register("mbbill/undotree")
  nnoremap <Leader>u :UndotreeToggle<CR>

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "UndotreeToggle",
    hook_source: () => {
      g:undotree_WindowLayout       = 2
      g:undotree_SplitWidth         = 50
      g:undotree_DiffpanelHeight    = 30
      g:undotree_SetFocusWhenToggle = true
    },
  })
endif

if kg8m#plugin#Register("Shougo/unite.vim", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "Unite",
    hook_source: function("kg8m#plugin#unite#OnSource"),
  })
endif

# Legacy Vim script version for my development.
if kg8m#plugin#Register("kg8m/vim-simple-align", { name: "vim-simple-align-legacy", if: false })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#Register("kg8m/vim-simple-align", { rev: "vim9" })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#Register("FooSoft/vim-argwrap", { if: !kg8m#util#IsGitTmpEdit() })
  nnoremap <Leader>a :ArgWrap<CR>

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "ArgWrap",
    hook_source: function("kg8m#plugin#argwrap#OnSource"),
  })
endif

if kg8m#plugin#Register("haya14busa/vim-asterisk")
  map <expr> *  kg8m#plugin#asterisk#WithNotify("<Plug>(asterisk-z*)")
  map <expr> #  kg8m#plugin#asterisk#WithNotify("<Plug>(asterisk-z#)")
  map <expr> g* kg8m#plugin#asterisk#WithNotify("<Plug>(asterisk-gz*)")
  map <expr> g# kg8m#plugin#asterisk#WithNotify("<Plug>(asterisk-gz#)")

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(asterisk-" },
  })
endif

kg8m#plugin#Register("h1mesuke/vim-benchmark")

if kg8m#plugin#Register("jkramer/vim-checkbox", { if: !kg8m#util#IsGitTmpEdit() })
  augroup vimrc-plugin-checkbox
    autocmd!
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call kg8m#plugin#checkbox#Run()<CR>
  augroup END

  kg8m#plugin#Configure({
    lazy: true,
  })
endif

if kg8m#plugin#Register("alvan/vim-closetag")
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: g:kg8m#plugin#closetag#filetypes,
    hook_source:      function("kg8m#plugin#closetag#OnSource"),
    hook_post_source: function("kg8m#plugin#closetag#OnPostSource"),
  })
endif

kg8m#plugin#Register("hail2u/vim-css3-syntax", { if: !kg8m#util#IsGitTmpEdit() })

if kg8m#plugin#Register("vim-denops/denops.vim", { lazy: true, on_start: true })
  if $DENOPS_DEBUG ==# "1"
    g:denops#debug      = true
    g:denops#trace      = true
    g:denops#type_check = true
  endif
endif

if kg8m#plugin#Register("kg8m/vim-detect-indent", { lazy: true, on_start: true, if: !kg8m#util#IsGitTmpEdit() && !use_editorconfig })
  g:detect_indent#detect_once      = false
  g:detect_indent#ignore_filetypes = ["", "gitcommit", "startify"]

  # Don't include `nofile` because a buffer generated by dps-ghosttext.vim has `nofile` buftype.
  g:detect_indent#ignore_buftypes = ["quickfix", "terminal"]

  kg8m#plugin#Configure({
    depends: ["denops.vim"],
  })
endif

if kg8m#plugin#Register("wsdjeg/vim-fetch")
  augroup vimrc-plugin-fetch
    autocmd!
    autocmd VimEnter * {
      # Disable vim-fetch's `gF` mappings because it conflicts with other plugins
      nmap gF <Plug>(gf-user-gF)
      xmap gF <Plug>(gf-user-gF)
    }
  augroup END
endif

kg8m#plugin#Register("thinca/vim-ft-diff_fold")
kg8m#plugin#Register("thinca/vim-ft-help_fold")

if kg8m#plugin#Register("muz/vim-gemfile")
  augroup vimrc-plugin-gemfile
    autocmd!

    # Execute lazily for overwriting default configs.
    autocmd FileType Gemfile timer_start(100, (_) => kg8m#plugin#gemfile#SetupBuffer())
  augroup END
endif

if kg8m#plugin#Register("kana/vim-gf-user")
  gf#user#extend("kg8m#plugin#gf_user#VimAutoload", 1000)

  if kg8m#util#OnRailsDir()
    gf#user#extend("kg8m#plugin#gf_user#RailsFiles", 1000)
  endif
endif

if kg8m#plugin#Register("tpope/vim-git", { if: kg8m#util#IsGitCommit() })
  augroup vimrc-plugin-git
    autocmd!

    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END
endif

kg8m#plugin#Register("tpope/vim-haml")

if kg8m#plugin#Register("itchyny/vim-histexclude")
  nnoremap <expr> : kg8m#plugin#histexclude#Run()

  kg8m#plugin#Configure({
    lazy: true,
    hook_source: function("kg8m#plugin#histexclude#OnSource"),
  })
endif

if kg8m#plugin#Register("obcat/vim-hitspop")
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: function("kg8m#plugin#hitspop#OnSource"),
  })
endif

if kg8m#plugin#Register("git@github.com:kg8m/vim-hz_ja-extracted")
  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: ["Hankaku", "HzjaConvert", "Zenkaku"],
    hook_source: () => {
      g:hz_ja_extracted_default_commands = true
      g:hz_ja_extracted_default_mappings = false
    },
  })
endif

# Text object for (Japanese) sentence: s
if kg8m#plugin#Register("deton/jasentence.vim")
  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nv: ["(", ")"], o: "s" },
    hook_source: () => {
      g:jasentence_endpat = '[。．？！!?]\+'
    },
  })
endif

if kg8m#plugin#Register("elzr/vim-json")
  g:vim_json_syntax_conceal = false
endif

kg8m#plugin#Register("MaxMEllon/vim-jsx-pretty")

if kg8m#plugin#Register("andymass/vim-matchup")
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: function("kg8m#plugin#matchup#OnSource"),
  })
endif

if kg8m#plugin#Register("mattn/vim-molder", { if: !kg8m#util#IsGitTmpEdit() })
  nnoremap <silent> <Leader>e :call kg8m#plugin#molder#Run()<CR>

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: function("kg8m#plugin#molder#OnSource"),
  })
endif

kg8m#plugin#Register("kana/vim-operator-user")

if kg8m#plugin#Register("kg8m/vim-parallel-auto-ctags", { if: kg8m#util#IsCtagsAvailable() && !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source:      function("kg8m#plugin#parallel_auto_ctags#OnSource"),
    hook_post_source: function("kg8m#plugin#parallel_auto_ctags#OnPostSource"),
  })
endif

if kg8m#plugin#Register("thinca/vim-prettyprint", { if: !kg8m#util#IsGitTmpEdit() })
  # Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work
  kg8m#plugin#Configure({
    lazy: false,
  })
endif

if kg8m#plugin#Register("lambdalisue/vim-protocol", { if: !kg8m#util#IsGitTmpEdit() })
  # Disable netrw.vim
  g:loaded_netrw             = true
  g:loaded_netrwPlugin       = true
  g:loaded_netrwSettings     = true
  g:loaded_netrwFileHandlers = true

  kg8m#plugin#Configure({
    lazy:    true,
    on_path: '^https\?://',
  })
endif

if kg8m#plugin#Register("tpope/vim-rails", { if: !kg8m#util#IsGitTmpEdit() && kg8m#util#OnRailsDir() })
  if !has_key(g:, "rails_path_additions")
    g:rails_path_additions = []
  endif

  if isdirectory("spec/support")
    g:rails_path_additions += [
      "spec/support",
    ]
  endif

  # Don't load lazily because some features don't work.
  kg8m#plugin#Configure({
    lazy: false,
  })
endif

kg8m#plugin#Register("tpope/vim-repeat")

if kg8m#plugin#Register("vim-ruby/vim-ruby")
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

if kg8m#plugin#Register("joker1007/vim-ruby-heredoc-syntax", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "ruby",
    hook_source: function("kg8m#plugin#ruby_heredoc_syntax#OnSource"),
  })
endif

# Text object for surrounded by a bracket-pair or same characters: S + {user input}
if kg8m#plugin#Register("machakann/vim-sandwich")
  kg8m#plugin#sandwich#DefineMappings()

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(operator-sandwich-", o: "<Plug>(textobj-sandwich-" },
    hook_source:      function("kg8m#plugin#sandwich#OnSource"),
    hook_post_source: function("kg8m#plugin#sandwich#OnPostSource"),
  })
endif

kg8m#plugin#Register("arzg/vim-sh")
kg8m#plugin#Register("slim-template/vim-slim")

if kg8m#plugin#Register("mhinz/vim-startify", { if: !kg8m#util#IsGitTmpEdit() })
  if argc() ># 0
    # `on_event: "BufWritePre"` for `SaveSession()`: Load startify before writing buffer (on `BufWritePre`) and
    # register autocmd for `BufWritePost`
    kg8m#plugin#Configure({
      lazy:     true,
      on_cmd:   "Startify",
      on_event: "BufWritePre",
      hook_source:      function("kg8m#plugin#startify#OnSource"),
      hook_post_source: function("kg8m#plugin#startify#OnPostSource"),
    })
  else
    kg8m#plugin#startify#Setup()
  endif
endif

if kg8m#plugin#Register("kopischke/vim-stay", { if: !kg8m#util#IsGitCommit() })
  set viewoptions=cursor,folds

  augroup vimrc-plugin-stay
    autocmd!
    autocmd User BufStaySavePre kg8m#configure#folding#manual#Restore()
  augroup END
endif

kg8m#plugin#Register("hashivim/vim-terraform")

if kg8m#plugin#Register("janko/vim-test", { if: !kg8m#util#IsGitTmpEdit() })
  nnoremap <Leader>T :write<CR>:TestFile<CR>
  nnoremap <Leader>t :write<CR>:TestNearest<CR>

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: ["TestFile", "TestNearest"],
    hook_source: function("kg8m#plugin#test#OnSource"),
  })
endif

# Text object for indentation: i
kg8m#plugin#Register("kana/vim-textobj-indent", { lazy: true, on_start: true })

# Text object for last search pattern: /
kg8m#plugin#Register("kana/vim-textobj-lastpat", { lazy: true, on_start: true })

# Text object for string: ,s
if kg8m#plugin#Register("rbtnn/vim-textobj-string", { lazy: true, on_start: true })
  g:vim_textobj_string_mapping = ",s"
endif

kg8m#plugin#Register("kana/vim-textobj-user")

# Text object for word for human: ,w
kg8m#plugin#Register("h1mesuke/textobj-wiw", { lazy: true, on_start: true })

# For syntaxes
kg8m#plugin#Register("thinca/vim-themis")

kg8m#plugin#Register("mattn/vim-treesitter", { if: false })
kg8m#plugin#Register("posva/vim-vue")

if kg8m#plugin#Register("thinca/vim-zenspace")
  augroup vimrc-plugin-zenspace
    autocmd!
    autocmd ColorScheme * highlight ZenSpace gui=underline guibg=DarkGray guifg=DarkGray
  augroup END

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source:      function("kg8m#plugin#zenspace#OnSource"),
    hook_post_source: function("kg8m#plugin#zenspace#OnPostSource"),
  })
endif

if kg8m#plugin#Register("monkoose/vim9-stargate")
  g:stargate_chars = "FKLASDHGUIONMREWCVTYBX,;J"
  nnoremap <C-w>f :call stargate#Galaxy()<CR>
endif

if kg8m#plugin#Register("Shougo/vimproc")
  kg8m#plugin#Configure({
    lazy:    true,
    build:   "make",
    on_func: "vimproc#",
  })
endif

# See `kg8m#util#xxx#Vital()`.
# Specify `merged: false` because `Vitalize` fails.
kg8m#plugin#Register("vim-jp/vital.vim", { merged: false })

if kg8m#plugin#Register("simeji/winresizer", { if: !kg8m#util#IsGitTmpEdit() })
  g:winresizer_start_key = "<C-w><C-e>"

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { n: g:winresizer_start_key },
  })
endif

kg8m#plugin#Register("stephpy/vim-yaml", { if: !kg8m#util#IsGitTmpEdit() })

# Use my fork until the PR https://github.com/pedrohdz/vim-yaml-folds/pull/7 is merged.
kg8m#plugin#Register("pedrohdz/vim-yaml-folds", { if: false, name: "vim-yaml-folds-original" })
if kg8m#plugin#Register("kg8m/vim-yaml-folds", { if: !kg8m#util#IsGitTmpEdit(), rev: "support_custom_foldtext" })
  g:yamlfolds_use_yaml_fold_text = false
endif

if kg8m#plugin#Register("jonsmithers/vim-html-template-literals", { if: !kg8m#util#IsGitTmpEdit() })
  g:htl_css_templates = true
  g:htl_all_templates = false

  kg8m#plugin#Configure({
    depends: "vim-javascript",
  })

  kg8m#plugin#Register("pangloss/vim-javascript")
endif

if kg8m#plugin#Register("LeafCage/yankround.vim")
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: function("kg8m#plugin#yankround#OnSource"),
  })
endif

# Colorschemes
if kg8m#plugin#Register("tomasr/molokai")
  g:molokai_original = true

  augroup vimrc-plugin-molokai
    autocmd!
    autocmd ColorScheme molokai kg8m#plugin#molokai#Overwrite()
  augroup END
endif
# }}}

# Finish plugin manager initialization  # {{{
kg8m#plugin#FinishSetup()

# Disable filetype before enabling filetype
# https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if kg8m#plugin#InstallableExists()
  kg8m#plugin#Install()
endif
# }}}
# }}}

colorscheme molokai

kg8m#configure#Backup()
kg8m#configure#Colors()
kg8m#configure#Column()
kg8m#configure#Comments()
kg8m#configure#Completion()
kg8m#configure#Cursor()
kg8m#configure#Folding()
kg8m#configure#Formatoptions()
kg8m#configure#Indent()
kg8m#configure#Scroll()
kg8m#configure#Search()
kg8m#configure#Statusline()
kg8m#configure#Undo()
kg8m#util#dim_inactive_windows#Setup()

if !kg8m#util#IsGitTmpEdit()
  kg8m#util#auto_reload#Setup()
  kg8m#util#check_typo#Setup()
  kg8m#util#daemons#Setup()
endif

kg8m#configure#Commands()
kg8m#configure#Mappings()
kg8m#configure#Others()

if has("gui_running")
  kg8m#configure#Gui()
endif

kg8m#util#SourceLocalVimrc()
