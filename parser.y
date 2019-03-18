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
%token MULT DIV MOD AND OR PLUS MINUS EQUALS ASSIGN
%token OF THEN DO UNTIL END ELSE ELSIF IF WHILE REPEAT
%token ARRAY RECORD CONST TYPE VAR PROCEDURE _BEGIN MODULE

//TODO: Precedence and associativities.
%left PLUS 
%start module

%%
module: MODULE ID ';' declarations _BEGIN statementSequence END ID '.'
      | MODULE ID ';' declarations END ID '.' 
      ;

// Note that order of declarations matter.
declarations: constants types vars
//            | procedureDeclarations
            ;
constants: 
          | CONST assignList
          ;
types:
     | TYPE typeList
     ;
vars:
    | VAR varList
    ;
assignList:
          | assignList ID EQUALS expression ';'
          ;
typeList:
        | typeList ID EQUALS type ';'
        ;
varList:
       | varList idList ':' type ';' 
       ;
procedureDeclarations:
                     | procedureDeclaration ';'
                     ;
expression: simpleExpression
          | simpleExpression CMP simpleExpression
          | simpleExpression EQUALS simpleExpression 
          ;
simpleExpression: term termList
                | PLUS term termList
                | MINUS term termList
                ;
termList:
        | termList PLUS term
        | termList MINUS term
        | termList OR term
        ;
term: factor factorList
    ;
factorList:
          | factorList MULT factor
          | factorList DIV factor
          | factorList MOD factor
          | factorList AND factor
          ;
factor: ID selector
      | VAL
      | '(' expression ')'
      | '~' factor
      ;
selector:
        | selector '.' ID
        | selector '[' expression ']'
        ;
idList: idList ',' ID
      | ID
      ;
procedureDeclaration: procedureHeading ';' procedureBody
                    ;
procedureHeading: PROCEDURE ID
                | PROCEDURE ID formalParameters
                ;
formalParameters: '(' ')'
                | '(' fpSection fpSectionList ')'
                ;
fpSectionList:
             | ';' fpSection fpSectionList
             ;
fpSection: VAR idList ':' type
         | idList ':' type
         ;
type: ID
    | arrayType
    | recordType
    ;
arrayType: ARRAY expression OF type
         ;
recordType: RECORD fieldList fields END
          ;
fields:
      | ';' fieldList fields
      ;
fieldList:
         | idList ':' type
         ;
procedureBody: declarations END ID
             | declarations _BEGIN statementSequence END ID
             ;
statementSequence: 
                 | statementSequence statement ';'
                 ;
statement: 
         | assignment
         | ifStatement
         | whileStatement
         ;
whileStatement: WHILE expression DO statementSequence END
ifStatement: IF expression THEN statementSequence elseifs END 
           | IF expression THEN statementSequence elseifs ELSE statementSequence END 
           ;
elseifs:
       | elseifs ELSIF expression THEN statementSequence
       ;
assignment: ID selector ASSIGN expression
          ;
procedureCall: ID selector
             | ID selector actualParameters
             ;
actualParameters: '(' ')'
                | '(' expression expressionList ')'
                ;
expressionList: 
              | ',' expression expressionList
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
      exit(0);
    }
  } while(!feof(yyin));
  printf("success.\n");
  return 0;
}
