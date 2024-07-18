autocmd BufNewFile,BufRead credentials.yml.enc.* set filetype=yaml

autocmd BufNewFile,BufRead *.crontab set filetype=crontab

autocmd BufNewFile,BufRead *.ctags set filetype=conf

autocmd BufNewFile,BufRead direnvrc set filetype=sh

autocmd BufNewFile,BufRead [Dd]ockerfile* set filetype=Dockerfile
autocmd BufNewFile,BufRead *[Dd]ockerfile set filetype=Dockerfile

autocmd BufNewFile,BufRead Gemfile.local* set filetype=Gemfile

autocmd BufNewFile,BufRead *.moin,*.trac,*.tracwiki set filetype=moin

autocmd BufNewFile,BufRead Procfile,Procfile.* set filetype=conf

autocmd BufNewFile,BufRead pryrc set filetype=ruby

autocmd BufNewFile,BufRead Steepfile set filetype=ruby

autocmd BufNewFile,BufRead *.tftpl set filetype=terraform

autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc

" https://gitlab.com/kroppy/TreeTabs
autocmd BufNewFile,BufRead *.tt_theme set filetype=json

autocmd BufNewFile,BufRead */yamllint/config set filetype=yaml
