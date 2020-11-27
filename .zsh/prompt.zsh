function plugin:setup:prompt {
  autoload colors && colors

  local user="%F{green}%n@%m%f"
  local current_dir="%F{cyan}%~%f"
  local git='$(gitprompt)'
  local mark="%F{white}%(!.#.%#)%f "

  export PROMPT="%B${user} ${current_dir}%b ${git}"$'\n'"${mark}"
  export PROMPT2="%F{green}%_>%f "

  unset -f plugin:setup:prompt
}
plugin:setup:prompt

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
