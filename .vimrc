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
const s:utility_path = expand("~/dotfiles/.vim")
&runtimepath ..= "," .. s:utility_path
&runtimepath ..= "," .. s:utility_path .. "/after"

kg8m#plugin#disable_defaults()

g:mapleader = ","
# }}}
# }}}

# ----------------------------------------------
# Plugins  # {{{
# Initialize plugin manager  # {{{
kg8m#plugin#init_manager()
# }}}

# Plugins list and settings  # {{{
# Completion, LSP  # {{{
if kg8m#plugin#register("prabirshrestha/asyncomplete.vim")
  kg8m#plugin#asyncomplete#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-buffer.vim")
  kg8m#plugin#asyncomplete#buffer#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-file.vim")
  kg8m#plugin#asyncomplete#file#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-neosnippet.vim")
  kg8m#plugin#asyncomplete#neosnippet#configure()
endif

if kg8m#plugin#register("high-moctane/asyncomplete-nextword.vim")
  kg8m#plugin#asyncomplete#nextword#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-tags.vim")
  kg8m#plugin#asyncomplete#tags#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-lsp.vim")
  kg8m#plugin#asyncomplete#lsp#configure()
endif

if kg8m#plugin#register("Shougo/neosnippet.vim")
  kg8m#plugin#neosnippet#configure()
endif

if kg8m#plugin#register("prabirshrestha/vim-lsp")
  kg8m#plugin#lsp#configure()
endif

if kg8m#plugin#register("hrsh7th/vim-vsnip")
  kg8m#plugin#vsnip#configure()
endif
# }}}

kg8m#plugin#register("dense-analysis/ale", { if: false, merged: false })
kg8m#plugin#register("pearofducks/ansible-vim")

# Show diff in Git's interactive rebase
kg8m#plugin#register("hotwatermorning/auto-git-diff", { if: kg8m#util#is_git_rebase() })

if kg8m#plugin#register("tyru/caw.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#caw#configure()
endif

if kg8m#plugin#register("rhysd/conflict-marker.vim")
  augroup vimrc-plugin-conflict_marker
    autocmd!
    autocmd FileType diff nmap <buffer> <Leader>c <Plug>(conflict-marker-next-hunk)
  augroup END

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { n: "<Plug>(conflict-marker-" },
    hook_source: () => {
      g:conflict_marker_enable_mappings = false
    },
  })
endif

if kg8m#plugin#register("Shougo/context_filetype.vim")
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

if kg8m#plugin#register("spolu/dwm.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#dwm#configure()
endif

if kg8m#plugin#register("editorconfig/editorconfig-vim", { if: !kg8m#util#is_git_tmp_edit() && filereadable(".editorconfig") })
  g:EditorConfig_preserve_formatoptions = true
endif

if kg8m#plugin#register("junegunn/fzf.vim", { if: executable("fzf") })
  kg8m#plugin#fzf#configure()
endif

if kg8m#plugin#register("lambdalisue/gina.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "Gina",
  })
endif

if kg8m#plugin#register("tweekmonster/helpful.vim")
  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "HelpfulVersion",
  })
endif

if kg8m#plugin#register("Yggdroot/indentLine", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#indent_line#configure()
endif

if kg8m#plugin#register("othree/javascript-libraries-syntax.vim", { if: !kg8m#util#is_git_tmp_edit() })
  g:used_javascript_libs = "jquery,react,vue"
endif

if kg8m#plugin#register("fuenor/JpFormat.vim")
  kg8m#plugin#jpformat#configure()
endif

if kg8m#plugin#register("cohama/lexima.vim")
  kg8m#plugin#lexima#configure()
endif

if kg8m#plugin#register("itchyny/lightline.vim")
  kg8m#plugin#lightline#configure()
endif

if kg8m#plugin#register("AndrewRadev/linediff.vim")
  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "Linediff",
    hook_source: () => {
      g:linediff_second_buffer_command = "rightbelow vertical new"
    },
  })
