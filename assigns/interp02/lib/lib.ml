
open Utils
open Stdlib320



(*pain *)

let parse = My_parser.parse


let rec fun_ty_of_args args result_ty =
  match args with
  | [] -> result_ty
  | (_, ty) :: rest ->


      (match result_ty with
       | FunTy _ -> result_ty 

       
       | _ -> FunTy (ty, fun_ty_of_args rest result_ty))




       let rec desugar_expr = function
       | SUnit -> Unit
       | STrue -> True
       | SFalse -> False
       | SNum n -> Num n
       | SVar x -> Var x
       | SFun { arg; args; body } ->
           List.fold_right (fun (v, t) acc -> Fun (v, t, acc)) (arg :: args) (desugar_expr body)
       | SApp (f, e) -> App (desugar_expr f, desugar_expr e)
       | SLet { is_rec; name; args; ty; value; body } ->
           let func_ty = fun_ty_of_args args ty in
           let func =
             List.fold_right (fun (v, t) acc -> Fun (v, t, acc)) args (desugar_expr value)
           in
           Let { is_rec; name; ty = func_ty; value = func; body = desugar_expr body }
       | SIf (cond, then_, else_) ->
           If (desugar_expr cond, desugar_expr then_, desugar_expr else_)
       | SBop (op, e1, e2) -> Bop (op, desugar_expr e1, desugar_expr e2)
       | SAssert e -> Assert (desugar_expr e)

       let desugar prog =
        match prog with
        | [] -> failwith "empty"
        | [t] ->
            let ty = fun_ty_of_args t.args t.ty in
            
            
            
            let value =
              List.fold_right (fun (v, t) acc -> Fun (v, t, acc)) t.args (desugar_expr t.value)
            in
            Let { is_rec = t.is_rec; name = t.name; ty = ty; value = value; body = desugar_expr t.value }
        | _ ->
            
          
          
          
          List.fold_right (fun t acc ->
              let ty = fun_ty_of_args t.args t.ty in
              let value =
                List.fold_right (fun (v, t) acc -> Fun (v, t, acc)) t.args (desugar_expr t.value)
              in
              Let { is_rec = t.is_rec; name = t.name; ty = ty; value = value; body = acc }
            ) prog Unit
       
      
      




