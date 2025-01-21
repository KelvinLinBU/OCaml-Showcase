let group lst =
  (* help function to determine if signs are opposite *)
  let opposite_signs a b = (a > 0 && b < 0) || (a < 0 && b > 0) in

  (* recursing *)
let rec aux current_group groups = function
| [] -> 
        (*  *)
if current_group = [] then Some (List.rev groups)
else Some (List.rev (List.rev current_group :: groups))
| 0 :: rest -> 
        (* 0 case *)
(match current_group, rest with
| [], _ -> None  (* A zero can't be the first element *)
| _, [] -> None  (* A zero can't be the last element *)
| x :: _, y :: _ when opposite_signs x y ->
             (* Valid zero between opposite signs, finalize the current group *)
aux [] (List.rev current_group :: groups) rest
| _ -> None)  (* Invalid zero placement *)
| x :: rest ->
        (* if num != 0 then... *)
match current_group with
| [] -> aux [x] groups rest  (*new group *)
| y :: _ when (x * y > 0) || (x = 0) -> aux (x :: current_group) groups rest
| _ -> None  (* Invalid adjacent number with a different sign *)
in aux [] [] lst

