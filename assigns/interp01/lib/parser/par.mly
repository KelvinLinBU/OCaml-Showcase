
%{
  open Utils
%}


%token REC


(*tokens with keywords and operators*)
%token IF THEN ELSE LET IN FUN TRUE FALSE UNIT ARROW

(* tokens for data types*)
%token <int> NUM
%token <string> VAR

%token PLUS MINUS LT LTE GT GTE EQ NEQ AND OR MUL DIV MOD 

%token LPAREN RPAREN EOF (*parenthesis*)



%start <prog> prog
%type <expr> expr



(*precedences*)
%right OR
%right AND

(*left precedences*)
%left EQ NEQ LT LTE GT GTE
%left PLUS MINUS
%left MUL DIV MOD
%nonassoc APP
%%

prog:

| expr EOF { $1 } (*modded from skeleton, doesn't work if not like this*)

(*expr*)
expr:
| LET REC VAR EQ expr IN expr { Let($3, App (Fun ($3, $5), Var $3), $7) }

| LET VAR EQ expr IN expr {Let($2,$4,$6)}
| FUN VAR ARROW expr {Fun($2, $4) }
| IF expr THEN expr ELSE expr {If($2, $4, $6)}


| binary_expr { $1 }




binary_expr: 
(*binary operators keepin g in mind precedence*)
| binary_expr PLUS binary_expr {Bop(Add, $1, $3)} | binary_expr MINUS binary_expr {Bop(Sub, $1, $3) }

| binary_expr LTE binary_expr { Bop (Lte, $1, $3) }

| binary_expr GT binary_expr { Bop (Gt, $1, $3) }

| binary_expr GTE binary_expr { Bop(Gte, $1, $3)}

| binary_expr EQ binary_expr { Bop (Eq, $1, $3) }

| binary_expr NEQ binary_expr {Bop (Neq, $1, $3) }

| binary_expr AND binary_expr {Bop (And, $1, $3) }

| binary_expr OR binary_expr {Bop (Or, $1, $3)}

| binary_expr MUL binary_expr {Bop (Mul, $1, $3) }

| binary_expr DIV binary_expr {Bop (Div, $1, $3) }

| binary_expr MOD binary_expr {Bop (Mod, $1, $3) }

| binary_expr LT binary_expr {Bop (Lt, $1, $3) } | atom { $1 }
| app_expr{$1}


(*app expr*)
app_expr:
| app_expr atom %prec APP {App($1, $2) } | atom{ $1 }

atom:
  | LPAREN expr RPAREN { $2 }
  | TRUE { True } (*bool*) | FALSE { False }
  | NUM { Num $1 } (*num*) | VAR { Var $1 } (*var*)
  | UNIT { Unit } (*units*)
