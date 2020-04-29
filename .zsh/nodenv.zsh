if [ -d ~/.nodenv ]; then
  export PATH=~/.nodenv/bin:$PATH

  function setup_my_nodenv {
    if which nodenv > /dev/null 2>&1; then
      eval "$( nodenv init - )"
    fi

    unset -f setup_my_nodenv
  }
  zinit ice lucid wait"!0a" atload"setup_my_nodenv"; zinit snippet /dev/null
fi
