function setup_my_binary_released_plugins {
  local repositories=(
    mattn/efm-langserver
    Songmu/ghch
    golangci/golangci-lint
    nametake/golangci-lint-langserver
    Songmu/make2help
    high-moctane/nextword
    lighttiger2505/sqls
    mvdan/sh
  )

  # Use `brew` command if available to detect that zinit gets broken or something is wrong
  if ! command -v brew > /dev/null; then
    repositories+=(
      sharkdp/bat
      dandavison/delta
      direnv/direnv
      junegunn/fzf
      sharkdp/hyperfine
      itchyny/mmv
      koalaman/shellcheck
      BurntSushi/ripgrep
    )
  fi

  # Don't use zinit's options like `as"command" mv"${plugin}* -> ${plugin}" pick"${plugin}/${plugin}"` because it
  # makes the `$PATH` longer and longer. Make symbolic links in `$HOME/bin` instead.
  function setup_my_binary_released_plugin {
    local plugin="$1"

    case "$plugin" in
      bat | delta | direnv | efm-langserver | ghch | golangci-lint | hyperfine | make2help | mmv | ripgrep | shellcheck | shfmt)
        mv ./"${plugin}"* ./"$plugin"
        ;;
      sqls)
        mv ./* ./"$plugin"
        ;;
      fzf | golangci-lint-langserver | nextword)
        # Do nothing
        ;;
      *)
        echo "Unknown plugin to move files: ${plugin}" >&2
        return 1
        ;;
    esac

    case "$plugin" in
      bat | delta | efm-langserver | ghch | golangci-lint | hyperfine | make2help | mmv | shellcheck | sqls)
        local binary="${plugin}/${plugin}"
        ;;
      direnv | fzf | golangci-lint-langserver | nextword | shfmt)
        local binary="${plugin}"
        ;;
      ripgrep)
        local binary="${plugin}/rg"
        ;;
      *)
        echo "Unknown plugin to detect binary: ${plugin}" >&2
        return 1
        ;;
    esac

    chmod +x "$binary"

    mkdir -p "$HOME/bin"
    execute_with_echo "ln -fs '$PWD/${binary}' '$HOME/bin/$(basename "$binary")'"

    case "$plugin" in
      nextword)
        setup_my_nextword
        ;;
    esac
  }

  function setup_my_nextword {
    if command -v nextword > /dev/null; then
      if ! [ -d "${NEXTWORD_DATA_PATH:-}" ]; then
        local current_dir="$PWD"
        local parent_dir="$(dirname "$NEXTWORD_DATA_PATH")"

        mkdir -p "$parent_dir"
        cd "$parent_dir"

        local name=large

        execute_with_echo "wget https://github.com/high-moctane/nextword-data/archive/${name}.tar.gz"
        execute_with_echo "tar xzvf ${name}.tar.gz"
        execute_with_echo "rm -f ${name}.tar.gz"
        execute_with_echo "mv nextword-data-${name} '$(basename "$NEXTWORD_DATA_PATH")'"

        cd "$current_dir"
      fi
    else
      echo 'Command `nextword` not found.' >&2
    fi
  }

  for repository in "${repositories[@]}"; do
    case "$repository" in
      mvdan/sh)
        local plugin="shfmt"
        ;;
      *)
        local plugin="$(basename "$repository")"
        ;;
    esac

    local options=(
      from"gh-r"
      as"null"
      id-as"$(dirname "$repository")---${plugin}-bin"
      atclone"setup_my_binary_released_plugin $plugin"
      atpull"%atclone"
    )

    case "$plugin" in
      bat | delta | hyperfine | ripgrep)
        # Choose musl for legacy environments
        options+=(bpick"*musl*")
        ;;
      golangci-lint)
        options+=(bpick"*.tar.gz")
        ;;
    esac

    zinit ice lucid "${options[@]}"
    zinit light "$repository"
  done

  unset -f setup_my_binary_released_plugins
}
zinit ice lucid nocd wait"0a" atload"setup_my_binary_released_plugins"
zinit snippet /dev/null
