syntax match DeinUpdateLogs_HeaderUpdated '\v^\( *\d+/\d+\) \|.+\| Updated$|^Updated plugins:$'
syntax match DeinUpdateLogs_HeaderError   '\v^\( *\d+/\d+\) \|.+\| Error$|^Error installing plugins:$'
syntax match DeinUpdateLogs_HeaderLocked  '\v^\( *\d+/\d+\) \|.+\| Locked$'
syntax match DeinUpdateLogs_URL           "\v<https://[^ ]+"

highlight default link DeinUpdateLogs_HeaderUpdated Title
highlight default link DeinUpdateLogs_HeaderError   ErrorMsg
highlight default link DeinUpdateLogs_HeaderLocked  WarningMsg
highlight default link DeinUpdateLogs_URL           Underlined
