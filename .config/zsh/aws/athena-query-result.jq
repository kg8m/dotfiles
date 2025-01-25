# Convert
#
#   [
#     [
#       { "VarCharValue": "key1" },
#       { "VarCharValue": "key2" },
#       ...,
#       { "VarCharValue": "last key" }
#     ],
#     [
#       { "VarCharValue": "value1 of record1" },
#       { "VarCharValue": "value2 of record1" },
#       ...,
#       { "VarCharValue": "last value of record1" }
#     ],
#     [
#       { "VarCharValue": "value1 of record2" },
#       { "VarCharValue": "value2 of record2" },
#       ...,
#       { "VarCharValue": "last value of record2" }
#     ],
#     ...,
#     [
#       { "VarCharValue": "value1 of last record" },
#       { "VarCharValue": "value2 of last record" },
#       ...,
#       { "VarCharValue": "last value of last record" }
#     ]
#   ]
#
# to
#
#   {
#     "key1": "value1 of record1",
#     "key2": "value2 of record1",
#     ...,
#     "last key": "last value of record1"
#   }
#   {
#     "key1": "value1 of record2",
#     "key2": "value2 of record2",
#     ...,
#     "last key": "last value of record2"
#   }
#   ...
#   {
#     "key1": "value1 of last record",
#     "key2": "value2 of last record",
#     ...,
#     "last key": "last value of last record"
#   }
. as $rows |
($rows[0] | map(.VarCharValue)) as $headers |
$rows[1:] |
map(
  map(.VarCharValue) as $vals |
  reduce range(0; $headers | length) as $i ({}; . + { ($headers[$i]): $vals[$i] })
) |
.[]
