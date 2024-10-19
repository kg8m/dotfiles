# Overwrite this function for private networks.
function aws:network:verify {
  return 0
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/start-query.html
# https://docs.aws.amazon.com/cli/latest/reference/logs/get-query-results.html
function aws:logs:query {
  function _aws:logs:query:help {
    cat <<- HELP
aws:logs:query {parameters}

  *Parameter*     *Required?*  *Default*   *Note*  *Example*
  --profile       required                         --profile 'default'
  --start-time    required                 JST     --start-time '2022-02-02 02:00:00'
  --end-time      required                 JST     --end-time '2022-02-02 02:00:00'
  --filter        required                         --filter '@logStream in ["foo", "bar"]'
  --limit         optional     1000                --limit 100
  --group-name    optional     (Select)            --group-name example_group

See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html for query syntaxes.
HELP
  }

  local limit="1000"
  local group_name=""
  local executor="execute_with_confirm"
  local pager="| less"

  while (("${#@}" > 0)); do
    case "$1" in
      --profile)
        local profile="${2:?}"
        shift 2
        ;;
      --start-time)
        local start_time="${2:?}"
        shift 2
        ;;
      --end-time)
        local end_time="${2:?}"
        shift 2
        ;;
      --filter)
        local filter="${2:?}"
        shift 2
        ;;
      --limit)
        limit="${2:?}"
        shift 2
        ;;
      --group-name)
        group_name="${2:?}"
        shift 2
        ;;

      # Undocumented options
      --force | --no-confirm | --yes)
        executor="execute_with_echo"
        shift 1
        ;;
      --no-pager)
        pager=""
        shift 1
        ;;
      -h | --help)
        _aws:logs:query:help
        return 0
        ;;
      *)
        echo:error "Unknown option/argument: $1"
        _aws:logs:query:help
        return 1
        ;;
    esac
  done

  if [ -z "${profile}" ] || [ -z "${start_time}" ] || [ -z "${end_time}" ] || [ -z "${filter}" ]; then
    _aws:logs:query:help
    return 1
  fi

  aws:network:verify || return 1
  aws-sso-verify-session "${profile}" || return 1

  if [ -z "${group_name}" ]; then
    group_name="$(_aws:logs:select_group "${profile}")"
  fi

  if [ -z "${group_name}" ]; then
    echo:error "No log group name specified."
    return 1
  fi

  local query_options=(
    --profile "${profile}"
    --log-group-name "${group_name}"
    --start-time "$(($(date -j -f '%F %T' "${start_time}" '+%s') * 1000))"
    --end-time "$(($(date -j -f '%F %T' "${end_time}" '+%s') * 1000))"

    # `+ 9 * 60 * 60 * 1000` converts the UTC timestamp to JST.
    # The JST @timestamp and @message will be returned by `aws logs get-query-results` and be parsed by `jq` later.
    --query-string "filter ${filter} | sort @timestamp | display @timestamp + 9 * 60 * 60 * 1000, @message"

    --limit "${limit}"
  )
  local outpath="/tmp/aws-logs-query-result-$(date '+%Y%m%d-%H%M%S').txt"

  local started_at="$(date '+%s')"
  local query_id="$("${executor}" aws logs start-query "${query_options[@]}" | jq --raw-output '.queryId')"

  if [ -z "${query_id}" ]; then
    # Canceled.
    return
  fi

  local result_options=(
    --profile "${profile}"
    --query-id "${query_id}"
  )

  function _aws:logs:query:status {
    aws logs get-query-results "$@" --query "status" | jq --raw-output
  }

  function _aws:logs:query:result {
    # The timestamp and data were specified in the `--query-string` of `aws logs start-query`.
    aws logs get-query-results "$@" --query "results" |
      jq --compact-output ".[] | { timestamp: .[0].value, data: (.[1].value | fromjson) }"
  }

  sleep 1
  while [ "$(_aws:logs:query:status "${result_options[@]}")" = "Running" ]; do
    echo:info "Waiting..."
    sleep 1
  done

  local fixed_status="$(_aws:logs:query:status "${result_options[@]}")"

  if [ "${fixed_status}" = "Complete" ]; then
    _aws:logs:query:result "${result_options[@]}" > "${outpath}"
  else
    echo:error "status: ${fixed_status}"
    echo:error "Run \`aws logs get-query-results ${result_options[*]}\` if needed."
    return 1
  fi

  local finished_at="$(date '+%s')"
  local notifier_options=(--title "aws:logs:query")

  if ((finished_at - started_at < 15)); then
    notifier_options+=(--nostay)
  fi

  local notifier_args="$(printf "%q " "Querying has been completed." "${notifier_options[@]}")"
  async_stop_worker  "AWS_LOGS_QUERY_NOTIFIER_$$" 2> /dev/null
  async_start_worker "AWS_LOGS_QUERY_NOTIFIER_$$"
  async_job          "AWS_LOGS_QUERY_NOTIFIER_$$" "notify ${notifier_args}"

  eval_with_echo jq --color-output . "${(q-)outpath}" "${pager}"
  echo
  echo:info "See the result in \`${outpath}\`."
  echo:info "Stats: $(aws logs get-query-results "${result_options[@]}" --query statistics)"
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/describe-log-groups.html
function _aws:logs:select_group {
  local profile="${1:?}"

  aws logs describe-log-groups --profile "${profile}" --output json |
    jq '.logGroups[].logGroupName' --raw-output |
    filter --preview-window "hidden" --prompt "Select a log group> " --no-multi
}

# https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html
function plugin:aws:sessionmanager:atclone {
  execute_with_echo sudo installer -pkg session-manager-plugin.pkg -target /
  execute_with_echo sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
  execute_with_echo session-manager-plugin
}
zinit ice lucid wait"0c" as"null" atclone"plugin:aws:sessionmanager:atclone" atpull"%atclone"
zinit snippet https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg
