typedef enum { typeCon, typeId, typeMem, typeOpr, typeLab } nodeEnum;

/* constants */
typedef struct {
    nodeEnum type;              /* type of node */
    int value;                  /* value of constant */
} conNodeType;

/* identifiers */
typedef struct {
    nodeEnum type;              /* type of node */
    int i;                      /* subscript to ident array */
} idNodeType;

typedef struct {
    nodeEnum type;              /* type of node */
    int i;                      /* subscript to ident array */
} memNodeType;

typedef struct {
    nodeEnum type;              /* type of node */
    int i;                      /* subscript to ident array */
} labNodeType;

/* operators */
typedef struct {
    nodeEnum type;              /* type of node */
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    union nodeTypeTag *op[1];   /* operands (expandable) */
} oprNodeType;

typedef union nodeTypeTag {
    nodeEnum type;              /* type of node */
    conNodeType con;            /* constants */
    idNodeType id;              /* identifiers */
    memNodeType mem;              /* identifiers */
    labNodeType lab;
    oprNodeType opr;            /* operators */
} nodeType;

extern int sym[28];
extern int memory[1024];
extern nodeType *labels[1024];

int ex(nodeType *p);





















