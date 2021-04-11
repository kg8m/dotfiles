function try_to_source {
  if [ ! $# = 1 ]; then
    echo "Specify only 1 filepath to source" >&2
    return 1
  fi

  local filepath="$1"
  [ -f "$filepath" ] && source "$filepath"
}

# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME=$HOME/.config     # Where user-specific configurations should be written (analogous to `/etc`).
export XDG_CACHE_HOME=$HOME/.cache       # Where user-specific non-essential (cached) data should be written (analogous to `/var/cache`).
export XDG_DATA_HOME=$HOME/.local/share  # Where user-specific data files should be written (analogous to `/usr/share`).

# Remove duplicated paths
typeset -U path

# (N-/): Ignore unless exists
path=(
  "$HOME/.config/git/bin"
  "$HOME/.config/zsh/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  "/usr/local/bin"(N-/)
  "/usr/bin"(N-/)
  "/bin"(N-/)
  "/usr/local/sbin"(N-/)
  "/usr/sbin"(N-/)
  "/sbin"(N-/)
  "${path[@]}"
)

export COLORTERM=truecolor

export BAT_THEME="Monokai Extended"
export NEXTWORD_DATA_PATH=$HOME/.local/share/nextword/nextword-data
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/config
export VIM_PLUGINS=$HOME/.vim/plugins/repos

export KG8M_ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh

if [[ ! -o interactive ]]; then
  source ~/.config/zsh/env/fzf.zsh
  source ~/.config/zsh/env/go.zsh
  source ~/.config/zsh/env/ruby.zsh
fi

try_to_source ~/.config/zsh.local/.zshenv.local
