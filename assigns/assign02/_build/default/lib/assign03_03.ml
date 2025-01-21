(* Type definition for the tree *)
type tree = 
  | Leaf of int
  | Node of tree list

(* Helper function to calculate the height of the tree *)
let rec height = function
  | Leaf _ -> 0  (* A leaf has height 0 *)
  | Node [] -> 0  (* A node with no children has height 0 *)
  | Node children -> 1 + List.fold_left (fun acc t -> max acc (height t)) 0 children
  (* The height of a node is 1 + the maximum height of its children *)

(* Helper function to collect all terminal elements in the tree *)
let rec terminal_elements = function
  | Leaf _ as leaf -> [leaf]  (* A leaf is a terminal element *)
  | Node [] as empty_node -> [empty_node]  (* An empty node is also terminal *)
  | Node children -> List.concat (List.map terminal_elements children)
  (* Recursively gather all terminal elements from the subtree *)

(* The main collapse function *)
let rec collapse h t =
  match t with
  | Leaf _ -> t  (* A leaf doesn't need collapsing *)
  | Node children ->
      if h = 0 then t  (* If height is 0, return the tree as is *)
      else
        (* Collapse children first, then replace their children with terminal elements *)
        if height t <= h then t  (* No need to collapse if the tree's height is less than or equal to h *)
        else
          (* Collapse each child and replace its children with terminal elements if necessary *)
          Node (List.map (fun child ->
            if height child = h - 1 then
              (* Replace the children of this node with its terminal elements *)
              Node (terminal_elements child)
            else
              (* Recursively collapse the child *)
              collapse h child
          ) children)
