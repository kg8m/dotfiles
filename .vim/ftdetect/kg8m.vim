autocmd BufNewFile,BufRead *.crontab set filetype=crontab

autocmd BufNewFile,BufRead .envrc set filetype=sh

autocmd BufNewFile,BufRead Gemfile.local set filetype=Gemfile

autocmd BufNewFile,BufRead */markdownlint/config set filetype=json

autocmd BufNewFile,BufRead *.moin,*.trac,*.tracwiki set filetype=moin

autocmd BufNewFile,BufRead .pryrc.local set filetype=ruby

" https://gitlab.com/kroppy/TreeTabs
autocmd BufNewFile,BufRead *.tt_theme set filetype=json

autocmd BufNewFile,BufRead */yamllint/config set filetype=yaml
