if [ -d ~/.nodenv ]; then
  export PATH=~/.nodenv/bin:$PATH

  setup_my_nodenv() {
    if which nodenv > /dev/null 2>&1; then
      eval "$( nodenv init - )"
    fi
  }
  zinit ice lucid wait at_load"setup_my_nodenv"; zinit snippet ~/.zsh/dummy.zsh
fi
