
open Utils (* open Utils*)
let handle_num n stack = Num n :: stack (*helper func for TNUM *)

(* TADD toks helper func *)
let handle_add stack = match stack with
| e2 :: e1 :: rest_of_thing -> Some (Add (e1, e2) :: rest_of_thing) (*add this with the rest*)
| _ -> None  




let handle_lt stack = (* TLt pop and push *)
    match stack with
    | e2 :: e1 :: rest_of_thing -> Some (Lt (e1, e2) :: rest_of_thing)
    | _ -> None  



(* pop and push*)
let handle_ite stack =
match stack with
| e3 :: e2 :: e1 :: rest_of_thing -> Some (Ite (e1, e2, e3) :: rest_of_thing)
| _ -> None  




(* helper function to help parse tokens *)
let rec parse_helper stack tokens =
  match tokens with
  | [] -> ((* one elem *)
      match stack with
      | [e] -> Some e
      | _ -> None  (* *)
    )


| TNum n :: r -> 
      parse_helper (handle_num n stack) r (*recurisvie call and call handle_num*)


  | TAdd :: r -> ( (* Tadds *)
      match handle_add stack with
      | Some new_stack -> parse_helper new_stack r
      | None -> None  
    )
  

| TIte :: r -> (
      (* conditionals token s *)
      match handle_ite stack with
      | Some new_stack -> parse_helper new_stack r
      | None -> None  
    )
    
    
  | TLt :: r -> (
      (*<*)
    match handle_lt stack with
      | Some new_stack -> parse_helper new_stack r
      | None -> None  
  )


let parse (toks :tok list) :expr option = (* actualy func *)

  parse_helper [] toks  
  (*start with empty stack for accumulator like in instructions and pass in toks *)

