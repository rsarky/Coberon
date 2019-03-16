%{
#include<stdio.h>
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

%%
stmt: ID;
%%
