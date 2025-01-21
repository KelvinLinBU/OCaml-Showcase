{
  open Par
}


(*skeleton code*)
let whitespace = [' ' '\t' '\n' '\r']+
let num = '-'? ['0'-'9']+
let var = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*

rule read = parse
  | [' ' '\t' '\n' '\r'] { read lexbuf }
  | "let" { LET }
  | "rec" { REC }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "fun" { FUN }
  | "in" { IN }
  | "int" { INT }
  | "bool" { BOOL }
  | "unit" { UNIT }
  | "true" { TRUE }
  | "false" { FALSE }
  | "assert" { ASSERT }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | ':' { COLON }
  | "->" { ARROW }
  | '=' { EQUAL }
  | '+' | '-' | '*' | '/' | "mod" | "<" | "<=" | ">" | ">=" | "==" | "!=" | "&&" | "||" as op { OP op }
  | ['0'-'9']+ as num { NUM (int_of_string num) }
  | ['a'-'z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_' '\\']* as var { VAR var }
  | eof { EOF }
  | _ { failwith "Unexpected character" }