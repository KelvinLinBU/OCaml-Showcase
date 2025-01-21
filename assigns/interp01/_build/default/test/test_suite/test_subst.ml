open OUnit2
open Utils
open Lib
let subst_test =
  "subst_test" >:::
  [
    (* Test: Substitution of a simple variable *)
    "test_subst_simple" >:: (fun _ ->
      let expr = Var "x" in
      let v = VNum 10 in
      let expected = Num 10 in
      print_endline ("Running test: test_subst_simple");
      print_endline ("Substituting variable 'x' with value 10");
      let result = subst v "x" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Substitution with a complex expression (like a function) *)
    "test_subst_with_fun" >:: (fun _ ->
      let expr = Fun ("y", Var "y") in
      let v = VNum 10 in
      let expected = Fun ("y", Num 10) in
      print_endline ("Running test: test_subst_with_fun");
      print_endline ("Substituting variable 'y' inside function");
      let result = subst v "y" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Substitution with a Let expression *)
    "test_subst_with_let" >:: (fun _ ->
      let expr = Let ("x", Num 5, Var "x") in
      let v = VNum 10 in
      let expected = Let ("x", Num 5, Num 10) in
      print_endline ("Running test: test_subst_with_let");
      print_endline ("Substituting variable 'x' in Let expression");
      let result = subst v "x" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Nested substitution in Let *)
    "test_subst_nested_let" >:: (fun _ ->
      let expr = Let ("x", Num 5, Let ("y", Var "x", Var "y")) in
      let v = VNum 10 in
      let expected = Let ("x", Num 5, Let ("y", Num 10, Num 10)) in
      print_endline ("Running test: test_subst_nested_let");
      print_endline ("Substituting variable 'x' in nested Let expressions");
      let result = subst v "x" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Substitution when variable does not match *)
    "test_subst_no_match" >:: (fun _ ->
      let expr = Var "z" in
      let v = VNum 10 in
      let expected = Var "z" in
      print_endline ("Running test: test_subst_no_match");
      print_endline ("Substitution should not happen since 'z' is not 'x'");
      let result = subst v "x" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Capture avoidance in Let bindings *)
    "test_subst_capture_avoidance" >:: (fun _ ->
      let expr = Let ("x", Var "z", Var "x") in
      let v = VNum 10 in
      let expected = Let ("x", Var "z", Num 10) in
      print_endline ("Running test: test_subst_capture_avoidance");
      print_endline ("Substituting variable 'x' and avoiding capture in Let bindings");
      let result = subst v "x" expr in
      print_endline ("Result of substitution: " ^ string_of_expr result);
      assert_equal expected result
    );

    (* Test: Substitution with debugging prints for every step *)
    "test_subst_debug_prints" >:: (fun _ ->
      let expr = Let ("x", Num 5, Let ("y", Var "x", Var "y")) in
      let v = VNum 10 in
      print_endline ("Running test: test_subst_debug_prints");
      print_endline ("Starting substitution...");
      print_endline ("Expression before substitution: " ^ string_of_expr expr);
      let result = subst v "x" expr in
      print_endline ("Expression after substitution: " ^ string_of_expr result);
      let expected = Let ("x", Num 5, Let ("y", Num 10, Num 10)) in
      assert_equal expected result
    );
  ]

let _ = OUnit2.run_test_tt_main subst_test
