%{
    #include <assert.h>
    #include <stdio.h>
    #include <string.h>
    #include <math.h>
    /*#include "myanalyzer.tab.h"*/
    #include "cgen.h"

    int lineNum = 1;
%}

ID      [a-zA-Z][a-zA-Z0-9_]*
DIGIT   [0-9]

NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?

SPEC    ("\""|"\\"|"\r"|"\t"|"\n")
PUNCT   ("-"|"+"|"*"|"/"|":"|"_"|"$"|"!"|"#"|"@"|"~"|"^"|"("|")"|",")
STRING  ("\"")([a-zA-Z0-9]|" "|{SPEC}|{PUNCT})*("\"")

%%

int                     { printf("Token KEYWORD_INT:\t\t\t%s\n", yytext); }/**/
scalar                  { printf("Token KEYWORD_SCALAR:\t\t\t%s\n", yytext); }/*NEW*/
str                     { printf("Token KEYWORD_STRING:\t\t\t%s\n", yytext); }/*NEW*/
bool                    { printf("Token KEYWORD_BOOL:\t\t\t%s\n", yytext); }/**/
const                   { printf("Token KEYWORD_CONST:\t\t\t%s\n", yytext); }/**/
if                      { printf("Token KEYWORD_IF:\t\t\t%s\n", yytext); }/**/
endif                   { printf("Token KEYWORD_ENDIF:\t\t\t%s\n", yytext); }/**/
else                    { printf("Token KEYWORD_ELSE:\t\t\t%s\n", yytext); }/**/
for                     { printf("Token KEYWORD_FOR:\t\t\t%s\n", yytext); }/**/
endfor                  { printf("Token KEYWORD_ENDFOR:\t\t\t%s\n", yytext); }/**/
while                   { printf("Token KEYWORD_WHILE:\t\t\t%s\n", yytext); }/**/
endwhile                { printf("Token KEYWORD_ENDWHILE:\t\t\t%s\n", yytext); }/**/
break                   { printf("Token KEYWORD_BREAK:\t\t\t%s\n", yytext); }/**/
continue                { printf("Token KEYWORD_CONTINUE:\t\t\t%s\n", yytext); }/**/
def                     { printf("Token KEYWORD_DEF:\t\t\t%s\n", yytext); }/**/
enddef                  { printf("Token KEYWORD_ENDDEF:\t\t\t%s\n", yytext); }/**/
main                    { printf("Token KEYWORD_MAIN:\t\t\t%s\n", yytext); }/**/
comp                    { printf("Token KEYWORD_COMP:\t\t\t%s\n", yytext); }/**/
endcomp                 { printf("Token KEYWORD_ENDCOMP:\t\t\t%s\n", yytext); }/**/
and                     { printf("Token KEYWORD_AND:\t\t\t%s\n", yytext); }/**/
or                      { printf("Token KEYWORD_OR:\t\t\t%s\n", yytext); }/**/
not                     { printf("Token KEYWORD_NOT:\t\t\t%s\n", yytext); }/**/
return                  { printf("Token KEYWORD_RETURN:\t\t\t%s\n", yytext); }/**/
true                    { printf("Token KEYWORD_TRUE:\t\t\t%s\n", yytext); }/**/
false                   { printf("Token KEYWORD_FALSE:\t\t\t%s\n", yytext); }/**/
of                      { printf("Token KEYWORD_OF:\t\t\t%s\n", yytext); }/**/
in                      { printf("Token KEYWORD_IN:\t\t\t%s\n", yytext); }/**/

readString              { printf("Token FN_readStr:\t\t\t%s\n", yytext); } /*lambdafuncs*/
readInteger             { printf("Token FN_readInt:\t\t\t%s\n", yytext); }
readReal                { printf("Token FN_readScalar:\t\t\t%s\n", yytext); }
writeString             { printf("Token FN_writeStr:\t\t\t%s\n", yytext); }
writeInteger            { printf("Token FN_writeInt:\t\t\t%s\n", yytext); }
writeReal               { printf("Token FN_writeScalar:\t\t\t%s\n", yytext); }

{ID}                    { printf("Token IDENTIFIER:\t\t\t%s\n", yytext);}
{NUMBER}                { printf("Token CONST_INT:\t\t\t%s\n", yytext);}
{REAL}                  { printf("Token CONST_REAL:\t\t\t%s\n", yytext);}
{STRING}                { printf("Token CONST_STRING:\t\t\t%s\n", yytext);}

"+"                     { printf("Token PLUS_OP:\t\t\t+\n"); }
"-"                     { printf("Token MINUS_OP:\t\t\t-\n"); }
"*"                     { printf("Token MULTIPLY_OP:\t\t\t*\n"); }
"/"                     { printf("Token DIVIDE_OP:\t\t\t/\n"); }
"%"                     { printf("Token REMAINDER_OP:\t\t\t%%\n"); }
"**"                    { printf("Token POWER_OP:\t\t\t**\n"); }

"="                     { printf("Token ASSIGN_OP:\t\t\t=\n"); }

"+=" 		            { printf("Token OP1:\t\t\t\t+=\n"); }
"-=" 		            { printf("Token OP2:\t\t\t\t-=\n"); }
"/=" 		            { printf("Token OP3:\t\t\t\t/=\n"); }
"%=" 		            { printf("Token OP4:\t\t\t\t%%=\n"); }
"*=" 		            { printf("Token OP5:\t\t\t\t*=\n"); }
":=" 		            { printf("Token OP6:\t\t\t\t:=\n"); }

"=="                    { printf("Token EQUAL_OP:\t\t\t==\n"); }
"!="                    { printf("Token NOT_EQUAL_OP:\t\t\t!=\n"); }
"<"                     { printf("Token LESS_OP:\t\t\t<\n"); }
"<="                    { printf("Token LESS_EQUAL_OP:\t\t\t<=\n"); }
">"                     { printf("Token GREATER_OP:\t\t\t>\n"); }
">="                    { printf("Token GREATER_EQUAL_OP:\t\t\t>=\n"); }

";"                     { printf("Token SEMICOLON:\t\t\t;\n"); }
"("                     { printf("Token LEFT_PARENTHESIS:\t\t\t(\n"); }
")"                     { printf("Token RIGHT_PARENTHESIS:\t\t\t)\n"); }
","                     { printf("Token COMMA:\t\t\t,\n"); }
"["                     { printf("Token LEFT_BRACKET:\t\t\t[\n"); }
"]"                     { printf("Token RIGHT_BRACKET:\t\t\t]\n"); }
":"                     { printf("Token COLON:\t\t\t:\n"); }
"."                     { printf("Token PERIOD:\t\t\t.\n"); }

"--"[^\n]*              /*line comments */

<<EOF>> 	return EOF;

[ \r\t]+     /* skip whitespace */
\n          ++lineNum;
.           { printf("Line %d Lexical Error: Unrecognized literal %s\n", lineNum, yytext); }

%%
