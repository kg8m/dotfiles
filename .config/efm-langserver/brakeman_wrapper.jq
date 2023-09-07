.warnings + .errors |
  .[] |
  select(.file == $filepath) |
  "\(.file):\(.line): [Brakeman][\(.warning_type) (\(.confidence))] \(.message) (cf. \(.link))"
