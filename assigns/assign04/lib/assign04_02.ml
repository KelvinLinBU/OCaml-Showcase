

(*VSCODE TIME OUT!!!!!*)

type expr = (*this definition is from the pset*)
  | True
  | False
  | Num of int
  | Or of expr * expr
  | Add of expr * expr
  | IfThenElse of expr * expr * expr

type ty =  (*pulled from assign*)
  | Int
  | Bool

let rec type_of (e : expr) : ty option =
(*

type_of e is Some t if t is the type of e 
  according to the above rules (i.e., there is a 
derivation of e : t) and None if e is not well-typed 
  (i.e., there is no derivation of e : t).

*)



  match e with
  (* Bools  *)
  |  False -> Some Bool
  | True -> Some Bool
  
  (* Ints *)
  | Num _ -> Some Int


  (*  ORs ||||| *)
  | Or (e1, e2) -> (match type_of e1, type_of e2 with
    | Some Bool, Some Bool -> Some Bool (*if both e1 and e2 are bools then the result is also booleans*)
    | _ -> None) (*else return back none!*)


  (* integers and addition *)
  | Add (e1, e2) -> (match type_of e1, type_of e2 with
    | Some Int, Some Int -> Some Int (*if both ints, then the result is trivially a int*)
    | _ -> None)



  (* conditionals*)
  | IfThenElse (e1, e2, e3) -> (match type_of e1, type_of e2, type_of e3 with
    | Some Bool, Some t2, Some t3 when t2 = t3 -> Some t2 (*if e1 is a bool, and e2 and e3 have the same type then we can return that type. Otherwise give back nothign*)
    | _ -> None)
