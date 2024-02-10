source ~/.config/zsh/utility-functions.zsh

function git:add:bulk {
  local files=("${(@f)$(git:status:filter:unstaged:with_untracked)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo    "git add --intent-to-add -- ${files[*]}"
    execute_with_echo    "git diff -- ${files[*]}"
    execute_with_confirm "git add -- ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:add:bulk:intent {
  local files=("${(@f)$(git:status:filter:untracked)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo "git add --intent-to-add -- ${files[*]}"
    execute_with_echo "git status-with-color"
  fi
}

function git:add:bulk:patch {
  local files=("${(@f)$(git:status:filter:unstaged:with_intended_to_add)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo "git add --patch -- ${files[*]}"
    execute_with_echo "git status-with-color"
  fi
}

function git:restore:bulk {
  local files=("${(@f)$(git:status:filter:unstaged)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo    "git diff -R -- ${files[*]}"
    execute_with_confirm "git restore -- ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:restore:bulk:patch {
  local files=("${(@f)$(git:status:filter:unstaged)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo "git restore --patch -- ${files[*]}"
    execute_with_echo "git status-with-color"
  fi
}

function git:restore:bulk:staged {
  local files=("${(@f)$(git:status:filter:staged)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo    "git diff --staged -R -- ${files[*]}"
    execute_with_confirm "git restore --staged -- ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:restore:bulk:staged:patch {
  local files=("${(@f)$(git:status:filter:staged)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo "git restore --staged --patch -- ${files[*]}"
    execute_with_echo "git status-with-color"
  fi
}

function git:switch:select {
  local current="$(git branch --show-current)"
  local branch="$(
    git:branch:list --all |
      grep -E -v "^${current} " |
      git:branch:filter:single
  )"

  [ -n "${branch}" ] && execute_with_echo "git switch ${branch}"
}

function git:switch:main {
  if git branch --contains main > /dev/null 2>&1; then
    git switch main
  else
    git switch master
  fi
}

function git:update:with_log {
  local remote_branch="$(git rev-parse --abbrev-ref '@{upstream}')"

  execute_with_echo "git --no-pager show --no-patch"
  execute_with_echo "git fetch"

  if [ "$(git rev-parse HEAD)" = "$(git rev-parse '@{upstream}')" ]; then
    echo "Up to date."
  else
    execute_with_echo "git --no-pager log --reverse HEAD... ${remote_branch}"
    execute_with_echo "git pull --stat"
    execute_with_echo "git status-with-color"
  fi
}

function git:update:shallow {
  execute_with_echo "git pull --depth 100"
}

function git:update:main {
  local current_branch="$(git branch --show-current)"

  execute_with_echo "git switch-to-main"

  if [[ "$(git branch --show-current)" =~ ^(main|master)$ ]]; then
    execute_with_echo "git update"
    execute_with_echo "git switch ${current_branch}"
    execute_with_echo "git branches | head -n15"
  else
    echo:error "Switching branch failed."
    return 1
  fi
}

function git:branch:create:with_set_upstream {
  if git status --porcelain | grep -E '^[^ ?]' -q; then
    echo:error "Staged changes exist. Unstage them before creating a branch."
    return 1
  fi

  local original_branch="${1:?Specify the original branch name.}"
  local branch_name="${2:?Specify a new branch name.}"
  local commit_message="${3:-create branch}"

  # shellcheck disable=SC2034
  local commands=(
    "execute_with_echo 'git switch --create ${branch_name} ${original_branch}'"
    "execute_with_echo 'git commit --allow-empty --message=\"${commit_message}\"'"
    "execute_with_echo 'git push --set-upstream origin ${branch_name}'"
  )

  execute_with_confirm "${(j: && :)commands}; execute_with_echo 'git branches | head -n15'"
}

function git:branch:delete:bulk:local {
  local current="$(git branch --show-current)"
  local branches=("${(@f)$(
    git:branch:list |
      grep -E -v "^${current} |${GIT_PROTECTED_LOCAL_BRANCH_PATTERN}" |
      git:branch:filter
  )}")

  if [ -n "${branches[*]}" ]; then
    execute_with_confirm "git branch --delete --force ${branches[*]}"
    execute_with_echo    "git branches | head -n15"
  else
    echo "No target branches."
  fi
}

function git:branch:delete:bulk:remote {
  local branches=("${(@f)$(
    git:branch:list --remote |
      grep -E -v "${GIT_PROTECTED_REMOTE_BRANCH_PATTERN}" |
      git:branch:filter
  )}")

  if [ -n "${branches[*]}" ]; then
    execute_with_confirm "git push --delete origin ${branches[*]}"
    execute_with_echo    "git branches | head -n15"
  else
    echo "No target branches."
  fi
}

function git:branch:filter {
  local options=(
    --prompt="Select branches> "
    --preview="git sh \"git:utility:preview:log {1}\""
    --preview-window="down:75%:wrap:nohidden"
    "$@"
  )

  filter "${options[@]}" | awk '{ print $1 }'
}

function git:branch:filter:single {
  local options=("$@")
  local branches=("${(@f)$(
    git:branch:filter --no-multi --prompt="Select a branch> " "${options[@]}"
  )}")

  if [ ${#branches} -ne 1 ] || [ -z "${branches[1]}" ]; then
    echo:error "Select a branch."; exit 1
  else
    echo "${branches[1]}"
  fi
}

function git:branch:list {
  local SEP="$(git:branch:list_format_separator)"

  git branch --format "$(git:branch:list_format)" "$@" |
    sd "\s*${SEP}\s*" "${SEP}" |
    sd '^origin/' '' |
    grep -E -v "^(HEAD|origin)${SEP}" |
    git:proxy:column "${SEP}" |
    awk '!x[$1]++' |  # Remove duplicated branches
    colrm "$((COLUMNS + 1))" |
    git:branch:colorize
}

function git:branch:list:all {
  local SEP="$(git:branch:list_format_separator)"

  git branch --all --format "%(HEAD) $(git:branch:list_format)" "$@" |
    sd "\s*${SEP}\s*" "${SEP}" |
    grep -E -v "^\s+origin/HEAD${SEP}" |
    git:proxy:column "${SEP}" |
    colrm "$((COLUMNS + 1))" |
    git:branch:colorize
}

function git:branch:list_format {
  local SEP="$(git:branch:list_format_separator)"
  # shellcheck disable=SC2034
  local items=(
    "%(refname:short)"
    "%(objectname:short)"
    "%(authorname)"
    "%(authordate:short)"
    "%(contents:subject)"
  )

  # shellcheck disable=SC2250
  echo "${(pj:$SEP:)items}"
}

function git:branch:list_format_separator {
  echo "💩"
}

function git:branch:colorize {
  local USER_NAME="$(git config user.name)"

  sd "\b(${USER_NAME})"     "$(highlight:pink '$1')" |                 # Highlight my names
  sd '^(\s+)(origin/[^ ]+)' "\$1$(highlight:green '$2' --no-bold)" |   # Highlight remote branches
  sd '^(\s+)([^ ]+)'        "\$1$(highlight:yellow '$2' --no-bold)" |  # Highlight local branches
  sd '^\* ([^ ]+)'          "* $(highlight:red '$1' --bg)"             # Highlight the current branch
}

function git:clone:shallow {
  execute_with_echo "git clone --depth 100 $*"
}

function git:clone:partial:blobless {
  execute_with_echo "git clone --filter blob:none $*"
}

function git:clone:partial:treeless {
  execute_with_echo "git clone --filter tree:0 $*"
}

function git:commit:bulk {
  local files=("${(@f)$(git:status:filter:all)}")

  if [ -n "${files[*]}" ]; then
    execute_with_echo    "git commit --dry-run -- ${files[*]} | git pager"
    execute_with_confirm "git commit -- ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:push:revision {
  local revision="${1:?Specify a revision.}"
  local branch="$(git branch --show-current)"

  git push origin "${revision}:refs/heads/${branch}"
}

function git:clean:bulk {
  local files=("${(@f)$(git:status:filter:untracked)}")

  if [ -n "${files[*]}" ]; then
    preview "${files[@]}"
    execute_with_confirm "git clean --force -- ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:trash:bulk {
  local files=("${(@f)$(git:status:filter:untracked)}")

  if [ -n "${files[*]}" ]; then
    preview "${files[@]}"
    execute_with_confirm "trash ${files[*]}"
    execute_with_echo    "git status-with-color"
  fi
}

function git:log:select {
  function git:log:select:pick:hash {
    # cf. `{commit:<15}` of `delta.blame-format`
    # cf. `--abbrev=14` of `git log-graph`
    # cf. `git blame --abbrev=13` in `git:blame:filter`
    local find_hash="grep -E '[a-z0-9]{14,}' -o | head -n1"
    local filter_options=(
      --no-multi
      --prompt "Select a commit> "
      --header "NOTE: You will choose an action in the next step."
      --preview "hash=\$(echo {} | ${find_hash}); [ -n \"\${hash}\" ] && git show --patch-with-stat \${hash} | delta"
      --preview-window 'down:50%:wrap:nohidden'
    )

    git log-graph --color | filter "${filter_options[@]}" | eval "${find_hash}"
  }

  function git:log:select:pick:action {
    local hash="${1:?}"
    local actions=(Copy Rebase Show)
    local filter_options=(
      --no-multi
      --prompt "Select an action> "
      --preview "git show ${hash} | delta"
      --preview-window "down:75%:wrap:nohidden"
    )

    printf "%s\n" "${actions[@]}" | filter "${filter_options[@]}"
  }

  local abbr_hash="$(git:log:select:pick:hash)"

  if [ -n "${abbr_hash}" ]; then
    local full_hash="$(git rev-parse "${abbr_hash}")"
  else
    return
  fi

  local action="$(git:log:select:pick:action "${full_hash}")"

  if [ -z "${action}" ]; then
    return
  fi

  case "${action}" in
    Copy)
      printf "%s" "${full_hash}" | ssh main -t pbcopy

      local message="Copied: ${full_hash}"
      notify --nostay "${message}" &
      echo "${message}"
      ;;
    Rebase)
      execute_with_confirm "git rebase --autosquash --interactive ${full_hash}"
      ;;
    Show)
      execute_with_echo "git show --patch-with-stat ${full_hash}"
      ;;
    *)
      echo:error "Unknown action: ${action}"
      return 1
      ;;
  esac
}

function git:log:compare:branch {
  local branch1=$(git:branch:list --remote | git:branch:filter:single --prompt="Select first branch> ")
  [ -n "${branch1}" ] || exit 1

  local branch2=$(git:branch:list --remote | git:branch:filter:single --prompt="Select another branch> ")
  [ -n "${branch2}" ] || exit 1

  execute_with_confirm "git log $* origin/${branch1}...origin/${branch2}"
}

function git:diff:branch {
  local branch1=$(git:branch:list --remote | git:branch:filter:single --prompt="Select first branch> ")
  [ -n "${branch1}" ] || exit 1

  local branch2=$(git:branch:list --remote | git:branch:filter:single --prompt="Select another branch> ")
  [ -n "${branch2}" ] || exit 1

  execute_with_confirm "git diff-without-space-changes $* origin/${branch1}...origin/${branch2}"
}

function git:diff:branch:from {
  local target="${1:?Specify a branch name, e.g., "main".}"
  local options=()
  local pathspecs=()

  local item
  for item in "${@[2,-1]}"; do
    if [ "${item}" = "--" ] || [ "${#pathspecs}" -gt 0 ]; then
      pathspecs+=("${item}")
    else
      options+=("${item}")
    fi
  done

  execute_with_confirm "git diff-without-space-changes ${options[*]} origin/${target}... ${pathspecs[*]}"
}

function git:diff:branch:from:nameonly {
  git:diff:branch:from "$1" --name-only "${@[2,-1]}"
}

function git:stash:all:with_message {
  # Make all changes staged before `git stash` instead of using `--include-untracked` option. Untracked files stashed
  # with `--include-untracked` aren't shown in diffs, i.e., `git diff ...stash@{0}` doesn't contain the untracked files.
  execute_with_confirm "git add --all && git stash push --no-keep-index --message '$*'"
}

function git:stash:select {
  function git:stash:select:pick:stash {
    local stash_options=(
      --color

      # %an = author name
      # %ci = committer date, ISO 8601-like format
      # %gd = shortened reflog selector; same as %gD, but the refname portion is shortened for human readability (so
      #       refs/heads/master becomes just master).
      # %s  = subject
      --format="%gd %C(cyan)%ci %C(green bold)%an  %C(reset)%s"
    )
    local filter_options=(
      --no-multi
      --prompt "Select a stash> "
      --header "NOTE: You will choose an action in the next step."
      --preview "git stash show {1} | delta"
      --preview-window "down:75%:wrap:nohidden"
    )

    git stash list "${stash_options[@]}" | filter "${filter_options[@]}" | awk '{ print $1 }'
  }

  function git:stash:select:pick:action {
    local stash="${1:?}"
    local actions=(Apply Drop)
    local filter_options=(
      --no-multi
      --prompt "Select an action> "
      --preview "git stash show ${stash} | delta"
      --preview-window "down:75%:wrap:nohidden"
    )

    printf "%s\n" "${actions[@]}" | filter "${filter_options[@]}"
  }

  local stash="$(git:stash:select:pick:stash)"

  if [ -z "${stash}" ]; then
    return
  fi

  local action="$(git:stash:select:pick:action "${stash}")"

  if [ -z "${action}" ]; then
    return
  fi

  case "${action}" in
    Apply)
      execute_with_echo "git stash apply ${stash}"
      ;;
    Drop)
      execute_with_echo    "git stash show ${stash}"
      execute_with_confirm "git stash drop ${stash}"
      ;;
    *)
      echo:error "Unknown action: ${action}"
      return 1
      ;;
  esac
}

