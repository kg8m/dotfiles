.[] |
  "\(.path):\(.severity): " +
  "\(.summary) -- \([.description, .reason] | join(" ") | gsub("^\\s+|\\s+$"; "")) " +
  "(\(.reference))"
