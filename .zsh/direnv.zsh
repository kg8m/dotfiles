if which direnv > /dev/null 2>&1; then
  setup_my_direnv() {
    eval "$( direnv hook zsh )"

    if [[ -f .envrc ]]; then
      # https://github.com/direnv/direnv/blob/a4632773637ee1a6b08fa81043cacd24ea941489/shell_zsh.go#L12
      eval "$( direnv export zsh )"
    fi

    unset -f setup_my_direnv
  }
  zinit ice lucid nocd wait"!0b" atload"setup_my_direnv"; zinit snippet ~/.zsh/dummy.zsh
else
  error_for_envrc() {
    if [[ -f .envrc ]]; then
      >&2 echo "WARNING: .envrc exists but direnv isn't installed."
    fi
  }
  add-zsh-hook chpwd error_for_envrc
fi
