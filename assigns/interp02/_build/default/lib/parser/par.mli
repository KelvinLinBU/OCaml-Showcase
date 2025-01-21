
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | UNIT
  | TRUE
  | TIMES
  | THEN
  | RPAREN
  | REC
  | PLUS
  | OR
  | NUM of (int)
  | NEQ
  | MOD
  | MINUS
  | LTE
  | LT
  | LPAREN
  | LET
  | INT
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
  | COLON
  | BOOL
  | ASSERT
  | ARROW
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Utils.prog)
