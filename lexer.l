%{
#include<stdio.h>
#include<string.h>
#include "parser.tab.h"

int PRINTOKENS;

int yyerror(char* s, ...);
void print(char *s) {
  if(PRINTOKENS) {
    printf("%d\t%s\n", yylineno, s);
  }
}
%}

%option noyywrap yylineno

%%
"." |
"," |
":" |
")" |
"]" |
"(" |
"[" |
"~" |
";" { print(yytext); return yytext[0]; }

"*" { print(yytext); return MULT; }
"+" { print(yytext); return PLUS; }
"-" { print(yytext); return MINUS; }
"&" { print(yytext); return AND; }

"=" { print(yytext); return EQUALS; } // NOTE: = is handled as a special case.
"#" { print(yytext); yylval.subtok = 1; return CMP; }
"<" { print(yytext); yylval.subtok = 2; return CMP; }
"<=" { print(yytext); yylval.subtok = 3; return CMP; }
">" { print(yytext); yylval.subtok = 4; return CMP; }
">=" { print(yytext); yylval.subtok = 5; return CMP; }

":=" { print(yytext); return ASSIGN; } 
DIV { print(yytext); return DIV; }
MOD { print(yytext); return MOD; }
OR { print(yytext); return OR; }
OF { print(yytext); return OF; }
THEN { print(yytext); return THEN; }
DO { print(yytext); return DO; }
UNTIL { print(yytext); return UNTIL; }
END { print(yytext); return END; }
ELSE { print(yytext); return ELSE; }
ELSIF { print(yytext); return ELSIF; }
IF { print(yytext); return IF; }
WHILE { print(yytext); return WHILE; }
REPEAT { print(yytext); return REPEAT; }
ARRAY { print(yytext); return ARRAY; }
RECORD { print(yytext); return RECORD; }
CONST { print(yytext); return CONST; }
TYPE { print(yytext); return TYPE; }
VAR { print(yytext); return VAR; }
PROCEDURE { print(yytext); return PROCEDURE; }
BEGIN { print(yytext); return _BEGIN; }
MODULE { print(yytext); return MODULE; }

[a-zA-Z][a-zA-Z0-9]* { print(yytext); yylval.strval = yytext; return ID; } 
[0-9]+ { print(yytext); yylval.intval = atoi(yytext); return VAL; }

"(*"[.\n]*"*)"
[ \t\n]
. { yyerror("Invalid Character\n"); }
%%
