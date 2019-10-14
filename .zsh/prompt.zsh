autoload colors
colors

PROMPT2="%{${fg[green]}%}%_> %{${reset_color}%}"
SPROMPT="%{${fg[yellow]}%}correct: %R -> %r [nyae]? %{${reset_color}%}"

prompt_user="%{${fg[green]}%}%n@%m"
prompt_current_dir="%{${fg[cyan]}%}%~%{${reset_color}%}"
prompt_git='$(gitprompt)'
prompt_self="%{${reset_color}%}%(!.#.%#) "

PROMPT="${prompt_user} ${prompt_current_dir} ${prompt_git}"$'\n'"${prompt_self}"

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_bold[cyan]%}:"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_BEHIND="v"
ZSH_THEME_GIT_PROMPT_AHEAD="^"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}C"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[blue]%}+"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[yellow]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[cyan]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}#"
ZSH_GIT_PROMPT_SHOW_STASH=1

zplugin ice pick"git-prompt.zsh"; zplugin light woefe/git-prompt.zsh