function git:status:color {
  local local_branch="$(git branch --show-current)"
  local local_branch_message_prefix="On branch"
  local local_branch_pattern="^${local_branch_message_prefix} ${local_branch}$"
  local local_branch_replace="${local_branch_message_prefix} $(highlight:magenta "${local_branch}")"

  local remote_branch="$(git for-each-ref --format="%(upstream:short)" "$(git symbolic-ref -q HEAD)")"
  local remote_branch_message_prefix="Your branch is"
  local remote_branch_pattern="^(${remote_branch_message_prefix} .+) '${remote_branch}'(.+)$"
  local remote_branch_replace="\$1 '$(highlight:magenta "${remote_branch}")'\$2"

  local ok_message="nothing to commit, working tree clean"
  local ok_pattern="^${ok_message}$"
  local ok_replace="$(highlight:green "${ok_message}")"

  git -c color.status=always status "$@" |
    sd "${local_branch_pattern}" "${local_branch_replace}" |
    sd "${remote_branch_pattern}" "${remote_branch_replace}" |
    sd "${ok_pattern}" "${ok_replace}"
}

# SC2120: references arguments, but none are ever passed.
# shellcheck disable=SC2120
function git:status:filter:all {
  git status --short "$@" | git:status:utility:filter
}

function git:status:filter:staged {
  # `^ A` for intent-to-add
  git status --short | grep -E '^[^ ?]|^ A' | git:status:utility:filter | git:status:utility:rename:only_removed
}

