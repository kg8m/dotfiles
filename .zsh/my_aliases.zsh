alias -g G="| grep --color=always"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g P="| peco"
alias -g GW='--ignore-all-space --ignore-blank-lines --ignore-space-at-eol --ignore-space-change'  # for Git: ignore whitespace changes

alias g='git'

if builtin command -v colorsvn > /dev/null; then
  alias s='colorsvn'
else
  alias s='svn'
fi

if [ -f /Applications/MacVim.app/Contents/MacOS/Vim ]; then
  macvim_cmd='    env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  macvimdiff_cmd='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/vimdiff "$@"'
  alias vi=${macvim_cmd}
  alias vim=${macvim_cmd}
  alias vimdiff=${macvimdiff_cmd}
fi

alias rm='rm -i'

if `crontab -i > /dev/null 2>&1`; then
  alias crontab='crontab -i'
fi

alias _ls='/bin/ls -a'
alias ls='ls --color -a'
alias ll='ls -l'
alias diff='diff -U 10 -b -B'
alias _diff='/usr/bin/diff'

alias log='     tail -F log/development.log log/production*.log'
alias log_test='tail -F log/test.log'

alias console='ruby script/console'
alias prepare='       execute_with_echo "rake db:test:prepare"'
alias load_structure='execute_with_echo "rake db:test:load_structure"'
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

alias reload='source ~/.zshrc; echo "~/.zshrc sourced."'

alias mux='attach_or_new_tmux'  # never use tmuxinator
