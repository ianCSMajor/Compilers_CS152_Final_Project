%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
  int num;
  char* id;
}

%start prog_start

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE BREAK READ WRITE NOT TRUE FALSE RETURN SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <num> NUMBER
%token <id> IDENT

%left MULT DIV MOD
%left ADD SUB 
%left LT LTE GT GTE EQ NEQ

%right NOT
%right ASSIGN

%%
prog_start: functions {printf("prog_start -> functions\n");}
functions: function functions {printf("functions -> function functions\n");}
  | %empty {printf("functions -> epsilon\n");}
function: FUNCTION identifiers SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION identifiers SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
declarations: declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
  | %empty {printf("declarations -> epsilon\n");}
declaration: identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
  | identifiers COLON ARRAY L_SQUARE_BRACKET numbers R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET numbers R_SQUARE_BRACKET OF INTEGER\n");}
statements: statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
  | %empty {printf("statements -> epsilon\n");}
statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
  | IF bool_exps THEN statements ENDIF {printf("statement -> IF bool_exps THEN statements ENDIF\n");}
  | IF bool_exps THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exps THEN statements ELSE statements ENDIF\n");}
  | WHILE bool_exps BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exps BEGINLOOP statements ENDLOOP\n");}
  | DO BEGINLOOP statements ENDLOOP WHILE bool_exps {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exps\n");}
  | READ var {printf("statement -> READ var\n");}
  | WRITE var {printf("statement -> WRITE var\n");}
  | CONTINUE {printf("statement -> CONTINUE\n");}
  | BREAK    {printf("statement -> BREAK\n");}
  | RETURN expression {printf("statement -> RETURN expression\n");}
  bool-exps: relation-and-expr bool-exp             {printf("bool-exps ->relation-exp bool-exp\n"); }
  bool-exp: OR relation-and-exp bool-exp                 {printf("bool-exp -> OR relation-and-exp bool-exp\n"); }
  | %empty                                                  {printf("bool-exp -> epsilon\n");}
  relation-and-expressions: relation-expr relation-and-expr {printf("relation-and-expressions -> relation-exp relation-and-expr\n"); }
  relation-and-expr: AND relation-expr relation-and-expr    {printf("relation-and-expr -> AND relation-expr relation-and-expr\n");}
  | %empty                                                  {printf("declarations -> epsilon\n");}
  relation-expr: nots expression comp expression    {printf("relation-expr -> nots expression comp expression\n");}
  | nots TRUE                      {printf("relation-expr -> nots expression comp expression\n");}
  | nots FALSE                     {printf("relation-expr -> nots FALSE\n");}
  | nots L_PAREN bool-exp R_PAREN {printf("relation-expr -> nots L_PAREN bool-expr R_PAREN\n");}
  nots: NOT nots                   {printf("relation-expr -> nots -> NOT nots\n");}
  | %empty                                 {printf("relation-expr -> epsilon\n");}
  comp: EQ                                 {printf("comp -> EQ\n"); }
  | NEQ                                    {printf("comp -> NEQ\n"); }
  | LT                                     {printf("comp -> LT\n"); }
  | GT                                     {printf("comp -> GT\n"); }
  | LTE                                    {printf("comp -> LTE\n"); }
  | GTE                                    {printf("comp -> GTE\n"); }
  expression: multiplicative-expr additive expression {printf("expression -> multiplicative-expr additive expression\n"); }
  | %empty                                                  {printf("expression -> epsilon\n");}

  //expr: MINUS multiplicative-expr expr {printf("expr ->  MINUS multiplicative-expr expr\n"); }
  //| PLUS multiplicative-expr expr      {printf("expr -> PLUS multiplicative-expr expr  \n");}
 // | %empty                             {printf("declarations -> epsilon\n");}
  multiplicative-expr: term multiplicative multiplicative_expr        {printf("multiplicative-expr -> term multiplicative multiplicative_expr\n"); }
  | %empty                                                  {printf("multiplicative-expr -> epsilon\n");}
  multiplicative: MULT  {printf("multiplicative -> MULT\n");}
  | DIV {printf("multiplicative -> DIV\n");}
  | MOD {printf("multiplicative -> MOD\n");}
  | %empty                                                  {printf("multiplicative -> epsilon\n");}
  additive: ADD {printf("additive -> ADD\n");}
  | SUB             {printf("additive -> SUB\n");}
  | %empty                                                  {printf("additive -> epsilon\n");}
  term: var                                 {printf("term -> var\n");}
  | numbers {printf("term -> numbers\n");}
  | L_PAREN expression R_PAREN  {printf("term -> L_PAREN expression R_PAREN\n");}
  | identifiers L_PAREN parameters R_PAREN {printf("term -> identifiers L_PAREN parameters R_PAREN\n");}

  parameters: expression parameter        {printf("parameters -> expression parameter\n"); }
  parameter: COMMA expression parameter    {printf("parameters-> COMMA expression parameter\n"); }
  | %empty                                 {printf("parameters -> epsilon\n");}
  var: identifiers                         {printf("var -> IDENT\n"); }
  | identifiers L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var-> identifiers L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n"); }
  identifiers: IDENT {printf("identifiers -> IDENT\n"); }
  numbers: NUMBER    {printf("numbers -> NUMBER\n"); }

%%

int main(int argc, char **argv) {
  ++argv, --argc;
  if(argc > 0)
    yyin = fopen(argv[0], "r");
  else
    yyin = stdin;

  do {
    yyparse();
  } while(!feof(yyin));
  printf("Parsing Completed!\n");
  return 0;
}

void yyerror(const char* s) {
  extern int l, c;
  extern char *yytext;

  printf("%s: %s on line %d, column %d\n", s, yytext, l, c);
  exit(1);
}
