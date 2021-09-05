do:
	bison -d parser.y
	flex lexer.l
	gcc -w parser.tab.c lex.yy.c -lfl

clean:
	rm parser.tab.c parser.tab.h lex.yy.c a.out
