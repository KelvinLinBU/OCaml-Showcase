open Utils
include My_parser

exception AssertFail
exception DivByZero
exception RecWithoutArg
exception CompareFunVals





let rec free_the_type_vars (ty : ty) : ident list =
  let  add_unique vars v =
    if List.mem v vars then vars else v :: vars
  in
  match ty with
  | TUnit | TInt | TFloat | TBool -> []
  | TVar v -> [v]


  | TList t | TOption t -> free_the_type_vars t
  | TPair (t1, t2) | TFun (t1, t2) ->
          let vars1 = free_the_type_vars t1 in
      let vars2 = free_the_type_vars t2 in
      List.fold_left add_unique vars1 vars2



  let general (_ctxt : stc_env) (ty : ty) : ty_scheme =
    let vars = free_the_type_vars ty in
    Forall (vars, ty)
  

    let rec apply_subst subst ty =
      match ty with
      | TUnit | TInt | TFloat | TBool -> ty
      | TVar v -> 
        (try apply_subst subst (List.assoc v subst) with Not_found -> TVar v)
    
      | TList t -> TList (apply_subst subst t)

      | TOption t -> TOption (apply_subst subst t)

      | TPair (t1, t2) -> TPair (apply_subst subst t1, apply_subst subst t2)

      | TFun (t1, t2) -> TFun (apply_subst subst t1, apply_subst subst t2)




let unify (ty) (constraints ) : ty_scheme option =
  let rec unify constraints subst =
    match constraints with
    | [] -> Some subst  

    | (t1, t2) :: rest ->

      let t1 = apply_subst subst t1 in
      let t2 = apply_subst subst t2 in
      match (t1, t2) with
     
      | TUnit, TUnit | TInt, TInt | TFloat, TFloat | TBool, TBool ->
          unify rest subst
          
          | TInt, TBool | TInt, TList _ | TInt, TOption _ 
          | TBool, TList _ | TBool, TOption _ 
          | TFloat, TBool | TFloat, TList _ | TFloat, TOption _ 
          | TUnit, TList _ | TUnit, TOption _ 
          | TList _, TFun _ | TOption _, TPair _ 
            -> None
          
          | TVar v, ty -> 
            if ty = TVar v then unify rest subst
            else if occurs v ty then None



            else 
              let subst = (v, ty) :: subst in 
              unify (List.map (fun (t1, t2) -> 
                (apply_subst [(v, ty)] t1, apply_subst [(v, ty)] t2)
              ) rest) subst
        | ty, TVar v -> 
            if ty = TVar v then unify rest subst
            else if occurs v ty then None
              
            else 
              let subst = (v, ty) :: subst in 
              unify (List.map (fun (t1, t2) -> 
                (apply_subst [(v, ty)] t1, apply_subst [(v, ty)] t2)
              ) rest) subst
        
    
      | TList t1, TList t2 | TOption t1, TOption t2 ->
          unify ((t1, t2) :: rest) subst

      | TPair (t1, t2), TPair (t1', t2') ->
          unify ((t1, t1') :: (t2, t2') :: rest) subst

      | TFun (t1, t2), TFun (t1', t2') ->


          unify ((t1, t1') :: (t2, t2') :: rest) subst

    
     
   
      | _, _ -> None
        

        
        and occurs v ty =
          match ty with

          | TUnit | TInt | TFloat | TBool -> false

          | TVar v' -> v = v'

          | TList t | TOption t -> occurs v t

          | TPair (t1, t2) | TFun (t1, t2) -> occurs v t1 || occurs v t2

        in
        match unify constraints [] with
        | Some subst -> Some (Forall (free_the_type_vars (apply_subst subst ty), apply_subst subst ty))
        | None -> None

(* Custom function to combine two lists into a list of pairs *)
let rec zip lst1 lst2 =
  match (lst1, lst2) with
  | ([], []) -> []
  | (x :: xs, y :: ys) -> (x, y) :: zip xs ys
  | _ -> failwith "Lists have different lengths"


