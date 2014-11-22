Param(
  [string]$source,
  [string]$target
)

pandoc -f html -t markdown -s $source -o $target