let type_of expr =
  let rec type_of_with_ctx ctx expr =
    (* type of helper and check operations*)
    let check_binop left right expected_left_ty expected_right_ty result_ty op =
      match (type_of_with_ctx ctx left, type_of_with_ctx ctx right) with
      | (Ok left_ty, Ok right_ty) ->
       if left_ty <> expected_left_ty then
        Error (OpTyErrL (op, expected_left_ty, left_ty)) else if right_ty <> expected_right_ty then
            Error (OpTyErrR (op, expected_right_ty, right_ty))
          else
            Ok result_ty
            | (Error (UnknownVar x), _) -> Error (UnknownVar x)
            | (_, Error (UnknownVar x)) -> Error (UnknownVar x)
            | (Error (IfCondTyErr ty), _) -> Error (IfCondTyErr ty)
            | (_, Error (IfCondTyErr ty)) -> Error (IfCondTyErr ty)
      | (Error err, _) -> Error err
      | (_, Error err) -> Error err
    in

    match expr with
 
    | Unit -> Ok UnitTy
    | True | False -> Ok BoolTy
    | Num _ -> Ok IntTy

  
    | Var x ->
        (match List.assoc_opt x ctx with
        | Some ty -> Ok ty
        | None -> Error (UnknownVar x))


    | Bop (op, left, right) ->
        (match op with


        | Add | Sub | Mul | Div | Mod ->
            check_binop left right IntTy IntTy IntTy op



        | Lt | Lte | Gt | Gte | Eq | Neq ->
            check_binop left right IntTy IntTy BoolTy op



        | And | Or ->
            check_binop left right BoolTy BoolTy BoolTy op)

    (*conds *)
    | If (cond, then_, else_) -> (
      match type_of_with_ctx ctx cond with
      | Ok BoolTy -> (
          match type_of_with_ctx ctx then_ with
          | Ok t1 -> (
            match type_of_with_ctx ctx else_ with
            | Ok t2 when t1 = t2 -> Ok t1
            | Ok t2 -> Error (IfTyErr (t1, t2))
              | Error (UnknownVar x) -> Error (UnknownVar x)
              | Error (IfCondTyErr ty) -> Error (IfCondTyErr ty)
              | Error err -> Error err)
          | Error (UnknownVar x) -> Error (UnknownVar x)
          | Error err -> Error err)

        | Ok ty -> Error (IfCondTyErr ty)
        | Error err -> Error err)

    (*funcs*)
    | Fun (x, arg_ty, body) ->
        let ctx' = (x, arg_ty) :: ctx in
        (match type_of_with_ctx ctx' body with
        | Ok body_ty -> Ok (FunTy (arg_ty, body_ty))
        | Error err -> Error err)

    (*apps *)
    | App (f, arg) ->
        (match type_of_with_ctx ctx f with
        | Ok (FunTy (arg_ty, ret_ty)) ->
            (match type_of_with_ctx ctx arg with
            | Ok ty when ty = arg_ty -> Ok ret_ty
            | Ok ty -> Error (FunArgTyErr (arg_ty, ty))
            | Error err -> Error err)
        | Ok ty -> Error (FunAppTyErr ty)
        | Error err -> Error err)

    (*lets *)
    | Let { is_rec; name; ty = expected_ty; value; body } ->
        if is_rec then
            (* ret*)
            let ctx' = (name, expected_ty) :: ctx in
            (match type_of_with_ctx ctx' value with
            | Error err -> Error err
            | Ok actual_ty ->
                if actual_ty <> expected_ty then Error (LetTyErr (expected_ty, actual_ty))
                else type_of_with_ctx ctx' body)
        else
            (*non rec *)
            (match type_of_with_ctx ctx value with
            | Error err -> Error err
            | Ok actual_ty ->
                if actual_ty <> expected_ty then Error (LetTyErr (expected_ty, actual_ty))
                else
                    let ctx' = (name, expected_ty) :: ctx in
                    type_of_with_ctx ctx' body)

    (*ASSERRT*)
    | Assert e ->
        (match type_of_with_ctx ctx e with
        | Ok BoolTy -> Ok UnitTy
        | Ok ty -> Error (AssertTyErr ty)
        | Error err -> Error err)

  in
  type_of_with_ctx [] expr

  

  exception AssertFail
  exception DivByZero


(* *)
let rec eval_with_env (env : value env) (expr : expr) : value =
  match expr with
  (* Unit *)
  
  
  (* Boolea*)
  | True -> VBool true
  | False -> VBool false
  
  (* Int *)
  | Num n -> VNum n
  
  (* vars *)
  | Var x -> (
      match Env.find_opt x env with
      | Some v -> v
      | None -> failwith ("Unbound variable: " ^ x)
    )
  
  (* binops *)
  | Bop (op, left, right) ->
      let v1 = eval_with_env env left in
      let v2 = eval_with_env env right in
      eval_binop op v1 v2
  
  (* conds *)
  | If (cond, then_, else_) -> (
      match eval_with_env env cond with
      | VBool true -> eval_with_env env then_
      | VBool false -> eval_with_env env else_
      | _ -> failwith "Condition of if-expression must be a boolean"
    )
  
  (* *)
  | Fun (arg, _, body) -> VClos { name = None; arg; body; env }
  
  (*apps *)
  | App (func, arg) -> (
      let func_val = eval_with_env env func in
      let arg_val = eval_with_env env arg in
      match func_val with
      | VClos { name = None; arg = arg_name; body; env = clos_env } ->
          eval_with_env (Env.add arg_name arg_val clos_env) body
      | VClos { name = Some name; arg = arg_name; body; env = clos_env } ->
          eval_with_env (Env.add name func_val (Env.add arg_name arg_val clos_env)) body
      | _ -> failwith "Attempting to apply a non-function"
    )
  
  (* Lets *)
  | Let { is_rec = false; name; ty = _ ; value; body } ->
      let value_val = eval_with_env env value in
      eval_with_env (Env.add name value_val env) body
  
  | Let { is_rec = true; name; ty = _; value; body } -> (
      match value with
      | Fun (arg, _, func_body) ->
          let rec_env = Env.add name (VClos { name = Some name; arg; body = func_body; env }) env in
          eval_with_env rec_env body
      | _ -> failwith "`let rec` right-hand side must be a function"
    )
  


    
  (*Assert*)
  | Assert cond -> (
      match eval_with_env env cond with
      | VBool true -> VUnit
      | VBool false -> raise AssertFail
      | _ -> failwith "Condition of assert must be a boolean"
    )
    | Unit -> VUnit
(*bin ops *)
and eval_binop (op : bop) (v1 : value) (v2 : value) : value =
  match (op, v1, v2) with
  | (Add, VNum n1, VNum n2) -> VNum (n1 + n2)
  | (Sub, VNum n1, VNum n2) -> VNum (n1 - n2)
  | (Mul, VNum n1, VNum n2) -> VNum (n1 * n2)
  | (Div, VNum n1, VNum n2) ->
      if n2 = 0 then raise DivByZero else VNum (n1 / n2)
  | (Mod, VNum n1, VNum n2) ->
      if n2 = 0 then raise DivByZero else VNum (n1 mod n2)
  | (Lt, VNum n1, VNum n2) -> VBool (n1 < n2)
  | (Lte, VNum n1, VNum n2) -> VBool (n1 <= n2)
  | (Gt, VNum n1, VNum n2) -> VBool (n1 > n2)
  | (Gte, VNum n1, VNum n2) -> VBool (n1 >= n2)
  | (Eq, VNum n1, VNum n2) -> VBool (n1 = n2)
  | (Neq, VNum n1, VNum n2) -> VBool (n1 <> n2)
  | (And, VBool b1, VBool b2) -> VBool (b1 && b2)
  | (Or, VBool b1, VBool b2) -> VBool (b1 || b2)
  | _ -> failwith "Invalid binary operation or operand types"

(*top*)
let eval (expr : expr) : value =
  eval_with_env Env.empty expr

  (* let rec string_of_expr = function
  | Unit -> "()"
  | True -> "true"
  | False -> "false"
  | Num n -> string_of_int n
  | Var x -> x
  | Bop (op, left, right) ->
      "(" ^ string_of_expr left ^ " " ^ string_of_bop op ^ " " ^ string_of_expr right ^ ")"
  | If (cond, then_, else_) ->
      "if " ^ string_of_expr cond ^ " then " ^ string_of_expr then_ ^ " else " ^ string_of_expr else_
  | Fun (arg, _, body) ->
      "fun " ^ arg ^ " -> " ^ string_of_expr body
  | App (fn, arg) ->
      string_of_expr fn ^ "(" ^ string_of_expr arg ^ ")"
  | Let { is_rec; name; ty = _; value; body } ->
      let rec_str = if is_rec then "rec " else "" in
      "let " ^ rec_str ^ name ^ " = " ^ string_of_expr value ^ " in " ^ string_of_expr body
  | Assert e -> "assert " ^ string_of_expr e


  let rec string_of_parsed_prog = function
  | [] -> "[]"
  | [t] -> string_of_toplet t
  | t :: ts -> string_of_toplet t ^ "; " ^ string_of_parsed_prog ts

and string_of_toplet toplet =
  let args_to_string args =
    if args = [] then ""
    else
      let arg_strings =
        List.map (fun (arg_name, _) -> arg_name) args
      in
      "(" ^ String.concat ", " arg_strings ^ ")"
  in
  let rec_str = if toplet.is_rec then "rec " else "" in
  let args_str = args_to_string toplet.args in
  let ty_str = string_of_ty toplet.ty in
  let value_str = string_of_sfexpr toplet.value in
  let name_str = toplet.name in
  "let " ^ rec_str ^ name_str ^ args_str ^ " : " ^ ty_str ^ " = " ^ value_str

and string_of_sfexpr = function
  | SUnit -> "()"
  | STrue -> "true"
  | SFalse -> "false"
  | SNum n -> string_of_int n
  | SVar x -> x
  | SFun { arg; args; body } ->
      let args_str = 
        arg :: args 
        |> List.map (fun (arg_name, _) -> arg_name)
        |> String.concat ", "
      in
      "fun " ^ args_str ^ " -> " ^ string_of_sfexpr body
  | SAssert e -> "assert " ^ string_of_sfexpr e
  | SApp (f, x) -> string_of_sfexpr f ^ "(" ^ string_of_sfexpr x ^ ")"
  | SLet { is_rec; name; args; ty; value; body } ->
      let rec_str = if is_rec then "rec " else "" in
      let args_str = 
        args 
        |> List.map (fun (arg_name, _) -> arg_name) 
        |> String.concat ", "
      in
      let ty_str = string_of_ty ty in
      "let " ^ rec_str ^ name ^ 
      (if args = [] then "" else "(" ^ args_str ^ ")") ^ 
      " : " ^ ty_str ^ " = " ^ string_of_sfexpr value ^ 
      " in " ^ string_of_sfexpr body
  | SIf (cond, then_, else_) ->
      "if " ^ string_of_sfexpr cond ^ " then " ^ string_of_sfexpr then_ ^ " else " ^ string_of_sfexpr else_
  | SBop (op, left, right) ->
      "(" ^ string_of_sfexpr left ^ " " ^ string_of_bop op ^ " " ^ string_of_sfexpr right ^ ")"
  *)

 
let interp (input : string) : (value, error) result =
  try
    (* Parse the input *)
    (* let _ = Stdlib320.print_string "Parsing input...\n" in *)
    match parse input with
    | None -> failwith "Parsing failed"
    | Some parsed_prog ->
      (* let _ = Stdlib320.print_string "Parsing successful!\n" in *)
      
      (* Print the parsed program *)
      (* let _ = Stdlib320.print_string ("Parsed program: " ^ (string_of_parsed_prog parsed_prog) ^ "\n") in *)
      

    (* let _ = Stdlib320.print_string "Desugaring program...\n" in *)
      let desugared_expr = desugar parsed_prog in
     (* let _ = Stdlib320.print_string "Desugaring successful!\n" in *)

     
      (* let _ = Stdlib320.print_string ("Desugared expression: " ^ (string_of_expr desugared_expr) ^ "\n") in *)

      (* Evaluate the desugared expression *)
      (* let _ = Stdlib320.print_string "Evaluating expression...\n" in *)
      let result = eval desugared_expr in
     (* let _ = Stdlib320.print_string "Evaluation successful!\n" in
      let result_str = match result with  
      | VNum n -> "Result: VInt " ^ string_of_int n 
      | VBool b -> "Result: VBool " ^ string_of_bool b 
      | VUnit -> "Result: VUnit" 
      | VClos _n -> "Result: Vclos" 
       in Stdlib320.print_string (result_str ^ "\n"); *)
      Ok result
  with
  | AssertFail -> 
   raise AssertFail
    
  | DivByZero -> 
   (* Stdlib320.print_string "Division by zero error!\n"; *)
    raise DivByZero
