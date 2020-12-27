function setup:prompt {
  autoload -U colors && colors

  # Execute `man zshmisc` and see "SIMPLE PROMPT ESCAPES" and "CONDITIONAL SUBSTRINGS IN PROMPTS" sections
  local header=$'%{\e[38;5;245m%}$(prompt:header)%{\e[0m%}'
  local user="%F{green}%n@%m%f"
  local current_dir="%F{cyan}%~%f"
  local git='$(gitprompt)'
  local mark="%(?..%B%F{red})%#%f%b "

  export PROMPT="${header}"$'\n'"%B${user} ${current_dir}%b ${git}"$'\n'"${mark}"
  export PROMPT2="%F{green}%_>%f "

  function prompt:header {
    local timestamp="$(date +'%Y/%m/%d %H:%M:%S')"
    local timestamp_width="${#timestamp}"
    local right_margin="$((timestamp_width + 1))"
    local window_width="${COLUMNS:-}"
    local line_width="$((window_width - right_margin))"

    printf "%s %s" "${(r:$line_width::-:)}" "$timestamp"
  }

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
