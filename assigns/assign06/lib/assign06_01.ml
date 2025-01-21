

open Utils

let rec gather acc  = function 
| [] -> Some (List.rev acc) (*base recursive case*)
| None :: _ -> None (*none otherwise*)
| Some head :: tail -> gather (head :: acc) tail (*make the recursive call*)


let lex s : tok list option =  (*take in string!*)
  let elems = split s in  (*split s using func*)
  let tok = List.map tok_of_string_opt elems in (*tokens*)

  gather [] tok (*get toks with [] as acc *)



