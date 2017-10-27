alias -g G="| grep --color=always"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g P="| peco"
alias -g GW='--ignore-all-space --ignore-blank-lines --ignore-space-at-eol --ignore-space-change'  # for Git: ignore whitespace changes

alias ag="ag --pager=less --color-line-number='1;36' --color-match='30;46' --color-path='1;34'"
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
alias _watch='/usr/bin/watch'
alias watch='watch --color'

alias reload='source ~/.zshrc; echo "~/.zshrc sourced."'

alias mux='attach_or_new_tmux'  # never use tmuxinator
