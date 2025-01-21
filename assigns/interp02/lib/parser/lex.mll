{

open Par
}


(*skeleton code*)
let whitespace = [' ' '\t' '\n' '\r']+
let num = '-'? ['0'-'9']+
let var = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*




rule read = parse
  | [' ' '\t' '\n' '\r'] { read lexbuf } (* Skip whitespace *)
  | "let" { LET }
  | "rec" { REC }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "fun" { FUN }
  | "in" { IN }
  | "assert" { ASSERT }
  | "int" { INT }
  | "bool" { BOOL }
  | "unit" { UNIT }
  | "true" { TRUE }
  | "false" { FALSE }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | ':' { COLON }
  | "->" { ARROW }

  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { TIMES }
  | "/" { DIV }
  | "mod" { MOD }
  | "<" { LT }
  | "<=" { LTE }
  | ">" { GT }
  | ">=" { GTE }
  | "=" { EQ }
  | "<>" { NEQ }
  | "&&" { AND }
  | "||" { OR }
  
  | '-'? ['0'-'9']+ as n { NUM (int_of_string n) } (* Match integers with optional '-' *)
  | ['a'-'z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']* as v { VAR v } (* Match valid variable names *)
  | eof { EOF } (* End of file token *)
  
