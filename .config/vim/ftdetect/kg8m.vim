autocmd BufNewFile,BufRead credentials.yml.enc.* set filetype=yaml

autocmd BufNewFile,BufRead *.crontab set filetype=crontab

autocmd BufNewFile,BufRead .envrc set filetype=sh

autocmd BufNewFile,BufRead Gemfile.local* set filetype=Gemfile

autocmd BufNewFile,BufRead *.moin,*.trac,*.tracwiki set filetype=moin

autocmd BufNewFile,BufRead Procfile,Procfile.* set filetype=conf

autocmd BufNewFile,BufRead pryrc set filetype=ruby

" https://gitlab.com/kroppy/TreeTabs
autocmd BufNewFile,BufRead *.tt_theme set filetype=json

autocmd BufNewFile,BufRead */yamllint/config set filetype=yaml
