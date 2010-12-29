#include <stdio.h>
#include "crokil.h"
#include "crokil.tab.h"

int ex(nodeType *p) 
{
  char szTemp[10];
  if (!p) return 0;
  switch(p->type) {
  case typeCon:       return p->con.value;
  case typeId:        return sym[p->id.i];
  case typeMem:       return memory[p->mem.i];
  case typeLab:       return ex(labels[p->lab.i]);
  case typeOpr:
    switch(p->opr.oper) {
    case IF:        if (ex(p->opr.op[0]))
      ex(p->opr.op[1]);
    else if (p->opr.nops > 2)
      ex(p->opr.op[2]);
      return 0;
    case WHILE:     while(ex(p->opr.op[0])) ex(p->opr.op[1]); return 0;
    case PRINT:     sprintf(szTemp,"%d\n", ex(p->opr.op[0]));crokilout(szTemp);return 0;
    case ':':       return ex(labels[p->opr.op[0]->lab.i]=p->opr.op[1]);
    case ';':       ex(p->opr.op[0]); return ex(p->opr.op[1]);
    case '=':       return sym[p->opr.op[0]->id.i] = ex(p->opr.op[1]);
    case '&':       return memory[p->opr.op[0]->mem.i] = ex(p->opr.op[1]);
    case '^':       return sym[p->opr.op[1]->id.i] = memory[p->opr.op[0]->mem.i];
    case '+':       return ex(p->opr.op[0]) + ex(p->opr.op[1]);
    case '-':       return ex(p->opr.op[0]) - ex(p->opr.op[1]);
    case '*':       return ex(p->opr.op[0]) * ex(p->opr.op[1]);
    case '/':       return ex(p->opr.op[0]) / ex(p->opr.op[1]);
    case '%':       return ex(p->opr.op[0]) % ex(p->opr.op[1]);
    case '<':       return ex(p->opr.op[0]) < ex(p->opr.op[1]);
    case '>':       return ex(p->opr.op[0]) > ex(p->opr.op[1]);
    case GE:        return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
    case LE:        return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
    case NE:        return ex(p->opr.op[0]) != ex(p->opr.op[1]);
    case EQ:        return ex(p->opr.op[0]) == ex(p->opr.op[1]);
    default:        sprintf(szTemp,"What's %d?\n",p->opr.oper);yyerror(szTemp);
    }
  }
}







