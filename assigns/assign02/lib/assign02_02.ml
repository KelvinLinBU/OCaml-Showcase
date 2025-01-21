type matrix = {
  entries : float list list;
  rows : int;
  cols : int;
}

let rec take n lst =
match (n, lst) with | (0, _) | (_, []) -> []  (*n=0 or empty*) | (_, x :: xs) -> x :: take (n - 1) xs  (*head*)

let rec drop n lst =
match (n, lst) with | (0, lst) -> lst  (*n=0 or empty*) | (_, []) -> []  (*empty*) | (_, _ :: xs) -> drop (n - 1) xs  (*drop head*)
  

let rec splitting lst row_length =
  match lst with | [] -> []  (*empty list then return empty list *) | _ ->  let row = List.(take row_length lst) in row :: splitting (List.(drop row_length lst)) row_length

(* mk_matrix *)
let mk_matrix (entries: float list) ((r, c): int * int) : matrix = let rows = splitting entries c in {entries = rows; rows = r; cols = c }  (* make matrix *)

(* Test case to verify the implementation *)
let _ =
let a = mk_matrix [1.; 0.; 0.; 1.] (2, 2) in
let b = {entries = [[1.; 0.]; [0.; 1.]]; rows = 2; cols = 2} in
assert (a = b)