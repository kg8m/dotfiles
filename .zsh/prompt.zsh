autoload colors
colors

prompt_user="%F{green}%n@%m%f"
prompt_current_dir="%F{cyan}%~%f"
prompt_git='$(gitprompt)'
prompt_mark="%F{white}%(!.#.%#)%f "

PROMPT="%B${prompt_user} ${prompt_current_dir}%b ${prompt_git}"$'\n'"${prompt_mark}"
PROMPT2="%F{green}%_>%f "

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

zplugin ice pick"git-prompt.zsh"; zplugin light woefe/git-prompt.zsh
