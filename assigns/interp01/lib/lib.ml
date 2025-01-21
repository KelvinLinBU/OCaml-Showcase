
open My_parser
open Utils
open Stdlib320

let parse s = parse' s



let rec string_of_expr = function
| Num n -> string_of_int n

| True -> "true"

| False -> "false"

| Fun (arg, body) -> "(fun " ^ arg ^ " -> " ^ string_of_expr body ^ ")"

| App (e1, e2) -> "(" ^ string_of_expr e1 ^ " " ^ string_of_expr e2 ^ ")"

| Let (x, e1, e2) -> "let " ^ x ^ " = " ^ string_of_expr e1 ^ " in " ^ string_of_expr e2

| If (cond, e1, e2) -> "if " ^ string_of_expr cond ^ " then " ^ string_of_expr e1 ^ " else " ^ string_of_expr e2

| Unit -> "()"

  | Var x -> x

  | Bop (op, e1, e2) ->

        let op_str = match op with

        | Add -> "+"
        | Sub -> "-"
        | Mul -> "*"
        | Div -> "/"
        | Mod -> "mod"
        | And -> "&&"
        | Or -> "||"
        | Eq -> "="
        | Neq -> "<>"
        | Lt -> "<"
        | Lte -> "<="
        | Gt -> ">"
        | Gte -> ">="
      in "(" ^ string_of_expr e1 ^ " " ^ op_str ^ " " ^ string_of_expr e2 ^ ")"


let expr_of_val v = match v with
| VNum n -> Num n
| VBool b -> if b then True else False
| VUnit -> Unit
| VFun (x, e) -> Fun (x, e)
let replace_var x y =
  let rec go = function
  | Var z -> if z = y then Var x else Var z
  | App (e1, e2) -> App (go e1, go e2)
  | Fun (z, e) -> if z = y then Fun (z, e) else Fun (z, go e)
  | Let (z, e1, e2) ->
    let e1' = go e1 in
      if z = y then Let (z, e1', e2) else Let (z, e1', go e2)
  | Unit -> Unit
  | True -> True
    | False -> False
    | Num n -> Num n
    | Bop (op, e1, e2) -> Bop (op, go e1, go e2)
    | If (cond, e1, e2) -> If (go cond, go e1, go e2)
  in go

(* subst *)
let subst v x =
  let rec go = function
