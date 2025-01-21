%{
open Utils (* To use ty, sfexpr, bop, etc. *)
%}

%token LET REC IF THEN ELSE FUN IN ASSERT
%token INT BOOL UNIT TRUE FALSE
%token LPAREN RPAREN COLON ARROW
%token PLUS MINUS TIMES DIV MOD LT LTE GT GTE EQ NEQ AND OR
%token <string> VAR
%token <int> NUM
%token EOF


%start prog
%type <prog> prog
%nonassoc ASSERT_KW  
%right OR
%right AND
%left EQ NEQ
%left LT LTE GT GTE
%left PLUS MINUS
%left TIMES DIV MOD

%%



(* <prog> ::= {<toplet>} EOF *)
prog:
  toplet_list EOF { $1 }

(* <toplet_list> ::= <toplet>
                     | <toplet_list> <toplet> *)
toplet_list:
  toplet { [$1] } (* Single toplet *)
| toplet_list toplet { $1 @ [$2] } (* Multiple toplets *)

(* <toplet> ::= let <var> {<arg>} : <ty> = <expr>
                | let rec <var> <arg> {<arg>} : <ty> = <expr> *)
toplet:
  LET VAR arg_list COLON ty EQ expr {
    { is_rec = false; name = $2; args = $3; ty = $5; value = $7 }
  }
| LET REC VAR arg_list COLON ty EQ expr {
    { is_rec = true; name = $3; args = $4; ty = $6; value = $8 }
  }

(* <arg> ::= ( <var> : <ty> ) *)
arg_list:


  /* empty */ { [] } (* No arguments *)
| arg_list arg { $1 @ [$2] }

arg:


  LPAREN VAR COLON ty RPAREN { ($2, $4) }

(* <ty> ::= int | bool | unit | <ty> -> <ty> | ( <ty> ) *)
ty: ty_arrow { $1 }

ty_arrow:
  ty_atom ARROW ty_arrow { FunTy ($1, $3) } (* Right recursion for right-associativity *)
| ty_atom { $1 }

ty_atom:
  INT { IntTy } (* <ty> ::= int *)
| BOOL { BoolTy } (* <ty> ::= bool *)
| UNIT { UnitTy } (* <ty> ::= unit *)
| ty ARROW ty { FunTy ($1, $3) } (* <ty> ::= <ty> -> <ty> *)
| LPAREN ty RPAREN { $2 } (* <ty> ::= ( <ty> ) *)

(* Expressions *)
expr:

  LET VAR arg_list COLON ty EQ expr IN expr {
    SLet { is_rec = false; name = $2; args = $3; ty = $5; value = $7; body = $9 }
  }
| LET REC VAR arg_list COLON ty EQ expr IN expr {
    SLet { is_rec = true; name = $3; args = $4; ty = $6; value = $8; body = $10 }
  }
| IF expr THEN expr ELSE expr { SIf ($2, $4, $6) }
| FUN arg_list ARROW expr {
    match $2 with
    | [] -> failwith "Function must have at least one argument"
    | arg :: args -> SFun { arg; args; body = $4 }
  }


| expr_or { $1 }


expr_or:
  expr_or OR expr_and { SBop (Or, $1, $3) }
| expr_and { $1 }

expr_and:

  expr_and AND expr_rel { SBop (And, $1, $3) }
| expr_rel { $1 }

expr_rel:
  expr_rel EQ expr_add { SBop (Eq, $1, $3) }
| expr_rel NEQ expr_add { SBop (Neq, $1, $3) }
| expr_rel LT expr_add { SBop (Lt, $1, $3) }
| expr_rel LTE expr_add { SBop (Lte, $1, $3) }
| expr_rel GT expr_add { SBop (Gt, $1, $3) }
| expr_rel GTE expr_add { SBop (Gte, $1, $3) }
| expr_add { $1 }

expr_add:
  expr_add PLUS expr_mul { SBop (Add, $1, $3) }
| expr_add MINUS expr_mul { SBop (Sub, $1, $3) }
| expr_mul { $1 }

expr_mul:
  expr_mul TIMES expr_unary { SBop (Mul, $1, $3) }
| expr_mul DIV expr_unary { SBop (Div, $1, $3) }
| expr_mul MOD expr_unary { SBop (Mod, $1, $3) }
| expr_app { $1 }

expr_unary:
  ASSERT expr_unary %prec ASSERT_KW { SAssert $2 }
| expr_app { $1 }

expr_app:
  expr_app expr_atom { SApp ($1, $2) } 
| ASSERT expr_atom { SAssert $2 }     
| expr_atom { $1 }


expr_atom:
  LPAREN expr RPAREN { $2 } 
| LPAREN RPAREN { SUnit }   
| TRUE { STrue }          
| FALSE { SFalse }          
| NUM { SNum $1 }          
| VAR { SVar $1 }          