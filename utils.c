#include "ast.h"
#include "symtab.h"
#include<stdio.h>
#include<stdlib.h>

static int tabCount = 0;
#define INDENT tabCount++
#define DEINDENT tabCount--

//Used for pretty printing
static void printTabs() {
  for(int i=0;i<tabCount;i++)
    printf("\t");
}

static void printStatement(struct ast_node* stmt);
static void printStatements(struct ast_stmt_list* stmts);

static void printExpression(struct ast_expression* exp) {
  if(exp) {
    switch(exp->op) {
      case OP_ADD:
        printExpression(exp->leftexpr);
        printf(" + ");
        printExpression(exp->rightexpr);
        break;
      case OP_SUB:
        printExpression(exp->leftexpr);
        printf(" - ");
        printExpression(exp->rightexpr);
        break;
      case OP_MULT:
        printExpression(exp->leftexpr);
        printf(" * ");
        printExpression(exp->rightexpr);
        break;
      case OP_DIV:
        printExpression(exp->leftexpr);
        printf(" / ");
        printExpression(exp->rightexpr);
        break;
      case OP_PRIM_ID:
        printf("%s", exp->primaryExpr.id);
        break;
      case OP_PRIM_VAL:
        printf("%d", exp->primaryExpr.intConst);
        break;
    }
    
  }
}

static void printAssignment(struct ast_assignment* asgt) {
  printf("%s := ", asgt->id);
  printExpression(asgt->exp);
  printf("\n");
}

static void printWhileStmt(struct ast_while* w) {
  printTabs();
  printf("WHILE STATEMENT:\n");
  INDENT;
  printTabs();
  printf("Expression: ");
  printExpression(w->condition);
  printf("\n");
  printTabs();
  printf("Statements:\n");
  printStatements(w->slist);
  DEINDENT;
}

static void printStatement(struct ast_node* stmt) {
  if(!stmt)
    return;
  switch(stmt->type) {
    case AST_ASSIGNMENT:
      INDENT;
      printTabs();
      printAssignment((struct ast_assignment*) stmt);
      DEINDENT;
      break;
    case AST_WHILE:
      INDENT;
      printWhileStmt((struct ast_while*) stmt);
      DEINDENT;
      break;
  }
}

static void printStatements(struct ast_stmt_list* stmts) {
  if(!stmts)
    return;
  printStatement(stmts->stmt);
  if(stmts->sibling)
    printStatements(stmts->sibling);
}

static void printVarDeclaration(struct ast_var_declaration* decl) {
  printf("ID: %s\tTYPE: %s\n", decl->var->name, decl->var->type);
}
static void printVarList(struct ast_var_list* vlist) {
  printTabs();
  printVarDeclaration(vlist->decl);
  if(vlist->sibling)
    printVarList(vlist->sibling);
}

static void printDeclarations(struct ast_declarations* decl) {
  printTabs();
  printf("Declarations Are:\n");
  INDENT;
  printVarList(decl->var_declarations);
  DEINDENT;
}
static void printModule(struct ast_module* mod) {
  printf("MODULE: %s\n", mod->id);
  INDENT;
  printDeclarations(mod->declarations);
  printTabs();
  printf("Statements Are:\n");
  printStatements(mod->statements);
  DEINDENT;
}

void printNode(struct ast_node* node) {
  printf("\n\n\n***PRINTING AST***\n");
  int type = node->type;
  void* nodep = node;
  switch(type) {
    case AST_NODE:
      printf("Cannot print general AST Node.\n");
      exit(1);
      break;
    case AST_MODULE:
      printModule(nodep);
      break;
    case AST_DECLARATIONS:
      printDeclarations(nodep);
      break;
    case AST_VAR_LIST:
      printVarList(nodep);
      break;
    case AST_VAR_DECLARATION:
      printVarDeclaration(nodep);
      break;
  }
  printf("\n\n\n");
}

void printSymbolTable() {
  struct symbol sym;
  //TODO Very inefficient.
  printf("The contents of the symbol table are: \n");
  for(int i=0;i<NSYM; i++) {
    sym = symTab[i];
    if(sym.name) {
      printf("%s\t%s\n", sym.name, sym.type);
    }
  }
}
