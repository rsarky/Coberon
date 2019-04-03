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
  struct ast_var_list* varList;
  struct ast_var_declaration* varDeclaration;
  struct ast_stmt_list* statements;
  struct ast_assignment* assignment;
  struct ast_expression* expression;
}

%token <strval> ID
%token <intval> VAL 
%token <subtok> CMP
%token MULT DIV MOD AND OR PLUS MINUS EQUALS ASSIGN
%token OF THEN DO UNTIL END ELSE ELSIF IF WHILE REPEAT
%token ARRAY RECORD CONST TYPE VAR PROCEDURE _BEGIN MODULE

%type <moduleNode> module
%type <declarationsNode> declarations
%type <varList> vars
%type <strval> type
%type <statements> statementSequence
%type <assignment> assignment
%type <expression> expression aritexp term factor statement
//TODO: Precedence and associativities.
%left PLUS MINUS MULT DIV MOD AND OR
%start module
%%
// Note: All the commented stuff is the original grammar. 
// Grammar has been tweaked to make life easier.
//  module: MODULE ID ';' declarations _BEGIN statementSequence END ID '.'
//        | MODULE ID ';' declarations END ID '.' 
//        ;

module:  MODULE ID ';' declarations _BEGIN statementSequence END ID '.' { $$ = createModule($4, $6, $2); printNode((struct ast_node*) $$); }
        | MODULE ID ';' declarations END ID '.' ;


// Note that order of declarations matter.
// declarations: constants types vars procedureDeclarations
//            ;

declarations: vars { $$ = createDeclarations($1); }

/* constants: */ 
/*           | CONST assignList */
/*           ; */
/* types: */
/*      | TYPE typeList */
/*      ; */

/* vars: { $$ = NULL; } */
/*     | VAR varList { $$ = $2; } */
/*     ; */

vars: { $$ = NULL; }
    | vars VAR ID ':' type ';' {
      struct ast_var_declaration* d = createVarDeclaration($3, $5);
      $$ =  createVarList($1 , d);
    };

/* assignList: */
/*           | assignList ID EQUALS expression ';' */ 
/*           ; */
/* typeList: */
/*         | typeList ID EQUALS type ';' */
/*         ; */
/* varList: */ 
/*        | varList idList ':' type ';' */ 
/*        ; */

/* procedureDeclarations: */
/*                      | procedureDeclarations procedureDeclaration ';' */
/*                      ; */

/* Only Arithmetic Expressions */
/* expression: simpleExpression */
/*           | simpleExpression CMP simpleExpression */
/*           | simpleExpression EQUALS simpleExpression */ 
/*           ; */
/* simpleExpression: term termList */
/*                 | PLUS term termList */
/*                 | MINUS term termList */
/*                 ; */
/* termList: */
/*         | termList PLUS term */
/*         | termList MINUS term */
/*         | termList OR term */
/*         ; */
/* term: factor factorList */
/*     ; */
/* factorList: */
/*           | factorList MULT factor */
/*           | factorList DIV factor */
/*           | factorList MOD factor */
/*           | factorList AND factor */
/*           ; */
/* factor: ID selector */ 
/*       | VAL */
/*       | '(' expression ')' */
/*       | '~' factor */
/*       ; */

expression: aritexp
          ;
aritexp : aritexp PLUS term {
    $$ = createExpression(OP_ADD, $1, $3);
} | aritexp MINUS term {
    $$ = createExpression(OP_SUB, $1, $3);
} | term ;

term:
    term MULT factor {
    $$ = createExpression(OP_MULT, $1, $3);
    }
   | term DIV factor {
    $$ = createExpression(OP_DIV, $1, $3);
   }
   | factor;

factor: ID { 
      if(!declared($1))
        yyerror("Variable not declared!");
      $$ = createExpression(OP_PRIM_ID, NULL, NULL);
      ($$)->primaryExpr.id = strdup($1);
      }
      | VAL {
      $$ = createExpression(OP_PRIM_VAL, NULL, NULL);
      ($$)->primaryExpr.intConst = $1;
      };

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
/* type: ID */ 
/*     | arrayType */
/*     | recordType */
/*     ; */


type: ID ;

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
                 | statementSequence ';' statement { $$ = createStmtList($1, (struct ast_node*) $3); }
                 ;
/* statement: */ 
/*          | assignment */
/*          | ifStatement */
/*          | whileStatement */
/*          | procedureCall */
/*          ; */
statement:
         | assignment;
whileStatement: WHILE expression DO statementSequence END
ifStatement: IF expression THEN statementSequence elseifs END 
           | IF expression THEN statementSequence elseifs ELSE statementSequence END 
           ;
elseifs:
       | elseifs ELSIF expression THEN statementSequence
       ;
assignment: ID selector ASSIGN expression { $$ = createAssignment($1, $4); }
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
  printf("Syntax error. Line No %d, Error: %s\n", yylineno, s);
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
