
(* 
 take the first 'n' elements of a list 'lst'.
  If 'n' is greater than the length of the list, it returns the entire list.
  If 'n' is 0 or negative, it returns an empty list.
*)
let rec take n lst =
  match lst with
  | [] -> [] (* base: if the list is empty, return an empty lst. *)
  | _ when n <= 0 -> [] (* If n is 0 or negative, return an empty lst. *)
  | x :: xs -> x :: take (n - 1) xs  (* rec case: add the first element 'x' to the result of recursively calling 
     'take' with 'n - 1' on the rest of the list 'xs'. This continues until 'n' is 0. *)

(* 
 gen_fib. If 'num' is less than the length of 'input_list', return the value from 'input_list'. If 'num' is greater than or equal to the length, rec compute the next value 
in the sequence by summing the last 'list_length' elements and appending it to the sequence.
*)
let gen_fib (input_list : int list) (num: int) : int = 
  (* Get the length of input list *)
  let list_length = List.length input_list in  (* Helper func*)
  let rec helper rec_list num = (* 
base: If 'num' is less than 'list_length', return the value from the reversed 
      'input_list' at index 'num'. reverse is needed because we are building 'rec_list' 
      from the most recent values backwards.
    *)
    if num < list_length then List.nth (List.rev input_list) num 
    (* 
      rec case: If 'num' is greater than or equal to 'list_length', we compute the next value in the sequence as the sum of the last 'list_length' elements of 'rec_list'.
      We do this by using the 'take' function to get the first 'list_length' elements and summing them using 'List.fold_left'.
    *)
    else (* Sum the last 'list_length' elements of the sequence 'rec_list'. *) let var = List.fold_left (+) 0 (List.rev (take list_length rec_list)) in
      (* computed value var to the front of 'rec_list' and recurse. *)helper (var :: rec_list) (num - 1) 
  in (* start rec with 'rec_list' initialized as the  reverse of 'input_list'. *) helper (List.rev input_list) num
