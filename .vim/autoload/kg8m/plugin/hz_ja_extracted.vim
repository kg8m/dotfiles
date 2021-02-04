vim9script

def kg8m#plugin#hz_ja_extracted#configure(): void
  g:hz_ja_extracted_default_commands = false
  g:hz_ja_extracted_default_mappings = false

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: ["Hankaku", "HzjaConvert", "Zenkaku"],
  })
enddef
