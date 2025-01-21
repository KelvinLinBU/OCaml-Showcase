(* from pset *)
type value =
  | VNum of int
  | VBool of bool


open Assign04_02  (* open Assign04_02 to get the type definitions *)

let rec eval (e : expr) : value = (*eval funcs*)
  match e with
  (* bools *)
  | True -> VBool true (*evals to vtrue and vfalse*)
  | False -> VBool false





  (* ints *)
  | Num n -> VNum n (*num n evals to vnum*)
  
  
  (* ors *)

| Or (e1, e2) -> (match eval e1, eval e2 with (*logical ors*)
     | VBool v1, VBool v2 -> VBool (v1 || v2)
     | _ -> failwith "bad args")
  
(* adds *)
  | Add (e1, e2) ->
    (match eval e1, eval e2 with
     | VNum v1, VNum v2 -> VNum (v1 + v2)
     | _ -> failwith "bad args")
 
 
     (* conds *)
  | IfThenElse (e1, e2, e3) ->
    (match eval e1 with
     | VBool true -> eval e2 (*if cond is true then eval and return e2, *)
     | VBool false -> eval e3 (*same logic as above*)
     | _ -> failwith "bad args")
