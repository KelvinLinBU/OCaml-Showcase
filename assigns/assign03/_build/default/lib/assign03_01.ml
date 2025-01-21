
let rec helper key value input_list = (* helper function*)
  match input_list with  (*input_list matching*)
  | [] -> [(key, value)] (*if empty input list, then add a key value pair to the list*)
  | (k, v) :: rest -> (*if key value pair, then return rest*)
    if k = key then (k, v + value) :: rest (*if k is the key, then we add the value v*)
    else (k, v) :: helper key value rest (*else, if k and v don't exist, then continue*)

let mk_unique_keys (input_list: (string * int) list) : (string * int) list = (*take list int*string**)
  List.fold_left (fun acc (key, value) -> helper key value acc) [] input_list (*traverse a list from the left, and run the helper function *)