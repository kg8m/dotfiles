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
const utility_path = expand("~/dotfiles/.vim")
&runtimepath ..= "," .. utility_path
&runtimepath ..= "," .. utility_path .. "/after"

kg8m#plugin#DisableDefaults()

g:mapleader = ","
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
  kg8m#plugin#asyncomplete#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-buffer.vim")
  kg8m#plugin#asyncomplete#buffer#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-file.vim")
  kg8m#plugin#asyncomplete#file#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-neosnippet.vim")
  kg8m#plugin#asyncomplete#neosnippet#Configure()
endif

if kg8m#plugin#Register("high-moctane/asyncomplete-nextword.vim")
  kg8m#plugin#asyncomplete#nextword#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-tags.vim")
  kg8m#plugin#asyncomplete#tags#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/asyncomplete-lsp.vim")
  kg8m#plugin#asyncomplete#lsp#Configure()
endif

if kg8m#plugin#Register("Shougo/neosnippet.vim")
  kg8m#plugin#neosnippet#Configure()
endif

if kg8m#plugin#Register("prabirshrestha/vim-lsp")
  kg8m#plugin#lsp#Configure()
endif

if kg8m#plugin#Register("hrsh7th/vim-vsnip")
  kg8m#plugin#vsnip#Configure()
endif
# }}}

kg8m#plugin#Register("dense-analysis/ale", { if: false, merged: false })
kg8m#plugin#Register("pearofducks/ansible-vim")

# Show diff in Git's interactive rebase
kg8m#plugin#Register("hotwatermorning/auto-git-diff", { if: kg8m#util#IsGitRebase() })

if kg8m#plugin#Register("tyru/caw.vim", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#caw#Configure()
endif

if kg8m#plugin#Register("rhysd/conflict-marker.vim")
  augroup vimrc-plugin-conflict_marker
    autocmd!
    autocmd FileType diff nmap <buffer> <Leader>c <Plug>(conflict-marker-next-hunk)
  augroup END

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { n: "<Plug>(conflict-marker-" },
    hook_source: () => {
      g:conflict_marker_enable_mappings = false
    },
  })
endif

if kg8m#plugin#Register("Shougo/context_filetype.vim")
  const for_js = [
    { start: '\<html`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "html" },
    { start: '\<css`$',  end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
  ]

  # For caw.vim and so on
  g:context_filetype#filetypes = {
    javascript: for_js,
    typescript: for_js,
  }
endif

if kg8m#plugin#Register("spolu/dwm.vim", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#dwm#Configure()
endif

if kg8m#plugin#Register("editorconfig/editorconfig-vim", { if: !kg8m#util#IsGitTmpEdit() && filereadable(".editorconfig") })
  g:EditorConfig_preserve_formatoptions = true
endif

if kg8m#plugin#Register("junegunn/fzf.vim", { if: executable("fzf") })
  kg8m#plugin#fzf#Configure()
endif

if kg8m#plugin#Register("lambdalisue/gin.vim", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  "GinPatch",
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
  kg8m#plugin#indent_line#Configure()
endif

if kg8m#plugin#Register("othree/javascript-libraries-syntax.vim", { if: !kg8m#util#IsGitTmpEdit() })
  g:used_javascript_libs = "jquery,react,vue"
endif

if kg8m#plugin#Register("fuenor/JpFormat.vim")
  kg8m#plugin#jpformat#Configure()
endif

if kg8m#plugin#Register("cohama/lexima.vim")
  kg8m#plugin#lexima#Configure()
endif

if kg8m#plugin#Register("itchyny/lightline.vim")
  kg8m#plugin#lightline#Configure()
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
  g:mr#mru#filename = printf("%s/vim/mr/mru", $XDG_DATA_HOME)
endif

if kg8m#plugin#Register("tyru/open-browser.vim")
  kg8m#plugin#open_browser#Configure()
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
  kg8m#plugin#qfenter#Configure()
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
  kg8m#plugin#unite#Configure()
endif

# Legacy Vim script version for my development.
if kg8m#plugin#Register("kg8m/vim-simple-align", { name: "vim-simple-align-legacy", if: false })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#Register("kg8m/vim-simple-align", { rev: "vim9" })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#Register("FooSoft/vim-argwrap", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#argwrap#Configure()
endif

if kg8m#plugin#Register("haya14busa/vim-asterisk")
  kg8m#plugin#asterisk#Configure()
endif

kg8m#plugin#Register("h1mesuke/vim-benchmark")

if kg8m#plugin#Register("jkramer/vim-checkbox", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#checkbox#Configure()
endif

if kg8m#plugin#Register("alvan/vim-closetag")
  kg8m#plugin#closetag#Configure()
endif

kg8m#plugin#Register("hail2u/vim-css3-syntax", { if: !kg8m#util#IsGitTmpEdit() })

if kg8m#plugin#Register("vim-denops/denops.vim", { lazy: true, on_start: true })
  if $DENOPS_DEBUG ==# "1"
    g:denops#debug      = true
    g:denops#trace      = true
    g:denops#type_check = true
  endif
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
kg8m#plugin#Register("muz/vim-gemfile")

if kg8m#plugin#Register("kana/vim-gf-user")
  kg8m#plugin#gf_user#Configure()
endif

if kg8m#plugin#Register("tpope/vim-git", { if: kg8m#util#IsGitCommit() })
  augroup vimrc-plugin-git
    autocmd!

    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END
endif

# Use LSP for completion, linting/formatting codes, and jumping to definition.
# Use vim-go's highlightings, foldings, and commands.
if kg8m#plugin#Register("fatih/vim-go", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#go#Configure()
endif

if kg8m#plugin#Register("gamoutatsumi/dps-ghosttext.vim", { if: $GHOST_TEXT_AVAILABLE ==# "1" })
  g:dps_ghosttext#enable_autostart = false

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: ["GhostStart"],
  })
