# Don't use `wait"0c"` because this plugin conflicts other plugins
#
# https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
# `FAST_HIGHLIGHT[chroma-man]=''` for slowness in MacOS
zinit ice lucid wait"0b" atinit"zpcompinit; zpcdreplay" atload"FAST_HIGHLIGHT[chroma-man]=''"
zinit light zdharma-continuum/fast-syntax-highlighting
