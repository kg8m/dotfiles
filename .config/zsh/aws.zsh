# Overwrite this function for private networks.
function aws:network:verify {
  return 0
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/filter-log-events.html
function aws:logs:filter_events {
  local profile start_time end_time filter
  local limit="1000"
  local group_name=""
  local stream_names=()
  local executor="execute_with_confirm"
  local pager="| less"

  local help="$(
    cat <<-HELP
aws:logs:filter_events {parameters}

  *Parameter*     *Required?*  *Default*   *Note*  *Example*
  --profile       required                         --profile 'default'
  --start-time    required                 JST     --start-time '2022-02-02 02:00:00'
  --end-time      required                 JST     --end-time '2022-02-02 02:00:00'
  --filter        required                         --filter '{ $.demand_id = "123456" || $.params = "*123456*" }'
  --limit         optional     1000                --limit 100
  --group-name    optional     (Select)            --group-name example_group
  --stream-names  optional     (Select)            --stream-names example_stream.1.log example_stream.2.log

See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html for filter syntaxes.
HELP
  )"

  while (("${#@}" > 0)); do
    case "$1" in
      --profile)
        profile="${2:?}"
        shift 2
        ;;
      --start-time)
        start_time="${2:?}"
        shift 2
        ;;
      --end-time)
        end_time="${2:?}"
        shift 2
        ;;
      --filter)
        filter="${2:?}"
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
      --stream-names)
        shift 1
        while (("${#@}" > 0)) && [[ ! "$1" =~ ^- ]]; do
          stream_names+=("${1:?}")
          shift 1
        done
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
        echo "${help}"
        return 0
        ;;
      *)
        echo:error "Unknown option/argument: $1"
        return 1
    esac
  done

  if [ -z "${profile}" ] || [ -z "${start_time}" ] || [ -z "${end_time}" ] || [ -z "${filter}" ]; then
    echo "${help}"
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

  if [ -z "${stream_names[*]}" ]; then
    stream_names=("${(@f)$(_aws:logs:select_streams "${profile}" "${group_name}")}")
  fi

  if [ -z "${stream_names[*]}" ]; then
    echo:error "No log stream names specified."
    return 1
  fi

  local aws_logs_options=(
    --profile "${profile}"
    --log-group-name "${group_name}"
    --log-stream-names "'${(j:' ':)stream_names}'"
    --start-time "$(($(date -j -f '%F %T' "${start_time}" '+%s') * 1000))"
    --end-time "$(($(date -j -f '%F %T' "${end_time}" '+%s') * 1000))"
    --filter "'${filter}'"
    --query "'events[]'"
    --page-size "${limit}"
    --max-items "${limit}"
    --output json
  )
  local jq_arg=".[] | [( .timestamp / 1000 | localtime | todateiso8601 ), ( .message | fromjson )]"
  local outpath="/tmp/aws-logs-filter_events-result-$(date '+%Y%m%d-%H%M%S').txt"

  # shellcheck disable=SC2034
  local filtering_commands=(
    "aws logs filter-log-events ${aws_logs_options[*]}"
    "jq --compact-output --monochrome-output '${jq_arg}'"
  )

  local start_time="$(date '+%s')"
  "${executor}" "${(j: | :)filtering_commands} > ${outpath}"
  local finish_time="$(date '+%s')"

  local notify_options=(--title "aws:logs:filter_events")

  if ((finish_time - start_time < 15)); then
    notify_options+=(--nostay)
  fi

  notify "Filtering has been completed." "${notify_options[@]}"
  execute_with_echo "jq --color-output . ${outpath} ${pager}"
  echo
  echo "See the result in \`${outpath}\`."
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/describe-log-groups.html
function _aws:logs:select_group {
  local profile="${1:?}"

  aws logs describe-log-groups --profile "${profile}" --output json |
    jq '.logGroups[].logGroupName' --raw-output |
    filter --preview-window "hidden" --prompt "Select a log group> " --no-multi
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/describe-log-streams.html
function _aws:logs:select_streams {
  local profile="${1:?}"
  local group_name="${2:?}"

  aws logs describe-log-streams --profile "${profile}" --log-group-name "${group_name}"  |
    jq '.logStreams[].logStreamName' --raw-output |
    filter --preview-window "hidden" --prompt "Select log streams> "
}

# https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html
function plugin:aws:sessionmanager:atclone {
  execute_with_echo "sudo installer -pkg session-manager-plugin.pkg -target /"
  execute_with_echo "sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin"
  execute_with_echo "session-manager-plugin"
}
zinit ice lucid wait"0c" as"null" atclone"plugin:aws:sessionmanager:atclone" atpull"%atclone"
zinit snippet https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg
