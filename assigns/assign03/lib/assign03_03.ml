type tree = 
| Leaf of int
| Node of tree list

let rec height = function (*height function*)
  | Leaf _ -> 0
  | Node [] -> 0
  | Node (hd :: tl) ->
      let rec max_height cur_max = function
        | [] -> cur_max
        | h :: t -> max_height (max cur_max (height h)) t
      in
      1 + max_height (height hd) tl

      let rec collect_terminal_elements = function (*another helper func we want to collect terminal elements*)
      | Leaf _ as leaf -> [leaf]
      | Node [] as node -> [node]
      | Node (hd :: tl) ->
          let rec collect acc = function
            | [] -> acc
            | h :: t ->
                collect (acc @ collect_terminal_elements h) t
          in
          collect (collect_terminal_elements hd) tl
          let rec collapse h = function (*actual function where we do collapsing*)
          | Leaf _ as leaf -> leaf  (* bc:leaf, no collapsing needed *)
          | Node [] as node -> node (* base case: node w no child *)
          | Node (hd :: tl) ->
              if h = 1 then (*condition *)
                
                let rec collapse_children acc = function (*recursive func for help*)
                  | [] -> Node acc
                  | hd :: tl -> 
                      let new_terminals = collect_terminal_elements hd in
                      collapse_children (acc @ new_terminals) tl
                in
                collapse_children (collect_terminal_elements hd) tl
              else
                (* recursive collapse of tree *)
                let rec collapse_subtrees acc = function
                  | [] -> Node acc
                  | hd :: tl -> 
                      let new_subtree = collapse (h - 1) hd in  (* collapse *)
                      collapse_subtrees (acc @ [new_subtree]) tl
                in
                collapse_subtrees [collapse (h - 1) hd] tl (*tail recurse*)
        
        