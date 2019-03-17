%{
#include<stdio.h>
#include<string.h>
#include "parser.tab.h"

int yyerror(char* s, ...);
%}

%option noyywrap

%%
"." |
"," |
":" |
")" |
"]" |
"(" |
"[" |
"~" |
";" { return yytext[0]; }

"*" { return MULT; }
"+" { return PLUS; }
"-" { return MINUS; }
"&" { return AND; }

"=" { return EQUALS; }
"#" { yylval.subtok = 1; return CMP; }
"<" { yylval.subtok = 2; return CMP; }
"<=" { yylval.subtok = 3; return CMP; }
">" { yylval.subtok = 4; return CMP; }
">=" { yylval.subtok = 5; return CMP; }

":=" { return ASSIGN; } 
DIV { return DIV; }
MOD { return MOD; }
OR { return OR; }
OF { return OF; }
THEN { return THEN; }
DO { return DO; }
UNTIL { return UNTIL; }
END { return END; }
ELSE { return ELSE; }
ELSIF { return ELSIF; }
IF { return IF; }
WHILE { return WHILE; }
REPEAT { return REPEAT; }
ARRAY { return ARRAY; }
RECORD { return RECORD; }
CONST { return CONST; }
TYPE { return TYPE; }
VAR { return VAR; }
PROCEDURE { return PROCEDURE; }
BEGIN { return _BEGIN; }
MODULE { return MODULE; }

[a-zA-Z][a-zA-Z0-9]* { yylval.strval = yytext; return ID; } 
[0-9]+ { yylval.intval = atoi(yytext); return VAL; }

"(*"[.\n]*"*)"
[ \t\n]
. { yyerror("Invalid Character\n"); }
%%
