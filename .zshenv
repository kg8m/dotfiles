function try_to_source {
  if [ ! $# = 1 ]; then
    echo "Specify only 1 filepath to source" >&2; return 1
  fi

  local filepath="$1"
  [ -f "$filepath" ] && source "$filepath"
}

export PATH=/usr/local/bin:/usr/local/sbin:/sbin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.config/git/bin:$PATH
export PATH=$HOME/.zsh/bin:$PATH

export NEXTWORD_DATA_PATH=$HOME/.local/share/nextword/nextword-data
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/config
export VIM_PLUGINS=$HOME/.vim/plugins/repos

case "$-" in
  *i*)  # Interactive shell
    ;;
  *)  # Non interactive shell
    source ~/.zsh/env/fzf.zsh
    source ~/.zsh/env/go.zsh
    source ~/.zsh/env/ruby.zsh
    ;;
esac

try_to_source ~/.zshenv.local
