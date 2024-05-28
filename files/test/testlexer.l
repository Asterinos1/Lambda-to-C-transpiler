%{
    #include <assert.h>
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int line_num = 1;    
%}

ID          [a-zA-Z][a-zA-Z0-9_]*
DIGIT       [0-9]
NUMBER      {DIGIT}{DIGIT}*
DECIMAL     ("."{NUMBER})|({NUMBER}"."{NUMBER}?)
REAL        {DECIMAL}([eE][+-]?{NUMBER})?

SPEC        ("\""|"\\"|"\r"|"\t"|"\n")
PUNCT       ("-"|"+"|"*"|"/"|":"|"_"|"$"|"!"|"#"|"@"|"~"|"^"|"("|")"|",")
STRING      ("\"")([a-zA-Z0-9]|" "|{SPEC}|{PUNCT})*("\"")

%x comment 

%%
integer         { printf("Token KEYWORD_INT:\t\t%s\n", yytext); } 
scalar          { printf("Token KEYWORD_SCALAR:\t\t%s\n", yytext); }
str             { printf("Token KEYWORD_STRING:\t\t%s\n", yytext); }
bool            { printf("Token KEYWORD_BOOL:\t\t%s\n", yytext); }
True            { printf("Token CONST_TRUE:\t\t%s\n", yytext); }
False           { printf("Token CONST_FALSE:\t\t%s\n", yytext); }
const           { printf("Token KEYWORD_CONST:\t\t%s\n", yytext); }
if              { printf("Token KEYWORD_IF:\t\t%s\n", yytext); }
else            { printf("Token KEYWORD_ELSE:\t\t%s\n", yytext); }
endif           { printf("Token KEYWORD_ENDIF:\t\t%s\n", yytext); }
for             { printf("Token KEYWORD_FOR:\t\t%s\n", yytext); }
in              { printf("Token KEYWORD_IN:\t\t%s\n", yytext); }
endfor          { printf("Token KEYWORD_ENDFOR:\t\t%s\n", yytext); }
while           { printf("Token KEYWORD_WHILE:\t\t%s\n", yytext); }
endwhile        { printf("Token KEYWORD_ENDWHILE:\t\t%s\n", yytext); }
break           { printf("Token KEYWORD_BREAK:\t\t%s\n", yytext); }
continue        { printf("Token KEYWORD_CONTINUE:\t\t%s\n", yytext); }
and             { printf("Token AND_OP:\t\t\t%s\n", yytext); }
or              { printf("Token OR_OP:\t\t\t%s\n", yytext); }
not             { printf("Token NOT_OP:\t\t\t%s\n", yytext); }
def             { printf("Token KEYWORD_DEF:\t\t%s\n", yytext); }
enddef          { printf("Token KEYWORD_ENDDEF:\t\t%s\n", yytext); }
main            { printf("Token KEYWORD_MAIN:\t\t%s\n", yytext); }
return          { printf("Token KEYWORD_RETURN:\t\t%s\n", yytext); }
comp            { printf("Token KEYWORD_COMP:\t\t%s\n", yytext); }
endcomp         { printf("Token KEYWORD_ENDCOMP:\t\t%s\n", yytext); }
of              { printf("Token KEYWORD_OF:\t\t%s\n", yytext); }

{ID}            { printf("Token IDENTIFIER:\t\t%s\n", yytext); }
{NUMBER}        { printf("Token CONST_INT:\t\t%s\n", yytext); }
{REAL}          { printf("Token CONST_REAL:\t\t%s\n", yytext); }
{STRING}        { printf("Token CONST_STRING:\t\t%s\n", yytext); }

"+"             { printf("Token PLUS_OP:\t\t\t+\n"); }         	
"-"             { printf("Token MINUS_OP:\t\t\t-\n"); }
"*"             { printf("Token MULTIPLY_OP:\t\t*\n"); }
"/"             { printf("Token DIVIDE_OP:\t\t/\n"); }    
"%"             { printf("Token REMAINDER_OP:\t\t%%\n"); }
"**"            { printf("Token POWER_OP:\t\t\t**\n"); }

"=="            { printf("Token EQUAL_OP:\t\t\t==\n"); }
"!="            { printf("Token NOT_EQUAL_OP:\t\t!=\n"); }
"<"             { printf("Token LESS_OP:\t\t\t<\n"); }
"<="            { printf("Token LESS_EQUAL_OP:\t\t<=\n"); }
">"             { printf("Token GREATER_OP:\t\t>\n"); }
">="            { printf("Token GREATER_EQUAL_OP:\t\t>=\n"); }       

"="             { printf("Token ASSIGN_OP:\t\t=\n"); }
"+=" 		    { printf("Token PLUS_ASSIGN_OP:\t\t+=\n"); }
"-=" 		    { printf("Token MINUS_ASSIGN_OP:\t\t-=\n"); }
"/=" 		    { printf("Token DIV_ASSIGN_OP:\t\t/=\n"); }
"%=" 		    { printf("Token MOD_ASSIGN_OP:\t\t%%=\n"); }
"*=" 		    { printf("Token MULT_ASSIGN_OP:\t\t*=\n"); }
":=" 		    { printf("Token S_ASSIGN_OP:\t\t:=\n"); }

";"             { printf("Token SEMICOLON:\t\t;\n"); }
"("             { printf("Token LEFT_PARENTHESIS:\t(\n"); }
")"             { printf("Token RIGHT_PARENTHESIS:\t)\n"); }
","             { printf("Token COMMA:\t\t\t,\n"); }
"["             { printf("Token LEFT_BRACKET:\t\t[\n"); }
"]"             { printf("Token RIGHT_BRACKET:\t\t]\n"); }
"{"             { printf("Token LEFT_CURLY_BRACKET:\t{\n"); }
"}"             { printf("Token RIGHT_CURLY_BRACKET:\t}\n"); }
":"             { printf("Token COLON:\t\t\t:\n"); }
"."             { printf("Token PERIOD:\t\t\t.\n"); }

"--"[^\n]*              /* eat line comments */

"/*"                    { BEGIN(comment); }
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        { BEGIN(INITIAL); }

<<EOF>> 	    {return EOF;}
                [ \r\t]			/* skip whitespace */
\n 			    ++line_num;     /* add an extra line when you see \n */
.               { printf("Line %d Lexical Error: Unrecognized literal %s\n", line_num, yytext); }

%%
