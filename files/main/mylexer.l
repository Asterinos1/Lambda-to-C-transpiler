%{
    #include <assert.h>
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>
    #include "myanalyzer.tab.h"
    #include "cgen.h"

    int line_num = 1;

    // Structure to store macros
    typedef struct Macro {
        char *identifier;
        char *replacement;
        struct Macro *next;
    } Macro;

    Macro *macro_list = NULL;

    // Function to add a macro to the list
    void add_macro(const char *identifier, const char *replacement) {
        Macro *new_macro = (Macro *)malloc(sizeof(Macro));
        new_macro->identifier = strdup(identifier);
        new_macro->replacement = strdup(replacement);
        new_macro->next = macro_list;
        macro_list = new_macro;
    }

    // Function to get a macro replacement
    const char *get_macro_replacement(const char *identifier) {
        Macro *current = macro_list;
        while (current) {
            if (strcmp(current->identifier, identifier) == 0) {
                return current->replacement;
            }
            current = current->next;
        }
        return NULL;
    }

    // Function to free the macro list
    void free_macros() {
        Macro *current = macro_list;
        while (current) {
            Macro *temp = current;
            current = current->next;
            free(temp->identifier);
            free(temp->replacement);
            free(temp);
        }
    }
%}

%x MACRO_DEF

ID      [a-zA-Z][a-zA-Z0-9_]*
DIGIT   [0-9]
NUMBER  {DIGIT}+
DECIMAL ("."{NUMBER})|({NUMBER}"."{NUMBER}?)
SCALAR    {DECIMAL}([eE][+-]?{NUMBER})?
STRING  \"[^\n&.]*\"

%%
int                     { printf("//Token KEYWORD_INT2:\t\t\t%s\n", yytext); return KW_INT; } /*including both int, integers and str, strings since some programs mix it...*/
integer                 { printf("//Token KEYWORD_INT:\t\t\t%s\n", yytext); return KW_INT; }
scalar                  { printf("//Token KEYWORD_SCALAR:\t\t\t%s\n", yytext); return KW_SCALAR; }
str                     { printf("//Token KEYWORD_STRING:\t\t\t%s\n", yytext); return KW_STR; }
string                  { printf("//Token KEYWORD_STRING2:\t\t\t%s\n", yytext); return KW_STR; }
bool                    { printf("//Token KEYWORD_BOOL:\t\t\t%s\n", yytext); return KW_BOOL; }
const                   { printf("//Token KEYWORD_CONST:\t\t\t%s\n", yytext); return KW_CONST; }
if                      { printf("//Token KEYWORD_IF:\t\t\t%s\n", yytext); return KW_IF; }
endif                   { printf("//Token KEYWORD_ENDIF:\t\t\t%s\n", yytext); return KW_ENDIF; }
else                    { printf("//Token KEYWORD_ELSE:\t\t\t%s\n", yytext); return KW_ELSE; }
for                     { printf("//Token KEYWORD_FOR:\t\t\t%s\n", yytext); return KW_FOR; }
endfor                  { printf("//Token KEYWORD_ENDFOR:\t\t\t%s\n", yytext); return KW_ENDFOR; }
while                   { printf("//Token KEYWORD_WHILE:\t\t\t%s\n", yytext); return KW_WHILE; }
endwhile                { printf("//Token KEYWORD_ENDWHILE:\t\t\t%s\n", yytext); return KW_ENDWHILE; }
break                   { printf("//Token KEYWORD_BREAK:\t\t\t%s\n", yytext); return KW_BREAK; }
continue                { printf("//Token KEYWORD_CONTINUE:\t\t\t%s\n", yytext); return KW_CONTINUE; }
def                     { printf("//Token KEYWORD_DEF:\t\t\t%s\n", yytext); return KW_DEF; }
enddef                  { printf("//Token KEYWORD_ENDDEF:\t\t\t%s\n", yytext); return KW_ENDDEF; }
main                    { printf("//Token KEYWORD_MAIN:\t\t\t%s\n", yytext); return KW_MAIN; }
comp                    { printf("//Token KEYWORD_COMP:\t\t\t%s\n", yytext); return KW_COMP; }
endcomp                 { printf("//Token KEYWORD_ENDCOMP:\t\t\t%s\n", yytext); return KW_ENDCOMP; }
and                     { printf("//Token KEYWORD_AND:\t\t\t%s\n", yytext); return KW_AND; }
or                      { printf("//Token KEYWORD_OR:\t\t\t%s\n", yytext); return KW_OR; }
not                     { printf("//Token KEYWORD_NOT:\t\t\t%s\n", yytext); return KW_NOT; }
return                  { printf("//Token KEYWORD_RETURN:\t\t\t%s\n", yytext); return KW_RETURN; }
True                    { printf("//Token KEYWORD_TRUE:\t\t\t%s\n", yytext); return KW_TRUE; }
False                   { printf("//Token KEYWORD_FALSE:\t\t\t%s\n", yytext); return KW_FALSE; }
of                      { printf("//Token KEYWORD_OF:\t\t\t%s\n", yytext); return KW_OF; }
in                      { printf("//Token KEYWORD_IN:\t\t\t%s\n", yytext); return KW_IN; }
void                    { printf("//Token KEYWORD_VOID:\t\t\t%s\n", yytext); return KW_VOID; }

