function plugin:asdf:atclone {
  execute_with_echo "mkdir -p '$(dirname "${ASDF_DIR:?}")'"
  execute_with_echo "mkdir -p '${ASDF_DATA_DIR:?}'"

  if [ ! -f "${ASDF_DIR}" ]; then
    [ -d "${ASDF_DIR}" ] && trash "${ASDF_DIR}"
    ln -s "${PWD}" "${ASDF_DIR}"
  fi

  local plugins=(golang nodejs python ruby)
  local plugin
  for plugin in "${plugins[@]}"; do
    execute_with_echo "asdf plugin add ${plugin}"

    case "${plugin}" in
      python)
        if ! command -v python2 > /dev/null; then
          echo:info 'Install Python 2.x.y and setup with `asdf global latest 2.x.y`'
        fi
        ;;
    esac
  done

  execute_with_echo "asdf plugin-list"
}

function plugin:asdf:atload {
  # https://github.com/asdf-vm/asdf/blob/788ccab5971cb828cf25364b0df5ed6f5e9e713d/asdf.sh#L35
  source lib/asdf.sh
}

zinit ice lucid wait"0c" as"null" atclone"plugin:asdf:atclone" atload"plugin:asdf:atload"
zinit light asdf-vm/asdf
