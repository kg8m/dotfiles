function plugin:setup:binary_releaseds {
  local repositories=(
    mrtazz/checkmake
    mattn/efm-langserver
    golangci/golangci-lint
    nametake/golangci-lint-langserver
    high-moctane/mocword
    high-moctane/nextword
    lighttiger2505/sqls
    mvdan/sh
    juliosueiras/terraform-lsp
    crate-ci/typos
    rhysd/vim-startuptime
    Ryooooooga/zabrze
  )

  # Use `brew` command if available to detect that zinit gets broken or something is wrong
  if ! command -v brew > /dev/null; then
    repositories+=(
      rhysd/actionlint
      sharkdp/bat
      cli/cli
      dandavison/delta
      direnv/direnv
      sharkdp/fd
      junegunn/fzf
      profclems/glab
      sharkdp/hyperfine
      itchyny/mmv
      BurntSushi/ripgrep
      koalaman/shellcheck
      dbrgn/tealdeer
      XAMPPRocky/tokei
    )

    if [ -z "${SD_UNAVAILABLE}" ]; then
      repositories+=(
        chmln/sd
      )
    fi
  fi

  # Don't use zinit's options like `as"command" mv"${plugin}* -> ${plugin}" pick"${plugin}/${plugin}"` because it
  # makes the `$PATH` longer and longer. Make symbolic links in `${HOME}/bin` instead.
  function plugin:binary_released:atclone {
    local repository="${1:?}"
    local plugin="${2:?}"

    echo >&2
    echo:info "URL: https://github.com/${repository}"
    echo >&2

    case "${plugin}" in
      actionlint | bat | checkmake | delta | direnv | efm-langserver | fd | gh | glab | golangci-lint | hyperfine |\
      mmv | mocword | sd | shellcheck | shfmt | terraform-lsp | typos | vim-startuptime | zabrze)
        mv ./"${plugin}"* ./"${plugin}"
        ;;
      rg)
        mv ./ripgrep* ./"${plugin}"
        ;;
      tldr)
        mv ./tealdeer* ./"${plugin}"
        ;;
      fzf | golangci-lint-langserver | nextword | sqls | tokei)
        # Do nothing
        ;;
      *)
        echo:error "Unknown plugin to move files: ${plugin}"
        return 1
        ;;
    esac

    case "${plugin}" in
      actionlint | checkmake | direnv | fzf | golangci-lint-langserver | mocword | nextword | sd | shfmt | sqls |\
      terraform-lsp | tldr | tokei | typos | vim-startuptime | zabrze)
        local binary="${plugin}"
        ;;
      bat | delta | efm-langserver | fd | golangci-lint | hyperfine | mmv | rg | shellcheck)
        local binary="${plugin}/${plugin}"
        ;;
      gh)
        local binary="${plugin}/bin/${plugin}"
        ;;
      glab)
        local binary="bin/${plugin}"
        ;;
      *)
        echo:error "Unknown plugin to detect binary: ${plugin}"
        return 1
        ;;
    esac

    chmod +x "${binary}"

    local command="$(basename "${binary}")"

    mkdir -p "${HOME}/bin"
    rm -f "${HOME}/bin/${command}"
    execute_with_echo "ln -s '${PWD}/${binary}' '${HOME}/bin/${command}'"
    execute_with_echo "which ${command}"

    case "${plugin}" in
      bat | checkmake | delta | direnv | fd | fzf | gh | glab | hyperfine | mmv | mocword | rg | sd | shellcheck |\
      tldr | tokei | typos | zabrze)
        execute_with_echo "${command} --version"
        ;;
      efm-langserver | nextword)
        execute_with_echo "${command} -v"
        ;;
      actionlint | shfmt | sqls)
        execute_with_echo "${command} -version"
        ;;
      golangci-lint)
        execute_with_echo "${command} version"
        ;;
      golangci-lint-langserver | terraform-lsp | vim-startuptime)
        echo >&2
        echo:info "Skip checking version because there are no ways."
        ;;
      *)
        echo:error "Unknown plugin to detect binary: ${plugin}"
        return 1
        ;;
    esac

    case "${plugin}" in
      bat)
        execute_with_echo "mv ./bat/autocomplete/{bat.zsh,_bat}"
        ;;
      nextword)
        execute_with_echo "plugin:nextword:after_update"
        ;;
      zabrze)
        execute_with_echo "plugin:zabrze:reset"
        execute_with_echo "plugin:zabrze:init"
        ;;
      *)
        # Do nothing.
        ;;
    esac

    [ -n "$(find . -type f -name '_*')" ] && execute_with_echo "zinit creinstall ${repository}"

    echo >&2
    echo:info "Done."

    # Echo empty lines because refreshing prompt by zinit clears the last few lines.
    echo >&2
    echo >&2
  }

  function plugin:nextword:after_update {
    if command -v nextword > /dev/null; then
      if [ ! -d "${NEXTWORD_DATA_PATH:-}" ]; then
        local parent_dir="$(dirname "${NEXTWORD_DATA_PATH}")"
        mkdir -p "${parent_dir}"

        # Use subshell to restore pwd.
        (
          cd "${parent_dir}"

          local name=large

          execute_with_echo "wget https://github.com/high-moctane/nextword-data/archive/${name}.tar.gz"
          execute_with_echo "tar xzvf ${name}.tar.gz"
          execute_with_echo "rm -f ${name}.tar.gz"
          execute_with_echo "mv nextword-data-${name} '$(basename "${NEXTWORD_DATA_PATH}")'"
        )
      fi
    else
      echo:warn 'Command `nextword` not found.'
    fi
  }

  local repository
  for repository in "${repositories[@]}"; do
    case "${repository}" in
      cli/cli)
        local plugin="gh"
        ;;
      BurntSushi/ripgrep)
        local plugin="rg"
        ;;
      mvdan/sh)
        local plugin="shfmt"
        ;;
      dbrgn/tealdeer)
        local plugin="tldr"
        ;;
      *)
        local plugin="$(basename "${repository}")"
        ;;
    esac

    local options=(
      from"gh-r"
      as"null"
      id-as"$(dirname "${repository}")---${plugin}-bin"
      atclone"plugin:binary_released:atclone ${repository} ${plugin}"
      atpull"%atclone"
    )

    case "${plugin}" in
      bat | delta | fd | hyperfine | rg | sd | tldr | tokei)
        # Choose musl for legacy environments
        options+=(bpick"*musl*")
        ;;
      gh | glab | golangci-lint)
        options+=(bpick"*.tar.gz")
        ;;
      sqls)
        if [ -n "${SQLS_VERSION}" ]; then
          options+=(ver"${SQLS_VERSION}")
        fi
        ;;
    esac

    zinit ice lucid "${options[@]}"
    zinit light "${repository}"
  done

  unset -f plugin:setup:binary_releaseds
}
zinit ice lucid nocd wait"0c" atload"plugin:setup:binary_releaseds"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-setup-binary_releaseds"

