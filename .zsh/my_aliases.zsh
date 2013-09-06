alias -g G="| grep"
alias -g V="| view -"
alias -g DIFF_MINIMAL="--diff-cmd /usr/bin/diff -x '-b -B -U 10'"
alias -g FFTEST="TESTOPTS='--runner=failfast'"

alias g='git'
alias s='svn'

if [ -f /Applications/MacVim.app/Contents/MacOS/Vim ]; then
  macvim_cmd='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  alias vi=${macvim_cmd}
  alias vim=${macvim_cmd}
fi

alias rm='rm -i'
alias ls='ls --color -a'
alias ll='ls -l'
alias vless='/usr/local/share/vim/vim73/macros/less.sh'
alias rak='rak --sort-files'
alias rak_app="rak -k 'db/|log/|public/|spec/|test/|tmp/|vendor/'"

alias cdb='cd ~/apps/${APP_NAME}/branch'
alias cdt='cd ~/apps/${APP_NAME}/trunk'
alias cdbd='cd ~/apps/${APP_NAME}/dummy_branch'
alias cdtd='cd ~/apps/${APP_NAME}/dummy_trunk'

alias 80='sudo ruby script/server webrick -p 80'
alias 443='sudo ruby script/webrick_ssl -p 443'
alias log='tail -f log/development.log'
alias log_test='tail -f log/test.log'
alias log_production='tail -f log/production.log'

alias console='ruby script/console'
alias about='ruby script/about'
alias prepare='execute_with_echo "rake db:test:prepare"'
alias rake_units='      execute_with_echo "TEST_ENV_NUMBER=2 rake test:units $1"'
alias rake_functionals='execute_with_echo "TEST_ENV_NUMBER=3 rake test:functionals $1"'
alias rake_integration='execute_with_echo "TEST_ENV_NUMBER=4 rake test:integration $1"'
alias rake_js='         execute_with_echo "rake test:js"'
alias frake='execute_with_echo "rake FFTEST"'
alias frake_units='      execute_with_echo "rake_units FFTEST"'
alias frake_functionals='execute_with_echo "rake_functionals FFTEST"'
alias frake_integration='execute_with_echo "rake_integration FFTEST"'
alias mrake='execute_with_echo "migrate; execute_with_echo rake"'
alias rake_models='     execute_with_echo "TEST_ENV_NUMBER=2 rake spec:models"'
alias rake_controllers='execute_with_echo "TEST_ENV_NUMBER=3 rake spec:controllers"'
alias rake_helpers='    execute_with_echo "TEST_ENV_NUMBER=4 rake spec:helpers"'
alias ruby_multitest='ruby -I ${RUBYGEMS_PATH}rake-*/lib ${RUBYGEMS_PATH}rake-*/lib/rake/rake_test_loader.rb'

alias reload='source ~/.zshrc; echo "~/.zshrc sourced."'
