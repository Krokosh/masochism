#include <stdio.h>

yyerror(s)
char *s;
{
  printf("%s\n",s);
}

extern FILE *yyin;

int main(int argc, char **argv)
{
  int i;
  FILE *fp;
  if(argc>1)
    for(i=1;i<argc;i++)
      {
	fp=fopen (argv[i], "r");
	yyin=fp;
	yyparse();
	fclose(fp);
      }
  else
    yyparse();
}
