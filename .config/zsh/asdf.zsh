function plugin:asdf:atclone {
  execute_with_echo "mkdir -p '$(dirname "${ASDF_DIR:?}")'"
  execute_with_echo "mkdir -p '${ASDF_DATA_DIR:?}'"

  if [ ! -f "${ASDF_DIR}" ]; then
    [ -d "${ASDF_DIR}" ] && trash "${ASDF_DIR}"
    ln -s "${PWD}" "${ASDF_DIR}"
  fi

  local plugins=(deno golang nodejs python ruby rust terraform)
  local plugin
  for plugin in "${plugins[@]}"; do
    if asdf plugin-list | grep -E "^${plugin}$" -q; then
      continue
    fi

    execute_with_echo "asdf plugin add ${plugin}"
    execute_with_echo "asdf install ${plugin} latest"

    case "${plugin}" in
      python)
        local older_latest="$(asdf list all python | grep -E '^2\.' | tail -n1)"
        execute_with_echo "asdf install ${plugin} ${older_latest}"
        execute_with_echo "asdf global ${plugin} latest ${older_latest}"
        ;;
      *)
        execute_with_echo "asdf global ${plugin} latest"
        ;;
    esac
  done

  execute_with_echo "asdf list"
}

zinit ice lucid wait"0c" as"null" atclone"plugin:asdf:atclone"
zinit light asdf-vm/asdf

function asdf:plugins:upgrade:check {
  # shellcheck disable=SC2317
  function asdf:plugins:upgrade:check:do {
    local plugin="${1:?}"
    shift 1

    local local_latest="$(asdf list "${plugin}" "$@" | tail -n1 | sd '^\s*\*?' '')"
    local remote_latest="$(asdf latest "${plugin}" "$@")"

    plugin="$(printf '%-10s' "${plugin}")"
    local_latest="$(printf '%-10s' "${local_latest}")"
    remote_latest="$(printf '%-10s' "${remote_latest}")"

    if [ ! "${local_latest}" = "${remote_latest}" ]; then
      remote_latest="$(highlight:yellow "${remote_latest}")"
    fi

    echo "${plugin} local ${local_latest} remote ${remote_latest}"
  }

  local plugins=("${(@f)$(asdf plugin list)}")
  local plugin
  for plugin in "${plugins[@]}"; do
    asdf:plugins:upgrade:check:do "${plugin}"

    if [ "${plugin}" = "python" ]; then
      asdf:plugins:upgrade:check:do "${plugin}" "2"
    fi
  done
}
