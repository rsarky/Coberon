#ifndef AST_H
#define AST_H
#include "symtab.h"

struct ast_node;
struct ast_module;
struct ast_declarations;
struct ast_var_list;
struct ast_var_declaration;
struct ast_stmt_list;
struct ast_assignment;
struct ast_expression;

enum astNodeType {
  AST_NODE,
  AST_MODULE,
  AST_DECLARATIONS,
  AST_VAR_LIST,
  AST_VAR_DECLARATION,
  AST_STMT_LIST,
  AST_ASSIGNMENT,
  AST_EXPRESSION
};

enum opType {
  OP_ADD,
  OP_SUB,
  OP_MULT,
  OP_DIV,
  OP_PRIM_ID,
  OP_PRIM_VAL
};

struct ast_node {
  enum astNodeType type;
};

struct ast_module {
  enum astNodeType type;
  struct ast_declarations* declarations;
  struct ast_stmt_list* statements;
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
  struct symbol* var;
};

struct ast_stmt_list {
  enum astNodeType type;
  struct ast_stmt_list* sibling;
  struct ast_node* stmt;
};

struct ast_assignment {
  enum astNodeType type;
  char* id;
  struct ast_expression* exp;
};

struct ast_expression {
   enum astNodeType type;
   enum opType op;
   struct ast_expression* leftexpr;
   struct ast_expression* rightexpr; 
   union {
     int intConst;
     char* id;
   } primaryExpr;
};

static void* alloc_node(enum astNodeType type);
struct ast_module* createModule(
    struct ast_declarations* decls,
    struct ast_stmt_list* stmts,
    char* id);
struct ast_declarations* createDeclarations(struct ast_var_list* vars);
struct ast_var_list* createVarList(
    struct ast_var_list* vlist,
    struct ast_var_declaration* vdecl);
struct ast_var_declaration* createVarDeclaration(char* id, char* dtype);
struct ast_stmt_list* createStmtList(
    struct ast_stmt_list* slist,
    struct ast_node* stmt);
struct ast_assignment* createAssignment(char* id, struct ast_expression* exp);
struct ast_expression* createExpression(
    enum opType op,
    struct ast_expression* l,
    struct ast_expression* r);
#endif

