all: mini_l
mini_l.tab.c mini_l.tab.h:	mini_l.y
	bison -t -v -d mini_l.y
lex.yy.c: mini_l.lex mini_l.tab.h
	flex mini_l.lex 
mini_l: lex.yy.c mini_l.tab.c mini_l.tab.h
	g++ -o mini_l mini_l.tab.c lex.yy.c
clean:
	rm mini_l mini_l.tab.c lex.yy.c mini_l.tab.h mini_l.output