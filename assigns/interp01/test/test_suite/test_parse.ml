open OUnit2
open Utils (* Assuming prog and related types are defined here *)
open Lib (* Assuming this contains your implementation *)

(* Helper function to compare the result of parse with expected output *)
let assert_parse_equal input expected =
  match parse input with
  | Some parsed -> assert_equal expected parsed
  | None -> assert_failure ("Failed to parse: " ^ input)

(* Test cases for the parse function *)
let test_parse_basic _ =
  let input1 = "let x : int = 42" in
  let expected1 =
    [Let ("x", [], TyInt, Num 42)] (* Adjust based on your AST representation *)
  in
  assert_parse_equal input1 expected1;

  let input2 = "let rec f (x : int) : int = x + 1" in
  let expected2 =
    [LetRec ("f", [("x", TyInt)], TyInt, BinOp ("+", Var "x", Num 1))]
  in
  assert_parse_equal input2 expected2

let test_parse_complex _ =
  let input = "let f (x : int) : int = if x > 0 then x else 0" in
  let expected =
    [Let ("f", [("x", TyInt)], TyInt,
          If (BinOp (">", Var "x", Num 0), Var "x", Num 0))]
  in
  assert_parse_equal input expected

(* Add more tests for edge cases and invalid inputs *)
let test_parse_invalid _ =
  let invalid_input1 = "let x : int" in
  assert_equal None (parse invalid_input1);

  let invalid_input2 = "fun x ->" in
  assert_equal None (parse invalid_input2)

(* Suite combining all parse tests *)
let parse_tests =
  "Parse Tests" >:::
  [
    "Basic Examples" >:: test_parse_basic;
    "Complex Examples" >:: test_parse_complex;
    "Invalid Inputs" >:: test_parse_invalid;
  ]

(* Add more test suites for desugar, type_of, eval, etc. if needed *)

let _ = OUnit2.run_test_tt_main parse_tests