| Var y -> if x = y then expr_of_val v else Var y
| App (e1, e2) -> App (go e1, go e2)
| Fun (y, e) ->



        if x = y then Fun (y, e)  (* shadow case*)
        else
          
          let z = gensym () in



          Fun (z, go (replace_var z y e))  (*sub *)
          
    | Let (y, e1, e2) ->
        let e1' = go e1 in
        if x = y then Let (y, e1', e2)  (*skip*)
        else
          let z = gensym () in
          Let (z, e1', go (replace_var z y e2))  (*help *)
  | Unit -> Unit
  | True -> True
    | False -> False
    | Bop (op, e1, e2) -> Bop (op, go e1, go e2)
    | If (cond, e1, e2) -> If (go cond, go e1, go e2)
    | Num n -> Num n
    
  in go


let ( let* ) opt f = 
  match opt with
  | Some x -> f x
  | None -> None
  

(*what?*)
let eval =
        
  let rec go = function
          | Num n -> Ok (VNum n)

          | True -> Ok (VBool true)

          | False -> Ok (VBool false)



          | Unit -> Ok VUnit

          

          | Fun (x, e) -> Ok (VFun (x, e))
      
          

          | Var x -> Error (UnknownVar x)  (* Unbound variable error *)
      
        


          | App (e1, e2) -> (


              match go e1 with


              | Ok (VFun (x, body)) -> (


                  match go e2 with



                  | Ok v2 -> go (subst (v2) x body)



                  | Error e -> Error e



                )
              | Ok _ -> Error InvalidApp  (* invalid *)


              | Error e -> Error e
            )
      
          | Let (x, e1, e2) -> (
              match e1 with
              App (Fun (arg, body), self_ref) when arg = x && self_ref = Var x ->
              (* Handle recursive function with subst that doesn't use gensym *)

         let rec evaluate_recursive expr =
          match go expr with
          | Ok (VFun (param, fun_body)) ->
              (* Apply subst to recursively evaluate function body without gensym *)
              let new_body = subst (VFun (param, fun_body)) x fun_body in
              evaluate_recursive new_body  (* Continue recursively applying *)
          | result -> result  (* Return result once we reach a base case *)
        in
        evaluate_recursive (subst (VFun (arg, body)) x e2)  (* Start evaluation *)
              | _ -> (
                  (* Non-recursive Let case *)
                  match go e1 with
                  | Ok v -> go (subst ( v) x e2)
                  | Error e -> Error e
                )
            )
            | Bop (Mod, e1, e2) -> (
        match go e1, go e2 with


        | Ok (VNum v1), Ok (VNum v2) when v2 <> 0 -> Ok (VNum (v1 mod v2))  (*mod ops *)
        | Ok _, Ok (VNum 0) -> Error DivByZero  (*div by 0 *)
        | Error e, _ | _, Error e -> Error e

        | _ -> Error (InvalidArgs Mod)
      )
      

      | Bop (Lt, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 < v2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Lt)
      )

      | Bop (Lte, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 <= v2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Lte)
      )
      | Bop (Gt, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 > v2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Gt)
      )


      | Bop (Gte, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 >= v2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Gte)
      )

      | Bop (Eq, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 = v2))
        | Ok (VBool b1), Ok (VBool b2) -> Ok (VBool (b1 = b2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Eq)
      )


      | Bop (Neq, e1, e2) -> (
        match go e1, go e2 with
        | Ok (VNum v1), Ok (VNum v2) -> Ok (VBool (v1 <> v2))
        | Ok (VBool b1), Ok (VBool b2) -> Ok (VBool (b1 <> b2))
        | Error e, _ | _, Error e -> Error e
        | _ -> Error (InvalidArgs Neq)
      )
            | Bop (Div, e1, e2) -> (
              match go e1, go e2 with


              | Ok (VNum v1), Ok (VNum v2) ->


                  if v2 = 0 then Error DivByZero else Ok (VNum (v1 / v2))


              | Ok _, Ok _ -> Error (InvalidArgs Div)


              | Error e, _ | _, Error e -> Error e
            )
            
         
          | Bop (And, e1, e2) -> (
              match go e1 with
              | Ok (VBool false) -> Ok (VBool false)


              | Ok (VBool true) -> go e2


              | Ok _ -> Error (InvalidArgs And)


              | Error e -> Error e
            )
      
          | Bop (Or, e1, e2) -> (
              match go e1 with


              | Ok (VBool true) -> Ok (VBool true)


              | Ok (VBool false) -> go e2


              | Ok _ -> Error (InvalidArgs Or)


              | Error e -> Error e
            )
          (* Arithmetic operations *)
          | Bop (Add, e1, e2) -> (


              match go e1, go e2 with


              | Ok (VNum v1), Ok (VNum v2) -> Ok (VNum (v1 + v2))


              | Ok _, Ok _ -> Error (InvalidArgs Add)


              | Error e, _ | _, Error e -> Error e
            )
      
          | Bop (Sub, e1, e2) -> (


              match go e1, go e2 with


              | Ok (VNum v1), Ok (VNum v2) -> Ok (VNum (v1 - v2))


              | Ok _, Ok _ -> Error (InvalidArgs Sub)


              | Error e, _ | _, Error e -> Error e
            )
      
          | Bop (Mul, e1, e2) -> (
              match go e1, go e2 with


              | Ok (VNum v1), Ok (VNum v2) -> Ok (VNum (v1 * v2))


              | Ok _, Ok _ -> Error (InvalidArgs Mul)


              | Error e, _ | _, Error e -> Error e
            )
      
          
      
          (*conds *)
          | If (cond, e1, e2) -> (
              match go cond with


              | Ok (VBool b) -> if b then go e1 else go e2


              | Ok _ -> Error InvalidIfCond


              | Error e -> Error e
            )
      
         
      
        in go
      

  let interp input = match parse input with
      | None -> Error ParseFail  (*interp modded to fit with value*)
          | Some prog -> (
match eval prog with
  | Error e -> Error e    (*get error *)
  | Ok v -> Ok v          (*okay*)
            )
        