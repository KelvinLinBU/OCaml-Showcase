open OUnit2
open Lib
open Stdlib320
open Utils



let rec compare_values v1 v2 =
  match (v1, v2) with
  | (VUnit, VUnit) -> true
  | (VBool b1, VBool b2) -> b1 = b2
  | (VNum n1, VNum n2) -> n1 = n2
  | (VClos { name = n1; arg = a1; body = b1; env = _ },
     VClos { name = n2; arg = a2; body = b2; env = _ }) ->
      (* Compare closures by their names, arguments, and body expressions *)
      n1 = n2 && a1 = a2 && compare_exprs b1 b2
  | _ -> false

and compare_exprs e1 e2 =
  match (e1, e2) with
  | (Unit, Unit) -> true
  | (True, True) -> true
  | (False, False) -> true
  | (Num n1, Num n2) -> n1 = n2
  | (Var x1, Var x2) -> x1 = x2
  | (Bop (op1, l1, r1), Bop (op2, l2, r2)) ->
      op1 = op2 && compare_exprs l1 l2 && compare_exprs r1 r2
  | (If (c1, t1, e1), If (c2, t2, e2)) ->
      compare_exprs c1 c2 && compare_exprs t1 t2 && compare_exprs e1 e2
  | (Fun (a1, t1, b1), Fun (a2, t2, b2)) ->
      a1 = a2 && t1 = t2 && compare_exprs b1 b2
  | (App (f1, a1), App (f2, a2)) ->
      compare_exprs f1 f2 && compare_exprs a1 a2
  | (Let { is_rec = r1; name = n1; ty = _; value = v1; body = b1 },
     Let { is_rec = r2; name = n2; ty = _; value = v2; body = b2 }) ->
      r1 = r2 && n1 = n2 && compare_exprs v1 v2 && compare_exprs b1 b2
  | (Assert e1, Assert e2) -> compare_exprs e1 e2
  | _ -> false


let rec string_of_value = function
  | VUnit -> "()"
  | VBool b -> string_of_bool b
  | VNum n -> string_of_int n
  | VClos { name; arg; body; env = _ } ->
      let name_str = match name with
        | Some n -> n
        | None -> "<anonymous>"
      in
      Printf.sprintf "<closure %s (%s) -> %s>" name_str arg (string_of_expr body)

