function tools:upgrade:check {
  execute_with_echo mise plugins update

  # Execute `echo` because the output of `mise plugins update` lacks a trailing newline.
  echo

  # Execute `mise outdated` before `mise ls` to show “(outdated)” annotations on the result of `mise ls`.
  execute_with_echo mise outdated
  execute_with_echo mise ls
}

function tools:install:latest {
  local tool="${1:?}"
  local command_array=()

  if [ -n "${COSTOM_LATEST_INSTALLATION_TOOLS[*]:-}" ] &&
     [ ! "${COSTOM_LATEST_INSTALLATION_TOOLS[(I)${tool}]}" = "0" ]; then

    echo:error "${tool} needs a custom installation process."
    return 1
  fi

  case "${tool}" in
    postgres)
      # https://github.com/smashedtoatoms/asdf-postgres/issues/77#issuecomment-1869649473
      command_array+=(PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig")
      ;;
  esac

  command_array+=(mise install "${tool}@latest")
  execute_with_echo "${command_array[@]}"
  echo

  execute_with_echo mise ls "${tool}"
}