let rec infer_type (ctxt ) (expr) : (ty * constr list) option =
  match expr with
  (* lits*)
   (*Binopps*)
   | Bop (op, e1, e2) ->
    
    (match infer_type ctxt e1 with
     | Some (t1, c1) ->
         (match infer_type ctxt e2 with
          | Some (t2, c2) ->
              let constraints = c1 @ c2 in
              (match op with
               | Add | Sub | Mul | Div | Mod ->
                   (* Arithmetic operators require TInt and result in TInt *)
                  
                   Some (TInt, (t1, TInt) :: (t2, TInt) :: constraints)

               | AddF | SubF | MulF | DivF | PowF ->
                  
                   Some (TFloat, (t1, TFloat) :: (t2, TFloat) :: constraints)

               | Eq | Neq ->
                  
                Some (TBool, (t1, t2) :: constraints)

               | Lt | Lte | Gt | Gte ->
                   
                Some (TBool, (t1, t2) :: constraints)
               | And | Or ->
                 
                   Some (TBool, (t1, TBool) :: (t2, TBool) :: constraints)

               | Cons ->
                  
                (
                  match infer_type ctxt e1 with
                  | Some (t1, c1) -> (
                      match infer_type ctxt e2 with
                      | Some (t2, c2) ->
                          
                          let constraints = (t2, TList t1) :: (c1 @ c2) in
                          Some (TList t1, constraints)
                      | None -> None)
                  | None -> None)

               | Concat ->
                 
                (
                  match infer_type ctxt e1 with
                  | Some (t1, c1) -> (
                      match infer_type ctxt e2 with
                      | Some (t2, c2) ->
                          let alpha = TVar (gensym ()) in
                          
                          let constraints = (t1, TList alpha) :: (t2, TList alpha) :: (c1 @ c2) in
                          Some (TList alpha, constraints)
                      | None -> None)
                  | None -> None)
               | Comma ->
        
                (
                  match infer_type ctxt e1 with
                  | Some (t1, c1) -> (
                      match infer_type ctxt e2 with
                      | Some (t2, c2) ->
                        
                          let constraints = c1 @ c2 in
                          Some (TPair (t1, t2), constraints)
                      | None -> None)
                  | None -> None)
                  )
          | None -> None)
     | None -> None)
| Unit ->
  
    Some (TUnit, [])
| Int _ ->
  
    Some (TInt, [])
| Float _ ->
 
    Some (TFloat, [])
| True | False ->

    Some (TBool, [])
  | Nil ->
  (*alpha*)
    let alpha = TVar (gensym ()) in 
    Some (TList alpha, [])
  | ENone ->

    let alpha = TVar (gensym ()) in
    Some (TOption alpha, [])
  (*var *)
  | Var x ->

    
    (match Env.find_opt x ctxt with
    | Some (Forall (vars, ty)) ->
        (* Instantiate polymorphic type *)
        let fresh_vars = List.map (fun _ -> TVar (gensym ())) vars in
        let subst = zip vars fresh_vars in
        let instantiated_ty = apply_subst subst ty in
        Some (instantiated_ty, [])
    | None -> None)
  (* annot*)
  | Annot (e, annotated_ty) ->

    (match infer_type ctxt e with
     | Some (inferred_ty, constraints) ->
       let constraints = (inferred_ty, annotated_ty) :: constraints in
       Some (annotated_ty, constraints)
     | None -> None)
  (*ASSert*)
  | Assert e -> 
    (match infer_type ctxt e with 
     | Some (ty_e, c_e) -> 
         if ty_e = TBool then
          
     match e with
           | False -> 
               let alpha = TVar (gensym ()) in
               Some (alpha, c_e)  
           | _ ->
             
               let constraints = (ty_e, TBool) :: c_e in
               Some (TUnit, constraints)
         else
           None  
     | None -> None)
     (*Comma*)


  
 


  (*iffy *)
  | If (cond, then_branch, else_branch) ->

    (match infer_type ctxt cond with

     | Some (ty_cond, c_cond) ->

       (match infer_type ctxt then_branch with

        | Some (ty_then, c_then) ->

          (match infer_type ctxt else_branch with

           | Some (ty_else, c_else) ->

             let constraints = (ty_cond, TBool) :: (ty_then, ty_else) :: c_cond @ c_then @ c_else in

             Some (ty_then, constraints)
           | None -> None)
        | None -> None)
     | None -> None)
  (* not fun *)
  | Fun (arg, ty_opt, body) ->
