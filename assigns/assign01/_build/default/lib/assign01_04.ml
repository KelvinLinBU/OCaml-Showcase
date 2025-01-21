


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
    


let nth (s : int) (i : int) : int = (*Take in s, i ints, and return int*)
    let prime_number = nth_prime i in 
    let rec get_power x prime_number power = 
      if x mod prime_number <> 0 (*base case*)
        then power 
    else 
      get_power (x / prime_number) prime_number (power + 1)
  in get_power s prime_number 0
  

  let to_string (encoded_number : int) : string =
    (* Helper function *)
    let rec decode_sequence encoded_number index sequence_acc = let power_of_prime = nth encoded_number index in  
  if power_of_prime = 0 then sequence_acc  
      else decode_sequence encoded_number (index + 1) (power_of_prime :: sequence_acc) in
    let decoded_sequence = List.rev (decode_sequence encoded_number 0 []) in  (* Reverse*)
    "[" ^ (String.concat "; " (List.map string_of_int decoded_sequence)) ^ "]"  (* Convert to string *)
  ;;