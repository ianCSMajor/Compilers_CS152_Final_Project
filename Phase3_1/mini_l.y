%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include "symboltable.h"

extern int yylex();
extern int yyparse();
extern int l, c;
extern FILE* yyin;

void yyerror(const char* s);

//For symbol table
SymbolTable st = SymbolTable();
bool errorRaised = false;
bool loopScope = false;

//For code generation
vector<string> params;
string code = "";
unsigned int temp_var = 0;

char* var_generator() {
  stringstream ss;
  ss << "_temp" << temp_var++;
  return strdup(ss.str().c_str());
}

%}

%union {
  char num[254];
  char id[254];
  struct {
    char * code;
    char * ret;
    char * i;
  } node;
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

%type <node> prog_start
%type <node> functions
%type <node> function

%type <node> param_declarations
%type <node> local_declarations
%type <node> param_declaration
%type <node> local_declaration

%type <node> statements
%type <node> statement

%type <node> read_var
%type <node> write_var

%type <node> bool_exp
%type <node> nots
%type <node> comp
%type <node> expression
%type <node> multiplicative_expr
%type <node> additive
%type <node> multiplicative
%type <node> term
%type <node> int_var
%type <node> arr_var

%type <node> parameters
%type <node> parameter
%type <node> numbers
%type <node> identifiers

%%
prog_start: functions {cout << $1.code; code = string($1.code);}


functions: function functions {stringstream ss;ss << $1.code << $2.code; $$.code = strdup(ss.str().c_str());}
  | %empty {$$.code = (char*)"";}
function: FUNCTION identifiers func_declaration SEMICOLON BEGIN_PARAMS param_declarations END_PARAMS BEGIN_LOCALS local_declarations END_LOCALS BEGIN_BODY statements END_BODY {
  st.LeaveCurrentScope();
  stringstream ss;
  ss << "func " << $2.ret << "\n" << $6.code;
  for(int i = 0; i < params.size(); i++)
    ss << "= " << params[i] << ", $" << i << "\n";
  params.clear();
  ss << $9.code << $12.code << "endfunc\n"; $$.code = strdup(ss.str().c_str());}


param_declarations: param_declaration SEMICOLON param_declarations {stringstream ss; ss << $1.code << $3.code; $$.code = strdup(ss.str().c_str());}
  | %empty {$$.code = (char*)"";}
param_declaration: identifiers COLON INTEGER int_declaration {stringstream ss; ss << ". " << $1.ret << "\n"; $$.code = strdup(ss.str().c_str()); params.push_back($1.ret);}
  | identifiers COLON ARRAY arr_declaration L_SQUARE_BRACKET numbers R_SQUARE_BRACKET OF INTEGER {stringstream ss; ss << ".[] " << $1.ret << ", " << $6.ret << "\n"; $$.code = strdup(ss.str().c_str());}
local_declarations: local_declaration SEMICOLON local_declarations {stringstream ss; ss << $1.code << $3.code; $$.code = strdup(ss.str().c_str());}
  | %empty {$$.code = (char*)"";}
local_declaration: identifiers COLON INTEGER int_declaration {stringstream ss; ss << ". " << $1.ret << "\n"; $$.code = strdup(ss.str().c_str());}
  | identifiers COLON ARRAY arr_declaration L_SQUARE_BRACKET numbers R_SQUARE_BRACKET OF INTEGER {stringstream ss; ss << ".[] " << $1.ret << ", " << $6.ret << "\n"; $$.code = strdup(ss.str().c_str());}


statements: statement SEMICOLON statements {stringstream ss; ss << $1.code << $3.code; $$.code = strdup(ss.str().c_str());}
  | %empty {$$.code = (char*)"";}
statement: int_var ASSIGN expression {stringstream ss; ss << $3.code << "= " << $1.ret << ", "  << $3.ret << "\n"; $$.code = strdup(ss.str().c_str());}
  | arr_var ASSIGN expression {stringstream ss; ss << $3.code << "[]= " << $1.ret << ", " << $1.i << ", " << $3.ret << "\n"; $$.code = strdup(ss.str().c_str());}
  | IF bool_exp THEN statements ENDIF
  | IF bool_exp THEN statements ELSE statements ENDIF
  | WHILE bool_exp BEGINLOOP {loopScope = true;} statements ENDLOOP {loopScope = false;}
  | DO BEGINLOOP {loopScope = true;} statements ENDLOOP WHILE bool_exp {loopScope = false;}
  | READ read_var {$$.code = strdup($2.code);}
  | WRITE write_var {$$.code = strdup($2.code);}
  | CONTINUE {if(!loopScope) {printf("Error line %d: continue statement not within a loop.\n", l); errorRaised = true;}}
  | BREAK {$$.code = (char*)"";}
  | RETURN expression {stringstream ss; ss << $2.code << "ret " << $2.ret << "\n"; $$.code = strdup(ss.str().c_str());}


read_var: int_var
  | arr_var
write_var: int_var {stringstream ss; ss << ".> " << $1.ret << "\n"; $$.code = strdup(ss.str().c_str());}
  | arr_var {stringstream ss; char* t = strdup(var_generator()); ss << ". " << t << "\n=[] " << t << ", " << $1.ret << ", " << $1.i << "\n.> " << t << "\n"; $$.code = strdup(ss.str().c_str());}


bool_exp: nots expression comp expression
  | nots L_PAREN expression comp expression R_PAREN
nots: NOT nots {$$.code = (char*)"";}
  | %empty {$$.code = (char*)"";}
comp: EQ {$$.code = (char*)"";}
  | NEQ {$$.code = (char*)"";}
  | LT {$$.code = (char*)"";}
  | GT {$$.code = (char*)"";}
  | LTE {$$.code = (char*)"";}
  | GTE {$$.code = (char*)"";}
expression: multiplicative_expr additive expression {
  stringstream ss;
  if($2.code[0] != '\0') {
    $$.ret = strdup(var_generator());
    ss << $1.code << $3.code;
    ss << ". " << $$.ret << "\n";
    ss << $2.code << " " << $$.ret << ", " << $1.ret << ", " << $3.ret << "\n";
    $$.code = strdup(ss.str().c_str());
  }
  else {
    $$.ret = strdup($1.ret);
    $$.code = strdup($1.code);
  }}
  | %empty {$$.code = (char*)"";}
multiplicative_expr: term multiplicative multiplicative_expr {
  stringstream ss;
  if($2.code[0] != '\0') {
    $$.ret = strdup(var_generator());
    ss << $1.code << $3.code;
    ss << ". " << $$.ret << "\n";
    ss << $2.code << " " << $$.ret << ", " << $1.ret << ", " << $3.ret << "\n";
    $$.code = strdup(ss.str().c_str());
  }
  else {
    $$.ret = strdup($1.ret);
    $$.code = strdup($1.code);
  }}
  | %empty {$$.code = (char*)"";}
additive: ADD {$$.code = (char*)"+";}
  | SUB {$$.code = (char*)"-";}
  | %empty {$$.code = (char*)"";}
multiplicative: MULT {$$.code = (char*)"*";}
  | DIV {$$.code = (char*)"/";}
  | MOD {$$.code = (char*)"%";}
  | %empty {$$.code = (char*)"";}
term: int_var {$$.ret = strdup($1.ret); $$.code = (char*)"";}
  | arr_var {stringstream ss; $$.ret = strdup(var_generator()); ss << ". " << $$.ret << "\n=[] " << $$.ret << ", " << $1.ret << ", " << $1.i << "\n"; $$.code = strdup(ss.str().c_str());}
  | numbers {$$.ret = strdup($1.ret); $$.code = (char*)"";}
  | L_PAREN expression R_PAREN {$$.ret = strdup($2.ret); $$.code = strdup($2.code);}
  | identifiers L_PAREN func_use parameters R_PAREN {stringstream ss; $$.ret = strdup(var_generator()); ss << $4.code << ". " << $$.ret << "\ncall " << $1.ret << ", " << $$.ret << "\n"; $$.code = strdup(ss.str().c_str());}
int_var: identifiers int_use {$$.ret = strdup($1.ret);}
arr_var: identifiers L_SQUARE_BRACKET arr_use expression R_SQUARE_BRACKET {$$.ret = strdup($1.ret); $$.i = strdup($4.ret);}
parameters: expression parameter {stringstream ss; ss << $1.code << "param " << $1.ret << "\n" << $2.code; $$.code = strdup(ss.str().c_str());}
parameter: COMMA expression parameter {stringstream ss; ss << $2.code << "param " << $2.ret << "\n" << $3.code; $$.code = strdup(ss.str().c_str());}
  | %empty {$$.code = (char*)"";}
identifiers: IDENT {$$.ret = strdup($1);}
numbers: NUMBER {$$.ret = strdup($1);}

int_declaration: %empty {errorRaised |= !st.addSymbol(string(yylval.id), SymbolTable::INT, l);}
arr_declaration: %empty {errorRaised |= !st.addSymbol(string(yylval.id), SymbolTable::ARR, l);}
func_declaration: %empty {errorRaised |= !st.addSymbol(string(yylval.id), SymbolTable::FUNC, l); st.EnterNewScope();}
int_use: %empty {errorRaised |= !st.checkUsage(string(yylval.id), SymbolTable::INT, l);}
arr_use: %empty {errorRaised |= !st.checkUsage(string(yylval.id), SymbolTable::ARR, l);}
func_use: %empty {errorRaised |= !st.checkUsage(string(yylval.id), SymbolTable::FUNC, l);}
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

  errorRaised |= !st.checkForMain();
  if(!errorRaised) {
    ofstream fout;
    string filename = "mil" + string(argv[0]).substr(string(argv[0]).find_first_of("/"));
    filename = filename.substr(0, filename.find_last_of(".")) + ".mil";
    fout.open(filename.c_str());
    fout << code;
    fout.close();
  }
  return 0;
}

void yyerror(const char* s) {
  extern int l;
  extern char *yytext;

  printf("%s: %s on line %d\n", s, yytext, l);
  exit(1);
}