endif

kg8m#plugin#register("kg8m/moin.vim")

if kg8m#plugin#register("lambdalisue/mr.vim", { if: !kg8m#util#is_git_tmp_edit() })
  g:mr#threshold = 10000
endif

if kg8m#plugin#register("tyru/open-browser.vim")
  kg8m#plugin#open_browser#configure()
endif

if kg8m#plugin#register("tyru/operator-camelize.vim")
  xmap <Leader>C <Plug>(operator-camelize)
  xmap <Leader>c <Plug>(operator-decamelize)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: ["<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"] },
  })
endif

if kg8m#plugin#register("yssl/QFEnter")
  kg8m#plugin#qfenter#configure()
endif

if kg8m#plugin#register("stefandtw/quickfix-reflector.vim")
  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "qf",
  })
endif

if kg8m#plugin#register("mechatroner/rainbow_csv", { if: !kg8m#util#is_git_tmp_edit() })
  augroup vimrc-plugin-rainbow_csv
    autocmd!
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "csv",
  })
endif

kg8m#plugin#register("lambdalisue/readablefold.vim", { if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("vim-scripts/sequence")
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: "<Plug>Sequence" },
  })
endif

if kg8m#plugin#register("AndrewRadev/splitjoin.vim", { if: !kg8m#util#is_git_tmp_edit() })
  nnoremap <Leader>J :SplitjoinJoin<CR>
  nnoremap <Leader>S :SplitjoinSplit<CR>

  kg8m#plugin#configure({
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

kg8m#plugin#register("lambdalisue/suda.vim")

if kg8m#plugin#register("leafgarland/typescript-vim")
  g:typescript_indent_disable = true
endif

if kg8m#plugin#register("mbbill/undotree")
  nnoremap <Leader>u :UndotreeToggle<CR>

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "UndotreeToggle",
    hook_source: () => {
      g:undotree_WindowLayout = 2
      g:undotree_SplitWidth = 50
      g:undotree_DiffpanelHeight = 30
      g:undotree_SetFocusWhenToggle = true
    },
  })
endif

if kg8m#plugin#register("Shougo/unite.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#unite#configure()
endif

# Legacy Vim script version for my development.
if kg8m#plugin#register("kg8m/vim-simple-align", { name: "vim-simple-align-legacy", if: false })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#register("kg8m/vim-simple-align", { rev: "vim9" })
  xnoremap <Leader>a :SimpleAlign<Space>
endif

if kg8m#plugin#register("FooSoft/vim-argwrap", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#argwrap#configure()
endif

if kg8m#plugin#register("haya14busa/vim-asterisk")
  kg8m#plugin#asterisk#configure()
endif

kg8m#plugin#register("h1mesuke/vim-benchmark")

if kg8m#plugin#register("jkramer/vim-checkbox", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#checkbox#configure()
endif

if kg8m#plugin#register("alvan/vim-closetag")
  kg8m#plugin#closetag#configure()
endif

kg8m#plugin#register("hail2u/vim-css3-syntax", { if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("wsdjeg/vim-fetch")
  augroup vimrc-plugin-fetch
    autocmd!
    autocmd VimEnter * {
      # Disable vim-fetch's `gF` mappings because it conflicts with other plugins
      nmap gF <Plug>(gf-user-gF)
      xmap gF <Plug>(gf-user-gF)
    }
  augroup END
endif

kg8m#plugin#register("thinca/vim-ft-diff_fold")
kg8m#plugin#register("thinca/vim-ft-help_fold")
kg8m#plugin#register("muz/vim-gemfile")
kg8m#plugin#register("kana/vim-gf-user")

if kg8m#plugin#register("tpope/vim-git", { if: kg8m#util#is_git_commit() })
  augroup vimrc-plugin-git
    autocmd!

    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END
endif

