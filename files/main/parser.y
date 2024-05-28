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


/* lambda tokens*/

%token KW_INT
%token KW_SCALAR
%token KW_STRING
%token KW_BOOL
%token KW_TRUE
%token KW_FALSE
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_ENDIF
%token KW_FOR
%token KW_IN
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_AND
%token KW_OR
%token KW_NOT
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_RETURN
%token KW_COMP
%token KW_ENDCOMP
%token KW_OF

/* speciaal keywords tokens*/
%token <str> IDENTIFIER
%token <str> CONST_INT
%token <str> CONST_REAL
%token <str> CONST_STRING

/* arithmetic operators tokens*/


/* relational operator tokens*/
%token EQ_OP
%token NEQ_OP
%token LE_OP
%token GE_OP


%%

program:

%%
int main ()
{
   if ( yyparse() == 0 )
		printf("//Accepted!\n");
	else
		printf("Rejected!\n");
}
