def one_if_null(number): if number == null then 1 else number end;
def humanize_severity(level): if level == 1 then "Warning" else "Error" end;
def linebreak_to_space(text): text | gsub("\n"; " ");

.[0].messages[] |
  "\(.line):\(one_if_null(.column)):\(humanize_severity(.severity)): " +
  "[ESLint][\(.ruleId)] \(linebreak_to_space(.message))"
