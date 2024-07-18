function plugin:setup:binary_releaseds {
  local repositories=(
    rhysd/actionlint
    sharkdp/bat
    mrtazz/checkmake
    cli/cli
    dandavison/delta
    direnv/direnv
    mattn/efm-langserver
    sharkdp/fd
    junegunn/fzf
    profclems/glab
    golangci/golangci-lint
    nametake/golangci-lint-langserver
    sharkdp/hyperfine
    LuaLS/lua-language-server
    itchyny/mmv
    high-moctane/mocword
    sorairolake/qrtool
    BurntSushi/ripgrep
    chmln/sd
    mvdan/sh
    koalaman/shellcheck
    lighttiger2505/sqls
    JohnnyMorganz/StyLua
    dbrgn/tealdeer
    juliosueiras/terraform-lsp
    XAMPPRocky/tokei
    crate-ci/typos
    rhysd/vim-startuptime
    Ryooooooga/zabrze
  )

  # Don't use zinit's options like `as"command" mv"${plugin}* -> ${plugin}" pick"${plugin}/${plugin}"` because it
  # makes the `$PATH` longer and longer. Make symbolic links in `${HOME}/bin` instead.
  #
  # shellcheck disable=SC2317
  function plugin:binary_released:atclone {
    local repository="${1:?}"
    local plugin="${2:?}"
    local plugin_id="${3:?}"

    echo >&2
    echo:info "URL: https://github.com/${repository}"
    echo >&2

    case "${plugin}" in
      qrtool)
        execute_with_echo "tar --extract --use-compress-program unzstd --file qrtool-*.tar.zst"
        execute_with_echo "rm -f qrtool-*.tar.zst"
        ;;
    esac

    case "${plugin}" in
      actionlint | bat | checkmake | delta | direnv | efm-langserver | fd | gh | glab | golangci-lint | hyperfine |\
      mmv | mocword | qrtool | sd | shellcheck | shfmt | terraform-lsp | typos | vim-startuptime | zabrze)
        mv ./"${plugin}"* ./"${plugin}"
        ;;
      rg)
        mv ./ripgrep* ./"${plugin}"
        ;;
      tldr)
        mv ./tealdeer* ./"${plugin}"
        ;;
      fzf | golangci-lint-langserver | lua-language-server | sqls | stylua | tokei)
        # Do nothing
        ;;
      *)
        echo:error "Unknown plugin to move files: ${plugin}"
        return 1
        ;;
    esac

    case "${plugin}" in
      actionlint | checkmake | direnv | fzf | golangci-lint-langserver | mocword | shfmt | sqls | stylua |\
      terraform-lsp | tldr | tokei | typos | vim-startuptime | zabrze)
        local binary="${plugin}"
        ;;
      bat | delta | efm-langserver | fd | golangci-lint | hyperfine | mmv | qrtool | rg | sd | shellcheck)
        local binary="${plugin}/${plugin}"
        ;;
      gh)
        local binary="${plugin}/bin/${plugin}"
        ;;
      glab | lua-language-server)
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

    case "${plugin}" in
      lua-language-server)
        # Don’t use a symbolic link for preventing the `lua-language-server: cannot open (bootstrap.lua): No such file
        # or directory` error.
        execute_with_echo "echo '${PWD}/${binary} \"\$@\"' > '${HOME}/bin/${command}'"
        execute_with_echo "chmod +x '${HOME}/bin/${command}'"
        ;;
      *)
        execute_with_echo "ln -s '${PWD}/${binary}' '${HOME}/bin/${command}'"
        ;;
    esac

    execute_with_echo "which ${command}"
    execute_with_echo "fd --type l --type x --glob '${command}' '${(j:' ':)path}'"

    case "${plugin}" in
      bat | checkmake | delta | direnv | fd | fzf | gh | glab | hyperfine | lua-language-server | mmv | mocword |\
      qrtool | rg | sd | shellcheck | stylua | tldr | tokei | typos | zabrze)
        execute_with_echo "${command} --version"
        ;;
      efm-langserver)
        execute_with_echo "${command} -v"
        ;;
      actionlint | shfmt | sqls)
        execute_with_echo "${command} -version"
        ;;
      golangci-lint)
        execute_with_echo "${command} version"
        ;;
      golangci-lint-langserver | vim-startuptime)
        execute_with_echo "${command} -h"
        ;;
      terraform-lsp)
        echo >&2
        echo:info "Skip checking version or showing help because there are no ways."
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
      zabrze)
        execute_with_echo "plugin:zabrze:reset"
        execute_with_echo "plugin:zabrze:init"
        ;;
      *)
        # Do nothing.
        ;;
    esac

    [ -n "$(find . -type f -name '_*')" ] && execute_with_echo "zinit creinstall ${plugin_id}"

    echo >&2
    echo:info "Done."

    # Echo empty lines because refreshing prompt by zinit clears the last few lines.
    echo >&2
    echo >&2
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
      JohnnyMorganz/StyLua)
        local plugin="stylua"
        ;;
      dbrgn/tealdeer)
        local plugin="tldr"
        ;;
      *)
        local plugin="$(basename "${repository}")"
        ;;
    esac

    local plugin_id="$(dirname "${repository}")/${plugin}-bin"
    local options=(
      from"gh-r"
      as"null"
      id-as"${plugin_id}"
      atclone"plugin:binary_released:atclone ${repository} ${plugin} ${plugin_id}"
      atpull"%atclone"
    )

    zinit ice lucid "${options[@]}"
    zinit light "${repository}"
  done

  unset -f plugin:setup:binary_releaseds
}
zinit ice lucid nocd wait"0c" atload"plugin:setup:binary_releaseds"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-setup-binary_releaseds"

function plugin:mocword:atload {
  # shellcheck disable=SC2317
  function plugin:mocword:data:atclone {
    # cf. exporting MOCWORD_DATA in .zshenv
    mkdir -p "$(dirname "${MOCWORD_DATA:?}")"
    execute_with_echo "ln -fs '${PWD}/mocword.sqlite' '${MOCWORD_DATA}'"
  }
  zinit ice lucid from"gh-r" as"null" bpick"mocword.sqlite.gz" atclone"plugin:mocword:data:atclone"
  zinit light high-moctane/mocword-data
}
zinit ice lucid nocd wait"0c" has"mocword" atload"plugin:mocword:atload"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-mocword-atload"

function plugin:zabrze:reset {
  rm -f "${XDG_CACHE_HOME:?}/zsh/zabrze_init.zsh"
}

function plugin:zabrze:init {
  if [ ! -f "${XDG_CACHE_HOME:?}/zsh/zabrze_init.zsh" ]; then
    zabrze init --bind-keys > "$(ensure_dir "${XDG_CACHE_HOME}/zsh/zabrze_init.zsh")"

    # cf. zsh:rcs:compile() and zsh:rcs:compile:clear()
    zcompile "${XDG_CACHE_HOME}/zsh/zabrze_init.zsh"
  fi
  source "${XDG_CACHE_HOME}/zsh/zabrze_init.zsh"
}
zinit ice lucid nocd wait"0a" has"zabrze" atload"plugin:zabrze:init"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-zabrze-init"

zinit ice lucid as"completion" mv"zsh_tealdeer -> _tldr"
zinit snippet https://github.com/dbrgn/tealdeer/blob/main/completion/zsh_tealdeer
