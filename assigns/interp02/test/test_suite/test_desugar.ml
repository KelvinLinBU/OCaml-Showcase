(* test/test_desugar.ml *)

open OUnit2
open Lib
open Utils


(* Convert expressions to strings *)
let rec string_of_expr = function
  | Unit -> "Unit"
  | True -> "True"
  | False -> "False"
  | Num n -> "Num " ^ string_of_int n
  | Var v -> "Var \"" ^ v ^ "\""
  | Fun (arg, ty, body) ->
      "Fun (\"" ^ arg ^ "\", " ^ string_of_ty ty ^ ", " ^ string_of_expr body ^ ")"
  | App (f, x) ->
      "App (" ^ string_of_expr f ^ ", " ^ string_of_expr x ^ ")"
  | Let { is_rec; name; ty; value; body } ->
      "Let { is_rec = " ^ string_of_bool is_rec ^
      "; name = \"" ^ name ^
      "\"; ty = " ^ string_of_ty ty ^
      "; value = " ^ string_of_expr value ^
      "; body = " ^ string_of_expr body ^ " }"
  | If (cond, then_, else_) ->
      "If (" ^ string_of_expr cond ^ ", " ^
      string_of_expr then_ ^ ", " ^
      string_of_expr else_ ^ ")"
  | Bop (op, left, right) ->
      "Bop (" ^ string_of_bop op ^ ", " ^
      string_of_expr left ^ ", " ^
      string_of_expr right ^ ")"
  | Assert e ->
      "Assert (" ^ string_of_expr e ^ ")"
(* Test Cases *)

