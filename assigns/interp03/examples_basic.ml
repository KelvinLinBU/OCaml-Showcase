(* basic lt test *)
let _ =
  let _ = assert (3 < 4) in
  let _ = assert (3. < 4) in
  let _ = assert (false < true) in
  let _ = assert ([3;3] < [3;4]) in
  ()
