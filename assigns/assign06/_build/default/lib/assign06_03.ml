type ty =  (* from assign*)
  | TInt
  | TBool
open Utils (*open utils and get vals*)

let rec type_of e : ty option =
  match e with





| Add (e1, e2) -> ( (*addition case*)
    match (type_of e1, type_of e2) with
    | (Some TInt, Some TInt) -> Some TInt  (* we need two ints *)
| _ -> None  (* if not integer then none *)
    )
  


| Ite (e1, e2, e3) -> ( (*bools*)
      match (type_of e1, type_of e2, type_of e3) with 
      | (Some TBool, Some t2, Some t3) when t2 = t3 -> Some t2(* conds*)
 | _ -> None  (* types need to align*))


      | Lt (e1, e2) -> (
      match (type_of e1, type_of e2) with
      | (Some TInt, Some TInt) -> Some TBool  (* comparing two ints gives bool*)
      | _ -> None  (* both need to be ints *)
    )
      
      
      | Num _ -> Some TInt  (* num is TInt *)
