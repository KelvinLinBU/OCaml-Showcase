open OUnit2
open Lib
open Stdlib320
open Utils

(* Helper Functions *)

(* Converts a value to a string for assertions *)
let string_of_value = function
  | VUnit -> "()"
  | VBool b -> string_of_bool b
  | VNum n -> string_of_int n
  | VClos { name; arg; body = _; env = _ } ->
      let name_str = Option.value ~default:"<anonymous>" name in
      Printf.sprintf "Closure(%s, %s, <body>)" name_str arg

(* Asserts that interp evaluates to a specific value *)
let assert_interp input expected_value =
  match interp input with
  | Ok value -> 
      assert_equal
        ~msg:("Expected: " ^ string_of_value expected_value ^ ", but got: " ^ string_of_value value)
        expected_value value
  | Error err ->
      assert_failure ("Expected: " ^ string_of_value expected_value ^ ", but got error: " ^ err_msg err)

(* Asserts that interp produces a specific error *)
let assert_interp_error input expected_error =
  match interp input with
  | Ok value ->
      assert_failure ("Expected error: " ^ err_msg expected_error ^ ", but got value: " ^ string_of_value value)
  | Error err ->
      assert_equal
        ~msg:("Expected error: " ^ err_msg expected_error ^ ", but got: " ^ err_msg err)
        expected_error err

(* Test Cases *)

(* Test Literals *)
let test_literals _ =
  assert_interp "let x : int = 2\nx" (VNum 2);
  assert_interp "let b : bool = true\nb" (VBool true);
  assert_interp "()" VUnit

(* Test Binary Operations *)
let test_binary_operations _ =
  assert_interp "let x : int = 2 + 3\nx" (VNum 5);
  assert_interp_error "let x : int = true + 3\nx" (OpTyErrL (Add, IntTy, BoolTy))

(* Test If Expressions *)
let test_if_expressions _ =
  assert_interp "let x : int = if true then 1 else 2\nx" (VNum 1);
  assert_interp_error "let x : int = if 42 then 1 else 2\nx" (IfCondTyErr IntTy)

(* Test Functions *)
let test_functions _ =
  assert_interp
    "let f (x : int) : int = x + 1\nf 5"
    (VNum 6);
  assert_interp_error
    "let f (x : int) : int = x + 1\nf true"
    (FunArgTyErr (IntTy, BoolTy))

(* Test Assertions *)
let test_assertions _ =
  assert_interp
    "let _ : unit = assert (42 = 42)"
    VUnit;
  assert_interp_error
    "let _ : unit = assert (42 = 43)"
    (AssertTyErr BoolTy)

(* Test Recursive Functions *)
let test_recursive_functions _ =
  assert_interp
    "let rec factorial (n : int) : int = if n <= 1 then 1 else n * factorial (n - 1)\nfactorial 5"
    (VNum 120);
  assert_interp_error
    "let rec factorial (n : int) : int = if n <= 1 then true else n * factorial (n - 1)\nfactorial 5"
    (OpTyErrR (Mul, IntTy, BoolTy))

(* Test Let Expressions *)
let test_let_expressions _ =
  assert_interp
    "let x : int = 42\nlet y : int = x + 1\ny"
    (VNum 43);
  assert_interp_error
    "let x : bool = 42\nx"
    (LetTyErr (BoolTy, IntTy))

(* Test Full Program *)
let test_full_program _ =
  let input =
    "let sum_of_squares (x : int) (y : int) : int =\n\
     let x_squared : int = x * x in\n\
     let y_squared : int = y * y in\n\
     x_squared + y_squared\n\
     let _ : unit = assert (sum_of_squares 3 (-5) = 34)"
  in
  assert_interp input VUnit

(* Combine all tests into a test suite *)
let interp_tests =
  "interp Tests" >:::
  [
    "Literals" >:: test_literals;
    "Binary Operations" >:: test_binary_operations;
    "If Expressions" >:: test_if_expressions;
    "Functions" >:: test_functions;
    "Assertions" >:: test_assertions;
    "Recursive Functions" >:: test_recursive_functions;
    "Let Expressions" >:: test_let_expressions;
    "Full Program" >:: test_full_program;
  ]

(* Entry point for running tests *)
let _ = run_test_tt_main interp_tests
