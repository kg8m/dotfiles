function tools:upgrade:check {
  # Execute `mise outdated` before `mise ls` to show “(outdated)” annotations on the result of `mise ls`.
  execute_with_echo mise outdated
  execute_with_echo mise ls
}

function tools:install:latest {
  local tool="${1:?}"
  local command_array=()

  case "${tool}" in
    postgres)
      # https://github.com/smashedtoatoms/asdf-postgres/issues/77#issuecomment-1869649473
      command_array+=(PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig")
      ;;
  esac

  command_array+=(mise install "${tool}@latest")
  execute_with_echo "${command_array[@]}"
  echo

  case "${tool}" in
    python)
      execute_with_echo mise install "python@2"
      echo
      ;;
  esac

  execute_with_echo mise ls "${tool}"
}
