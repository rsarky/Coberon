#include<stdlib.h>
#include<string.h>
#include"ast.h"
#include"symtab.h"
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
      break;
    case AST_STMT_LIST:
      size = sizeof(struct ast_stmt_list);
      break;
    case AST_EXPRESSION:
      size = sizeof(struct ast_expression);
      break;
    case AST_ASSIGNMENT:
      size = sizeof(struct ast_assignment);
      break;
  }
  node = calloc(1, size);
  if (node==NULL) {
    printf("Cant allocate memory!\n");
    exit(1);
  }
  node->type = type;
  return node;
}

struct ast_module* createModule(struct ast_declarations* decls,struct ast_stmt_list* stmts, char* id) {
  struct ast_module* module;
  module = alloc_node(AST_MODULE);
  module->declarations = decls;
  module->statements = stmts;
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
  if(declared(s)) {
    yyerror("Variable already declared!");
  }
  struct ast_var_declaration* node;
  node = alloc_node(AST_VAR_DECLARATION);
  node->var = lookup(s);
  node->var->type = strdup(dtype);
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

struct ast_stmt_list* createStmtList(
    struct ast_stmt_list* slist,
    struct ast_node* n) {
  struct ast_stmt_list* s;
  s = alloc_node(AST_STMT_LIST);
  s->stmt = n;
  if(slist) {
    struct ast_stmt_list* head = slist;
    while(slist->sibling)
      slist = slist->sibling;
    slist->sibling = s;
    return head;
  }
  return s;
}

struct ast_assignment* createAssignment(char* id, struct ast_expression* exp) {
  if(!declared(id)) {
    yyerror("Variable not declared!");
  }
  struct ast_assignment* at;
  at = alloc_node(AST_ASSIGNMENT);
  at->id = strdup(id);
  at->exp = exp;
  return at;
}

struct ast_expression* createExpression(
    enum opType op,
    struct ast_expression* lexp,
    struct ast_expression* rexp) {
  struct ast_expression* exp;
  exp = alloc_node(AST_EXPRESSION);
  exp->op = op;
  exp->leftexpr = lexp;
  exp->rightexpr = rexp;
  return exp;
}
