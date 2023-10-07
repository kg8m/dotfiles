function plugin:asdf:atclone {
  execute_with_echo "mkdir -p '$(dirname "${ASDF_DIR:?}")'"
  execute_with_echo "mkdir -p '${ASDF_DATA_DIR:?}'"

  if [ ! -f "${ASDF_DIR}" ]; then
    [ -d "${ASDF_DIR}" ] && trash "${ASDF_DIR}"
    ln -s "${PWD}" "${ASDF_DIR}"
  fi

  local plugins=(deno golang nodejs python ruby rust)
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
