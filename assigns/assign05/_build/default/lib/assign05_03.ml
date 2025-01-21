
type ident = string
type ty = 
| Unit
| Arr of ty * ty
type expr = 
| Var of ident
| Fun of ident * ty * expr
| App of expr * expr

let rec type_of gamma e =
  match e with
  | Var x -> (* find x in gamma *) List.assoc_opt x gamma
  | Fun (x, t1, e) ->(*gamma *) let gamma' = (x, t1) :: gamma in
      (match type_of gamma' e with
| Some t2 -> Some (Arr (t1, t2))  (*  t2 return the func type t1->t2 *)| None -> None)  (* If the body cannot be typed, return None *)
| App (e1, e2) ->
(* infer types *)
(match type_of gamma e1, type_of gamma e2 with
| Some (Arr (t2, t)), Some t2' when t2 = t2' ->
Some t  (* if t1 *)
| _ -> None)  (* return none *)
