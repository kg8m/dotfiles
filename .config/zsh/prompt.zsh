function setup:prompt {
  autoload -U colors && colors

  # Execute `man zshmisc` and see "SIMPLE PROMPT ESCAPES" and "CONDITIONAL SUBSTRINGS IN PROMPTS" sections
  local header=$'%{\e[38;5;240;1m%}$(prompt:header:render)%{\e[0m%}'
  local user="%F{green}%n@%m%f"
  local current_dir="%F{cyan}%~%f"
  local git='$(gitprompt)'
  local mark="%(?..%B%F{red})%#%f%b "

  export PROMPT="${header}"$'\n'"%B${user} ${current_dir}%b ${git}"$'\n'"${mark}"
  export PROMPT2="%F{green}%_>%f "

  export PROMPT_HEADER_CACHE_FILEPATH="${KG8M_ZSH_CACHE_DIR:?}/prompt_header.$$"

  function prompt:header:render {
    if [ -f "$PROMPT_HEADER_CACHE_FILEPATH" ]; then
      cat "$PROMPT_HEADER_CACHE_FILEPATH"
    else
      echo
    fi
  }

  function prompt:header:build {
    local timestamp="$(date +'%Y/%m/%d %H:%M:%S')"
    local timestamp_width="${#timestamp}"
    local right_margin="$((timestamp_width + 1))"
    local window_width="${1:-COLUMNS}"
    local line_width="$((window_width - right_margin))"

    printf "%s %s" "${(r:$line_width::-:)}" "$timestamp" > "$PROMPT_HEADER_CACHE_FILEPATH"
  }

  function prompt:header:lazy_build {
    sleep 0.2
    prompt:header:build "$@"
  }

  # Refresh prompt at any widget triggered/executed
  function setup:prompt:reset_hook {
    export PROMPT_RESETTER_WORKER_NAME="PROMPT_RESETTER_$$"

    function prompt:reset:queue {
      case "${LASTWIDGET:-}" in
        fzf-completion | autosuggest-suggest)
          case "${_lastcomp[insert]:-}" in
            # Don't reset prompt when a completion candidate is selected because resetting prompt hides candidates
            automenu | automenu-unambiguous)
              return
              ;;
          esac
          ;;
        _abbr_widget_expand_and_accept | accept-line)
          prompt:header:build
          prompt:reset
          return
          ;;
      esac

      # Restart the worker everytime because it causes high load average and it is sometimes dead in background
      async_stop_worker       "$PROMPT_RESETTER_WORKER_NAME"
      async_start_worker      "$PROMPT_RESETTER_WORKER_NAME"
      async_job               "$PROMPT_RESETTER_WORKER_NAME" "prompt:header:lazy_build $COLUMNS"
      async_register_callback "$PROMPT_RESETTER_WORKER_NAME" "prompt:reset"
    }

    function prompt:reset {
      zle .reset-prompt
      async_stop_worker "$PROMPT_RESETTER_WORKER_NAME"
    }

    # http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Manipulating-Hook-Functions
    autoload -U add-zle-hook-widget
    add-zle-hook-widget zle-line-pre-redraw prompt:reset:queue
    add-zle-hook-widget zle-line-init       prompt:reset:queue

    prompt:reset:queue

    unset -f setup:prompt:reset_hook
  }
  zinit ice lucid wait"0c" atload"setup:prompt:reset_hook"
  zinit light mafredri/zsh-async

  unset -f setup:prompt
}
setup:prompt

export ZSH_THEME_GIT_PROMPT_PREFIX="["
export ZSH_THEME_GIT_PROMPT_SUFFIX="]"
export ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
export ZSH_THEME_GIT_PROMPT_DETACHED="%F{cyan}:"
export ZSH_THEME_GIT_PROMPT_BRANCH="%F{magenta}"
export ZSH_THEME_GIT_PROMPT_BEHIND="-"
export ZSH_THEME_GIT_PROMPT_AHEAD="+"
export ZSH_THEME_GIT_PROMPT_UNMERGED="%F{red}C"
export ZSH_THEME_GIT_PROMPT_STAGED="%F{blue}+"
export ZSH_THEME_GIT_PROMPT_UNSTAGED="%F{yellow}!"
export ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
export ZSH_THEME_GIT_PROMPT_STASHED="%F{cyan}*"
export ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}#"
export ZSH_GIT_PROMPT_SHOW_STASH=1

zinit ice lucid pick"git-prompt.zsh"
zinit light woefe/git-prompt.zsh
