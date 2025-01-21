let last_function_standing funcs start pred = 
  (* This is to determine the function that lasts the longest. *)
  
  let find_lifespan func = 
    (* count *)
    
    let rec helper s steps seen_states = 
      (* helper recursive function *)
      if List.mem s seen_states then None (* keep track of seen, if same then infinite and return None *)
      else if pred s then
        if steps = 0 then None else
         Some steps (* If predicate fails, return steps *)
      
      else helper (func s) (steps + 1) (s :: seen_states) (* Continue recursion and add state to seen states *)

    in if pred start then None else helper start 0 [] (* tail recursion, start with no seen states *)
  in

  let lifespans = List.map (fun f -> (f, find_lifespan f)) funcs in 
  (* map out the functions and do pattern matching *)

  let finite_lifespans = List.fold_left (fun acc (f, l) -> match l with
    | Some lifespan -> (f, lifespan) :: acc (* add only finite lifespans to the list *)
    | None -> acc  (* ignore infinite lifespans *)
  ) [] lifespans in

  match finite_lifespans with
  | [] -> None 
  (* return None if there are no functions with finite lifespans *)
  | _ -> 
    (* find the maximum finite lifespan of the functions *)
    let max_lifespan = List.fold_left (fun acc (_, l) -> max acc l) (-1) finite_lifespans in
    let max_funcs = List.filter (fun (_, l) -> l = max_lifespan) finite_lifespans in

    match max_funcs with
    | [(f, _)] -> Some f 
    (* return the function with the maximum lifespan *)
    | _ -> None 
    (* return None if there are multiple functions with the same lifespan *)