(*new var w gensym*)
    let arg_ty = match ty_opt with Some t -> t | None -> TVar (gensym ()) in

    let ctxt_arg = Env.add arg (Forall ([], arg_ty)) ctxt in
    (match infer_type ctxt_arg body with
     | Some (body_ty, c_body) ->
       Some (TFun (arg_ty, body_ty), c_body)
     | None -> None)
  (*apply *)
  | App (func, arg) ->

    (match infer_type ctxt func with
     | Some (ty_func, c_func) ->
       (match infer_type ctxt arg with
        | Some (ty_arg, c_arg) ->
          let alpha = TVar (gensym ()) in

          let constraints = (ty_func, TFun (ty_arg, alpha)) :: c_func @ c_arg in

          Some (alpha, constraints)
        | None -> None)
     | None -> None)
  (* let false *)
  | Let { is_rec = false; name; value; body } ->

    (match infer_type ctxt value with
     | Some (ty_value, c_value) ->
       (match unify ty_value c_value with
        | Some ty_scheme_value ->
          let Forall (_, ty_value_unified) = ty_scheme_value in

          let generalized_ty = general ctxt ty_value_unified in

          let new_ctxt = Env.add name generalized_ty ctxt in

          infer_type new_ctxt body
        | None ->

          None)
     | None ->

       None)
  (* let rec true *)
  | Let { is_rec = true; name; value; body } ->
   
    (*bro *)
    let a = TVar (gensym ()) in
    let b = TVar (gensym ()) in
    let f_ty = TFun (a, b) in

    (*crying *)
    let ctxt_with_rec = Env.add name (Forall ([], f_ty)) ctxt in

    (*pain*)
    (match value with
     | Fun (arg, _, body_fun) ->
     
         let ctxt_with_arg = Env.add arg (Forall ([], a)) ctxt_with_rec in


         (match infer_type ctxt_with_arg body_fun with
          | Some (body_ty, c1) ->
              (* unify *)
              let constraints = (body_ty, b) :: c1 in
            
              (match infer_type ctxt_with_rec body with



               | Some (body_ty, c2) ->
                   let combined_constraints = constraints @ c2 in
                   Some (body_ty, combined_constraints)
               | None -> None)
          | None -> None)
     | _ ->
 
         None)

  (*opt match *)
  | OptMatch { matched; some_name; some_case; none_case } ->
  
    (match infer_type ctxt matched with
     | Some (ty_matched, c_matched) ->
       let alpha = TVar (gensym ()) in
       let constraints = (ty_matched, TOption alpha) :: c_matched in
       let ctxt_some = Env.add some_name (Forall ([], alpha)) ctxt in
       (match infer_type ctxt_some some_case with
        | Some (ty_some_case, c_some_case) ->
          (match infer_type ctxt none_case with
           | Some (ty_none_case, c_none_case) ->
             let constraints = (ty_some_case, ty_none_case) :: constraints @ c_some_case @ c_none_case in
             Some (ty_some_case, constraints)
           | None -> None)
        | None -> None)
     | None -> None)
  (* Lists*)
  | ListMatch { matched; hd_name; tl_name; cons_case; nil_case } ->

    (match infer_type ctxt matched with
     | Some (ty_matched, c_matched) ->
       let alpha = TVar (gensym ()) in
       let constraints = (ty_matched, TList alpha) :: c_matched in
       let ctxt_cons = Env.add hd_name (Forall ([], alpha)) (Env.add tl_name (Forall ([], TList alpha)) ctxt) in
       (match infer_type ctxt_cons cons_case with
        | Some (ty_cons_case, c_cons_case) ->
          (match infer_type ctxt nil_case with
           | Some (ty_nil_case, c_nil_case) ->
             let constraints = (ty_cons_case, ty_nil_case) :: constraints @ c_cons_case @ c_nil_case in
             Some (ty_cons_case, constraints)
           | None -> None)
        | None -> None)
     | None -> None)
  (* Pairs *)
  | PairMatch { matched; fst_name; snd_name; case } ->
  
    (match infer_type ctxt matched with

     | Some (ty_matched, c_matched) ->
       let alpha = TVar (gensym ()) in
       let beta = TVar (gensym ()) in
       let constraints = (ty_matched, TPair (alpha, beta)) :: c_matched in
       let ctxt_pair = Env.add fst_name (Forall ([], alpha)) (Env.add snd_name (Forall ([], beta)) ctxt) in
       (match infer_type ctxt_pair case with
        | Some (ty_case, c_case) ->
          Some (ty_case, constraints @ c_case)
        | None -> None)
     | None -> None
     )
   

  (* Esome *)
  | ESome e ->

    (match infer_type ctxt e with

     | Some (ty_e, c_e) ->
       Some (TOption ty_e, c_e)
     | None -> None)
    
    
    
     let free_vars_in_ctxt ctxt =
      let ctxt_list = Env.to_list ctxt in
      List.fold_left (fun acc (_, Forall (_, ty)) ->
        let vars = free_the_type_vars ty in
        List.fold_left (fun acc v -> if List.mem v acc then acc else v :: acc) acc vars
      ) [] ctxt_list



