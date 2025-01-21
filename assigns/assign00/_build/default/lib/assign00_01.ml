let sqrt (n:int) : int = 
  (* Define a helper recursive function find_k that takes k as its argument *)
  let rec find_k k =
    if k * k >= n then k  (* If k^2 is greater than or equal to n, return k *)
    else find_k (k + 1)   (* Otherwise, increment k by 1 and continue searching *)
  in
  find_k 0  (* Start the search with k = 0 *)

