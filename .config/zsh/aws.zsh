# https://docs.aws.amazon.com/cli/latest/reference/logs/filter-log-events.html
function aws:logs:filter_events {
  local start_time end_time filter
  local limit="1000"
  local group_name=""
  local stream_names=()

  local help="$(
    cat <<-HELP
aws:logs:filter_events {parameters}

  *Parameter*     *Required?*  *Default*   *Note*  *Example*
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
      -h | --help)
        echo "${help}"
        return 0
        ;;
      *)
        echo:error "Unknown option/argument: $1"
        return 1
    esac
  done

  if [ -z "${start_time}" ] || [ -z "${end_time}" ] || [ -z "${filter}" ]; then
    echo "${help}"
    return 1
  fi

  if [ -z "${group_name}" ]; then
    group_name="$(aws:logs:select_group)"
  fi

  if [ -z "${group_name}" ]; then
    echo:error "No log group name specified."
    return 1
  fi

  if [ -z "${stream_names[*]}" ]; then
    stream_names=("${(@f)$(aws:logs:select_streams "${group_name}")}")
  fi

  if [ -z "${stream_names[*]}" ]; then
    echo:error "No log stream names specified."
    return 1
  fi

  local aws_logs_options=(
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
  execute_with_confirm "${(j: | :)filtering_commands} > ${outpath}"
  local finish_time="$(date '+%s')"

  local notify_options=(--title "aws:logs:filter_events")

  if ((finish_time - start_time < 15)); then
    notify_options+=(--nostay)
  fi

  notify "Filtering has been completed." "${notify_options[@]}"
  execute_with_echo "jq --color-output . ${outpath} | less"
  echo
  echo "See the result in \`${outpath}\`."
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/describe-log-groups.html
function aws:logs:select_group {
  aws logs describe-log-groups --output json |
    jq '.logGroups[].logGroupName' --raw-output |
    filter --preview-window "hidden" --prompt "Select a log group> " --no-multi
}

# https://docs.aws.amazon.com/cli/latest/reference/logs/describe-log-streams.html
function aws:logs:select_streams {
  local group_name="${1:?}"

  aws logs describe-log-streams --log-group-name "${group_name}"  |
    jq '.logStreams[].logStreamName' --raw-output |
    filter --preview-window "hidden" --prompt "Select log streams> "
}
