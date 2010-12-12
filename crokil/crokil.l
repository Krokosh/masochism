%{
    #include <stdlib.h>
    #include "crokil.h"
    #include "crokil.tab.h"
%}
%%
[ \t] ;

[a-z]  {yylval.sIndex = *yytext - 'a';return VARIABLE;}

[0-9]+ {yylval.iValue = atoi(yytext); return NUMBER;}

"," return COMMA;
[+\-*/] {yylval.iValue = yytext[0];return OPR;}
"^" return SQR;
"$" return PRINT;
"let" return LET;
"?" return CMP;
"[" return LOAD;
"]" return SAVE;
"=" return EQ;
[><] {yylval.iValue = yytext[0];return CON;}
">=" {yylval.iValue = GE;return CON;}
"=<" {yylval.iValue = LE;return CON;}
"==" {yylval.iValue = EQ;return CON;}
"@" return WHILE;
"#" return JMP;
"\\" return REF;
\n|. return yytext[0];
%%
