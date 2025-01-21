

type 'a tree = 
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let sum_tr t =
let rec help t cont =
match t with
| Leaf -> cont 0
| Node (x, l, r) ->
 help l (fun sum_left -> 
help r (fun sum_right -> 
  cont (x + sum_left + sum_right))) in help t (fun x -> x)
