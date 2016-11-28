if which direnv > /dev/null 2>&1; then
  eval "$( direnv hook zsh )"
else
  error_for_envrc() {
    if [[ -f .envrc ]]; then
      >&2 echo "WARNING: .envrc exists but direnv isn't installed."
    fi
  }
  add-zsh-hook chpwd error_for_envrc
fi