let type_of ctxt expr : ty_scheme option =
        match infer_type ctxt expr with
        | Some (ty, constraints) -> (
           
            match unify ty constraints with
            | Some (Forall (vars, unified_ty)) ->
                
                let subst = List.map (fun v -> (v, TVar (gensym ()))) vars in
                
              
                let substituted_ty = apply_subst subst unified_ty in
      
             
                let free_vars_in_ctxt = free_vars_in_ctxt ctxt in
                
              
                let free_vars = free_the_type_vars substituted_ty in
                let generalized_vars = 
                  List.fold_left (fun acc v -> if List.mem v free_vars_in_ctxt then acc else v :: acc) [] free_vars  in
                Some (Forall (generalized_vars, substituted_ty))
            | None -> 
              None
          )
        | None -> None


(*helper func for comparison*)
let rec compare_values v1 v2 =
  match v1, v2 with
| VInt n1, VInt n2 -> compare_int n1 n2
| VFloat f1, VFloat f2 -> compare_float f1 f2
| VBool b1, VBool b2 -> compare_bool b1 b2
| VUnit, VUnit -> 0
| VList l1, VList l2 -> compare_lists l1 l2
| VPair (a1, b1), VPair (a2, b2) ->
      let c = compare_values a1 a2 in
      if c <> 0 then c else compare_values b1 b2
| VSome v1, VSome v2 -> compare_values v1 v2
| VNone, VNone -> 0
| VClos _, VClos _ -> raise CompareFunVals
| _, _ -> raise CompareFunVals

and compare_int n1 n2 =

  if n1 = n2 then 0 else if n1 < n2 then -1 else 1

and compare_float f1 f2 =

  if f1 = f2 then 0 else if f1 < f2 then -1 else 1

and compare_bool b1 b2 =

match b1, b2 with
| true, false -> 1
| true, true -> 0
  | false, false -> 0
  | false, true -> -1


and compare_lists l1 l2 =

  match l1, l2 with
  | [], [] -> 0
  | [], _ -> -1
  | _, [] -> 1
  | x1 :: xs1, x2 :: xs2 -> let c = compare_values x1 x2 in if c <> 0 then c else compare_lists xs1 xs2




        
