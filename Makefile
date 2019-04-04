all: parser

parser.tab.c parser.tab.h: parser.y symtab.h
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h symtab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h symtab.c symtab.h ast.h ast.c utils.c utils.h
	gcc -o parser parser.tab.c symtab.c lex.yy.c ast.c utils.c -DYYDEBUG=1

clean:
	rm parser parser.tab.c lex.yy.c parser.tab.h
