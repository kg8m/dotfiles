function try_to_source {
  if [ ! $# = 1 ]; then
    echo "Specify only 1 filepath to source" >&2; return 1
  fi

  local filepath="$1"
  [ -f "$filepath" ] && source "$filepath"
}

export PATH=/usr/local/bin:/usr/local/sbin:/sbin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.git_templates/bin:$PATH
export PATH=$HOME/dotfiles/.zsh/bin:$PATH

export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

try_to_source ~/.zshenv.local
