vim9script

def kg8m#plugin#hz_ja_extracted#configure(): void  # {{{
  g:hz_ja_extracted_default_commands = v:false
  g:hz_ja_extracted_default_mappings = v:false

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: ["Hankaku", "HzjaConvert", "Zenkaku"],
  })
enddef  # }}}
