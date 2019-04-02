#include"ast.h"
#include<stdlib.h>
#include<string.h>

static void* alloc_node(enum astNodeType type) {
  struct ast_node* node;
  size_t size = 0;
  switch(type) {
    case AST_MODULE:
      size = sizeof(struct ast_module);
    case AST_VAR_DECLARATION:
      size = sizeof(struct ast_var_declaration);
      break;
    case AST_NODE:
      size = sizeof(struct ast_node);
      break;
    case AST_DECLARATIONS:
      size = sizeof(struct ast_declarations);
      break;
    case AST_VAR_LIST:
      size = sizeof(struct ast_var_list);
  }
  node = calloc(1, size);
  if (node==NULL) {
    printf("Cant allocate memory!\n");
    exit(1);
  }
  node->type = type;
  return node;
}

struct ast_module* createModule(struct ast_declarations* decls, char* id) {
  struct ast_module* module;
  module = alloc_node(AST_MODULE);
  module->declarations = decls;
  module->id = strdup(id); 
  return module;
}

struct ast_declarations* createDeclarations(struct ast_var_list* vars) {

  struct ast_declarations* decls;
  decls = alloc_node(AST_DECLARATIONS);
  decls->var_declarations = vars;
  return decls;
}

struct ast_var_declaration* createVarDeclaration(char* s, char *dtype) {
  struct ast_var_declaration* node;
  node = alloc_node(AST_VAR_DECLARATION);
  node->dtype = strdup(dtype);
  node->id = strdup(s);
  return node;
}

struct ast_var_list* createVarList(
    struct ast_var_list* vlist,
    struct ast_var_declaration* vdecl) {
  struct ast_var_list* v;

  v = alloc_node(AST_VAR_LIST);
  v->sibling = NULL;
  v->decl = vdecl;

  struct ast_var_list* head = vlist;
  if(vlist) {
    while(vlist->sibling)
      vlist = vlist->sibling;
    vlist->sibling = v;
    return head;
  }
  return v;
}
