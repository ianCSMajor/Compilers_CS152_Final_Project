%option noyywrap

%{
  #include "mini_l.tab.h"
  int l = 1;
  int c = 0;
%}

DIGIT [0-9]
LETTER [A-Za-z]
INTEGER {DIGIT}+
IDENT {LETTER}|({LETTER}({LETTER}|{INTEGER}|_)*({LETTER}|{INTEGER}))

%%
function {return(FUNCTION); c += 8;}
beginparams {return(BEGIN_PARAMS); c += 11;}
endparams {return(END_PARAMS); c += 9;}
beginlocals {return(BEGIN_LOCALS); c += 11;}
endlocals {return(END_LOCALS); c += 9;}
beginbody {return(BEGIN_BODY); c += 9;}
endbody {return(END_BODY); c += 7;}
integer {return(INTEGER); c += 7;}
array {return(ARRAY); c += 5;}
of {return(OF); c += 2;}
if {return(IF); c += 2;}
then {return(THEN); c += 4;}
endif {return(ENDIF); c += 5;}
else {return(ELSE); c += 4;}
while {return(WHILE); c += 5;}
do {return(DO); c += 2;}
beginloop {return(BEGINLOOP); c += 9;}
endloop {return(ENDLOOP); c += 7;}
continue {return(CONTINUE); c += 8;}
break {return(BREAK); c += 5;}
read {return(READ); c += 4;}
write {return(WRITE); c += 5;}
not {return(NOT); c += 3;}
true {return(TRUE); c += 4;}
false {return(FALSE); c += 5;}
return {return(RETURN); c += 6;}

- {return(SUB); c++;}
\+ {return(ADD); c++;}
\* {return(MULT); c++;}
\/ {return(DIV); c++;}
% {return(MOD); c++;}

== {return(EQ); c += 2;}
\<> {return(NEQ); c += 2;}
\< {return(LT); c++;}
> {return(GT); c++;}
\<= {return(LTE); c += 2;}
>= {return(GTE); c += 2;}

{INTEGER} {strcpy(yylval.num, yytext); return(NUMBER); c += strlen(yytext);}
{IDENT} {strcpy(yylval.id, yytext); return(IDENT); c += strlen(yytext);}

; {return(SEMICOLON); c++;}
: {return(COLON); c++;}
, {return(COMMA); c++;}
\( {return(L_PAREN); c++;}
\) {return(R_PAREN); c++;}
\[ {return(L_SQUARE_BRACKET); c++;}
\] {return(R_SQUARE_BRACKET); c++;}
:= {return(ASSIGN); c += 2;}

([ \t])+ {c += strlen(yytext);}
\n {l++; c = 0;}
##.*\n {l++; c = 0;}

(_|{DIGIT})+{IDENT} {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", l, c + 1, yytext); return 0;}
{IDENT}_ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", l, c + 1, yytext); return 0;}
. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", l, c + 1, yytext); return 0;}
%%
