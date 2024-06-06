%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>		
#include "cgen.h"
#include "lambdalib.h"

extern int yylex(void);
extern int line_num;
%}

%union
{
    char* str;
}

%token <str> IDENTIFIER
%token <str> CONST_INT
%token <str> CONST_REAL
%token <str> CONST_STRING

%token FN_readStr
%token FN_readInteger
%token FN_readScalar
%token FN_writeStr
%token FN_writeInteger
%token FN_writeScalar

%token KW_INT
%token KW_SCALAR
%token KW_STR
%token KW_BOOL
%token KW_CONST
%token KW_IF
%token KW_ENDIF
%token KW_ELSE
%token KW_FOR
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_COMP
%token KW_ENDCOMP
%token KW_AND
%token KW_OR
%token KW_NOT
%token KW_RETURN
%token KW_TRUE
%token KW_FALSE
%token KW_OF
%token KW_IN

/**%token POW_OP*/
/*%token ASSIGN*/
%token OP1
%token OP2
%token OP3
%token OP4
%token OP5
%token OP6
%token EQ_OP
%token NEQ_OP
%token LE_OP
%token GE_OP

%right ASSIGN

%left '+' '-'
%left '/' '*' '%' 
%right POW_OP

%left '(' ')'
%left '[' ']'
%left ','
%token ';'
%token ':'
%token '.'
%left '<' '>' EQ_OP NEQ_OP LE_OP GE_OP

%right SIGN_PLUS
%right SIGN_MINUS
%right KW_NOT

%start program

//declarations
%type <str> decl_list decl
%type <str> const_decl var_decl 
%type <str> basic_data_type data_type
%type <str> var_identifiers const_identifiers arr_identifiers

//expressions
%type <str> expr

//functions
%type <str> func_decl func_data_type params
%type <str> body

//statements
%type <str> assign_cmd
%type <str> if_stmt
%type <str> for_stmt
%type <str> while_stmt
%type <str> la_func
%type <str> smp_stmt cmp_stmt
%type <str> function_call args


%%

program: 
    decl_list KW_DEF KW_MAIN '(' ')' ':' body KW_ENDDEF';' {
        if (yyerror_count == 0) {
            // include the pilib.h file
            printf("/* program */ \n\n");
            printf("#include <stdio.h>\n"
                    "#include <stdlib.h>\n"
                    "#include <string.h>\n"
                    "#include <math.h>\n"
                    "#include \"lambdalib.h\"\n"
                    "\n"); 
            printf("%s\n\n", $1);
            printf("int main() {\n%s\n} \n", $7);
        } 
    }
| KW_DEF KW_MAIN '(' ')' ':' body KW_ENDDEF';' {
        if (yyerror_count == 0) {
            // include the pilib.h file
            printf("/* program */ \n\n");
            printf("#include <stdio.h>\n"
                    "#include <stdlib.h>\n"
                    "#include <string.h>\n"
                    "#include <math.h>\n"
                    "#include \"lambdalib.h\"\n"
                    "\n"); 
            printf("\n\n");
            printf("int main() {\n%s\n} \n", $6);
        } 
    }    
;

/*====================== Declarations ======================*/

//Data Types
data_type:
  '[' ']' basic_data_type   { $$ = template("%s*", $3); }
| basic_data_type           { $$ = $1; }
;

basic_data_type: /*need to include comp*/
  KW_INT    { $$ = template("%s", "int"); }
| KW_SCALAR   { $$ = template("%s", "double"); }
| KW_STR { $$ = template("%s", "char*"); }
| KW_BOOL   { $$ = template("%s", "int"); }
;

//Declaration Schema
decl_list: 
  decl_list decl    { $$ = template("%s\n%s", $1, $2); }
| decl              { $$ = $1; }
;

//Simple Declaration
decl: 
  const_decl    { $$ = $1; }
| var_decl      { $$ = $1; }
| func_decl     { $$ = $1; }
;

//Constant Declarations
const_decl:  
    KW_CONST const_identifiers basic_data_type ';' {
        $$ = template("const %s %s;", $3, $2); 
    }
;

const_identifiers:
  assign_cmd                          { $$ = $1; }
| const_identifiers ',' assign_cmd    { $$ = template("%s, %s", $1, $3); }
;

//Variable Declarations
arr_identifiers:
  IDENTIFIER                        { $$ = $1; }
| arr_identifiers ',' IDENTIFIER    { $$ = template("%s, %s", $1, $3); }
;

var_identifiers:
  arr_identifiers                          { $$ = $1; }
| var_identifiers ',' arr_identifiers      { $$ = template("%s, %s", $1, $3); }
| IDENTIFIER '=' expr                      { $$ = template("%s = %s", $1, $3); }
| IDENTIFIER '=' expr ',' var_identifiers  { $$ = template("%s, %s", $1, $3); }
;

var_decl:  
  var_identifiers ':' data_type ';'  { $$ = template("%s %s;", $3, $1); }
