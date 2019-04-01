%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include "symtab.h"
#include "ast.h"

int yyerror(char* s, ...);
int yylex();
extern int PRINTOKENS;
extern FILE* yyin;
extern int yylineno;
void printNode(struct ast_node* node);
%}

%union {
  int intval;
  char* strval;
  int subtok;
  struct symbol* id;
  struct ast_node* node;
  struct ast_module* moduleNode;
  struct ast_declarations* declarationsNode;
  struct ast_var_declaration* varDeclaration;
}

%token <strval> ID
%token <intval> VAL 
%token <subtok> CMP
%token MULT DIV MOD AND OR PLUS MINUS EQUALS ASSIGN
%token OF THEN DO UNTIL END ELSE ELSIF IF WHILE REPEAT
%token ARRAY RECORD CONST TYPE VAR PROCEDURE _BEGIN MODULE

%type <moduleNode> module
%type <declarationsNode> declarations
%type <varDeclaration> vars
%type <strval> type

//TODO: Precedence and associativities.
%left PLUS MINUS MULT DIV MOD AND OR
%start module
%%

//  module: MODULE ID ';' declarations _BEGIN statementSequence END ID '.'
//        | MODULE ID ';' declarations END ID '.' 
//        ;

module:  MODULE ID ';' declarations END ID '.' { $$ = createModule($4, $2); printNode((struct ast_node*) $$); }; 


// Note that order of declarations matter.
// declarations: constants types vars procedureDeclarations
//            ;

declarations: vars { $$ = createDeclarations($1); };

constants: 
          | CONST assignList
          ;
types:
     | TYPE typeList
     ;

//    vars:
//      | VAR varList 
//      ;

vars: VAR ID ':' type ';' { $$ = createVarDeclaration($4,$2); };

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
type: ID { $$ = $1; }
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
  printf("Syntax error around line no %d\n", yylineno);
  return 1;
}

int main(int argc, char** argv) {
  int opt;
  yyin = NULL;
  initTable();
  while((opt=getopt(argc, argv, ":tf:")) != -1) {
    switch(opt) {
      case 't':
        PRINTOKENS = 1;
        break;
      case 'f':
        yyin = fopen(optarg, "r");
        if(yyin == NULL) {
          printf("Cant open the given file.\n");
          exit(1);
        }
        printf("Parsing %s...\n", optarg);
        break;
      case ':':
        printf("Option needs a filename.\n");
        exit(1);
      case '?':
        printf("Unrecognised option.\n");
        exit(1);
    }
  }
  if(yyin == NULL) {
    printf("Usage: ./parser [-t] -f <file-name>\n");
    exit(1);
  }

  if(!yyparse())
    printf("Parsing Successful.\n");
  else
    printf("Parse error.\n");
  return 0;
}
