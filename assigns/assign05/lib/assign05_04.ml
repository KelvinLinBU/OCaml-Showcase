
type set_info = {
  ind : int -> bool;
  mn : int;
  mx : int;
} (*def of set info*)
let rec merge_sorted l1 l2 = match (l1, l2) with (* merge the sorted?  *)
| ([], l) -> l
| (l, []) -> l
| (x1 :: xs1, x2 :: xs2) ->
  if x1 < x2 then x1 :: merge_sorted xs1 l2
  else 
    if x1 > x2 then x2 :: merge_sorted l1 xs2
  else x1 :: merge_sorted xs1 xs2  (* Skip duplicates *)

module ListSet = struct
  type t = int list (*variable*)
  let empty : t = []
  (* singleton*)
  let singleton (x: int) : t = [x]
  (* cardinality *)
  let card (s: t) : int = List.length s
  (* see if element in *)
  let mem (x: int) (s: t) : bool =
    List.mem x s
  (* union*) let union (s1: t) (s2: t) : t =
    merge_sorted s1 s2  (* call the helper *) end

(* func module *)
module FuncSet = struct
  type t = set_info
  (* empty *)
  let empty : t = { ind = (fun _ -> false); mn = 1; mx = 0 }

  (* singleton*)
  
  let singleton (x: int) : t = { ind = (fun y -> y = x); mn = x; mx = x }
  (* cardinality *)
  let card (s: t) : int =
  let rec count acc n =
    if n > s.mx then acc
else if s.ind n then count (acc + 1) (n + 1)
   else count acc (n + 1)
    in count 0 s.mn
  let mem (x: int) (s: t) : bool =
    s.ind x
  let union (s1: t) (s2: t) : t =
    let new_ind x = s1.ind x || s2.ind x in
    let new_mn = min s1.mn s2.mn in
    let new_mx = max s1.mx s2.mx in
    { ind = new_ind; mn = new_mn; mx = new_mx }
end
