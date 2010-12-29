%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "crokil.h"
  int sym[28];
  int result;
  int memory[1024];
  nodeType *labels[1024];

nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *mem(int i);
nodeType *lab(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
void parseNode(nodeType *p);
 %}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    int aLabel;
    nodeType *nPtr;             /* node pointer */
};

%token <iValue> NUMBER
%token <sIndex> VARIABLE
%token <aLabel> LABEL
%token PRINT LET CMP LOAD SAVE IF WHILE LABEL JMP REF

%right COMMA
%token OPR CON
%left SQR
%left '='

%left EQ NE LT GT LE GE

%type <nPtr> actn expr assg cond actn_list loc
%type <iValue> OPR CON

%%
comm: comm '\n'
    |
    | comm actn '\n'  {ex($2); /*freeNode($2);*/}
    | comm error '\n' {yyerrok;crokilout("AARGH!  It's all broken!\n");}
    ;

actn: PRINT expr               {$$ = opr(PRINT, 1, $2); }
    | assg COMMA VARIABLE      {$$ = opr('=',2,id($3),$1);}
    | CMP expr COMMA expr      {$$ = opr('=',2,id(27),opr('-',2,$2,$4));}
    | LOAD loc COMMA VARIABLE  {$$ = opr('^',2,$2,id($4));}
    | SAVE loc COMMA expr      {$$ = opr('&',2,$2,$4);}
    | cond actn                {$$ = opr(IF, 2, $1, $2); }
    | WHILE cond actn          {$$ = opr(WHILE, 2, $2, $3); }
    | '{' actn_list '}'        {$$ = $2; }
    | ':' expr actn            {$$=NULL;labels[ex($2)]=$3;}
    | JMP expr                 {$$=labels[ex($2)];}
    | REF expr                 {$$=NULL;parseNode(labels[ex($2)]);crokilout("\n");}
    ;

actn_list: actn                  { $$ = $1; }
         | actn_list ';' actn    { $$ = opr(';', 2, $1, $3); }
         ;

cond: CON {$$=opr($1,2,id(27),0);}
    ;

assg: EQ  expr           {$$= $2;}
    | OPR expr COMMA expr  {$$= opr($1,2,$2,$4);}
    ;

loc: expr /*{$$=ex($1);}*/
   ;

expr: '(' expr ')'    {$$ = $2;}
    | expr OPR expr  {$$ = opr($2,2,$1,$3);}
    | SQR expr        {$$ = opr('*',2,$2,$2);}
    | '!' assg        {$$ = $2;}
    | VARIABLE        {$$ = id($1);}
    | NUMBER          {$$ = con($1);}
    ;

%% 

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(conNodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(idNodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *mem(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(memNodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeMem;
    p->mem.i = i;

    return p;
}

nodeType *lab(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(labNodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeLab;
    p->lab.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t size;
    int i;

    /* allocate node */
    size = sizeof(oprNodeType) + (nops - 1) * sizeof(nodeType*);
    if ((p = malloc(size)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void parseNode(nodeType *p) {
  int i;
  char szTemp[10];
  char op=',';
  if (!p) return;
  switch(p->type) 
    {	
    case typeOpr:
      if(p->opr.oper==';')
	crokilout("{");
      else 
	switch(p->opr.oper) {
	case IF:        break;
	case WHILE:     crokilout("@");break;
	case PRINT:     crokilout("$");break;
	case CMP:       crokilout("?");break;
	case GE:        crokilout(">=");break;
	case LE:        crokilout("=<");break;
	case NE:        crokilout("!");break;
	case EQ:        crokilout("==");break;
	case '=':       
	  if(p->opr.op[0]->id.i<27)
	    crokilout("=");
	  else
	    {
	      crokilout("?");
	      parseNode(p->opr.op[1]->opr.op[0]);
	      crokilout(",");
	      parseNode(p->opr.op[1]->opr.op[1]);
	      return;
	    }
	  break;
	default:        op=p->opr.oper;
	}
      if(p->opr.oper==WHILE)
	{
	  switch(p->opr.op[0]->opr.oper)
	    {
	    case GE:        crokilout(">=");break;
	    case LE:        crokilout("=<");break;
	    case NE:        crokilout("!");break;
	    case EQ:        crokilout("==");break;
	    default:        sprintf(szTemp,"%c",p->opr.op[0]->opr.oper);crokilout(szTemp);
	    }
	  parseNode(p->opr.op[1]);
	}
      else if(p->opr.oper==';')
	for (i = 0; i < p->opr.nops; i++)
	  {
	    if(i)
	      crokilout(";");
	    parseNode(p->opr.op[i]);
	  }
      else
	{
	  for (i = 1; i < p->opr.nops; i++)
	    {
	      parseNode(p->opr.op[i]);
	      if(i)
		{
		  sprintf(szTemp,"%c",op);
		  crokilout(szTemp);
		}
	    }  
	  parseNode(p->opr.op[0]);

	}
      if(p->opr.oper==';')
	crokilout("}");
      break;

    case typeCon:
      sprintf(szTemp,"%d", p->con.value);
      crokilout(szTemp);
      break;
    case typeId: 
      sprintf(szTemp,"%c", p->id.i+'a');
      crokilout(szTemp);
      break;
    case typeMem: 
      sprintf(szTemp,"%d", memory[p->mem.i]);
      crokilout(szTemp);
      break;
    case typeLab:  
      sprintf(szTemp,"%d", ex(labels[p->lab.i]));
      crokilout(szTemp);
      break;
    }
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

