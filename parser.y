%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include "symtab.h"
#include "ast.h"
#include "utils.h"

int yyerror(char* s, ...);
int yylex();
extern int PRINTOKENS;
int PRINTAST = 0;
int PRINTST = 0;
extern FILE* yyin;
extern int yylineno;
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
%type <assignment> assignment statement
%type <expression> expression aritexp term factor 
//TODO: Precedence and associativities.
%left PLUS MINUS MULT DIV MOD AND OR
%start module
%%
module:  MODULE ID ';' declarations _BEGIN statementSequence END ID '.' { 
        $$ = createModule($4, $6, $2);
        if(PRINTAST) {
          printNode((struct ast_node*) $$);
        }
        if(PRINTST) {
          printSymbolTable();
        }
      }
      | MODULE ID ';' declarations END ID '.'  { $$ = createModule($4, NULL, $2); }
      ;
        
declarations: vars { $$ = createDeclarations($1); }
            ;

vars: { $$ = NULL; }
    | vars VAR ID ':' type ';' {
      struct ast_var_declaration* d = createVarDeclaration($3, $5);
      $$ =  createVarList($1 , d);
    }
    | vars error ';'
    ;

expression: aritexp
          ;

aritexp : aritexp PLUS term { $$ = createExpression(OP_ADD, $1, $3); } 
        | aritexp MINUS term { $$ = createExpression(OP_SUB, $1, $3); } 
        | term 
        ;

term:
    term MULT factor { $$ = createExpression(OP_MULT, $1, $3); }
   | term DIV factor { $$ = createExpression(OP_DIV, $1, $3); }
   | factor
   ;

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

type: ID
    ;

statementSequence: statement { $$ = createStmtList(NULL, (struct ast_node*) $1); }
                 | statementSequence ';' statement { $$ = createStmtList($1, (struct ast_node*) $3); }
                 | statementSequence error
                 ;

statement: assignment
         ;

assignment: ID ASSIGN expression { $$ = createAssignment($1, $3); }
          ;

%%

int yyerror(char* s, ...) {
  printf("Error. Line No %d. %s\n", yylineno, s);
  return 1;
}

int main(int argc, char** argv) {
  int opt;
  yyin = NULL;
  initTable();
  while((opt=getopt(argc, argv, ":tasf:")) != -1) {
    switch(opt) {
      case 't':
        PRINTOKENS = 1;
        break;
      case 'a':
        PRINTAST = 1;
        break;
      case 's':
        PRINTST = 1;
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