endif

kg8m#plugin#Register("tpope/vim-haml")

if kg8m#plugin#Register("itchyny/vim-histexclude")
  kg8m#plugin#histexclude#Configure()
endif

if kg8m#plugin#Register("obcat/vim-hitspop")
  kg8m#plugin#hitspop#Configure()
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
  kg8m#plugin#matchup#Configure()
endif

if kg8m#plugin#Register("mattn/vim-molder", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#molder#Configure()
endif

kg8m#plugin#Register("kana/vim-operator-user")

if kg8m#plugin#Register("kg8m/vim-parallel-auto-ctags", { if: kg8m#util#IsCtagsAvailable() && !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#parallel_auto_ctags#Configure()
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
  kg8m#plugin#rails#Configure()
endif

kg8m#plugin#Register("tpope/vim-repeat")

if kg8m#plugin#Register("vim-ruby/vim-ruby")
  g:no_ruby_maps = true

  augroup vimrc-plugin-ruby
    autocmd!

    # vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile set filetype=Gemfile

    # Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby unlet! b:ruby_no_expensive
  augroup END
endif

if kg8m#plugin#Register("joker1007/vim-ruby-heredoc-syntax", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#ruby_heredoc_syntax#Configure()
endif

# Text object for surrounded by a bracket-pair or same characters: S + {user input}
if kg8m#plugin#Register("machakann/vim-sandwich")
  kg8m#plugin#sandwich#Configure()
endif

kg8m#plugin#Register("arzg/vim-sh")
kg8m#plugin#Register("slim-template/vim-slim")

if kg8m#plugin#Register("mhinz/vim-startify", { if: !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#startify#Configure()
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
  kg8m#plugin#test#Configure()
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

kg8m#plugin#Register("posva/vim-vue")

if kg8m#plugin#Register("thinca/vim-zenspace")
  kg8m#plugin#zenspace#Configure()
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

if kg8m#plugin#Register("preservim/vimux", { if: kg8m#util#OnTmux() && !kg8m#util#IsGitTmpEdit() })
  kg8m#plugin#vimux#Configure()
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
kg8m#plugin#Register("pedrohdz/vim-yaml-folds", { if: !kg8m#util#IsGitTmpEdit() })

if kg8m#plugin#Register("jonsmithers/vim-html-template-literals", { if: !kg8m#util#IsGitTmpEdit() })
  g:htl_css_templates = true
  g:htl_all_templates = false

  kg8m#plugin#Configure({
    depends: "vim-javascript",
  })

  kg8m#plugin#Register("pangloss/vim-javascript")
endif

if kg8m#plugin#Register("LeafCage/yankround.vim")
  kg8m#plugin#yankround#Configure()
endif

# Colorschemes
if kg8m#plugin#Register("tomasr/molokai")
  kg8m#plugin#molokai#Configure()
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
