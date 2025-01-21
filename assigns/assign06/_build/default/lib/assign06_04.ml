open Utils
type value = 
  | VNum of int
  | VBool of bool


  

let rec eval e : value = (*thing*)
  match e with


  | Num n -> VNum n  (*num is val*)


| Add (e1, e2) -> (
match (eval e1, eval e2) with
| (VNum v1, VNum v2) -> VNum (v1 + v2)  (* add nums *)
      | _ -> failwith "weird behavior" 
      (*exception case*)
    ) | Lt (e1, e2) -> ( match (eval e1, eval e2) with
      | (VNum v1, VNum v2) -> VBool (v1 < v2)  (* Comp nums*)
      | _ -> failwith "weird" )



  | Ite (e1, e2, e3) -> (
   match eval e1 with
      | VBool true -> eval e2  (* if true next *)
      | VBool false -> eval e3  (* If false e3*)
      | _ -> failwith "weird" )
