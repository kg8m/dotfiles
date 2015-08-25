alias -g G="| grep --color=always"
alias -g V="| view -"
alias -g L="| less"
alias -g P="| peco"
alias -g DIFF_MINIMAL="--diff-cmd /usr/bin/diff -x '-b -B -U 10'"
alias -g FFTEST="TESTOPTS='--runner=failfast'"

alias g='git'

if builtin command -v colorsvn > /dev/null; then
  alias s='colorsvn'
else
  alias s='svn'
fi

if [ -f /Applications/MacVim.app/Contents/MacOS/Vim ]; then
  macvim_cmd='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  macvimdiff_cmd='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/vimdiff "$@"'
  alias vi=${macvim_cmd}
  alias vim=${macvim_cmd}
  alias vimdiff=${macvimdiff_cmd}
fi

alias rm='rm -i'
alias crontab='crontab -i'
alias _ls='/bin/ls -a'
alias ls='ls --color -a'
alias ll='ls -l'
alias less='less -R'
alias vless='/usr/local/share/vim/vim73/macros/less.sh'
alias rak='rak --sort-files'
alias rak_app="rak -k 'db/|log/|public/|spec/|test/|tmp/|vendor/'"
alias ag='ag --hidden --pager "less -R" -S'
alias pt='pt --color -HSe --parallel'

alias 80='sudo ruby script/server webrick -p 80'
alias 443='sudo ruby script/webrick_ssl -p 443'
alias log='tail -F log/development.log log/production.log'
alias log_test='tail -F log/test.log'
alias log_production='tail -F log/production.log'

alias console='ruby script/console'
alias about='ruby script/about'
alias prepare='execute_with_echo "rake db:test:prepare"'
alias rake_units='      execute_with_echo "TEST_ENV_NUMBER=2 prepare; TEST_ENV_NUMBER=2 rake test:units $1"'
alias rake_functionals='execute_with_echo "TEST_ENV_NUMBER=3 prepare; TEST_ENV_NUMBER=3 rake test:functionals $1"'
alias rake_integration='execute_with_echo "TEST_ENV_NUMBER=4 prepare; TEST_ENV_NUMBER=4 rake test:integration $1"'
alias rake_js='         execute_with_echo "rake test:js"'
alias frake='execute_with_echo "rake FFTEST"'
alias frake_units='      execute_with_echo "rake_units FFTEST"'
alias frake_functionals='execute_with_echo "rake_functionals FFTEST"'
alias frake_integration='execute_with_echo "rake_integration FFTEST"'
alias rake_models='     execute_with_echo "TEST_ENV_NUMBER=2 rake spec:models"'
alias rake_controllers='execute_with_echo "TEST_ENV_NUMBER=3 rake spec:controllers"'
alias rake_helpers='    execute_with_echo "TEST_ENV_NUMBER=4 rake spec:helpers"'
alias ruby_multitest='ruby -I ${RUBYGEMS_PATH}rake-*/lib ${RUBYGEMS_PATH}rake-*/lib/rake/rake_test_loader.rb --runner=failfast'

alias reload='source ~/.zshrc; echo "~/.zshrc sourced."'

alias mux='attach_or_new_tmux'  # never use tmuxinator