# Use LSP for completion, linting/formatting codes, and jumping to definition.
# Use vim-go's highlightings, foldings, and commands.
if kg8m#plugin#register("fatih/vim-go", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#go#configure()
endif

kg8m#plugin#register("tpope/vim-haml")

if kg8m#plugin#register("itchyny/vim-histexclude")
  kg8m#plugin#histexclude#configure()
endif

if kg8m#plugin#register("obcat/vim-hitspop")
  kg8m#plugin#hitspop#configure()
endif

if kg8m#plugin#register("git@github.com:kg8m/vim-hz_ja-extracted")
  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: ["Hankaku", "HzjaConvert", "Zenkaku"],
    hook_source: () => {
      g:hz_ja_extracted_default_commands = true
      g:hz_ja_extracted_default_mappings = false
    },
  })
endif

# Text object for (Japanese) sentence: s
if kg8m#plugin#register("deton/jasentence.vim")
  kg8m#plugin#configure({
    lazy:   true,
    on_map: { nv: ["(", ")"], o: "s" },
    hook_source: () => {
      g:jasentence_endpat = '[。．？！!?]\+'
    },
  })
endif

if kg8m#plugin#register("osyo-manga/vim-jplus")
  # Remove line-connectors with `J`
  nmap <S-j> <Plug>(jplus)
  xmap <S-j> <Plug>(jplus)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { nx: "<Plug>(jplus)" },
  })
endif

if kg8m#plugin#register("elzr/vim-json")
  g:vim_json_syntax_conceal = false
endif

kg8m#plugin#register("MaxMEllon/vim-jsx-pretty")

if kg8m#plugin#register("andymass/vim-matchup")
  kg8m#plugin#matchup#configure()
endif

if kg8m#plugin#register("mattn/vim-molder", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#molder#configure()
endif

kg8m#plugin#register("kana/vim-operator-user")

if kg8m#plugin#register("kg8m/vim-parallel-auto-ctags", { if: kg8m#util#is_ctags_available() && !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#parallel_auto_ctags#configure()
endif

if kg8m#plugin#register("thinca/vim-prettyprint", { if: !kg8m#util#is_git_tmp_edit() })
  # Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work
  kg8m#plugin#configure({
    lazy: false,
  })
endif

if kg8m#plugin#register("lambdalisue/vim-protocol", { if: !kg8m#util#is_git_tmp_edit() })
  # Disable netrw.vim
  g:loaded_netrw             = true
  g:loaded_netrwPlugin       = true
  g:loaded_netrwSettings     = true
  g:loaded_netrwFileHandlers = true

  kg8m#plugin#configure({
    lazy:    true,
    on_path: '^https\?://',
  })
endif

if kg8m#plugin#register("tpope/vim-rails", { if: !kg8m#util#is_git_tmp_edit() && kg8m#util#on_rails_dir() })
  kg8m#plugin#rails#configure()
endif

kg8m#plugin#register("tpope/vim-repeat")

if kg8m#plugin#register("vim-ruby/vim-ruby")
  g:no_ruby_maps = true

  augroup vimrc-plugin-ruby
    autocmd!

    # vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile* set filetype=Gemfile

    # Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby unlet! b:ruby_no_expensive
  augroup END
endif

if kg8m#plugin#register("joker1007/vim-ruby-heredoc-syntax", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#ruby_heredoc_syntax#configure()
endif

# Text object for surrounded by a bracket-pair or same characters: S + {user input}
if kg8m#plugin#register("machakann/vim-sandwich")
  kg8m#plugin#sandwich#configure()
endif

kg8m#plugin#register("arzg/vim-sh")

if kg8m#plugin#register("mhinz/vim-startify", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#startify#configure()
endif

if kg8m#plugin#register("kopischke/vim-stay", { if: !kg8m#util#is_git_commit() })
  set viewoptions=cursor,folds

  augroup vimrc-plugin-stay
    autocmd!
    autocmd User BufStaySavePre kg8m#configure#folding#manual#restore()
  augroup END