readString              { printf("//Token FN_readStr:\t\t\t%s\n", yytext); return FN_readStr; } /*lambdafuncs*/
readInteger             { printf("//Token FN_readInteger:\t\t\t%s\n", yytext); return FN_readInteger; }
readScalar              { printf("//Token FN_readScalar:\t\t\t%s\n", yytext); return FN_readScalar; }
writeString             { printf("//Token FN_writeStr:\t\t\t%s\n", yytext); return FN_writeStr; }
writeInteger            { printf("//Token FN_writeInteger:\t\t\t%s\n", yytext); return FN_writeInteger; }
writeScalar             { printf("//Token FN_writeScalar:\t\t\t%s\n", yytext); return FN_writeScalar; }
write                   { printf("//Token FN_write:\t\t\t%s\n", yytext); return FN_write; }

"@defmacro" {
    BEGIN(MACRO_DEF);
    yytext[0] = 0;  
} 

<MACRO_DEF>[^\n]*\n {
    char id[256];
    char replacement[256];
    if (sscanf(yytext, " %255s %255[^\n]", id, replacement) == 2) {
        add_macro(id, replacement);
        printf("//Macro defined: %s -> %s\n", id, replacement);
        BEGIN(INITIAL);
    } else {
        printf("//Line %d Lexical Error: Invalid macro definition %s\n", line_num, yytext);
        BEGIN(INITIAL);
    }
}

{ID} {
    const char *replacement = get_macro_replacement(yytext);
    if (replacement) {
        printf("//Token MACRO_REPLACEMENT:\t\t%s -> %s\n", yytext, replacement);
        yylval.str = strdup(replacement);
        return CONST_STRING;  // Use a suitable token type for macro replacements
    } else {
        printf("//Token IDENTIFIER:\t\t\t%s\n", yytext);
        yylval.str = strdup(yytext);
        return IDENTIFIER;
    }
}

{NUMBER}                { printf("//Token CONST_INT:\t\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_INT; }
{SCALAR}                  { printf("//Token CONST_SCALAR:\t\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_SCALAR; }
{STRING}                { printf("//Token CONST_STRING:\t\t\t%s\n", yytext); yylval.str = strdup(yytext); return CONST_STRING; }

"+"                     { printf("//Token PLUS_OP:\t\t\t+\n"); return '+'; }
"-"                     { printf("//Token MINUS_OP:\t\t\t-\n"); return '-'; }
"*"                     { printf("//Token MULTIPLY_OP:\t\t\t*\n"); return '*'; }
"/"                     { printf("//Token DIVIDE_OP:\t\t\t/\n"); return '/'; }
"%"                     { printf("//Token REMAINDER_OP:\t\t\t%%\n"); return '%'; }
"**"                    { printf("//Token POWER_OP:\t\t\t**\n"); return POW_OP; }

"="                     { printf("//Token ASSIGN_OP:\t\t\t=\n"); return ASSIGN; }

"+="                    { printf("//Token OP1:\t\t\t\t+=\n"); return OP1; }
"-="                    { printf("//Token OP2:\t\t\t\t-=\n"); return OP2; }
"/="                    { printf("//Token OP3:\t\t\t\t/=\n"); return OP3; }
"%="                    { printf("//Token OP4:\t\t\t\t%%=\n"); return OP4; }
"*="                    { printf("//Token OP5:\t\t\t\t*=\n"); return OP5; }
":="                    { printf("//Token OP6:\t\t\t\t:=\n"); return OP6; }

"=="                    { printf("//Token EQUAL_OP:\t\t\t==\n"); return EQ_OP; }
"!="                    { printf("//Token NOT_EQUAL_OP:\t\t\t!=\n"); return NEQ_OP; }
"<"                     { printf("//Token LESS_OP:\t\t\t<\n"); return '<'; }
"<="                    { printf("//Token LESS_EQUAL_OP:\t\t\t<=\n"); return LE_OP; }
">"                     { printf("//Token GREATER_OP:\t\t\t>\n"); return '>'; }
">="                    { printf("//Token GREATER_EQUAL_OP:\t\t\t>=\n"); return GE_OP; }

";"                     { printf("//Token SEMICOLON:\t\t\t;\n"); return ';'; }
"("                     { printf("//Token LEFT_PARENTHESIS:\t\t(\n"); return '('; }
")"                     { printf("//Token RIGHT_PARENTHESIS:\t\t)\n"); return ')'; }
","                     { printf("//Token COMMA:\t\t\t,\n"); return ','; }
"["                     { printf("//Token LEFT_BRACKET:\t\t[\n"); return '['; }
"]"                     { printf("//Token RIGHT_BRACKET:\t\t]\n"); return ']'; }
":"                     { printf("//Token COLON:\t\t\t:\n"); return ':'; }
"."                     { printf("//Token PERIOD:\t\t\t.\n"); return '.'; }

"#"                     { printf("//Token DIESI:\t\t\tdiesi\n"); return '#'; } /*NEW*/

"--"[^\n]*              /* line comment */

<<EOF>>                 { free_macros(); return EOF; }

[ \r\t]+                /* skip whitespace */
\n                      { ++line_num; }
.                       { printf("//Line %d Lexical Error: Unrecognized literal %s\n", line_num, yytext); }