function git:status:filter:unstaged {
  git status --short | grep -E '^[^?][^ A]' | git:status:utility:filter | git:status:utility:rename:only_added
}

function git:status:filter:unstaged:with_intended_to_add {
  git status --short | grep -E '^[^?][^ ]' | git:status:utility:filter | git:status:utility:rename:only_added
}

function git:status:filter:unstaged:with_untracked {
  git status --short | grep -E '^.[^ ]' | git:status:utility:filter | git:status:utility:rename:only_added
}

function git:status:filter:untracked {
  git status --short | grep -E '^\?\?' | git:status:utility:filter
}

function git:status:utility:filter {
  local filter_options=(
    --prompt "Select files> "

    # Use `{2..}` instead of `{2}` for filepaths that contain whitespaces.
    --preview "git diff-or-cat {2..}"

    --preview-window "down:75%:wrap:nohidden"
  )

  filter "${filter_options[@]}" | sd '^..\s' ''
}

function git:status:utility:rename:only_added {
  sd '^.+ -> ' ''
}

function git:status:utility:rename:only_removed {
  sd ' -> .+$' ''
}

function git:submodule:update {
  execute_with_echo "git submodule update --remote --rebase"
  execute_with_echo "git status-with-color"
}

function git:submodule:remove:bulk {
  local targets=("${(@f)$(git submodule | filter | awk '{ print $2 }')}")
  local target

  if [ -n "${targets[*]}" ]; then
    for target in "${targets[@]}"; do
      execute_with_confirm "git submodule deinit ${target}"
      execute_with_confirm "git rm ${target}"
      execute_with_confirm "trash ${target}"
    done
  fi
}

