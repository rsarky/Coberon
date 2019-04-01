#ifndef AST_H
#define AST_H

struct ast_node;
struct ast_var_declaration;
struct ast_module;
struct ast_declarations;
struct ast_statements;

enum astNodeType {
  AST_NODE,
  AST_MODULE,
  AST_DECLARATIONS,
  //AST_STATEMENTS,
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
  struct ast_var_declaration* var_declarations;
};

struct ast_var_declaration {
  enum astNodeType type;
  char* dtype;
  char* id;
};


static void* alloc_node(enum astNodeType type);
struct ast_module* createModule(struct ast_declarations* decls, char* id);
struct ast_declarations* createDeclarations(struct ast_var_declaration* vars);
struct ast_var_declaration* createVarDeclaration(char* dtype, char* id);
#endif

