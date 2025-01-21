
(* The type of tokens. *)

type token = 
  | WITH
  | VAR of (string)
  | UNIT
  | TVAR of (string)
  | TUNIT
  | TRUE
  | TLIST
  | TINT
  | THEN
  | TFLOAT
  | TBOOL
  | SUBF
  | SUB
  | SOME
  | SEMICOLON
  | RPAREN
  | REC
  | RBRACKET
  | POW
  | OR
  | OPTION
  | NONE
  | NEQ
  | MULF
  | MUL
  | MOD
  | MATCH
  | LTE
  | LT
  | LPAREN
  | LET
  | LBRACKET
  | INT of (int)
  | IN
  | IF
  | GTE
  | GT
  | FUN
  | FLOAT of (float)
  | FALSE
  | EQUALS
  | EOF
  | ELSE
  | DIVF
  | DIV
  | CONS
  | CONCATL
  | COMMA
  | COLON
  | ASSERT
  | ARROW
  | AND
  | ALT
  | ADDF
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Utils.prog)
