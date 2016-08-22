export PATH=~/.rbenv/bin:$PATH
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export PATH=bin:vendor/bundle/bin:$HOME/.git_templates/bin:$HOME/.go/bin:$HOME/bin:/usr/local/bin:/sbin:$PATH

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
