
type dir = 
  | North
  | South
  | East
  | West

type path = dir list

let dist (dirs: path) : float =
let rec walk (x, y) dirs = match dirs with | [] -> (x, y)  (*final*) | North :: rest -> walk (x, y + 1) rest  (*north*) | South :: rest -> walk (x, y - 1) rest  (*south*) | East :: rest -> walk (x + 1, y) rest   (*east*) | West :: rest -> walk (x - 1, y) rest   (*west*) in
(*final position*)
let (x_fin, y_fin) = walk (0, 0) dirs in
(*square root to find euclidean distance*)
sqrt (float_of_int (x_fin * x_fin + y_fin * y_fin))

(* Test case to verify the function *)
let is_close f1 f2 = abs_float (f1 -. f2) < 0.000001

let _ = assert (is_close (dist [North; North; South; East]) (sqrt 2.))