let test_simple_let_binding _ =
  let toplet = {
    is_rec = false;
    name = "x";
    args = [];
    ty = IntTy;
    value = SNum 5;
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "x";
    ty = IntTy;
    value = Num 5;
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_single_argument_let_binding _ =
  let toplet = {
    is_rec = false;
    name = "f";
    args = [("x", IntTy)];
    ty = BoolTy;
    value = SFun { arg = ("x", IntTy); args = []; body = SBop (Gt, SVar "x", SNum 0) };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "f";
    ty = FunTy (IntTy, BoolTy);
    value = Fun ("x", IntTy, Bop (Gt, Var "x", Num 0));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_multiple_arguments_let_binding _ =
  let toplet = {
    is_rec = true;
    name = "add";
    args = [("x", IntTy); ("y", IntTy)];
    ty = IntTy;
    value = SFun { arg = ("x", IntTy); args = [("y", IntTy)]; body = SBop (Add, SVar "x", SVar "y") };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = true;
    name = "add";
    ty = FunTy (IntTy, FunTy (IntTy, IntTy));
    value = Fun ("x", IntTy, Fun ("y", IntTy, Bop (Add, Var "x", Var "y")));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_nested_let_bindings _ =
  let toplet1 = {
    is_rec = false;
    name = "x";
    args = [];
    ty = IntTy;
    value = SNum 5;
  } in
  let toplet2 = {
    is_rec = false;
    name = "y";
    args = [];
    ty = IntTy;
    value = SNum 10;
  } in
  let toplet3 = {
    is_rec = false;
    name = "z";
    args = [];
    ty = IntTy;
    value = SBop (Add, SVar "x", SVar "y");
  } in
  let prog = [toplet1; toplet2; toplet3] in
  let expected = Let {
    is_rec = false;
    name = "x";
    ty = IntTy;
    value = Num 5;
    body = Let {
      is_rec = false;
      name = "y";
      ty = IntTy;
      value = Num 10;
      body = Let {
        is_rec = false;
        name = "z";
        ty = IntTy;
        value = Bop (Add, Var "x", Var "y");
        body = Unit;
      };
    };
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_anonymous_function_single_arg _ =
  let toplet = {
    is_rec = false;
    name = "f";
    args = [("x", IntTy)];
    ty = FunTy (IntTy, IntTy);
    value = SFun { arg = ("x", IntTy); args = []; body = SBop (Mul, SVar "x", SNum 2) };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "f";
    ty = FunTy (IntTy, IntTy);
    value = Fun ("x", IntTy, Bop (Mul, Var "x", Num 2));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_anonymous_function_multiple_args _ =
  let toplet = {
    is_rec = false;
    name = "g";
    args = [("x", IntTy); ("y", IntTy); ("z", BoolTy)];
    ty = FunTy (IntTy, FunTy (IntTy, FunTy (BoolTy, IntTy)));
    value = SFun { 
      arg = ("x", IntTy); 
      args = [("y", IntTy); ("z", BoolTy)]; 
      body = SBop (Add, SVar "x", SVar "y") 
    };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "g";
    ty = FunTy (IntTy, FunTy (IntTy, FunTy (BoolTy, IntTy)));
    value = Fun ("x", IntTy, Fun ("y", IntTy, Fun ("z", BoolTy, Bop (Add, Var "x", Var "y"))));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_application _ =
  let toplet = {
    is_rec = false;
    name = "app_test";
    args = [];
    ty = IntTy;
    value = SApp (SVar "f", SVar "x");
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "app_test";
    ty = IntTy;
    value = App (Var "f", Var "x");
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_nested_application _ =
  let toplet = {
    is_rec = false;
    name = "nested_app";
    args = [];
    ty = IntTy;
    value = SApp (SApp (SVar "f", SVar "x"), SVar "y");
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "nested_app";
    ty = IntTy;
    value = App (App (Var "f", Var "x"), Var "y");
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_conditional _ =
  let toplet = {
    is_rec = false;
    name = "if_test";
    args = [];
    ty = BoolTy;
    value = SIf (SVar "cond", SVar "then_branch", SVar "else_branch");
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "if_test";
    ty = BoolTy;
    value = If (Var "cond", Var "then_branch", Var "else_branch");
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_binary_operations _ =
  let toplet = {
    is_rec = false;
    name = "binary_op";
    args = [];
    ty = IntTy;
    value = SBop (Sub, SNum 10, SNum 5);
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "binary_op";
    ty = IntTy;
    value = Bop (Sub, Num 10, Num 5);
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_assertion _ =
  let toplet = {
    is_rec = false;
    name = "assert_test";
    args = [];
    ty = UnitTy;
    value = SAssert (SVar "x");
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "assert_test";
    ty = UnitTy;
    value = Assert (Var "x");
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_no_toplet_bindings _ =
  let prog = [] in
  let expected = Unit in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_complex_program _ =
  let toplet1 = {
    is_rec = false;
    name = "x";
    args = [];
    ty = IntTy;
    value = SNum 5;
  } in
  let toplet2 = {
    is_rec = false;
    name = "f";
    args = [("y", IntTy)];
    ty = FunTy (IntTy, IntTy);
    value = SFun { arg = ("y", IntTy); args = []; body = SBop (Add, SVar "x", SVar "y") };
  } in
  let toplet3 = {
    is_rec = false;
    name = "result";
    args = [];
    ty = IntTy;
    value = SApp (SVar "f", SNum 10);
  } in
  let prog = [toplet1; toplet2; toplet3] in
  let expected = Let {
    is_rec = false;
    name = "x";
    ty = IntTy;
    value = Num 5;
    body = Let {
      is_rec = false;
      name = "f";
      ty = FunTy (IntTy, IntTy);
      value = Fun ("y", IntTy, Bop (Add, Var "x", Var "y"));
      body = Let {
        is_rec = false;
        name = "result";
        ty = IntTy;
        value = App (Var "f", Num 10);
        body = Unit;
      };
    };
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

(* Additional Test Cases *)

let test_recursive_let_binding_no_args _ =
  let toplet = {
    is_rec = true;
    name = "x";
    args = [];
    ty = IntTy;
    value = SNum 5;
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = true;
    name = "x";
    ty = IntTy;
    value = Num 5;
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_anonymous_function_returning_function _ =
  let toplet = {
    is_rec = false;
    name = "h";
    args = [("x", IntTy); ("y", IntTy)];
    ty = FunTy (IntTy, FunTy (IntTy, IntTy));
    value = SFun { 
      arg = ("x", IntTy); 
      args = [("y", IntTy)]; 
      body = SFun { 
        arg = ("z", BoolTy); 
        args = []; 
        body = SBop (Add, SVar "x", SVar "y") 
      } 
    };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "h";
    ty = FunTy (IntTy, FunTy (IntTy, IntTy));
    value = Fun ("x", IntTy, Fun ("y", IntTy, Fun ("z", BoolTy, Bop (Add, Var "x", Var "y"))));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_application_of_functions_returning_functions _ =
  let toplet = {
    is_rec = false;
    name = "apply_test";
    args = [];
    ty = IntTy;
    value = SApp (SApp (SVar "f", SVar "x"), SVar "y");
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "apply_test";
    ty = IntTy;
    value = App (App (Var "f", Var "x"), Var "y");
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result

let test_conditional_inside_let_binding _ =
  let toplet = {
    is_rec = false;
    name = "f_cond";
    args = [("x", IntTy)];
    ty = BoolTy;
    value = SFun { 
      arg = ("x", IntTy); 
      args = []; 
      body = SIf (SVar "x", STrue, SFalse) 
    };
  } in
  let prog = [toplet] in
  let expected = Let {
    is_rec = false;
    name = "f_cond";
    ty = FunTy (IntTy, BoolTy);
    value = Fun ("x", IntTy, If (Var "x", True, False));
    body = Unit;
  } in
  let result = desugar prog in
  assert_equal ~printer:string_of_expr expected result


  let test_higher_order_function _ =
    let toplet = {
      is_rec = false;
      name = "apply_twice";
      args = [("f", FunTy (IntTy, IntTy)); ("x", IntTy)];
      ty = IntTy;
      value = SFun {
        arg = ("f", FunTy (IntTy, IntTy));
        args = [("x", IntTy)];
        body = SApp (SVar "f", SApp (SVar "f", SVar "x"))
      };
    } in
    let prog = [toplet] in
    let expected = Let {
      is_rec = false;
      name = "apply_twice";
      ty = FunTy (FunTy (IntTy, IntTy), FunTy (IntTy, IntTy));
      value = Fun ("f", FunTy (IntTy, IntTy),
        Fun ("x", IntTy,
          App (Var "f", App (Var "f", Var "x"))
        ));
      body = Unit;
    } in
    let result = desugar prog in
    assert_equal ~printer:string_of_expr expected result
  

    let test_function_with_conditional _ =
      let toplet = {
        is_rec = false;
        name = "sign";
        args = [("x", IntTy)];
        ty = IntTy;
        value = SFun {
          arg = ("x", IntTy);
          args = [];
          body = SIf (
            SBop (Lt, SVar "x", SNum 0),
            SNum (-1),
            SIf (SBop (Eq, SVar "x", SNum 0), SNum 0, SNum 1)
          )
        };
      } in
      let prog = [toplet] in
      let expected = Let {
        is_rec = false;
        name = "sign";
        ty = FunTy (IntTy, IntTy);
        value = Fun ("x", IntTy,
          If (
            Bop (Lt, Var "x", Num 0),
            Num (-1),
            If (Bop (Eq, Var "x", Num 0), Num 0, Num 1)
          ));
        body = Unit;
      } in
      let result = desugar prog in
      assert_equal ~printer:string_of_expr expected result
    

      let test_let_with_assertions _ =
        let toplet = {
          is_rec = false;
          name = "test";
          args = [];
          ty = UnitTy;
          value = SLet {
            is_rec = false;
            name = "x";
            args = [];
            ty = IntTy;
            value = SNum 5;
            body = SAssert (SBop (Eq, SVar "x", SNum 5));
          };
        } in
        let prog = [toplet] in
        let expected = Let {
          is_rec = false;
          name = "test";
          ty = UnitTy;
          value = Let {
            is_rec = false;
            name = "x";
            ty = IntTy;
            value = Num 5;
            body = Assert (Bop (Eq, Var "x", Num 5));
          };
          body = Unit;
        } in
        let result = desugar prog in
        assert_equal ~printer:string_of_expr expected result
      

        let test_recursive_factorial _ =
          let toplet = {
            is_rec = true;
            name = "factorial";
            args = [("n", IntTy)];
            ty = FunTy (IntTy, IntTy);
            value = SFun {
              arg = ("n", IntTy);
              args = [];
              body = SIf (
                SBop (Lte, SVar "n", SNum 1),
                SNum 1,
                SBop (Mul, SVar "n", SApp (SVar "factorial", SBop (Sub, SVar "n", SNum 1)))
              )
            };
          } in
          let prog = [toplet] in
          let expected = Let {
            is_rec = true;
            name = "factorial";
            ty = FunTy (IntTy, IntTy);
            value = Fun ("n", IntTy,
              If (
                Bop (Lte, Var "n", Num 1),
                Num 1,
                Bop (Mul, Var "n", App (Var "factorial", Bop (Sub, Var "n", Num 1)))
              ));
            body = Unit;
          } in
          let result = desugar prog in
          assert_equal ~printer:string_of_expr expected result
          let test_deeply_nested_functions _ =
            let toplet = {
              is_rec = true;
              name = "nested";
              args = [("x", IntTy)];
              ty = FunTy (IntTy, FunTy (IntTy, IntTy));
              value = SFun {
                arg = ("x", IntTy);
                args = [("y", IntTy)];
                body = SFun {
                  arg = ("z", IntTy);
                  args = [];
                  body = SBop (Add, SVar "x", SBop (Add, SVar "y", SVar "z"))
                }
              };
            } in
            let prog = [toplet] in
            let expected = Let {
              is_rec = true;
              name = "nested";
              ty = FunTy (IntTy, FunTy (IntTy, FunTy (IntTy, IntTy)));
              value = Fun ("x", IntTy,
                Fun ("y", IntTy,
                  Fun ("z", IntTy,
                    Bop (Add, Var "x", Bop (Add, Var "y", Var "z"))
                  )));
              body = Unit;
            } in
            let result = desugar prog in
            assert_equal ~printer:string_of_expr expected result
                  
(* Define the test suite *)
let suite =
  "Desugar Test Suite" >::: [
    "test_simple_let_binding" >:: test_simple_let_binding;
    "test_single_argument_let_binding" >:: test_single_argument_let_binding;
    "test_multiple_arguments_let_binding" >:: test_multiple_arguments_let_binding;
    "test_nested_let_bindings" >:: test_nested_let_bindings;
    "test_anonymous_function_single_arg" >:: test_anonymous_function_single_arg;
    "test_anonymous_function_multiple_args" >:: test_anonymous_function_multiple_args;
    "test_application" >:: test_application;
    "test_nested_application" >:: test_nested_application;
    "test_conditional" >:: test_conditional;
    "test_binary_operations" >:: test_binary_operations;
    "test_assertion" >:: test_assertion;
    "test_no_toplet_bindings" >:: test_no_toplet_bindings;
    "test_complex_program" >:: test_complex_program;
    "test_recursive_let_binding_no_args" >:: test_recursive_let_binding_no_args;
    "test_anonymous_function_returning_function" >:: test_anonymous_function_returning_function;
    "test_application_of_functions_returning_functions" >:: test_application_of_functions_returning_functions;
    "test_conditional_inside_let_binding" >:: test_conditional_inside_let_binding;
    "higher order" >:: test_higher_order_function;
    "func with conditionals" >:: test_function_with_conditional;
    "test_deeply_nested_functions" >:: test_deeply_nested_functions;
    "test_recursive_factorial" >:: test_recursive_factorial;
    "test_let_with_assertions" >:: test_let_with_assertions;
  ]

(* Run the test suite *)
let () =
  run_test_tt_main suite
