export PATH=~/.rbenv/bin:$PATH
if which rbenv > /dev/null 2>&1; then eval "$( rbenv init - )"; fi

[ -d ~/.rbenv/plugins ] || mkdir ~/.rbenv/plugins
[ -d ~/.rbenv/plugins/rbenv-update ] || ln -s ~/dotfiles/.rbenv/plugins/rbenv-update ~/.rbenv/plugins/rbenv-update