function git:submodule:deinit:bulk {
  local targets=("${(@f)$(git submodule | filter | awk '{ print $2 }')}")
  local target

  if [ -n "${targets[*]}" ]; then
    for target in "${targets[@]}"; do
      execute_with_confirm "git submodule deinit -f ${target}"
      execute_with_confirm "rm -r ./git/modules/${target}"
      execute_with_confirm "trash ${target}/*"
      execute_with_confirm "trash ${target}/.*"
    done
  fi
}

function git:alias:list {
  git config --get-regexp '^alias\.' |
    sd 'alias\.([^ ]*) (.*)' '$1\t => $2'
}

function git:alias:which {
  local command="${1:?Specify a command name.}"
  local result="$(git:alias:list | grep -E "^${command}\s+" | sd '\s+' ' ')"
  echo "${result}"

  if [[ "${result}" =~ \ sh\ [\"\']?git:[a-z_:]+ ]]; then
    echo
    # shellcheck disable=SC2230
    which "$(echo "${result}" | grep -E -o '\bgit:[a-z_:]+')"
  else
    local original="$(echo "${result}" | grep -E -o '=> [-a-z]+' | sd '=> ' '')"

    if git:alias:list | grep -q -E "^${original}\s+"; then
      echo
      git:alias:which "${original}"
    fi
  fi
}

function git:utility:chmod {
  local permissions="${1:?Specify permissions.}"
  execute_with_echo "git update-index --add --chmod=${permissions}"
}

function git:utility:diff_or_cat {
  local filepath="${1:?Specify a filepath.}"

  # Remove quotation marks around the filepath.
  if [[ "${filepath}" =~ ^\" ]] && [[ "${filepath}" =~ \"$ ]]; then
    local offset="1"
    local length="$((${#filepath} - 2))"
    filepath="${filepath:${offset}:${length}}"
  fi

  local git_status="$(git status --short -- "${filepath}")"

  if [[ "${git_status}" =~ ^D ]]; then
    local renamed_status="$(git status --short | grep -E '^R' | grep -F " ${filepath} ->")"

    if [ -n "${renamed_status}" ]; then
      git_status="${renamed_status}"
    fi
  fi

  # Untracked files
  if [[ "${git_status}" =~ '^\?\?' ]]; then
    preview "${filepath}"
  # Renamed files
  elif [[ "${git_status}" =~ ^R ]]; then
    local removed="${filepath}"
    local added="${git_status#* -> }"
    local renamed_diff="$(git:utility:diff --staged -- "${removed}" "${added}")"

    if [[ "${git_status}" =~ ^R[A-Z] ]]; then
      git:utility:header "Not Staged"
      git:utility:diff -- "${added}"
      echo
      git:utility:header "Staged"
      echo "${renamed_diff}"
    else
      echo "${renamed_diff}"
    fi
  # Partially staged files
  elif [[ "${git_status}" =~ ^[A-Z]{2} ]]; then
    git:utility:header "Not Staged"
    git:utility:diff -- "${filepath}"
    echo
    git:utility:header "Staged"
    git:utility:diff --staged -- "${filepath}"
  # Staged files
  elif [[ "${git_status}" =~ ^[A-Z] ]]; then
    git:utility:diff --staged -- "${filepath}"
  # Others: unstaged tracked files
  else
    git:utility:diff -- "${filepath}"
  fi
}

function git:utility:header {
  local border="$(printf "%s" "${(r:${COLUMNS} / 3::-:)}")"

  printf "\e[1m"
  printf "%s\n" "${border}"
  printf "%s\n" "$@"
  printf "%s\n" "${border}"
  printf "\e[0m"
}

function git:utility:diff {
  git diff-without-space-changes --color=always "$@" | git pager
}

function git:utility:preview:log {
  local branch="${1:?Specify a branch name.}"
  local local_timestamp="$(git show --pretty='format:%at' --no-patch "${branch}" 2>/dev/null)"
  local remote_timestamp="$(git show --pretty='format:%at' --no-patch "origin/${branch}" 2>/dev/null)"

  if [ -n "${remote_timestamp}" ]; then
    if [ -z "${local_timestamp}" ] || ((remote_timestamp > local_timestamp)); then
      branch="origin/${branch}"
    fi
  fi

  git log --max-count=100 --color=always "${branch}"
}

# Use short options like `-t` or `-s` because BSD `column` command doesn't support long options like `--table` or
# `--separator`.
# The local variable `dummy` is for newer `column` command. Newer `column` command removes leading whitespaces. So
# prevent it by putting a dummy text on the top of each line.
function git:proxy:column {
  local separator="${1:?}"
  local dummy="@"

  sd '^(.)' "${dummy}\$1" |
    column -t -s "${separator}" |
    sd "^${dummy}" ''
}