and string_of_expr = function
  | Unit -> "()"
  | True -> "true"
  | False -> "false"
  | Num n -> string_of_int n
  | Var x -> x
  | Bop (op, left, right) ->
      Printf.sprintf "(%s %s %s)" (string_of_expr left) (string_of_bop op) (string_of_expr right)
  | If (cond, then_, else_) ->
      Printf.sprintf "if %s then %s else %s" (string_of_expr cond) (string_of_expr then_) (string_of_expr else_)
  | Fun (arg, _, body) ->
      Printf.sprintf "fun %s -> %s" arg (string_of_expr body)
  | App (fn, arg) ->
      Printf.sprintf "%s(%s)" (string_of_expr fn) (string_of_expr arg)
  | Let { is_rec; name; ty = _; value; body } ->
      let rec_str = if is_rec then "rec " else "" in
      Printf.sprintf "let %s%s = %s in %s" rec_str name (string_of_expr value) (string_of_expr body)
  | Assert e -> "assert " ^ string_of_expr e

  (* Assert Evaluation *)
  let assert_eval expr expected =
    let result = eval expr in
    assert_equal ~printer:string_of_value expected result
  
  let assert_eval_exception expr exn =
    assert_raises exn (fun () -> ignore (eval expr))
  
  (* Test Cases *)
  let test_functions_edge_cases _ =
    (* Anonymous functions *)
    let anon_func = Fun ("x", IntTy, Bop (Add, Var "x", Num 1)) in
    assert_eval (App (anon_func, Num 41)) (VNum 42)

  let test_literals _ =
    assert_eval (Num 42) (VNum 42);
    assert_eval True (VBool true);
    assert_eval False (VBool false);
    assert_eval Unit VUnit
  
  let test_binary_operations_extended _ =
    assert_eval (Bop (Add, Num (-5), Num 3)) (VNum (-2)); (* -5 + 3 *)
    assert_eval (Bop (Mul, Num (-3), Num (-2))) (VNum 6); (* -3 * -2 *)
    assert_eval (Bop (Eq, Num 0, Num (-0))) (VBool true); (* 0 = -0 *)
    assert_eval (Bop (Lt, Num (-1), Num 0)) (VBool true); (* -1 < 0 *)
    assert_eval (Bop (Lte, Num 5, Num 5)) (VBool true);
    assert_eval (Bop (Gte, Num 5, Num 6)) (VBool false);
    assert_eval
    (Bop (Add, Bop (Add, Num 1, Num 2), Num 3)) (VNum 6); (* (1 + 2) + 3 *)
  assert_eval
    (Bop (Add, Num 1, Bop (Add, Num 2, Num 3))) (VNum 6); (* 1 + (2 + 3) *)

  (* Mixed comparisons *)
  assert_eval (Bop (And, Bop (Lt, Num 1, Num 2), Bop (Gt, Num 3, Num 2))) (VBool true);
  assert_eval (Bop (Or, Bop (Eq, Num 3, Num 4), Bop (Neq, Num 4, Num 4))) (VBool false);

    assert_eval_exception (Bop (Add, True, False)) (Failure "Invalid binary operation or operand types")
  
  let test_function_application _ =
    let func = Fun ("x", IntTy, Bop (Mul, Var "x", Num 2)) in
    assert_eval (App (func, Num 10)) (VNum 20);
    let nested_func = Fun ("x", IntTy, Fun ("y", IntTy, Bop (Add, Var "x", Var "y"))) in
    assert_eval (App (App (nested_func, Num 3), Num 4)) (VNum 7)
  
  let test_recursive_function_extended _ =
    let fib_expr =
      Let {
        is_rec = true;
        name = "fib";
        ty = IntTy;
        value = Fun (
          "n",
          IntTy,
          If (
            Bop (Lte, Var "n", Num 1),
            Var "n",
            Bop (Add, App (Var "fib", Bop (Sub, Var "n", Num 1)), App (Var "fib", Bop (Sub, Var "n", Num 2)))
          )
        );
        body = App (Var "fib", Num 6);
      }
    in
    assert_eval fib_expr (VNum 8)
  
  let test_let_expressions_extended _ =
    (* Let binding inside another let binding *)
    let nested_let_expr =
      Let {
        is_rec = false;
        name = "x";
        ty = IntTy;
        value = Num 10;
        body = Let {
          is_rec = false;
          name = "y";
          ty = IntTy;
          value = Num 20;
          body = Bop (Add, Var "x", Var "y")
        }
      }
    in
    assert_eval nested_let_expr (VNum 30)
  
  let test_assertions_extended _ =
    let assert_pass = Assert (Bop (Eq, Num 3, Num 3)) in
    let assert_fail = Assert (Bop (Lt, Num 5, Num 2)) in
    assert_eval assert_pass VUnit;
    assert_eval_exception assert_fail AssertFail
  
  let test_conditional_with_assert _ =
    let conditional_assert_expr =
      If (
        Bop (Eq, Num 5, Num 5),
        Assert (Bop (Gt, Num 10, Num 1)),
        Assert (Bop (Lt, Num 10, Num 1))
      )
    in
    assert_eval conditional_assert_expr VUnit
  
    let test_conditionals_extended _ =
      (* Boolean conditions *)
      assert_eval (If (True, Num 1, Num 0)) (VNum 1);
      assert_eval (If (False, Num 1, Num 0)) (VNum 0);
    
      (* Complex conditions *)
      assert_eval (If (Bop (Lt, Num 5, Num 10), Num 42, Num 0)) (VNum 42);
      assert_eval (If (Bop (Gt, Num 10, Num 20), Num 1, Bop (Sub, Num 10, Num 2))) (VNum 8);
    
      (* Invalid conditions *)
      assert_eval_exception (If (Num 42, Num 1, Num 0)) (Failure "Condition of if-expression must be a boolean")
    
  let test_comprehensive_recursive_let _ =
    let sum_to_n_expr =
      Let {
        is_rec = true;
        name = "sum_to_n";
        ty = IntTy;
        value = Fun (
          "n",
          IntTy,
          If (
            Bop (Lte, Var "n", Num 0),
            Num 0,
            Bop (Add, Var "n", App (Var "sum_to_n", Bop (Sub, Var "n", Num 1)))
          )
        );
        body = App (Var "sum_to_n", Num 10);
      }
    in
    assert_eval sum_to_n_expr (VNum 55)
  
  (* Suite *)

  let test_let_expressions_edge_cases _ =
    (* Nested let expressions *)
    let nested_let_expr =
      Let {
        is_rec = false;
        name = "x";
        ty = IntTy;
        value = Num 2;
        body = Let {
          is_rec = false;
          name = "y";
          ty = IntTy;
          value = Bop (Mul, Var "x", Num 5);
          body = Bop (Add, Var "y", Num 1);
        }
      }
    in
    assert_eval nested_let_expr (VNum 11)
  
    
  
  let eval_tests =
    "Extended Eval Test Suite" >::: [
      "test_literals" >:: test_literals;
      "test_anon" >:: test_functions_edge_cases;
      "test_binary_operations_extended" >:: test_binary_operations_extended;
      "test_function_application" >:: test_function_application;
      "test_recursive_function_extended" >:: test_recursive_function_extended;
      "test_let_expressions_extended" >:: test_let_expressions_extended;
      "test_assertions_extended" >:: test_assertions_extended;
      "test_conditional_with_assert" >:: test_conditional_with_assert;
      "test_comprehensive_recursive_let" >:: test_comprehensive_recursive_let;
      "test_conditionals_extended" >:: test_conditionals_extended;
      "test_let_expressions_edge_cases" >:: test_let_expressions_edge_cases
    ]
  
  let () = run_test_tt_main eval_tests