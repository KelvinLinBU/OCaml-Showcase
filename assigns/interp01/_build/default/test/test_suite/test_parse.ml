

open OUnit2
open Utils
open Lib

let test s e =
  let d = "testing parse \"" ^ s ^ "\"" in
  let t _ =
    let a = parse s in
    assert_equal e a
  in d >: test_case ~length:(Custom_length 2.) t

let basic_examples = "basic parse examples" >:::
  [ test "2 + 3" (Some (Bop (Add, Num 2, Num 3)))
  ; test "" None
  ; test "3 + 3 * 3 + 3" (Some (Bop (Add, Bop (Add, Num 3, Bop (Mul, Num 3, Num 3)), Num 3)))
  ; test "(fun x -> x + 1) 2 3 4" (Some (App (App (App (Fun ("x", Bop (Add, Var "x", Num 1)), Num 2), Num 3), Num 4)))
  ; test "let x = 2 in x" (Some (Let ("x", Num 2, Var "x")))
  ; test "let x = x in in" None
  ; test "let fun = 2 in x" None
  ; test "let f = (fun x -> x) in f ()" (Some (Let ("f", Fun ("x", Var "x"), App (Var "f", Unit))))
  ; test "2 mod (if true then 2 else 3)" (Some (Bop (Mod, Num 2, If (True, Num 2, Num 3))))
  ; test "(((( 2 <= 3 <= 4 ))))" (Some (Bop (Lte, Bop (Lte, Num 2, Num 3), Num 4)))
  ; test "let rec fact = fun n -> if n <= 0 then 1 else n * fact (n - 1) in fact 5"
      (Some (Let ("fact", 
                  App (Fun ("fact", 
                            Fun ("n", 
                                 If (Bop (Lte, Var "n", Num 0), 
                                     Num 1, 
                                     Bop (Mul, Var "n", App (Var "fact", Bop (Sub, Var "n", Num 1)))
                                    )
                                )
                           ), 
                       Var "fact"  (* This should be a single prog, not a tuple *)
                      )
                 ,
            App (Var "fact", Num 5))  (* The entire application of fact 5 as the final expression *)
          )
      )
      ]