(*for evaluation of binary ops*)
let eval_bop op v1 v2 =
  match op with

  | Add ->
      (match v1, v2 with
       | VInt n1, VInt n2 -> VInt (n1 + n2)
       | _ -> failwith "add two integers")

  | Sub ->
      (match v1, v2 with
       | VInt n1, VInt n2 -> VInt (n1 - n2)
       | _ -> failwith "sub two integers")
  | SubF ->
        (match v1, v2 with
         | VFloat f1, VFloat f2 -> VFloat (f1 -. f2)
         | _ -> failwith "sub floats two floats")
  
    | MulF ->
        (match v1, v2 with
         | VFloat f1, VFloat f2 -> VFloat (f1 *. f2)
         | _ -> failwith "mult floatstwo floats")
  
    | DivF ->
        (match v1, v2 with
         | VFloat f1, VFloat f2 ->
          if f2 = 0.0 then raise DivByZero 
          else VFloat (f1 /. f2)
         | _ -> failwith "dvstwo floats")
  | Mul ->
      (match v1, v2 with
       | VInt n1, VInt n2 -> VInt (n1 * n2)
       | _ -> failwith "mul  two integers")

  | Div ->
      (match v1, v2 with
       | VInt n1, VInt n2 -> if n2 = 0 then raise DivByZero  else VInt (n1 / n2)
       | _ -> failwith "divtwo integers")

  | Mod ->
      (match v1, v2 with
       | VInt n1, VInt n2 -> VInt (n1 mod n2)
       | _ -> failwith "mod two integers")

  | AddF ->
      (match v1, v2 with
       | VFloat f1, VFloat f2 -> VFloat (f1 +. f2)
       | _ -> failwith "addf two floats")

  

  | PowF ->
      (match v1, v2 with
       | VFloat f1, VFloat f2 -> VFloat (f1 ** f2)
       | _ -> failwith " two floats")


       | Or ->
        (match v1, v2 with
         | VBool b1, VBool b2 -> VBool (b1 || b2)
         | _ -> failwith "boolean vals required")
  (*bools*)

  | And ->
      (match v1, v2 with
       | VBool b1, VBool b2 -> VBool (b1 && b2)
       | _ -> failwith "boolean vals required")

  (*comparison*)
  | Eq ->
      VBool (try compare_values v1 v2 = 0 with Failure _ -> false)
  | Neq ->
      VBool (try compare_values v1 v2 <> 0 with Failure _ -> true)
  (* comparison *)
  | Lt ->
      VBool (try compare_values v1 v2 < 0 with Failure _ -> raise CompareFunVals)
  | Lte ->
      VBool (try compare_values v1 v2 <= 0 with Failure _ -> raise CompareFunVals)
  | Gt ->
      VBool (try compare_values v1 v2 > 0 with Failure _ -> raise CompareFunVals)
  | Gte ->
      VBool (try compare_values v1 v2 >= 0 with Failure _ -> raise CompareFunVals)

  (* lists *)
  | Cons ->
      (match v2 with
       | VList l -> VList (v1 :: l)
       | _ -> failwith "")
  | Concat ->
      (match v1, v2 with
       | VList l1, VList l2 -> VList (l1 @ l2)
       | _ -> failwith "concat needs two lists")
  (* paris *)
  | Comma ->
      VPair (v1, v2)
 


  let rec eval_expr (env : value env) (expr : expr) : value =
    match expr with


    | Unit -> VUnit

    | Int n -> VInt n
    | Float f -> VFloat f
    | True -> VBool true
    | False -> VBool false
    | Nil -> VList []
    | ENone -> VNone
  
    | Var x ->


      (match Env.find_opt x env with
       | Some v ->

           v
       | None ->

           failwith ("unbound variable " ^ x))
 
    | Assert e ->
        let v = eval_expr env e in
        (match v with
         | VBool true -> VUnit
         | VBool false -> raise AssertFail
         | _ -> failwith "Rassert fail")
 
    | Fun (arg, _, body) ->
        VClos { name = None; arg; body; env }
 
    | App (func, arg) ->

  

      let v_func = eval_expr env func in
      let v_arg = eval_expr env arg in

  
  
      (match v_func with
       | VClos { name = Some fname; arg = param; body; env = clos_env } ->

  
      
           let env_with_rec_and_arg =
             Env.add fname v_func (Env.add param v_arg clos_env)
           in
  

  
      
           eval_expr env_with_rec_and_arg body
  
       | VClos { name = None; arg = param; body; env = clos_env } ->

             let env_with_arg = Env.add param v_arg clos_env in

  
  
           eval_expr env_with_arg body
  
       | _ ->

           failwith ("calling a nonfunction"))
  
       | Let { is_rec = false; name; value; body } ->

   
        let v_value = eval_expr env value in
 

        let env' = Env.add name v_value env in

    
   
        (match value with
         | Let { is_rec = true; name = f; value = Fun (x, _, body_fun); body = inner_body } ->
            
             let placeholder_closure =
               VClos { name = Some f; arg = x; body = body_fun; env = env' }


             in
             let env_with_placeholder = Env.add f placeholder_closure env' in


             let closure =
               VClos { name = Some f; arg = x; body = body_fun; env = env_with_placeholder }


             in
             let env_with_rec = Env.add f closure env' in
             let _result = eval_expr env_with_rec inner_body in
   
             eval_expr env_with_rec body 
         | _ ->
      
             let result = eval_expr env' body in

             result)

        | Let { is_rec = true; name = f; value; body = e2 } ->
    
          (match value with
           | Fun (x, _, body_fun) ->
            
      
           
               let placeholder_closure =
                 VClos { name = Some f; arg = x; body = body_fun; env = env }
               in
     
      
        
               let env_with_placeholder = Env.add f placeholder_closure env in

      
       
               let closure =
                 VClos { name = Some f; arg = x; body = body_fun; env = env_with_placeholder }
               in
   
      
      
               let env_with_rec = Env.add f closure env in
        
      
            
    
               let result = eval_expr env_with_rec e2 in

               result
           | _ ->
              raise RecWithoutArg)
      
 
    | Bop (op, e1, e2) ->

        let v1 = eval_expr env e1 in

        let v2 = eval_expr env e2 in

        eval_bop op v1 v2
  
    | If (cond, then_branch, else_branch) ->
        let v_cond = eval_expr env cond in
        (match v_cond with
         | VBool true -> eval_expr env then_branch

         | VBool false -> eval_expr env else_branch

         | _ -> raise AssertFail)


    | ESome e ->
        let v = eval_expr env e in
        VSome v

    | ListMatch { matched; hd_name; tl_name; cons_case; nil_case } ->

        let v_matched = eval_expr env matched in
        (match v_matched with
         | VList (hd :: tl) ->
             let env' = Env.add hd_name hd (Env.add tl_name (VList tl) env) in
             eval_expr env' cons_case


         | VList [] ->
             eval_expr env nil_case
         | _ -> failwith "need a list")

    | OptMatch { matched; some_name; some_case; none_case } ->
        let v_matched = eval_expr env matched in
        (match v_matched with
         | VSome v ->
             let env' = Env.add some_name v env in
             eval_expr env' some_case

         | VNone ->
             eval_expr env none_case
         | _ -> failwith "need  an option")
 
    | PairMatch { matched; fst_name; snd_name; case } ->
        let v_matched = eval_expr env matched in
        (match v_matched with
         | VPair (v1, v2) ->
             let env' = Env.add fst_name v1 (Env.add snd_name v2 env) in
             eval_expr env' case
         | _ -> failwith "nedd a pair")
  
    | Annot (e, _) ->
        eval_expr env e
    
  
      let type_check =
        let rec go ctxt = function
        | [] -> Some (Forall ([], TUnit))
        | {is_rec;name;value} :: ls ->
          match type_of ctxt (Let {is_rec;name;value; body = Var name}) with
          | Some ty -> (
            match ls with
            | [] -> Some ty
            | _ ->
              let ctxt = Env.add name ty ctxt in
              go ctxt ls
          )
          | None -> None
        in go Env.empty

let eval p =
  let rec nest = function
    | [] -> Unit
    | [{ is_rec; name; value }] -> Let { is_rec; name; value; body = Var name }
    | { is_rec; name; value } :: ls -> Let { is_rec; name; value; body = nest ls }
  in
  eval_expr Env.empty (nest p)

let interp input =
  match parse input with
  | Some prog ->
    
    (match type_check prog with
    | Some ty ->

      let result = eval prog in
      Ok (result, ty)
    | None ->
      
      Error TypeError)
  | None ->

    Error ParseError
