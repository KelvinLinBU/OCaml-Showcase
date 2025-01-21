
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | UNIT
  | TRUE
  | THEN
  | RPAREN
  | PLUS
  | OR
  | NUM of (int)
  | NEQ
  | MUL
  | MOD
  | MINUS
  | LTE
  | LT
  | LPAREN
  | LET
  | IN
  | IF
  | GTE
  | GT
  | FUN
  | FALSE
  | EQ
  | EOF
  | ELSE
  | DIV
  | ARROW
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Utils.prog)
