#ifndef AST_H
#define AST_H
#include "symtab.h"

struct ast_node;
struct ast_module;
struct ast_declarations;
struct ast_var_list;
struct ast_var_declaration;

enum astNodeType {
  AST_NODE,
  AST_MODULE,
  AST_DECLARATIONS,
  AST_VAR_LIST,
  AST_VAR_DECLARATION
};


struct ast_node {
  enum astNodeType type;
};

struct ast_module {
  enum astNodeType type;
  struct ast_declarations* declarations;
  //struct ast_statements* statements;
  char* id;
};

struct ast_declarations {
  enum astNodeType type;
  struct ast_var_list* var_declarations;
};

struct ast_var_list {
  enum astNodeType type;
  struct ast_var_list* sibling;
  struct ast_var_declaration* decl;
};

struct ast_var_declaration {
  enum astNodeType type;
  char* id;
  char* dtype;
};


static void* alloc_node(enum astNodeType type);
struct ast_module* createModule(struct ast_declarations* decls, char* id);
struct ast_declarations* createDeclarations(struct ast_var_list* vars);
struct ast_var_list* createVarList(
    struct ast_var_list* vlist,
    struct ast_var_declaration* vdecl);
struct ast_var_declaration* createVarDeclaration(char* id, char* dtype);
#endif

