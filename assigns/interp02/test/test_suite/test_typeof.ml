open OUnit2
open Utils
open Lib (* Replace with the module name where type_of is defined *)

(* Helper functions *)
let assert_type_of expr expected_ty =
  match type_of expr with
  | Ok ty ->
      assert_equal ~msg:("Expected type: " ^ string_of_ty expected_ty ^ ", but got: " ^ string_of_ty ty)
        expected_ty ty
  | Error err ->
      assert_failure ("Expected type: " ^ string_of_ty expected_ty ^ ", but got error: " ^ err_msg err)

let assert_type_of_error expr expected_err =
  match type_of expr with
  | Ok ty ->
      assert_failure ("Expected error: " ^ err_msg expected_err ^ ", but got type: " ^ string_of_ty ty)
  | Error err ->
      assert_equal ~msg:("Expected error: " ^ err_msg expected_err ^ ", but got: " ^ err_msg err)
        expected_err err

(* Test Variables *)
let test_variables _ =
  let bound_variable_expr =
    Let {
      is_rec = false;
      name = "x";
      ty = IntTy;
      value = Num 42;
      body = Var "x";
    }
  in
  assert_type_of bound_variable_expr IntTy;

  let unbound_variable_expr = Var "y" in
  assert_type_of_error unbound_variable_expr (UnknownVar "y")

(* Test Literals *)
let test_literals _ =
  assert_type_of Unit UnitTy;
  assert_type_of True BoolTy;
  assert_type_of False BoolTy;
  assert_type_of (Num 42) IntTy

(* Test Binary Operations *)
let test_binary_operations _ =
  let valid_expr = Bop (Add, Num 2, Num 3) in
  assert_type_of valid_expr IntTy;

  let invalid_expr = Bop (Add, True, Num 3) in
  assert_type_of_error invalid_expr (OpTyErrL (Add, IntTy, BoolTy))

(* Test If-Expressions *)
let test_if_expressions _ =
  let valid_if_expr =
    If (True, Num 1, Num 2)
  in
  assert_type_of valid_if_expr IntTy;

  let invalid_cond_expr =
    If (Num 1, Num 2, Num 3)
  in
  assert_type_of_error invalid_cond_expr (IfCondTyErr IntTy);

  let mismatched_branches_expr =
    If (True, Num 1, True)
  in
  assert_type_of_error mismatched_branches_expr (IfTyErr (IntTy, BoolTy))

(* Test Functions *)
let test_functions _ =
  let valid_fun_expr =
    Fun ("x", IntTy, Bop (Add, Var "x", Num 3))
  in
  assert_type_of valid_fun_expr (FunTy (IntTy, IntTy));

  let invalid_body_expr =
    Fun ("x", IntTy, Bop (Add, Var "x", True))
  in
  assert_type_of_error invalid_body_expr (OpTyErrR (Add, IntTy, BoolTy))

(* Test Function Applications *)
let test_function_applications _ =
  let valid_fun_app_expr =
    Let {
      is_rec = false;
      name = "f";
      ty = FunTy (IntTy, IntTy);
      value = Fun ("x", IntTy, Bop (Add, Var "x", Num 3));
      body = App (Var "f", Num 5);
    }
  in
  assert_type_of valid_fun_app_expr IntTy;

  let invalid_arg_type_expr =
    Let {
      is_rec = false;
      name = "f";
      ty = FunTy (IntTy, IntTy);
      value = Fun ("x", IntTy, Bop (Add, Var "x", Num 3));
      body = App (Var "f", True);
    }
  in
  assert_type_of_error invalid_arg_type_expr (FunArgTyErr (IntTy, BoolTy))

(* Test Let Expressions *)
let test_let_expressions _ =
  let valid_let_expr =
    Let {
      is_rec = false;
      name = "x";
      ty = IntTy;
      value = Num 42;
      body = Bop (Add, Var "x", Num 3);
    }
  in
  assert_type_of valid_let_expr IntTy;

  let mismatched_let_expr =
    Let {
      is_rec = false;
      name = "x";
      ty = BoolTy;
      value = Num 42;
      body = Var "x";
    }
  in
  assert_type_of_error mismatched_let_expr (LetTyErr (BoolTy, IntTy))

(* Test Assertions *)
let test_assertions _ =
  let valid_assert_expr =
    Assert (Bop (Eq, Num 42, Num 42))
  in
  assert_type_of valid_assert_expr UnitTy;

  let invalid_assert_expr =
    Assert (Num 42)
  in
  assert_type_of_error invalid_assert_expr (AssertTyErr IntTy)

(* Combine all tests into a test suite *)
let type_of_tests =
  "type_of Tests" >:::
  [
    "Variables" >:: test_variables;
    "Literals" >:: test_literals;
    "Binary Operations" >:: test_binary_operations;
    "If Expressions" >:: test_if_expressions;
    "Functions" >:: test_functions;
    "Function Applications" >:: test_function_applications;
    "Let Expressions" >:: test_let_expressions;
    "Assertions" >:: test_assertions;
  ]

(* Entry point for running tests *)
let _ = run_test_tt_main type_of_tests
