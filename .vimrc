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

set fileformats=unix,dos,mac
set ambiwidth=double
scriptencoding utf-8
# }}}

# Reset my autocommands for reloading vimrc
augroup my_vimrc
  autocmd!
augroup END
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

if kg8m#plugin#register("kitagry/asyncomplete-tabnine.vim", { build: "./install.sh" })
  kg8m#plugin#asyncomplete#tabnine#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-tags.vim")
  kg8m#plugin#asyncomplete#tags#configure()
endif

if kg8m#plugin#register("prabirshrestha/asyncomplete-lsp.vim")
  kg8m#plugin#asyncomplete#lsp#configure()
endif

if kg8m#plugin#register("Shougo/neosnippet")
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

if kg8m#plugin#register("Shougo/context_filetype.vim")
  kg8m#plugin#context_filetype#configure()
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
  kg8m#plugin#gina#configure()
endif

if kg8m#plugin#register("tweekmonster/helpful.vim")
  kg8m#plugin#helpful#configure()
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
  kg8m#plugin#linediff#configure()
endif

kg8m#plugin#register("kg8m/moin.vim")

if kg8m#plugin#register("lambdalisue/mr.vim", { if: !kg8m#util#is_git_tmp_edit() })
  g:mr#threshold = 10000
endif

if kg8m#plugin#register("tyru/open-browser.vim")
  kg8m#plugin#open_browser#configure()
endif

if kg8m#plugin#register("tyru/operator-camelize.vim")
  kg8m#plugin#operator#camelize#configure()
endif

if kg8m#plugin#register("mechatroner/rainbow_csv", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#rainbow_csv#configure()
endif

kg8m#plugin#register("lambdalisue/readablefold.vim", { if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("lambdalisue/reword.vim")
  cnoreabbrev <expr> Reword reword#live#start()
endif

if kg8m#plugin#register("vim-scripts/sequence")
  kg8m#plugin#sequence#configure()
endif

if kg8m#plugin#register("AndrewRadev/splitjoin.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#splitjoin#configure()
endif

kg8m#plugin#register("lambdalisue/suda.vim")

if kg8m#plugin#register("leafgarland/typescript-vim")
  g:typescript_indent_disable = true
endif

if kg8m#plugin#register("mbbill/undotree")
  kg8m#plugin#undotree#configure()
endif

if kg8m#plugin#register("Shougo/unite.vim", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#unite#configure()
endif

if kg8m#plugin#register("kg8m/vim-simple-align")
  kg8m#plugin#simple_align#configure()
endif

if kg8m#plugin#register("FooSoft/vim-argwrap", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#argwrap#configure()
endif

if kg8m#plugin#register("haya14busa/vim-asterisk")
  kg8m#plugin#asterisk#configure()
endif

if kg8m#plugin#register("Chiel92/vim-autoformat", { if: !kg8m#util#is_git_tmp_edit() })
  g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif

kg8m#plugin#register("h1mesuke/vim-benchmark")

if kg8m#plugin#register("jkramer/vim-checkbox", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#checkbox#configure()
endif

if kg8m#plugin#register("t9md/vim-choosewin", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#choosewin#configure()
endif

kg8m#plugin#register("hail2u/vim-css3-syntax", { if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("easymotion/vim-easymotion")
  kg8m#plugin#easymotion#configure()
endif

# Disable because findent sometimes detects wrong indentations
if kg8m#plugin#register("lambdalisue/vim-findent", { if: false && !kg8m#util#is_git_tmp_edit() && !filereadable(".editorconfig") })
  kg8m#plugin#findent#configure()
endif

kg8m#plugin#register("thinca/vim-ft-diff_fold")
kg8m#plugin#register("thinca/vim-ft-help_fold")
kg8m#plugin#register("muz/vim-gemfile")
kg8m#plugin#register("kana/vim-gf-user")

if kg8m#plugin#register("tpope/vim-git", { if: kg8m#util#is_git_commit() })
  kg8m#plugin#git#configure()
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

if kg8m#plugin#register("kg8m/vim-hz_ja-extracted")
  kg8m#plugin#hz_ja_extracted#configure()
endif

# Text object for (Japanese) sentence: s
if kg8m#plugin#register("deton/jasentence.vim")
  kg8m#plugin#jasentence#configure()
endif

if kg8m#plugin#register("osyo-manga/vim-jplus")
  kg8m#plugin#jplus#configure()
endif

if kg8m#plugin#register("elzr/vim-json")
  g:vim_json_syntax_conceal = false
endif

if kg8m#plugin#register("andymass/vim-matchup")
  kg8m#plugin#matchup#configure()
endif

if kg8m#plugin#register("mattn/vim-molder", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#molder#configure()
endif

if kg8m#plugin#register("kana/vim-operator-replace")
  kg8m#plugin#operator#replace#configure()
endif

kg8m#plugin#register("kana/vim-operator-user")

if kg8m#plugin#register("kg8m/vim-parallel-auto-ctags", { if: kg8m#util#on_rails_dir() && !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#parallel_auto_ctags#configure()
endif

if kg8m#plugin#register("thinca/vim-prettyprint", { if: !kg8m#util#is_git_tmp_edit() })
  # Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work
  kg8m#plugin#configure({
    lazy: false,
  })
endif

if kg8m#plugin#register("lambdalisue/vim-protocol", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#protocol#configure()
endif

if kg8m#plugin#register("tpope/vim-rails", { if: !kg8m#util#is_git_tmp_edit() && kg8m#util#on_rails_dir() })
  kg8m#plugin#rails#configure()
endif

kg8m#plugin#register("tpope/vim-repeat")

if kg8m#plugin#register("vim-ruby/vim-ruby")
  kg8m#plugin#ruby#configure()
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
  kg8m#plugin#stay#configure()
endif

if kg8m#plugin#register("janko/vim-test", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#test#configure()
endif

# Text object for indentation: i
kg8m#plugin#register("kana/vim-textobj-indent")

# Text object for last search pattern: /
kg8m#plugin#register("kana/vim-textobj-lastpat")

kg8m#plugin#register("kana/vim-textobj-user")
kg8m#plugin#register("cespare/vim-toml")
kg8m#plugin#register("posva/vim-vue")

if kg8m#plugin#register("thinca/vim-zenspace")
  kg8m#plugin#zenspace#configure()
endif

if kg8m#plugin#register("Shougo/vimproc")
  kg8m#plugin#vimproc#configure()
endif

if kg8m#plugin#register("preservim/vimux", { if: kg8m#util#on_tmux() && !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#vimux#configure()
endif

# See `kg8m#util#xxx_module()`.
# Specify `merged: false` because `Vitalize` fails.
kg8m#plugin#register("vim-jp/vital.vim", { merged: false })

if kg8m#plugin#register("simeji/winresizer", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#winresizer#configure()
endif

kg8m#plugin#register("stephpy/vim-yaml", { if: !kg8m#util#is_git_tmp_edit() })
kg8m#plugin#register("pedrohdz/vim-yaml-folds", { if: !kg8m#util#is_git_tmp_edit() })

# Disable because yajs.vim conflicts with vim-html-template-literals.
# Don't merge because some syntax files are duplicated.
kg8m#plugin#register("othree/yajs.vim", { if: false, merged: false })

if kg8m#plugin#register("jonsmithers/vim-html-template-literals", { if: !kg8m#util#is_git_tmp_edit() })
  kg8m#plugin#html_template_literals#configure()
endif

if kg8m#plugin#register("LeafCage/yankround.vim")
  kg8m#plugin#yankround#configure()
endif

kg8m#plugin#register("zinit-zsh/zinit-vim-syntax")

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
