#include <stdio.h>

yyerror(s)
char *s;
{
  printf("%s\n",s);
}

int crokilout(char *szString)
{
  printf(szString);
}

extern FILE *yyin;

int main(int argc, char **argv)
{
  int i;
  if(argc>1)
    for(i=1;i<argc;i++)
      {
	yyin=fopen (argv[i], "r");
	yyparse();
	fclose(yyin);
      }
  else
    yyparse();
}