function plugin:mocword:atload {
  function plugin:mocword:data:atclone {
    # cf. exporting MOCWORD_DATA in .zshenv
    mkdir -p "$(dirname "${MOCWORD_DATA:?}")"
    ln -fs "${PWD}/mocword.sqlite" "${MOCWORD_DATA}"
  }
  zinit ice lucid from"gh-r" as"null" bpick"mocword.sqlite.gz" atclone"plugin:mocword:data:atclone"
  zinit light high-moctane/mocword-data
}
zinit ice lucid nocd wait"0c" has"mocword" atload"plugin:mocword:atload"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-mocword-atload"

function plugin:zabrze:reset {
  rm -f "${KG8M_ZSH_CACHE_DIR:?}/zabrze_init"
}

function plugin:zabrze:init {
  if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/zabrze_init" ]; then
    zabrze init --bind-keys > "${KG8M_ZSH_CACHE_DIR}/zabrze_init"
    zcompile "${KG8M_ZSH_CACHE_DIR}/zabrze_init"
  fi
  source "${KG8M_ZSH_CACHE_DIR}/zabrze_init"
}
zinit ice lucid nocd wait"0a" has"zabrze" atload"plugin:zabrze:init"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-zabrze-init"

zinit ice lucid as"completion" mv"zsh_tealdeer -> _tldr"
zinit snippet https://github.com/dbrgn/tealdeer/blob/main/completion/zsh_tealdeer
