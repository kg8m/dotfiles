setopt no_global_rcs

function try_to_source {
  local filepath="${1:?Specify a filepath to source.}"
  [ -f "${filepath}" ] && source "${filepath}"
}

function ensure_dir {
  local filepath="${1:?}"
  mkdir -p "$(dirname "${filepath}")"
  echo "${filepath}"
}

# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="${HOME}/.config"     # Where user-specific configurations should be written (analogous to `/etc`).
export XDG_CACHE_HOME="${HOME}/.cache"       # Where user-specific non-essential (cached) data should be written (analogous to `/var/cache`).
export XDG_DATA_HOME="${HOME}/.local/share"  # Where user-specific data files should be written (analogous to `/usr/share`).

# Remove duplicated paths
typeset -U path

# (N-/): Ignore unless exists
path=(
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
export GPG_TTY="$(tty)"

# cf. data setup in .config/zsh/binary-released-plugins.zsh
export MOCWORD_DATA="${HOME}/.local/share/mocword/mocword.sqlite"

export RIPGREP_CONFIG_PATH="${HOME}/.config/ripgrep/config"
export VIM_PLUGINS="${HOME}/.vim/plugins/repos"

if [ -d "/opt/homebrew" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

path=(
  # Required for tools used outside of the interactive shell.
  "${XDG_DATA_HOME:?}/mise/shims"

  "${path[@]}"
)

mkdir -p "${VIM_PLUGINS}"

# cf. .config/ctags/default.ctags
# cf. .config/fd/ignore
# cf. .config/ripgrep/config
# cf. rails:assets:clean:force in rails:assets:clean:force
#
# NOTE: Subdirectories can’t be specified.
# NOTE: Don’t specify the `--ignore-glob` in the `$EZA_DEFAULT_OPTIONS` because the directries/files are always hidden.
#       Use this variable in some specific cases, e.g., with `--tree` option.
# shellcheck disable=SC2034
EZA_IGNORE_GLOBS=(
  ".bundle"
  ".cache"
  ".gem_rbs_collection"
  ".git"
  ".nuxt"
  ".ruby-lsp"
  "node_modules"
  "tmp"
  "vendor"
)
# shellcheck disable=SC2178
export EZA_IGNORE_GLOB="${(j:|:)EZA_IGNORE_GLOBS}"
unset EZA_IGNORE_GLOBS

export EZA_DEFAULT_OPTIONS=(
  # Always colorize
  --color "always"

  # Show hidden and "dot" files
  --all

  # Show icons
  --icons "auto"

  # Don’t quote file names with spaces
  --no-quotes
)

export FD_DEFAULT_OPTIONS=(
  # Include hidden files and directories
  --hidden

  # Show search results from files and directories that would otherwise be ignored by VCS ignore files
  --no-ignore-vcs

  # Remove './' prefixes of relative paths
  # Don’t set as default because this option can’t be used with paths or `--search-path` options.
  # --strip-cwd-prefix

  # Sort search results
  # Comment out because `fd` doesn’t sort the result even with this option.
  # --threads 1
)

path=(
  "${HOME}/.config/git/bin"
  "${HOME}/.config/zsh/bin"
  "${HOME}/.config/bin"
  "${HOME}/bin"
  "${path[@]}"
)

if [[ -o interactive ]]; then
  # https://github.com/sharkdp/bat/blob/ed3246c423932561435d45c50fd8cd9e06add7f5/README.md?plain=1#L171
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  source ~/.config/zsh/env/fzf.zsh
fi

try_to_source ~/.config/zsh.local/zshenv.local.zsh
