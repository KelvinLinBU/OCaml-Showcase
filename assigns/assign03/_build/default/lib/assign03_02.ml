let gen_fib l k =
  (* Helper function to sum the last len_l elements from the current list *)
  let sum_last_elements current_list len_l =
    let rec sum_helper lst count acc =
      match lst with
      | [] -> acc
      | hd :: tl -> if count < len_l then sum_helper tl (count + 1) (acc + hd) else acc
    in

    sum_helper current_list 0 0
  in
  (* separate func *)
  let rec fib_aux current_k current_list len_l =
    if current_k = k + 1 then 
      match current_list with
      | hd :: _ -> hd  (*return first element*)
      | [] -> failwith "Empty list"
    else
      let sum_last = sum_last_elements current_list len_l in (* adding the sum of the last len_l elements to the front *)
      let updated_list = sum_last :: current_list in
      (* last*)



      let rec trim_list lst n =
        match lst, n with
        | [], _ -> []
        | _ :: _, 0 -> []
        | hd :: tl, _ -> hd :: (trim_list tl (n - 1))
      in
      fib_aux (current_k + 1) (trim_list updated_list len_l) len_l
  in

  (* replace List.nth func *)
  let rec get_nth_element lst n =
    match lst with
    | [] -> failwith "Index out of bounds" 
    (*fail*)
    | hd :: tl -> if n = 0 then hd else get_nth_element tl (n - 1)
  in

  
  let len_l = (* length of list *)
    let rec list_length lst acc =
      match lst with
      | [] -> acc
      | _::tail -> list_length tail (acc + 1)
    in
    list_length l 0
  in

  if k < len_l then
    get_nth_element l k  (* return the k element *)
  else(* recrusvie call *)
    fib_aux len_l (List.rev l) len_l  
;;
