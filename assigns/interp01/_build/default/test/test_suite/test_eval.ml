(*

open OUnit2
open Utils (* Assuming Utility defines value, error, etc. *)
open Lib (* Assuming Lib is where eval and subst are defined *)


(* Helper function to test eval with expressions *)
let eval_test expr expected ctxt =
  let result = eval expr in
  let result_str = match result with
    | Some v -> "Some " ^ (string_of_value v)
    | None -> "None"
  in
  let expected_str = match expected with
    | Some v -> "Some " ^ (string_of_value v)
    | None -> "None"
  in
  assert_equal ~ctxt ~printer:(fun x -> x) expected_str result_str

(* Eval test cases *)
let eval_tests = "Eval tests" >::: [

  (* Literal values *)
  "eval_int_literal" >:: eval_test (Num 5) (Some (VNum 5));
  "eval_true_literal" >:: eval_test True (Some (VBool true));
  "eval_false_literal" >:: eval_test False (Some (VBool false));
  "eval_unit_literal" >:: eval_test Unit (Some VUnit);

  (* Arithmetic operations *)
  "eval_add" >:: eval_test (Bop (Add, Num 3, Num 2)) (Some (VNum 5));
  "eval_div_zero" >:: eval_test (Bop (Div, Num 10, Num 0)) None;

  (* Boolean operations *)
  "eval_and_true_false" >:: eval_test (Bop (And, True, False)) (Some (VBool false));
  "eval_or_true_false" >:: eval_test (Bop (Or, True, False)) (Some (VBool true));

  (* Conditional expressions *)
  "eval_if_true" >:: eval_test (If (True, Num 1, Num 2)) (Some (VNum 1));
  "eval_if_nonbool" >:: eval_test (If (Num 1, Num 2, Num 3)) None;

  (* Function evaluation *)
  "eval_fun_identity" >:: eval_test (App (Fun ("x", Var "x"), Num 5)) (Some (VNum 5));
  "eval_fun_add" >:: eval_test (App (Fun ("x", Bop (Add, Var "x", Num 2)), Num 3)) (Some (VNum 5));

  (* Let bindings *)
  "eval_let_binding" >:: eval_test (Let ("x", Num 3, Bop (Add, Var "x", Num 2))) (Some (VNum 5));
  "eval_let_shadowing" >:: eval_test (Let ("x", Num 3, Let ("x", Num 4, Bop (Add, Var "x", Num 2)))) (Some (VNum 6));

  (* Variable errors *)
  "eval_unbound_var" >:: eval_test (Var "y") None;

  (* Recursive function tests *)
  "eval_recursive_factorial" >:: eval_test (
    Let ("fact", App (Fun ("fact", Fun ("n",
      If (Bop (Lte, Var "n", Num 0),
          Num 1,
          Bop (Mul, Var "n", App (Var "fact", Bop (Sub, Var "n", Num 1)))
      ))), Var "fact"), App (Var "fact", Num 5))
  ) (Some (VNum 120));

  "eval_recursive_fibonacci" >:: eval_test (
    Let ("fib", App (Fun ("fib", Fun ("n",
      If (Bop (Lte, Var "n", Num 1),
          Var "n",
          Bop (Add, App (Var "fib", Bop (Sub, Var "n", Num 1)), App (Var "fib", Bop (Sub, Var "n", Num 2)))
      ))), Var "fib"), App (Var "fib", Num 6))
  ) (Some (VNum 8));
]*)