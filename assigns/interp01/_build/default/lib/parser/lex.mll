{
  open Par
}


(*skeleton code*)
let whitespace = [' ' '\t' '\n' '\r']+
let num = '-'? ['0'-'9']+
let var = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*


(*implementation*)
rule read =
parse
  (*keywords*)
  | "rec" { REC }
  | "if" { IF } | "then" { THEN } | "else" { ELSE }
  | "let" { LET }
  | "in" { IN }
  | "fun" { FUN }
  | "true" { TRUE }
  | "false" { FALSE }
(*operators*)
  | '<' { LT } | '=' { EQ } | "<>" { NEQ }
  | "&&" { AND }
  | "<=" { LTE }
  | '>' { GT } | ">=" { GTE }
| "||" { OR }
| '(' { LPAREN }
| "()" { UNIT }
| "->" { ARROW }
| '+' { PLUS }
| '-' { MINUS }
| '*' { MUL }
| '/' { DIV }
| "mod" { MOD }
| ')' { RPAREN }



  (*stuff already in skelly code*)
  | num { NUM (int_of_string (Lexing.lexeme lexbuf)) }
  | var { VAR (Lexing.lexeme lexbuf) }
  | whitespace { read lexbuf }
  | eof { EOF }

