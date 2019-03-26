%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

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
%left PLUS MINUS MULT DIV MOD AND OR
%start module

%%
module: MODULE ID ';' declarations _BEGIN statementSequence END ID '.'
      | MODULE ID ';' declarations END ID '.' 
      ;

// Note that order of declarations matter.
declarations: constants types vars procedureDeclarations
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
                     | procedureDeclarations procedureDeclaration ';'
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
                | '(' fpSectionList ')'
                ;
fpSectionList: fpSection
             | fpSectionList ';' fpSection 
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
statementSequence: statement 
                 | statementSequence ';' statement
                 ;
statement: 
         | assignment
         | ifStatement
         | whileStatement
         | procedureCall
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
                | '(' expressionList ')'
                ;
expressionList: expression
              | expressionList ',' expression 
              ;

%%

int yyerror(char* s, ...) {
  printf("Parse error! : %s\n", s);
  return 1;
}

int main(int argc, char** argv) {
  if(argc > 1) {
    if (strcmp(argv[1], "-d") == 0) {
      yydebug = 1;
      argc--;
      argv++;
    }
  }

  extern FILE* yyin;
  if(argc > 1 && (yyin = fopen(argv[1], "r")) == NULL ) {
    printf("Cant open the given file.\n");
    exit(1);
  }

  do {
    if(yyparse()) {
      exit(0);
    }
  } while(!feof(yyin));
  printf("success.\n");
  return 0;
}
