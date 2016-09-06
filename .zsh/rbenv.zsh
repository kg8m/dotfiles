export PATH=~/.rbenv/bin:$PATH
if which rbenv > /dev/null; then eval "$( rbenv init - )"; fi

[ -d ~/.rbenv/plugins ] || mkdir ~/.rbenv/plugins
[ -d ~/.rbenv/plugins/rbenv-update ] || ln -s ~/dotfiles/.rbenv/plugins/rbenv-update ~/.rbenv/plugins/rbenv-update
