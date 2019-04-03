#ifndef SYMTAB_H
#define SYMTAB_H
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#define NSYM 1000

int yyerror(char* s, ...);

struct symbol {
  char* name;
  int value;
  char* type;
};

// Hash table using open addressing
struct symbol symTab[NSYM];

void initTable(void);

int hash(char* s);

struct symbol* lookup(char* s);

int declared(char* s);

#endif
