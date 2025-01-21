(* test_parser.ml *)
open OUnit2

open Stdlib320
open Utils
open My_parser

let rec string_of_ty ty =
  match ty with
  | IntTy -> "int"
  | BoolTy -> "bool"
  | UnitTy -> "unit"
  | FunTy (t1, t2) -> Printf.sprintf "(%s -> %s)" (string_of_ty t1) (string_of_ty t2)

let rec string_of_sfexpr expr =
  match expr with
  | SNum n -> string_of_int n
  | SVar v -> v
  | STrue -> "true"
  | SFalse -> "false"
  | SUnit -> "()"
  | SIf (e1, e2, e3) ->
      Printf.sprintf "if %s then %s else %s" (string_of_sfexpr e1) (string_of_sfexpr e2) (string_of_sfexpr e3)
  | SFun { arg; args; body } ->
      let args_str = String.concat " " (List.map (fun (v, t) -> Printf.sprintf "(%s : %s)" v (string_of_ty t)) (arg :: args)) in
      Printf.sprintf "fun %s -> %s" args_str (string_of_sfexpr body)
  | SLet { is_rec; name; args; ty; value; body } ->
      let rec_str = if is_rec then "rec " else "" in
      let args_str = String.concat " " (List.map (fun (v, t) -> Printf.sprintf "(%s : %s)" v (string_of_ty t)) args) in
      Printf.sprintf "let %s%s %s : %s = %s in %s" rec_str name args_str (string_of_ty ty) (string_of_sfexpr value) (string_of_sfexpr body)
  | SApp (e1, e2) -> Printf.sprintf "(%s %s)" (string_of_sfexpr e1) (string_of_sfexpr e2)
  | SBop (op, e1, e2) -> Printf.sprintf "(%s %s %s)" (string_of_sfexpr e1) (string_of_bop op) (string_of_sfexpr e2)
  | SAssert e -> Printf.sprintf "assert %s" (string_of_sfexpr e)

and string_of_bop op =
  match op with
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "mod"
  | Lt -> "<"
  | Lte -> "<="
  | Gt -> ">"
  | Gte -> ">="
  | Eq -> "="
  | Neq -> "<>"
  | And -> "&&"
  | Or -> "||"

let string_of_toplet toplet =
  let { is_rec; name; args; ty; value } = toplet in
  let rec_str = if is_rec then "rec " else "" in
  let args_str = String.concat " " (List.map (fun (v, t) -> Printf.sprintf "(%s : %s)" v (string_of_ty t)) args) in
  Printf.sprintf "let %s%s %s : %s = %s" rec_str name args_str (string_of_ty ty) (string_of_sfexpr value)

let string_of_prog prog =
  String.concat "\n" (List.map string_of_toplet prog)

(* Assume parse function is available *)
(* val parse : string -> prog option *)
(* Replace this placeholder with your actual parse function implementation *)

(* Helper function to compare ASTs *)
let assert_prog_equal expected actual =
  let expected_str = string_of_prog expected in
  let actual_str = string_of_prog actual in
  assert_equal ~printer:(fun x -> x) expected_str actual_str

