let is_prime n =
  (* Check if n is less than 2, as numbers less than 2 are not prime *)
  if n < 2 then false
  else

    let rec divisors d =
      if d * d > n then true  (* n is prime *)
      else if n mod d = 0 then false  (* not prime *)
      else divisors (d + 1)  (* next *)
    in
    divisors 2  (* Start checking from divisor 2 *)
