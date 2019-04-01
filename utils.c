#include "ast.h"
#include<stdio.h>
#include<stdlib.h>

static void printVarDeclarations(struct ast_var_declaration* var) {
  printf("ID: %s\tTYPE: %s\n", var->id, var->dtype);
}
static void printDeclarations(struct ast_declarations* decl) {
  printf("Declarations Are:\n\t\t");
  printVarDeclarations(decl->var_declarations);
}
static void printModule(struct ast_module* mod) {
  printf("MODULE: %s\n", mod->id);
  printf("\t");
  printDeclarations(mod->declarations);
}

void printNode(struct ast_node* node) {
  printf("\n\n\n---PRINTING AST---\n");
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
    case AST_VAR_DECLARATION:
      printVarDeclarations(nodep);
      break;
  }
  printf("\n\n\n");
}
