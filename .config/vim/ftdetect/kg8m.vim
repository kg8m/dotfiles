autocmd BufNewFile,BufRead credentials.yml.enc.* set filetype=yaml

autocmd BufNewFile,BufRead *.crontab set filetype=crontab

autocmd BufNewFile,BufRead *.ctags set filetype=conf

autocmd BufNewFile,BufRead direnvrc set filetype=sh

autocmd BufNewFile,BufRead [Dd]ockerfile*,*[Dd]ockerfile set filetype=Dockerfile

autocmd BufNewFile,BufRead Gemfile.local set filetype=Gemfile
autocmd BufNewFile,BufRead Gemfile.lock,Gemfile.local.lock set filetype=Gemfilelock

autocmd BufNewFile,BufRead *git*/info/exclude,*git*/ignore set filetype=gitignore

autocmd BufNewFile,BufRead */litecli/config set filetype=toml

autocmd BufNewFile,BufRead *.moin,*.trac,*.tracwiki set filetype=moin

autocmd BufNewFile,BufRead */pgcli/config set filetype=toml

autocmd BufNewFile,BufRead Procfile,Procfile.* set filetype=conf

autocmd BufNewFile,BufRead pryrc set filetype=ruby

autocmd BufNewFile,BufRead Steepfile set filetype=ruby

autocmd BufNewFile,BufRead */.ssh/config,*/.ssh/config.* set filetype=sshconfig

autocmd BufNewFile,BufRead *.tftpl set filetype=terraform

autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc

" https://gitlab.com/kroppy/TreeTabs
autocmd BufNewFile,BufRead *.tt_theme set filetype=json

autocmd BufNewFile,BufRead */yamllint/config set filetype=yaml
