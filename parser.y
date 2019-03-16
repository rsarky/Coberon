%{
#include<stdio.h>
#include<stdlib.h>

int yyerror(char* s, ...);
int yylex();
%}

%union {
  int intval;
  char* strval;
  int subtok;
}

%token <strval> ID
%token <intval> VAL 
%token <subtok> CMP
%token MULT DIV MOD AND OR PLUS MINUS
%token OF THEN DO UNTIL END ELSE ELSIF IF WHILE REPEAT
%token ARRAY RECORD CONST TYPE VAR PROCEDURE _BEGIN MODULE

%start module

%%
module: MODULE ID ';' declarations
      | _BEGIN statementSequence END ID '.'
      | END ID '.'
      ;

declarations:
            ;
statementSequence:
                 ;
%%

int yyerror(char* s, ...) {
  printf("Parse error! : %s\n", s);
  return 1;
}

int main() {
  extern FILE* yyin;
  yyin = fopen("in.txt", "r");
  do {
    if(yyparse()) {
      printf("failure");
      exit(0);
    }
  } while(!feof(yyin));
  printf("success.\n");
  return 0;
}
