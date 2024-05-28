%{
    #include <assert.h>
    #include <stdio.h>
    #include <string.h>

    int line_num=1;    
%}


ID          [a-zA-Z][a-zA-Z0-9_]
DIGIT       [0-9]
NUMBER      {DIGIT}{DIGIT}*
DECIMAL     ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL        {DECIMAL}([eE][+-]?{NUMBER})?

STRING      \"[^\n&.]*\"


%x comment

%%
        /*lambda keywords*/
integer         { printf("Token KEYWORD_INT:\t\t%s\n", yytext); return KW_INT;} 
scalar          { printf("Token KEYWORD_SCALAR:\t\t%s\n", yytext); return KW_SCALAR;}
str             { printf("Token KEYWORD_STRING:\t\t%s\n", yytext); return KW_STRING;}
bool            { printf("Token KEYWORD_BOOL:\t\t%s\n", yytext); return KW_BOOL;}
True            { printf("Token CONST_TRUE:\t\t%s\n", yytext); return KW_TRUE;}
False           { printf("Token CONST_FALSE:\t\t%s\n", yytext); return KW_FALSE;}
const           { printf("Token KEYWORD_CONST:\t\t%s\n", yytext); return KW_CONST;}
if              { printf("Token KEYWORD_IF:\t\t%s\n", yytext); return KW_IF;}
else            { printf("Token KEYWORD_ELSE:\t\t%s\n", yytext); return KW_ELSE;}
endif           { printf("Token KEYWORD_ENDIF:\t\t%s\n", yytext); return KW_ENDIF;}
for             { printf("Token KEYWORD_FOR:\t\t%s\n", yytext); return KW_FOR;}
in              { printf("Token KEYWORD_IN:\t\t%s\n", yytext); return KW_IN;}
endfor          { printf("Token KEYWORD_ENDFOR:\t\t%s\n", yytext); return KW_ENDFOR;}
while           { printf("Token KEYWORD_WHILE:\t\t%s\n", yytext); return KW_WHILE;}
endwhile        { printf("Token KEYWORD_ENDWHILE:\t\t%s\n", yytext); return KW_ENDWHILE;}
break           { printf("Token KEYWORD_BREAK:\t\t%s\n", yytext); return KW_BREAK;}
continue        { printf("Token KEYWORD_CONTINUE:\t\t%s\n", yytext); return KW_CONTINUE;}
and             { printf("Token AND_OP:\t\t\t%s\n", yytext); return KW_AND;}
or              { printf("Token OR_OP:\t\t\t%s\n", yytext); return KW_OR;}
not             { printf("Token NOT_OP:\t\t\t%s\n", yytext); return KW_NOT;}
def             { printf("Token KEYWORD_DEF:\t\t%s\n", yytext); return KW_DEF;}
enddef          { printf("Token KEYWORD_ENDDEF:\t\t%s\n", yytext); return KW_ENDDEF;}
main            { printf("Token KEYWORD_MAIN:\t\t%s\n", yytext); return KW_MAIN;}
return          { printf("Token KEYWORD_RETURN:\t\t%s\n", yytext); return KW_RETURN;}
comp            { printf("Token KEYWORD_COMP:\t\t%s\n", yytext); return KW_COMP;}
endcomp         { printf("Token KEYWORD_ENDCOMP:\t\t%s\n", yytext); return KW_ENDCOMP;}
of              { printf("Token KEYWORD_FOR:\t\t%s\n", yytext); return KW_OF;}

/* special keywords */
{ID}            { printf("Token IDENTIFIER:\t\t%s\n", yytext); yylval.str = strdup(yytext); return IDENTIFIER;}
{NUMBER}        { printf("Token CONST_INT:\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_INT;}
{REAL}          { printf("Token CONST_REAL:\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_REAL;}
{STRING}        { printf("Token CONST_STRING:\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_STRING;}

/* arithmetic operators */
"+"             { printf("Token PLUS_OP:\t\t\t+\n"); return '+';}         	
"-"             { printf("Token MINUS_OP:\t\t\t-\n"); return '-';}
"*"             { printf("Token MULTIPLY_OP:\t\t*\n"); return '*';}
"/"             { printf("Token DIVIDE_OP:\t\t/\n"); return '/';}    
"%"             { printf("Token REMAINDER_OP:\t\t%%\n"); return '%';}
"**"            { printf("Token POWER_OP:\t\t\t**\n"); return POW_OP;}


/* relational operators */
"=="            { printf("Token EQUAL_OP:\t\t\t==\n"); return EQ_OP;}
"!="            { printf("Token NOT_EQUAL_OP:\t\t!=\n"); return NEQ_OP;}
"<"             { printf("Token LESS_OP:\t\t\t<\n"); return '<';}
"<="            { printf("Token LESS_EQUAL_OP:\t\t<=\n"); return LE_OP;}
">"             { printf("Token GREATER_OP:\t\t>\n"); return '>';}
">="            { printf("Token GREATER_EQUAL_OP:\t\t<=\n"); return GE_OP;}       
		

/* assignment operators */        
"="             { printf("Token ASSING_OP:\t\t\t==\n"); return '=';}
"+=" 		    { printf("Token PLUS_ASSING_OP:\t\t\t==\n"); return OP1;}
"-=" 		    { printf("Token MINUS_ASSING_OP:\t\t\t==\n"); return OP2;}
"/=" 		    { printf("Token DIV_ASSING_OP:\t\t\t==\n"); return OP3;}
"%=" 		    { printf("Token MOD_ASSING_OP:\t\t\t==\n"); return OP4;}
"*=" 		    { printf("Token MULT_ASSING_OP:\t\t\t==\n"); return OP5;}
":=" 		    { printf("Token S_ASSING_OP:\t\t\t==\n"); return OP6;}

/* delimiters */
";"             { printf("Token SEMICOLON:\t\t;\n"); return ';';}
"("             { printf("Token LEFT_PARENTHESIS:\t\t(\n"); return '(';}
")"             { printf("Token RIGHT_PARENTHESIS:\t)\n"); return ')';}
","             { printf("Token COMMA:\t\t\t,\n"); return ',';}
"["             { printf("Token LEFT_BRACKET:\t\t[\n"); return '[';}
"]"             { printf("Token RIGHT_BRACKET:\t\t]\n"); return ']';}
":"             { printf("Token LEFT_CURLY_BRACKET:\t{\n"); return ':';}
"."             { printf("Token RIGHT_CURLY_BRACKET:\t}\n"); return '.';}
/* signle line comments */
"--"            [^\n]*


/*  House keeping stuff */

[ \r\t]			/* skip whitespace */
\n 			    ++line_num;     /* add an extra line when you see \n*/
.               { printf("Line %d Lexical Error: Unrecognized literal %s\n", lineNum, yytext); }
<<EOF>> 	    { printf("Reached end of file"); return EOF;}

%%
