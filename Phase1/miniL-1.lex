
%option noyywrap
/*Phase1:
 * Description: Idenitfy special characters, numbers and symbols and output correct keyword.
 */

%{
/* definitions */
/* need this for the call to getlogin() below */
#include <unistd.h>
%}

%%
function {printf("FUNCTION\n");}
beginparams {printf("BEGIN_PARAMS\n");}
endparams {printf("END_PARAMS\n");}
beginlocals {printf("BEGIN_LOCALS\n");}
endlocals {printf("END_LOCALS\n");}
beginbody {printf("BEGIN_BODY\n");}
endbody {printf("END_BODY\n");}
integer {printf("INTEGER\n");}
array {printf("ARRAY\n");}
of {printf("OF\n");}
if {printf("IF\n");}
then {printf("THEN\n");}
endif {printf("endif\n");}
else {printf("ELSE\n");}
while {printf("WHILE\n");}
do {printf("DO\n");}
beginloop {printf("BEGINLOOP\n");}
endloop {printf("ENDLOOP\n");}
continue {printf("CONTINUE\n");}
break {printf("BREAK\n");}
read {printf("READ\n");}
write {printf("WRITE\n");}
not {printf("NOT\n");}
true {printf("TRUE\n");}
false {printf("FALSE\n");}
return {printf("RETURN\n");}

\- {printf("SUB\n");}
\+ {printf("ADD\n");}
\* {printf("MULT\n");}
\/ {printf("DIV\n");}
\% {printf("MOD\n");}

\=\= {printf("EQ\n");}
\<\> {printf("NEQ\n");}
\< {printf("LT\n");}
\> {printf("GT\n");}
\<\= {printf("LTE\n");}
\>\= {printf("GTE\n");}

\; {printf("SEMICOLON\n");}
\: {printf("COLON\n");}
\, {printf("COMMA\n");}
\( {printf("L_PAREN\n");}
\) {printf("R_PAREN\n");}
\[ {printf("L_SQUARE_BRACKET\n");}
\] {printf("R_SQUARE_BRACKET\n");}
\:\= {printf("ASSIGN\n");}

[a-zA-Z_][a-zA-Z0-9_]* {printf("Identifier: %s\n", yytext);}
.+ {printf("Invalid\n");}
\n {return 0;}
%%


main()
{
  printf("Enter String: ");
  yylex();

  return 0;
}