endif

kg8m#plugin#register("hashivim/vim-terraform")

if kg8m#plugin#register("janko/vim-test", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#test#configure()
endif

# Text object for indentation: i
kg8m#plugin#register("kana/vim-textobj-indent", { lazy: true, on_start: true })

# Text object for last search pattern: /
kg8m#plugin#register("kana/vim-textobj-lastpat", { lazy: true, on_start: true })

# Text object for string: ,s
if kg8m#plugin#register("rbtnn/vim-textobj-string", { lazy: true, on_start: true })
  g:vim_textobj_string_mapping = ",s"
endif

kg8m#plugin#register("kana/vim-textobj-user")

# Text object for word for human: ,w
kg8m#plugin#register("h1mesuke/textobj-wiw", { lazy: true, on_start: true })

# For syntaxes
kg8m#plugin#register("thinca/vim-themis")

kg8m#plugin#register("posva/vim-vue")

if kg8m#plugin#register("thinca/vim-zenspace")
  kg8m#plugin#zenspace#configure()
endif

if kg8m#plugin#register("monkoose/vim9-stargate")
  g:stargate_chars = "FKLASDHGUIONMREWCVTYBX,;J"
  nnoremap <C-w>f :call stargate#galaxy()<CR>
endif

if kg8m#plugin#register("Shougo/vimproc")
  kg8m#plugin#configure({
    lazy:    true,
    build:   "make",
    on_func: "vimproc#",
  })
endif

if kg8m#plugin#register("preservim/vimux", { if: kg8m#util#on_tmux() && !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#vimux#configure()
endif

# See `kg8m#util#xxx_module()`.
# Specify `merged: false` because `Vitalize` fails.
kg8m#plugin#register("vim-jp/vital.vim", { merged: false })

if kg8m#plugin#register("simeji/winresizer", { if: !kg8m#util#is_git_tmp_edit() })
  g:winresizer_start_key = "<C-w><C-e>"

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { n: g:winresizer_start_key },
  })
endif

kg8m#plugin#register("stephpy/vim-yaml", { if: !kg8m#util#is_git_tmp_edit() })
kg8m#plugin#register("pedrohdz/vim-yaml-folds", { if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("jonsmithers/vim-html-template-literals", { if: !kg8m#util#is_git_tmp_edit() })
  g:htl_css_templates = true
  g:htl_all_templates = false

  kg8m#plugin#configure({
    depends: "vim-javascript",
  })

  kg8m#plugin#register("pangloss/vim-javascript")
endif

if kg8m#plugin#register("LeafCage/yankround.vim")
  kg8m#plugin#yankround#configure()
endif

# Colorschemes
if kg8m#plugin#register("tomasr/molokai")
  kg8m#plugin#molokai#configure()
endif
# }}}

# Finish plugin manager initialization  # {{{
kg8m#plugin#finish_setup()

# Disable filetype before enabling filetype
# https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if kg8m#plugin#installable_exists()
  kg8m#plugin#install()
endif
# }}}
# }}}

colorscheme molokai

kg8m#configure#backup()
kg8m#configure#colors()
kg8m#configure#column()
kg8m#configure#completion()
kg8m#configure#cursor()
kg8m#configure#folding()
kg8m#configure#formatoptions()
kg8m#configure#indent()
kg8m#configure#scroll()
kg8m#configure#search()
kg8m#configure#statusline()
kg8m#configure#undo()
kg8m#util#dim_inactive_windows#setup()

if !kg8m#util#is_git_tmp_edit()
  kg8m#util#auto_reload#setup()
  kg8m#util#check_typo#setup()
  kg8m#util#daemons#setup()
endif

kg8m#configure#commands()
kg8m#configure#mappings()
kg8m#configure#others()

if has("gui_running")
  kg8m#configure#gui()
endif

kg8m#util#source_local_vimrc()
