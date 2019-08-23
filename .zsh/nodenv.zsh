if [ -d ~/.nodenv ]; then
  export PATH=~/.nodenv/bin:$PATH

  if which nodenv > /dev/null 2>&1; then
    eval "$( nodenv init - )"
  fi
fi
