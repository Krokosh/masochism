#include <stdio.h>
#include <X11/Intrinsic.h>
#include <X11/StringDefs.h>
#include <X11/Xaw/Form.h>
#include <X11/Xaw/Command.h>

XtAppContext app_context;

yyerror(s)
char *s;
{
  printf("%s\n",s);
}

int crokilout(char *szString)
{
  printf("%s",szString);
}

extern FILE *yyin;

int main(int argc, char **argv)
{
  int i;
  Widget toplevel, form, w;
  toplevel = XtOpenApplication (&app_context, "XFirst", NULL, 0, &argc,
                                argv, NULL, applicationShellWidgetClass, NULL,
                                0);
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