| arr_identifiers '[' CONST_INT ']' basic_data_type ';'  {
    char * ids = strtok($1, ", ");
    char * arrays = NULL;

    arrays = template("%s[%s]", ids, $3);
    ids = strtok(NULL, ", ");

    while (ids != NULL) {
        arrays = template("%s, %s[%s]", arrays, ids, $3);
        ids = strtok(NULL, ", ");
    }

    $$ = template("%s %s;", $5, arrays);
}
;

/*====================== Expressions ======================*/

expr:
  CONST_INT                         { $$ = $1; }
| CONST_REAL                        { $$ = $1; }
| CONST_STRING                      { $$ = $1; }
| IDENTIFIER                        { $$ = $1; }
| function_call                     { $$ = $1; }
| la_func                           { $$ = $1; }
| KW_TRUE                           { $$ = "1"; }
| KW_FALSE                          { $$ = "0"; }
| '(' expr ')'                      { $$ = template("(%s)",  $2); }
| '+' expr %prec SIGN_PLUS          { $$ = template("+%s",  $2); }
| '-' expr %prec SIGN_MINUS         { $$ = template("-%s",  $2); } 
| expr KW_AND expr                  { $$ = template("%s && %s", $1, $3); } 
| expr KW_OR expr                   { $$ = template("%s || %s", $1, $3); } 
| KW_NOT expr                       { $$ = template("!%s", $2); }
| expr '+' expr                     { $$ = template("%s + %s", $1, $3); } 
| expr '-' expr                     { $$ = template("%s - %s", $1, $3); } 
| expr '*' expr                     { $$ = template("%s * %s", $1, $3); } 
| expr '/' expr                     { $$ = template("%s / %s", $1, $3); } 
| expr '%' expr                     { $$ = template("%s %% %s", $1, $3); } 
| expr POW_OP expr                  { $$ = template("pow(%s, %s)", $1, $3); }
| expr '<' expr                     { $$ = template("%s < %s", $1, $3); }
| expr '>' expr                     { $$ = template("%s > %s", $1, $3); }
| expr LE_OP expr                   { $$ = template("%s <= %s", $1, $3); }
| expr GE_OP expr                   { $$ = template("%s >= %s", $1, $3); }
| expr EQ_OP expr                   { $$ = template("%s == %s", $1, $3); }
| expr NEQ_OP expr                  { $$ = template("%s != %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']'      { $$ = template("%s[%s]", $1, $3); }
| IDENTIFIER '[' IDENTIFIER ']'     { $$ = template("%s[%s]", $1, $3); }
;

/*====================== Functions ======================*/

func_decl:
KW_DEF IDENTIFIER '(' params ')' '-''>' func_data_type ':' body KW_ENDDEF';'{
      $$ = template("\n%s %s(%s) {\n%s\n}\n", $8, $2, $4, $10);
  }
;

func_data_type:
  %empty    { $$ = template("void"); }
| data_type { $$ = $1; }
;

params:
    %empty                          { $$ = ""; }
| IDENTIFIER ':' data_type              { $$ = template("%s %s", $3, $1); }
| IDENTIFIER ':' data_type ',' params   { $$ = template("%s %s, %s", $3, $1, $5); }
;

body:  
 %empty          { $$ = ""; }
| smp_stmt          { $$ = $1; }
| var_decl          { $$ = $1; }
| const_decl        { $$ = $1; }
| body smp_stmt     { $$ = template("%s\n%s", $1, $2); }
| body var_decl     { $$ = template("%s\n%s", $1, $2); }
| body const_decl   { $$ = template("%s\n%s", $1, $2); }
;

/*====================== Statements ======================*/

//General
smp_stmt:
  assign_cmd ';'        { $$ = template("%s;", $1); }
| KW_BREAK ';'          { $$ = template("break;"); }
| KW_CONTINUE ';'       { $$ = template("continue;"); }
| KW_RETURN ';'         { $$ = template("return;"); }
| KW_RETURN expr ';'    { $$ = template("return %s;", $2); }
| la_func ';'           { $$ = template("%s;", $1); }
| function_call ';'     { $$ = template("%s;", $1); }
| for_stmt              { $$ = template("%s", $1); }
| while_stmt            { $$ = template("%s", $1); }
| if_stmt               { $$ = template("%s", $1); }
| for_stmt ';'          { $$ = template("%s", $1); }
| while_stmt ';'        { $$ = template("%s", $1); }
| if_stmt ';'           { $$ = template("%s", $1); }
;

cmp_stmt:
  cmp_stmt  smp_stmt    { $$ = template("%s\n%s", $1, $2); }
| smp_stmt              { $$ = $1; }
| cmp_stmt  var_decl    { $$ = template("%s\n%s", $1, $2); }
| var_decl              { $$ = $1; }
| cmp_stmt  const_decl  { $$ = template("%s\n%s", $1, $2); }
| const_decl            { $$ = $1; }
;

//Assignment
assign_cmd:
  IDENTIFIER ASSIGN expr { $$ = template("%s = %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' ASSIGN ':' expr { $$ = template("%s[%s] = %s", $1, $3, $7); }
| IDENTIFIER '[' IDENTIFIER ']' ASSIGN ':' expr { $$ = template("%s[%s] = %s", $1, $3, $7); }
;


//Lambda functions
la_func:
  FN_readInteger '(' ')'            { $$ = template("readInteger()"); }
| FN_readScalar '(' ')'           { $$ = template("readScalar()"); }
| FN_readStr '(' ')'         { $$ = template("readStr()"); }
| FN_writeInteger '(' expr ')'      { $$ = template("writeInteger(%s)", $3); }
| FN_writeScalar '(' expr ')'     { $$ = template("writeScalar(%s)", $3); }
| FN_writeStr '(' expr ')'   { $$ = template("writeStr(%s)", $3); }
;

//Call own functions
function_call:
    IDENTIFIER '(' args ')' { $$ = template("%s(%s)", $1, $3); }
;

args:
    %empty          { $$ = ""; }
| expr              { $$ = $1; }
| args ',' expr     { $$ = template("%s, %s", $1, $3); }
;

//While statement
while_stmt:
 // KW_WHILE '(' expr ')' ':' smp_stmt KW_ENDWHILE';'     { $$ = template("while (%s)\n\t%s", $3, $6); }
 KW_WHILE '(' expr ')' ':' smp_stmt  KW_ENDWHILE';'    { $$ = template("while (%s) {\n%s\n}\n", $3, $6); }
| KW_WHILE '(' expr ')' ':' cmp_stmt  KW_ENDWHILE';'    { $$ = template("while (%s) {\n%s\n}\n", $3, $6); }
;

//If-else statement
/* if_stmt:
  KW_IF '(' expr ')' ':' smp_stmt KW_ENDIF ';'   { $$ = template("if (%s)\n\t%s\n", $3, $6); }
| KW_IF '(' expr ')' smp_stmt KW_ELSE smp_stmt KW_ENDIF ';' { $$ = template("if (%s)\n\t%s\nelse\n\t%s\n", $3, $5, $7); }
| KW_IF '(' expr ')' smp_stmt KW_ELSE '{' cmp_stmt '}' { $$ = template("if (%s)\n\t%s\nelse {\n%s\n}\n", $3, $5, $8); }
| KW_IF '(' expr ')' '{' cmp_stmt '}'       { $$ = template("if (%s) {\n%s\n}\n", $3, $6); }
| KW_IF '(' expr ')' '{' cmp_stmt '}' KW_ELSE smp_stmt  { $$ = template("if (%s) {\n%s\n}\nelse\n\t%s\n", $3, $6, $9); }
| KW_IF '(' expr ')' '{' cmp_stmt '}' KW_ELSE '{' cmp_stmt '}'  { $$ = template("if (%s) {\n%s\n}\nelse {\n%s\n}\n", $3, $6, $10); }
; */

//If-else statement
if_stmt:
  KW_IF '(' expr ')' ':' cmp_stmt KW_ENDIF       { $$ = template("if (%s) {\n%s\n}\n", $3, $6); }
| KW_IF '(' expr ')' ':' cmp_stmt  KW_ELSE ':' cmp_stmt KW_ENDIF  { $$ = template("if (%s) {\n%s\n}\nelse {\n%s\n}\n", $3, $6, $9); }
;


//For statement
/* for_stmt:
  KW_FOR '(' assign_cmd ';' expr ';' assign_cmd ')' smp_stmt KW_ENDFOR';'{ $$ = template("for (%s; %s; %s)\n\t%s\n", $3, $5, $7, $9); }
| KW_FOR '(' assign_cmd ';' ';' assign_cmd ')' smp_stmt KW_ENDFOR ';'{ $$ = template("for (%s; ; %s)\n\t%s\n", $3, $6, $8); }
| KW_FOR '(' assign_cmd ';' expr ';' assign_cmd ')' '{' cmp_stmt KW_ENDFOR';' { $$ = template("for (%s; %s; %s) {\n%s\n}\n", $3, $5, $7, $10); }
| KW_FOR '(' assign_cmd ';' ';' assign_cmd ')' '{' cmp_stmt KW_ENDFOR ';' { $$ = template("for (%s; ; %s) {\n%s\n}\n", $3, $6, $9); }
; */

for_stmt:
  KW_FOR IDENTIFIER KW_IN '[' CONST_INT ':' CONST_INT ']' ':' cmp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s++) {\n%s\n}", $2, $5, $2, $7, $2, $10); }
| KW_FOR IDENTIFIER KW_IN '[' CONST_INT ':' CONST_INT ':' CONST_INT ']' ':' cmp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s += %s) {\n%s\n}", $2, $5, $2, $7, $2, $9, $12); }
| KW_FOR IDENTIFIER KW_IN '[' CONST_INT ':' CONST_INT ']' ':' smp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s++) {\n%s\n}", $2, $5, $2, $7, $2, $10); }
| KW_FOR IDENTIFIER KW_IN '[' CONST_INT ':' CONST_INT ':' CONST_INT ']' ':' smp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s += %s) {\n%s\n}", $2, $5, $2, $7, $2, $9, $12);}
;

%%
int main () {
  if ( yyparse() != 0 ){
    printf("\nRejected!\n");
  }else{
    printf("\n/* Your program is syntactically correct! */\n");
  }
}
