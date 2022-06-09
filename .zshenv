function try_to_source {
  if [ ! $# = 1 ]; then
    echo "Specify only 1 filepath to source" >&2
    return 1
  fi

  local filepath="$1"
  [ -f "${filepath}" ] && source "${filepath}"
}

# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="${HOME}/.config"     # Where user-specific configurations should be written (analogous to `/etc`).
export XDG_CACHE_HOME="${HOME}/.cache"       # Where user-specific non-essential (cached) data should be written (analogous to `/var/cache`).
export XDG_DATA_HOME="${HOME}/.local/share"  # Where user-specific data files should be written (analogous to `/usr/share`).

# Remove duplicated paths
typeset -U path

# (N-/): Ignore unless exists
path=(
  "${HOME}/.local/bin"
  "/opt/homebrew/bin"(N-/)
  "/usr/local/bin"(N-/)
  "/usr/bin"(N-/)
  "/bin"(N-/)
  "/opt/homebrew/sbin"(N-/)
  "/usr/local/sbin"(N-/)
  "/usr/sbin"(N-/)
  "/sbin"(N-/)
  "${path[@]}"
)

export COLORTERM=truecolor

# https://github.com/asdf-vm/asdf/blob/788ccab5971cb828cf25364b0df5ed6f5e9e713d/asdf.sh#L17
ASDF_ROOT="${XDG_DATA_HOME}/zsh/asdf"
export ASDF_DIR="${ASDF_ROOT}/src"
export ASDF_DATA_DIR="${ASDF_ROOT}/data"
unset ASDF_ROOT

export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/asdfrc"

# https://github.com/asdf-vm/asdf/blob/788ccab5971cb828cf25364b0df5ed6f5e9e713d/asdf.sh#L25-26
path=(
  "${ASDF_DATA_DIR}/shims"
  "${ASDF_DIR}/bin"
  "${path[@]}"
)

# cf. data setup in .config/zsh/binary-released-plugins.zsh
export MOCWORD_DATA="${HOME}/.local/share/mocword/mocword.sqlite"

export NEXTWORD_DATA_PATH="${HOME}/.local/share/nextword/nextword-data"
export RIPGREP_CONFIG_PATH="${HOME}/.config/ripgrep/config"
export VIM_PLUGINS="${HOME}/.vim/plugins/repos"

if [ -d "/opt/homebrew" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

export KG8M_ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"

mkdir -p "${VIM_PLUGINS}"

export FD_DEFAULT_OPTIONS=(
  # Include hidden files and directories
  --hidden

  # Show search results from files and directories that would otherwise be ignored by VCS ignore files
  --no-ignore-vcs

  # Remove './' prefixes of relative paths
  # Don't set as default because this option can't be used with paths or `--search-path` options.
  # --strip-cwd-prefix

  # Exclude files/directories
  # cf. configs for ripgrep
  --exclude "*.zwc"
  --exclude ".cache/"
  --exclude ".git/"
  --exclude ".hg/"
  --exclude ".svn/"
  --exclude ".vim-sessions/"
  --exclude "cache/"
  --exclude "log/"
  --exclude "node_modules/"
  --exclude "tmp/"
  --exclude "vendor/bundle/"

  # For Mac
  --exclude "/System/Volumes/"
  --exclude "/Volumes/"

  # Sort search results
  # Comment out because `fd` doesn't sort the result even with this option.
  # --threads 1
)

path=(
  "${HOME}/.config/git/bin"
  "${HOME}/.config/zsh/bin"
  "${HOME}/bin"
  "${path[@]}"
)

if [[ -o interactive ]]; then
  # https://github.com/sharkdp/bat/blob/ed3246c423932561435d45c50fd8cd9e06add7f5/README.md?plain=1#L171
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  source ~/.config/zsh/env/fzf.zsh
fi

try_to_source ~/.config/zsh.local/.zshenv.local
