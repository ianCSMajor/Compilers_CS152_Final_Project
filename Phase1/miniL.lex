%{
  int l = 1;
  int c = 0;
%}

DIGIT [0-9]
LETTER [A-Za-z]
INTEGER {DIGIT}+
IDENT {LETTER}|({LETTER}({LETTER}|{INTEGER}|_)*({LETTER}|{INTEGER}))

%%
function {printf("FUNCTION\n"); c += 8;}
beginparams {printf("BEGIN_PARAMS\n"); c += 11;}
endparams {printf("END_PARAMS\n"); c += 9;}
beginlocals {printf("BEGIN_LOCALS\n"); c += 11;}
endlocals {printf("END_LOCALS\n"); c += 9;}
beginbody {printf("BEGIN_BODY\n"); c += 9;}
endbody {printf("END_BODY\n"); c += 7;}
integer {printf("INTEGER\n"); c += 7;}
array {printf("ARRAY\n"); c += 5;}
of {printf("OF\n"); c += 2;}
if {printf("IF\n"); c += 2;}
then {printf("THEN\n"); c += 4;}
endif {printf("ENDIF\n"); c += 5;}
else {printf("ELSE\n"); c += 4;}
while {printf("WHILE\n"); c += 5;}
do {printf("DO\n"); c += 2;}
beginloop {printf("BEGINLOOP\n"); c += 9;}
endloop {printf("ENDLOOP\n"); c += 7;}
continue {printf("CONTINUE\n"); c += 8;}
break {printf("BREAK\n"); c += 5;}
read {printf("READ\n"); c += 4;}
write {printf("WRITE\n"); c += 5;}
not {printf("NOT\n"); c += 3;}
true {printf("TRUE\n"); c += 4;}
false {printf("FALSE\n"); c += 5;}
return {printf("RETURN\n"); c += 6;}

- {printf("SUB\n"); c++;}
\+ {printf("ADD\n"); c++;}
\* {printf("MULT\n"); c++;}
\/ {printf("DIV\n"); c++;}
% {printf("MOD\n"); c++;}

== {printf("EQ\n"); c += 2;}
\<> {printf("NEQ\n"); c += 2;}
\< {printf("LT\n"); c++;}
> {printf("GT\n"); c++;}
\<= {printf("LTE\n"); c += 2;}
>= {printf("GTE\n"); c += 2;}

{INTEGER} {printf("NUMBER %s\n", yytext); c += strlen(yytext);}
{IDENT} {printf("IDENT %s\n", yytext); c += strlen(yytext);}

; {printf("SEMICOLON\n"); c++;}
: {printf("COLON\n"); c++;}
, {printf("COMMA\n"); c++;}
\( {printf("L_PAREN\n"); c++;}
\) {printf("R_PAREN\n"); c++;}
\[ {printf("L_SQUARE_BRACKET\n"); c++;}
\] {printf("R_SQUARE_BRACKET\n"); c++;}
:= {printf("ASSIGN\n"); c += 2;}

([" "\t])+ {c += strlen(yytext);}
\n {l++; c = 0;}
##.*\n {l++; c = 0;}

(_|{DIGIT})+{IDENT} {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", l, c + 1, yytext); return 0;}
{IDENT}_ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", l, c + 1, yytext); return 0;}
. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", l, c + 1, yytext); return 0;}
%%

int yywrap(){}
int main(int argc, char **argv) {
  ++argv, --argc;
  if(argc > 0)
    yyin = fopen(argv[0], "r");
  else
    yyin = stdin;
  yylex();
  fclose(yyin);
  return 0;
}
