def humanize_severity(level): if level == 1 then "Warning" else "Error" end;
def linebreak_to_space(text): text | gsub("\n"; " ");

.[0].messages[] |
  "\(.line):\(.column):\(humanize_severity(.severity)): [\(.ruleId)] \(linebreak_to_space(.message))"
