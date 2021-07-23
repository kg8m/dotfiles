function plugin:setup:binary_releaseds {
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
      rhysd/actionlint
      sharkdp/bat
      cli/cli
      dandavison/delta
      direnv/direnv
      junegunn/fzf
      profclems/glab
      sharkdp/hyperfine
      itchyny/mmv
      koalaman/shellcheck
      BurntSushi/ripgrep
    )
  fi

  # Don't use zinit's options like `as"command" mv"${plugin}* -> ${plugin}" pick"${plugin}/${plugin}"` because it
  # makes the `$PATH` longer and longer. Make symbolic links in `$HOME/bin` instead.
  function plugin:setup:binary_released {
    local plugin="$1"

    case "$plugin" in
      actionlint | bat | delta | direnv | efm-langserver | ghch | glab | golangci-lint | hyperfine | make2help | mmv | ripgrep | shellcheck | shfmt)
        mv ./"${plugin}"* ./"$plugin"
        ;;
      cli)
        mv ./gh* ./"$plugin"
        ;;
      fzf | golangci-lint-langserver | nextword | sqls)
        # Do nothing
        ;;
      *)
        echo:error "Unknown plugin to move files: ${plugin}"
        return 1
        ;;
    esac

    case "$plugin" in
      bat | delta | efm-langserver | ghch | golangci-lint | hyperfine | make2help | mmv | shellcheck)
        local binary="${plugin}/${plugin}"
        ;;
      actionlint | direnv | fzf | golangci-lint-langserver | nextword | shfmt | sqls)
        local binary="${plugin}"
        ;;
      cli)
        local binary="${plugin}/bin/gh"
        ;;
      ripgrep)
        local binary="${plugin}/rg"
        ;;
      glab)
        local binary="bin/${plugin}"
        ;;
      *)
        echo:error "Unknown plugin to detect binary: ${plugin}"
        return 1
        ;;
    esac

    chmod +x "$binary"

    local command="$(basename "$binary")"

    mkdir -p "$HOME/bin"
    rm -f "$HOME/bin/$command"
    execute_with_echo "ln -s '$PWD/$binary' '$HOME/bin/$command'"
    execute_with_echo "which $command"

    case "$plugin" in
      bat | cli | delta | direnv | fzf | glab | hyperfine | mmv | ripgrep | shellcheck)
        execute_with_echo "$command --version"
        ;;
      make2help)
        execute_with_echo "$command -h"
        ;;
      efm-langserver | nextword)
        execute_with_echo "$command -v"
        ;;
      actionlint | shfmt | sqls)
        execute_with_echo "$command -version"
        ;;
      ghch | golangci-lint)
        execute_with_echo "$command version"
        ;;
      golangci-lint-langserver)
        # Do nothing because there are no ways to check version
        ;;
      *)
        echo:error "Unknown plugin to detect binary: ${plugin}"
        return 1
        ;;
    esac

    case "$plugin" in
      bat)
        execute_with_echo "mv ./bat/autocomplete/{bat.zsh,_bat}"
        ;;
      nextword)
        plugin:setup:nextword
        ;;
    esac

    [ -n "$(find . -type f -name '_*')" ] && execute_with_echo "zinit creinstall '$PWD'"
  }

  function plugin:setup:nextword {
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
      echo:warn 'Command `nextword` not found.'
    fi
  }

  local repository
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
      atclone"plugin:setup:binary_released $plugin"
      atpull"%atclone"
    )

    case "$plugin" in
      bat | delta | hyperfine | ripgrep)
        # Choose musl for legacy environments
        options+=(bpick"*musl*")
        ;;
      cli | glab | golangci-lint)
        options+=(bpick"*.tar.gz")
        ;;
    esac

    zinit ice lucid "${options[@]}"
    zinit light "$repository"
  done

  unset -f plugin:setup:binary_releaseds
}
zinit ice lucid nocd wait"0a" atload"plugin:setup:binary_releaseds"
zinit snippet /dev/null
