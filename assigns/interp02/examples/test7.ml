let rec factorial (n : int) : int =
  if n <= 1 then 1
  else n * factorial (n - 1)

factorial 5
