
let is_prime (n: int) : bool =
  (* Check if n is less than 2, as numbers less than 2 are not prime *)
  if n < 2 then false
  else

    let rec divisors d =
      if d * d > n then true  (* n is prime *)
      else if n mod d = 0 then false  (* not prime *)
      else divisors (d + 1)  (* next *)
    in
    divisors 2  (* Start checking from divisor 2 *)

  let nth_prime (n : int) : int =
      if n = 0 then 2
      else
      let rec help count number =
        
        if count = n then number  (* Return the current number when count matches n *)
        else if is_prime (number + 1) then help (count + 1) (number + 1)  (* Increment count if the next number is prime *)
        else help count (number + 1)  (* Continue searching *)
      in
      help 1 3  (* Start the search from 1 *)
    ;;



