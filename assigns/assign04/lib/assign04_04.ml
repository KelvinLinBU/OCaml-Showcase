

type ident = string 
(*pulled from assign*)

type expr' = 
(*pulled from assign*)
  | True
  | False
  | Num of int
  | Var of ident
  | Let of ident * expr' * expr'
  | Add of expr' * expr'
  | Or of expr' * expr'
  | IfThenElse of expr' * expr' * expr'


type ty' =
  | Int
  | Bool

type context = (ident * ty') list

(*everything above this line is from assign*)

(* help func *)
let rec look (x : ident) (gamma : context) : ty' option = match gamma with
  | [] -> None (*if context is empty then none*)
  | (y, t) :: rest -> if x = y then Some t else look x rest 
  (*if x is found return type, if not return to search*)

(* Type inference function with context *)
let rec type_of' (gamma : context) (e : expr') : ty' option = match e with (*this is the func*)
  (* boolss *)
  | True -> Some Bool
  | False -> Some Bool




  (* ints*)
  | Num _ -> Some Int
  
  (* Variable *)
  | Var x -> look x gamma
  
  (* ors *)
  | Or (e1, e2) ->(match type_of' gamma e1, type_of' gamma e2 with
     | Some Bool, Some Bool -> Some Bool (*if both bool then bool*)
     | _ -> None)


  (* num operations *)
  | Add (e1, e2) -> (match type_of' gamma e1, type_of' gamma e2 with
     | Some Int, Some Int -> Some Int (*if both e1 and e2 are ints then result = int*)
     | _ -> None)


  (* conds *)
  | IfThenElse (e1, e2, e3) -> (match type_of' gamma e1, type_of' gamma e2, type_of' gamma e3 with
     | Some Bool, Some t2, Some t3 when t2 = t3 -> Some t2
     | _ -> None) (*badly typed*)



  (* lets *)
  | Let (x, e1, e2) ->(match type_of' gamma e1 with
     | Some t1 -> type_of' ((x, t1) :: gamma) e2 (*if e1 has type t1 then add type to the context then type check*)
     | None -> None)
