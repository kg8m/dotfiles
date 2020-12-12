" Profile  " {{{
" 1. Enable following profile commands (`profile start ...`)
" 2. Do something you are concerned with
" 3. Disable and finish profiling by `:profile pause | noautocmd qall!`
" 4. Check ~/tmp/vim-profile.log

" profile start ~/tmp/vim-profile.log
" profile func *
" profile file *
" }}}

" ----------------------------------------------
" Initialize  " {{{
" Set initial variables/options  " {{{
let s:utility_path = expand("~/dotfiles/.vim")
let &runtimepath .= ","..s:utility_path
let &runtimepath .= ","..s:utility_path.."/after"

call kg8m#plugin#disable_defaults()

let g:mapleader = ","

set fileformats=unix,dos,mac
set ambiwidth=double
scriptencoding utf-8
" }}}

" Reset my autocommands
augroup my_vimrc  " {{{
  autocmd!
augroup END  " }}}
" }}}

" ----------------------------------------------
" Plugins  " {{{
" Initialize plugin manager  " {{{
call kg8m#plugin#init_manager()
" }}}

" Plugins list and settings  " {{{
" Completion, LSP  " {{{
if kg8m#plugin#register("prabirshrestha/asyncomplete.vim")  " {{{
  call kg8m#plugin#asyncomplete#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-buffer.vim")  " {{{
  call kg8m#plugin#asyncomplete#buffer#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-file.vim")  " {{{
  call kg8m#plugin#asyncomplete#file#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-neosnippet.vim")  " {{{
  call kg8m#plugin#asyncomplete#neosnippet#configure()
endif  " }}}

if kg8m#plugin#register("high-moctane/asyncomplete-nextword.vim")  " {{{
  call kg8m#plugin#asyncomplete#nextword#configure()
endif  " }}}

if kg8m#plugin#register("kitagry/asyncomplete-tabnine.vim", #{ build: "./install.sh" })  " {{{
  call kg8m#plugin#asyncomplete#tabnine#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-tags.vim")  " {{{
  call kg8m#plugin#asyncomplete#tags#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/asyncomplete-lsp.vim")  " {{{
  call kg8m#plugin#asyncomplete#lsp#configure()
endif  " }}}

if kg8m#plugin#register("Shougo/neosnippet")  " {{{
  call kg8m#plugin#neosnippet#configure()
endif  " }}}

if kg8m#plugin#register("prabirshrestha/vim-lsp")  " {{{
  call kg8m#plugin#lsp#configure()
endif  " }}}

if kg8m#plugin#register("hrsh7th/vim-vsnip")  " {{{
  call kg8m#plugin#vsnip#configure()
endif  " }}}
" }}}

call kg8m#plugin#register("dense-analysis/ale", #{ if: v:false, merged: v:false })
call kg8m#plugin#register("pearofducks/ansible-vim")

" Show diff in Git's interactive rebase
call kg8m#plugin#register("hotwatermorning/auto-git-diff", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("vim-scripts/autodate.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#autodate#configure()
endif  " }}}

if kg8m#plugin#register("tyru/caw.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#caw#configure()
endif  " }}}

if kg8m#plugin#register("Shougo/context_filetype.vim")  " {{{
  call kg8m#plugin#context_filetype#configure()
endif  " }}}

if kg8m#plugin#register("spolu/dwm.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#dwm#configure()
endif  " }}}

if kg8m#plugin#register("editorconfig/editorconfig-vim", #{ if: !kg8m#util#is_git_tmp_edit() && filereadable(".editorconfig") })  " {{{
  let g:EditorConfig_preserve_formatoptions = v:true
endif  " }}}

if kg8m#plugin#register("junegunn/fzf.vim", #{ if: executable("fzf") })  " {{{
  call kg8m#plugin#fzf#configure()
endif  " }}}

if kg8m#plugin#register("lambdalisue/gina.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#gina#configure()
endif  " }}}

if kg8m#plugin#register("Yggdroot/indentLine", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#indent_line#configure()
endif  " }}}

if kg8m#plugin#register("othree/javascript-libraries-syntax.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:used_javascript_libs = "jquery,react,vue"
endif  " }}}

if kg8m#plugin#register("fuenor/JpFormat.vim")  " {{{
  call kg8m#plugin#jpformat#configure()
endif  " }}}

if kg8m#plugin#register("cohama/lexima.vim")  " {{{
  call kg8m#plugin#lexima#configure()
endif  " }}}

if kg8m#plugin#register("itchyny/lightline.vim")  " {{{
  call kg8m#plugin#lightline#configure()
endif  " }}}

if kg8m#plugin#register("AndrewRadev/linediff.vim")  " {{{
  call kg8m#plugin#linediff#configure()
endif  " }}}

call kg8m#plugin#register("kg8m/moin.vim")

if kg8m#plugin#register("lambdalisue/mr.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:mr#threshold = 10000
endif  " }}}

if kg8m#plugin#register("tyru/open-browser.vim")  " {{{
  call kg8m#plugin#open_browser#configure()
endif  " }}}

if kg8m#plugin#register("tyru/operator-camelize.vim")  " {{{
  call kg8m#plugin#operator#camelize#configure()
endif  " }}}

if kg8m#plugin#register("mechatroner/rainbow_csv", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#rainbow_csv#configure()
endif  " }}}

call kg8m#plugin#register("lambdalisue/readablefold.vim", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("lambdalisue/reword.vim")  " {{{
  cnoreabbrev <expr> Reword reword#live#start()
endif  " }}}

if kg8m#plugin#register("vim-scripts/sequence")  " {{{
  call kg8m#plugin#sequence#configure()
endif  " }}}

if kg8m#plugin#register("AndrewRadev/splitjoin.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#splitjoin#configure()
endif  " }}}

call kg8m#plugin#register("lambdalisue/suda.vim")

if kg8m#plugin#register("leafgarland/typescript-vim")  " {{{
  let g:typescript_indent_disable = v:true
endif  " }}}

if kg8m#plugin#register("mbbill/undotree")  " {{{
  call kg8m#plugin#undotree#configure()
endif  " }}}

if kg8m#plugin#register("Shougo/unite.vim", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#unite#configure()
endif  " }}}

if kg8m#plugin#register("FooSoft/vim-argwrap", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#argwrap#configure()
endif  " }}}

if kg8m#plugin#register("haya14busa/vim-asterisk")  " {{{
  call kg8m#plugin#asterisk#configure()
endif  " }}}

if kg8m#plugin#register("Chiel92/vim-autoformat", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  let g:formatdef_jsbeautify_javascript = '"js-beautify -f -s2 -"'
endif  " }}}

call kg8m#plugin#register("h1mesuke/vim-benchmark")

if kg8m#plugin#register("jkramer/vim-checkbox", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#checkbox#configure()
endif  " }}}

if kg8m#plugin#register("t9md/vim-choosewin", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#choosewin#configure()
endif  " }}}

call kg8m#plugin#register("hail2u/vim-css3-syntax", #{ if: !kg8m#util#is_git_tmp_edit() })

if kg8m#plugin#register("junegunn/vim-easy-align", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#easyalign#configure()
endif  " }}}

if kg8m#plugin#register("easymotion/vim-easymotion")  " {{{
  call kg8m#plugin#easymotion#configure()
endif  " }}}

if kg8m#plugin#register("lambdalisue/vim-findent", #{ if: !kg8m#util#is_git_tmp_edit() && !filereadable(".editorconfig") })  " {{{
  call kg8m#plugin#findent#configure()
endif  " }}}

call kg8m#plugin#register("thinca/vim-ft-diff_fold")
call kg8m#plugin#register("thinca/vim-ft-help_fold")
call kg8m#plugin#register("muz/vim-gemfile")
call kg8m#plugin#register("kana/vim-gf-user")

if kg8m#plugin#register("tpope/vim-git", #{ if: kg8m#util#is_git_commit() })  " {{{
  call kg8m#plugin#git#configure()
endif  " }}}

" Use LSP for completion, linting/formatting codes, and jumping to definition.
" Use vim-go's highlightings, foldings, and commands.
if kg8m#plugin#register("fatih/vim-go", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#go#configure()
endif  " }}}

call kg8m#plugin#register("tpope/vim-haml")

if kg8m#plugin#register("itchyny/vim-histexclude")  " {{{
  call kg8m#plugin#histexclude#configure()
endif  " }}}

if kg8m#plugin#register("obcat/vim-hitspop")  " {{{
  call kg8m#plugin#hitspop#configure()
endif  " }}}

" Text object for (Japanese) sentence: s
if kg8m#plugin#register("deton/jasentence.vim")  " {{{
  call kg8m#plugin#jasentence#configure()
endif  " }}}

if kg8m#plugin#register("osyo-manga/vim-jplus")  " {{{
  call kg8m#plugin#jplus#configure()
endif  " }}}

if kg8m#plugin#register("elzr/vim-json")  " {{{
  let g:vim_json_syntax_conceal = v:false
endif  " }}}

if kg8m#plugin#register("rcmdnk/vim-markdown", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#markdown#configure()
endif  " }}}

if kg8m#plugin#register("andymass/vim-matchup")  " {{{
  call kg8m#plugin#matchup#configure()
endif  " }}}

if kg8m#plugin#register("mattn/vim-molder", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#molder#configure()
endif  " }}}

if kg8m#plugin#register("kana/vim-operator-replace")  " {{{
  call kg8m#plugin#operator#replace#configure()
endif  " }}}

call kg8m#plugin#register("kana/vim-operator-user")

if kg8m#plugin#register("kg8m/vim-parallel-auto-ctags", #{ if: kg8m#util#on_rails_dir() && !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#parallel_auto_ctags#configure()
endif  " }}}

if kg8m#plugin#register("thinca/vim-prettyprint", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  " Don't load lazily because dein.vim's `on_cmd: "PP"` doesn't work
  call kg8m#plugin#configure(#{
  \   lazy: v:false,
  \ })
endif  " }}}

if kg8m#plugin#register("lambdalisue/vim-protocol", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#protocol#configure()
endif  " }}}

if kg8m#plugin#register("tpope/vim-rails", #{ if: !kg8m#util#is_git_tmp_edit() && kg8m#util#on_rails_dir() })  " {{{
  call kg8m#plugin#rails#configure()
endif  " }}}

call kg8m#plugin#register("tpope/vim-repeat")

if kg8m#plugin#register("vim-ruby/vim-ruby")  " {{{
  call kg8m#plugin#ruby#configure()
endif  " }}}

if kg8m#plugin#register("joker1007/vim-ruby-heredoc-syntax", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#ruby_heredoc_syntax#configure()
endif  " }}}

" Text object for surrounded by a bracket-pair or same characters: S + {user input}
if kg8m#plugin#register("machakann/vim-sandwich")  " {{{
  call kg8m#plugin#sandwich#configure()
endif  " }}}

call kg8m#plugin#register("arzg/vim-sh")

if kg8m#plugin#register("mhinz/vim-startify", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#startify#configure()
endif  " }}}

if kg8m#plugin#register("kopischke/vim-stay", #{ if: !kg8m#util#is_git_commit() })  " {{{
  call kg8m#plugin#stay#configure()
endif  " }}}

if kg8m#plugin#register("janko/vim-test", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#test#configure()
endif  " }}}

" Text object for indentation: i
call kg8m#plugin#register("kana/vim-textobj-indent")

" Text object for last search pattern: /
call kg8m#plugin#register("kana/vim-textobj-lastpat")

call kg8m#plugin#register("kana/vim-textobj-user")
call kg8m#plugin#register("cespare/vim-toml")
call kg8m#plugin#register("posva/vim-vue")

if kg8m#plugin#register("thinca/vim-zenspace")  " {{{
  call kg8m#plugin#zenspace#configure()
endif  " }}}

if kg8m#plugin#register("Shougo/vimproc")  " {{{
  call kg8m#plugin#vimproc#configure()
endif  " }}}

if kg8m#plugin#register("benmills/vimux", #{ if: kg8m#util#on_tmux() && !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#vimux#configure()
endif  " }}}

" See `kg8m#util#xxx_module()`
call kg8m#plugin#register("vim-jp/vital.vim")

if kg8m#plugin#register("simeji/winresizer", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#winresizer#configure()
endif  " }}}

call kg8m#plugin#register("stephpy/vim-yaml", #{ if: !kg8m#util#is_git_tmp_edit() })
call kg8m#plugin#register("pedrohdz/vim-yaml-folds", #{ if: !kg8m#util#is_git_tmp_edit() })

" Disable because yajs.vim conflicts with vim-html-template-literals.
" Don't merge because some syntax files are duplicated.
call kg8m#plugin#register("othree/yajs.vim", #{ if: v:false, merged: v:false })

if kg8m#plugin#register("jonsmithers/vim-html-template-literals", #{ if: !kg8m#util#is_git_tmp_edit() })  " {{{
  call kg8m#plugin#html_template_literals#configure()
endif  " }}}

if kg8m#plugin#register("LeafCage/yankround.vim")  " {{{
  call kg8m#plugin#yankround#configure()
endif  " }}}

call kg8m#plugin#register("zinit-zsh/zinit-vim-syntax")

" Colorschemes
if kg8m#plugin#register("tomasr/molokai")  " {{{
  call kg8m#plugin#molokai#configure()
endif  " }}}
" }}}

" Finish plugin manager initialization  " {{{
call kg8m#plugin#finish_setup()

" Disable filetype before enabling filetype
" https://gitter.im/vim-jp/reading-vimrc?at=5d73bf673b1e5e5df16c0559
filetype off
filetype plugin indent on

syntax enable

if kg8m#plugin#installable_exists()
  call kg8m#plugin#install()
endif
" }}}
" }}}

call kg8m#configure#backup()
call kg8m#configure#colors()
call kg8m#configure#column()
call kg8m#configure#completion()
call kg8m#configure#cursor()
call kg8m#configure#folding()
call kg8m#configure#formatoptions()
call kg8m#configure#indent()
call kg8m#configure#scroll()
call kg8m#configure#search()
call kg8m#configure#statusline()
call kg8m#configure#undo()
call kg8m#util#dim_inactive_windows#setup()

if !kg8m#util#is_git_tmp_edit()  " {{{
  call kg8m#util#auto_reload#setup()
  call kg8m#util#check_typo#setup()
  call kg8m#util#daemons#setup()
endif  " }}}

call kg8m#configure#commands()
call kg8m#configure#mappings()
call kg8m#configure#others()

if has("gui_running")
  call kg8m#configure#gui()
endif

call kg8m#util#source_local_vimrc()