(* Test cases for valid inputs *)
let test_parse_valid_input _ =
  let test_cases = [
    (* Simple numeric literal *)
    ("let x : int = 42",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy; value = SNum 42 }]);

    (* Simple variable *)
    ("let x : int = y",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy; value = SVar "y" }]);

    (* Simple addition *)
    ("let x : int = 1 + 2",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy; value = SBop (Add, SNum 1, SNum 2) }]);

    (* Function application *)
    ("let x : int = f y",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy; value = SApp (SVar "f", SVar "y") }]);

    (* Let expression *)
    ("let x : int = let y : int = 2 in y + 1",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy;
        value = SLet { is_rec = false; name = "y"; args = []; ty = IntTy; value = SNum 2;
                       body = SBop (Add, SVar "y", SNum 1) } }]);

    (* If expression *)
    ("let x : int = if true then 1 else 0",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy;
        value = SIf (STrue, SNum 1, SNum 0) }]);

    (* Function definition *)
    ("let f (x : int) : int = x + 1",
     [{ is_rec = false; name = "f"; args = [("x", IntTy)]; ty = IntTy;
        value = SFun { arg = ("x", IntTy); args = []; body = SBop (Add, SVar "x", SNum 1) } }]);

    (* Recursive function *)
    ("let rec fact (n : int) : int = if n = 0 then 1 else n * fact (n - 1)",
     [{ is_rec = true; name = "fact"; args = [("n", IntTy)]; ty = IntTy;
        value = SFun { arg = ("n", IntTy); args = []; body =
          SIf (SBop (Eq, SVar "n", SNum 0), SNum 1,
               SBop (Mul, SVar "n", SApp (SVar "fact", SBop (Sub, SVar "n", SNum 1)))) } }]);

    (* Complex expression with operator precedence *)
    ("let x : int = 1 + 2 * 3",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy;
        value = SBop (Add, SNum 1, SBop (Mul, SNum 2, SNum 3)) }]);

    (* Function type *)
    ("let f : int -> int -> bool = fun (x : int) (y : int) -> x < y",
     [{ is_rec = false; name = "f"; args = []; ty = FunTy (IntTy, FunTy (IntTy, BoolTy));
        value = SFun { arg = ("x", IntTy); args = [("y", IntTy)];
                       body = SBop (Lt, SVar "x", SVar "y") } }]);

    (* Assert *)
    ("let x : unit = assert y > 0",
     [{ is_rec = false; name = "x"; args = []; ty = UnitTy;
        value = SAssert (SBop (Gt, SVar "y", SNum 0)) }]);

    (* Parentheses *)
    ("let x : int = (1 + 2) * 3",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy;
        value = SBop (Mul, SBop (Add, SNum 1, SNum 2), SNum 3) }]);

    (* Nested function applications *)
    ("let x : int = f (g y) z",
     [{ is_rec = false; name = "x"; args = []; ty = IntTy;
        value = SApp (SApp (SVar "f", SApp (SVar "g", SVar "y")), SVar "z") }]);

    (* Function with multiple arguments *)
    ("let add (x : int) (y : int) : int = x + y",
     [{ is_rec = false; name = "add"; args = [("x", IntTy); ("y", IntTy)]; ty = IntTy;
        value = SFun { arg = ("x", IntTy); args = [("y", IntTy)]; body = SBop (Add, SVar "x", SVar "y") } }]);
  ] in
  let rec run_valid_tests cases =
    match cases with
    | [] -> ()
    | (input, expected_ast) :: rest ->
        (match parse input with
        | Some ast ->
            assert_prog_equal expected_ast ast
        | None ->
            assert_failure (Printf.sprintf "Parsing failed for valid input: %s" input));
        run_valid_tests rest
  in
  run_valid_tests test_cases

(* Test cases for invalid inputs *)
let test_parse_invalid_input _ =
  let invalid_inputs = [
    "";                                 (* Empty input *)
    "let";                              (* Incomplete let *)
    "if true then";                     (* Incomplete if *)
    "fun -> x";                         (* Missing argument *)
    "1 +";                              (* Incomplete expression *)
    "let x = 1 in";                     (* Incomplete let-in *)
    "assert";                           (* Missing expression *)
    "int ->";                           (* Incomplete type *)
    "let x : = 1";                      (* Syntax error *)
    "let x : int = if";                 (* Incomplete if expression *)
    "let x : int = fun";                (* Incomplete function *)
    "let x : int = assert";             (* Missing expression after assert *)
    "let x : int = (1 + 2";             (* Missing closing parenthesis *)
    "let x : int = 1 + )";              (* Unmatched closing parenthesis *)
    "let x : int = 1 ++ 2";             (* Invalid operator *)
    "let x : int = ;";                  (* Missing expression *)
    "let x : int = 1 + ;";              (* Incomplete expression *)
    "let x : int = let y : int = in x"; (* Missing value in inner let *)
  ] in
  let rec run_invalid_tests inputs =
    match inputs with
    | [] -> ()
    | input :: rest ->
        (match parse input with
        | Some _ ->
            assert_failure (Printf.sprintf "Parsing should have failed for invalid input: %s" input)
        | None ->
            ());
        run_invalid_tests rest
  in
  run_invalid_tests invalid_inputs

let suite =
  "Parser Tests" >::: [
    "test_parse_valid_input" >:: test_parse_valid_input;
    "test_parse_invalid_input" >:: test_parse_invalid_input;
  ]

let () =
  run_test_tt_main suite