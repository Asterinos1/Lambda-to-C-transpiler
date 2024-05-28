%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>	    
    
extern int yylex(void);    
%}

%union
{
    char* str;
}


/* lamda tokens*/

%token KW_INT
%token KW_REAL
%token KW_STRING
%token KW_BOOL
%token KW_VAR
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_FOR
%token KW_WHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_FUNC
%token KW_NIL
%token KW_RETURN
%token KW_BEGIN
%token KW_TRUE
%token KW_FALSE
%token KW_NOT
%token KW_AND
%token KW_OR
