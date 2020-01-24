setup_prompt() {
  autoload colors && colors

  local user="%F{green}%n@%m%f"
  local current_dir="%F{cyan}%~%f"
  local git='$(gitprompt)'
  local mark="%F{white}%(!.#.%#)%f "

  PROMPT="%B${user} ${current_dir}%b ${git}"$'\n'"${mark}"
  PROMPT2="%F{green}%_>%f "
}
setup_prompt

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_DETACHED="%F{cyan}:"
ZSH_THEME_GIT_PROMPT_BRANCH="%F{magenta}"
ZSH_THEME_GIT_PROMPT_BEHIND="-"
ZSH_THEME_GIT_PROMPT_AHEAD="+"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{red}C"
ZSH_THEME_GIT_PROMPT_STAGED="%F{blue}+"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%F{yellow}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
ZSH_THEME_GIT_PROMPT_STASHED="%F{cyan}*"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}#"
ZSH_GIT_PROMPT_SHOW_STASH=1

zinit ice pick"git-prompt.zsh"; zinit light woefe/git-prompt.zsh
