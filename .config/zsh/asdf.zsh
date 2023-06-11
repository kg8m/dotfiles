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
    execute_with_echo "asdf global ${plugin} latest"

    case "${plugin}" in
      python)
        if ! command -v python2 > /dev/null; then
          echo:info 'Install Python 2.x.y and setup with `asdf global latest 2.x.y`'
        fi
        ;;
    esac
  done

  execute_with_echo "asdf list"
}

zinit ice lucid wait"0c" as"null" atclone"plugin:asdf:atclone"
zinit light asdf-vm/asdf
