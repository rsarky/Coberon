#include "symtab.h"

void initTable() {
  struct symbol* sp;
  for(sp=symTab; sp<&symTab[NSYM]; sp++) {
    sp->name = NULL;
    sp->value = 0;
    sp->type = NULL;
  }
}

int hash(char* s) {
  int h = 7;
  int l = strlen(s);
  for(int i=0; i<l; i++) {
    h = h*31 + s[i];
  }
  return h;
}

struct symbol* lookup(char *s) {
  struct symbol* sp = &symTab[hash(s)%NSYM];
  int count = NSYM;
  while(--count > 0) {
    if(sp->name && !strcmp(sp->name, s))
      return sp;
    if(!sp->name) {
      sp->name = strdup(s);
      return sp;
    }

    if(++sp > symTab + NSYM) sp = symTab;
  }
  yyerror("Symbol table full.\n");
  exit(1);
    
}

int declared(char *s) {
  int h = hash(s)%NSYM;
  struct symbol* sp = &symTab[h];
  if(!sp->name)
    return 0;
  while(sp->name) {
    if(!strcmp(sp->name, s))
      return 1;
    if(++sp > symTab + NSYM) sp = symTab;
  }
  return 0;
}
