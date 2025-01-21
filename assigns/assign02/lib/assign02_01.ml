
type piece = 
| X
| O

type pos = 
| Piece of piece
| Blank

type board = (pos * pos * pos) * (pos * pos * pos) * (pos * pos * pos)

type row_index = 
| Top
| Middle
| Bottom

type col_index = 
| Left
| Middle
| Right

type pos_index = row_index * col_index

let get_column_position (row: pos * pos * pos) (col_idx: col_index) : pos =
match col_idx with
| Left -> let (p, _, _) = row in p        (*left pos *)
| Middle -> let (_, p, _) = row in p      (* mid pos *)
| Right -> let (_, _, p) = row in p       (* right pos*)

let get_row_position (board: board) (row_idx: row_index) : (pos * pos * pos) = 
match row_idx with
| Top -> let (top_row, _, _) = board in top_row       (*top row of board*)

| Middle -> let (_, middle_row, _) = board in middle_row  (* Middle row of board*)
| Bottom -> let (_, _, bottom_row) = board in bottom_row  (* Bottom row of board *)

let get_pos (board_input: board) (pos_index_input: pos_index) : pos =(* Get row and column indexes *) let (row_idx, col_idx) = pos_index_input in (* get row*)let row = get_row_position board_input row_idx in get_column_position row col_idx(*get col *)

(* win_conditiion *)
let win_condition (a: pos) (b: pos) (c: pos) : bool =
    match (a, b, c) with
    | (Piece X, Piece X, Piece X) -> true
    | (Piece O, Piece O, Piece O) -> true
    | _ -> false
  
let winner (board_input: board) : bool =
let (top_row, middle_row, bottom_row) = board_input in
    (*row conditions *)let row1 = win_condition (let (a, _, _) = top_row in a) (let (_, b, _) = top_row in b) (let (_, _, c) = top_row in c) in let row2 = win_condition (let (a, _, _) = middle_row in a) (let (_, b, _) = middle_row in b) (let (_, _, c) = middle_row in c) in let row3 = win_condition (let (a, _, _) = bottom_row in a) (let (_, b, _) = bottom_row in b) (let (_, _, c) = bottom_row in c) in
    (*column check *)
let column1 = win_condition (let (a, _, _) = top_row in a) (let (a, _, _) = middle_row in a) (let (a, _, _) = bottom_row in a) in let column2 = win_condition (let (_, b, _) = top_row in b) (let (_, b, _) = middle_row in b) (let (_, b, _) = bottom_row in b) in let column3 = win_condition (let (_, _, c) = top_row in c) (let (_, _, c) = middle_row in c) (let (_, _, c) = bottom_row in c) in
    (* Check diagonals *)
let diagonal1 = win_condition (let (a, _, _) = top_row in a) (let (_, b, _) = middle_row in b) (let (_, _, c) = bottom_row in c) in let diagonal2 = win_condition (let (_, _, c) = top_row in c) (let (_, b, _) = middle_row in b) (let (a, _, _) = bottom_row in a) in
    (* If any of these conditions are true then win*)
    row1 || row2 || row3 || column1 || column2 || column3 || diagonal1 || diagonal2
