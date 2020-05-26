function try_to_source {
  if [ ! $# = 1 ]; then
    echo "Specify only 1 filepath to source" >&2; return 1
  fi

  local filepath="$1"
  [ -f "$filepath" ] && source "$filepath"
}

# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME=$HOME/.config     # Where user-specific configurations should be written (analogous to `/etc`).
export XDG_CACHE_HOME=$HOME/.cache       # Where user-specific non-essential (cached) data should be written (analogous to `/var/cache`).
export XDG_DATA_HOME=$HOME/.local/share  # Where user-specific data files should be written (analogous to `/usr/share`).

export PATH=/usr/local/bin:/usr/local/sbin:/sbin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.config/git/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.zsh/bin:$PATH

export BAT_THEME="Monokai Extended"
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
