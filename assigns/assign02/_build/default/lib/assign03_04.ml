
let hd lst = 
  match lst with
  | [] -> failwith "Empty list"
  | x :: _ -> x


(* Function to check if two integers have opposite signs *)
  let opposite_or_not first second = (first < 0 && second > 0) || (first > 0 && second < 0)

(* Main function to group a valid list of integers *)
let group (input_list : int list) : int list list option = 
  (* Recursive helper function to validate and group the list *)
  let rec helper var current_group input_list = 
    match input_list with
    | [] -> 
        (* If the input list is empty, check if there's a remaining group to add *)
        if current_group = [] then Some (List.rev var) else Some (List.rev (current_group :: var))
    
    | 0 :: [] -> 
        (* A zero at the end of the list is invalid, so return None *)
        None

    | 0 :: x :: xs -> 
        (* Handle a zero followed by another number *)
        if opposite_or_not (hd current_group) x then
          (* If the numbers surrounding the zero have opposite signs, start a new group *)
          helper (current_group :: var) [] (x :: xs)
        else
          (* If the numbers surrounding the zero do not have opposite signs, return None *)
          None

    | x :: xs when x = 0 ->
        (* A zero appearing at the start or in the wrong position is invalid *)
        None
    
    | x :: xs ->
        (* Non-zero case: check if it should be part of the current group *)
        if current_group = [] || (x * hd current_group > 0) then
          (* If the current number has the same sign as the group, continue grouping *)
          helper var (x :: current_group) xs
        else
          (* Invalid if it switches signs without a zero in between *)
          None
  in
  (* Start the recursive process with an empty accumulator and current group *)
  helper [] [] input_list
