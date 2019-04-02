#include "ast.h"
#include<stdio.h>
#include<stdlib.h>

static int tabCount = 0;
static void printTabs() {
  for(int i=0;i<tabCount;i++)
    printf("\t");
}
static void printVarDeclaration(struct ast_var_declaration* decl) {
  printf("ID: %s\tTYPE: %s\n", decl->id, decl->dtype);
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
  tabCount++;
  printVarList(decl->var_declarations);
  tabCount--;
}
static void printModule(struct ast_module* mod) {
  printf("MODULE: %s\n", mod->id);
  tabCount++;
  printDeclarations(mod->declarations);
  tabCount--;
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
    case AST_VAR_LIST:
      printVarList(nodep);
      break;
    case AST_VAR_DECLARATION:
      printVarDeclaration(nodep);
      break;
  }
  printf("\n\n\n");
}
