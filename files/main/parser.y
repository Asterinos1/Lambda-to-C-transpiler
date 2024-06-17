%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>		
#include "cgen.h"
#include "lambdalib.h"

extern int yylex(void);
extern int line_num;

// Function for := operator
void replace_string(char *str, const char *old, const char *new);

%}

%union
{
    char* str;
}

%token <str> IDENTIFIER
%token <str> CONST_INT
%token <str> CONST_SCALAR
%token <str> CONST_STRING

%token FN_readStr
%token FN_readInteger
%token FN_readScalar
%token FN_writeStr
%token FN_writeInteger
%token FN_writeScalar
%token FN_write

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
%token KW_VOID

%right ASSIGN OP1 OP2 OP3 OP4 OP5 OP6
%left '+' '-'
%left '/' '*' '%' 
%right POW_OP
%left KW_AND
%left KW_OR
%left '(' ')'
%left '[' ']'
%left ','
%token ';'
%token ':'
%token '.'
%left '<' '>' LE_OP GE_OP
%left EQ_OP NEQ_OP
%right SIGN_PLUS SIGN_MINUS
%right KW_NOT

%start program

//declarations
%type <str> arr_decl arr_decl_list
%type <str> decl_list decl
%type <str> const_decl var_decl 
%type <str> basic_data_type data_type
%type <str> var_identifiers const_identifiers
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

//Complete program declaration

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

//Declarations

//Data Types
data_type:
  '[' ']' basic_data_type   { $$ = template("%s*", $3); }
| basic_data_type           { $$ = $1; }
;

basic_data_type: /*need to include identifer for comp variables*/
  KW_INT      { $$ = template("%s", "int"); }
| KW_SCALAR   { $$ = template("%s", "double"); }
| KW_STR      { $$ = template("%s", "char* "); }
| KW_BOOL     { $$ = template("%s", "int"); }
| KW_VOID     { $$ = template("%s", "void"); }
;

//Declaration list
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
    KW_CONST const_identifiers ':' basic_data_type ';' {
        $$ = template("const %s %s;", $4, $2); 
    }
;

const_identifiers:
  assign_cmd                          { $$ = $1; }
| const_identifiers ',' assign_cmd    { $$ = template("%s, %s", $1, $3); }
;

//Variable Declarations
var_decl:
    var_identifiers ':' data_type ';' {
        $$ = template("%s %s;", $3, $1);
    }
| arr_decl_list ':' data_type ';' {
        $$ = template("%s %s;", $3, $1);
    }
;

//Identifiers for variables
var_identifiers:
    IDENTIFIER {
        $$ = $1;
    }
| var_identifiers ',' IDENTIFIER {
        $$ = template("%s, %s", $1, $3);
    }
;

//Array Declarations
arr_decl_list:
    arr_decl {
        $$ = $1;
    }
| arr_decl_list ',' arr_decl {
        $$ = template("%s, %s", $1, $3);
    }
;

arr_decl:
    IDENTIFIER '[' CONST_INT ']' {
        $$ = template("%s[%s]", $1, $3);
    }
;

// Expressions 
expr:
  CONST_INT                         { $$ = $1; }
| CONST_SCALAR                      { $$ = $1; }
| CONST_STRING                      { $$ = $1; }
| IDENTIFIER                        { $$ = $1; }
| function_call                     { $$ = $1; }
| la_func                           { $$ = $1; }
| KW_TRUE                           { $$ = "1"; }
| KW_FALSE                          { $$ = "0"; }
| '(' expr ')'                      { $$ = template("(%s)",  $2); }  
| '+' expr %prec SIGN_PLUS          { $$ = template("+%s",  $2); } //Although SIGN_PLUS and SIGN_MINUS are not provided by the lexer,s
| '-' expr %prec SIGN_MINUS         { $$ = template("-%s",  $2); } // their role here is to distinguish between signed numbers and arithmetic operations
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

//Functions
func_decl:
  KW_DEF IDENTIFIER '(' params ')' func_data_type ':' body KW_ENDDEF';'{ $$ = template("\n%s %s(%s) {\n%s\n}\n", $6, $2, $4, $8);}
;

func_data_type:
  %empty    { $$ = template("void"); }
| '-''>' data_type { $$ = template("%s", $3); }
;

params:
  %empty                            { $$ = ""; }
| IDENTIFIER ':' data_type              { $$ = template("%s %s", $3, $1); }
| IDENTIFIER ':' data_type ',' params   { $$ = template("%s %s, %s", $3, $1, $5); }
| IDENTIFIER '['']'':' data_type              { $$ = template("%s* %s", $5, $1); }
| IDENTIFIER '['']'':' data_type ',' params   { $$ = template("%s* %s, %s", $5, $1, $7); }
;

body:  
  smp_stmt          { $$ = $1; }
| var_decl          { $$ = $1; }
| const_decl        { $$ = $1; }
| body smp_stmt     { $$ = template("%s\n%s", $1, $2); }
| body var_decl     { $$ = template("%s\n%s", $1, $2); }
| body const_decl   { $$ = template("%s\n%s", $1, $2); }
;

//Statements 
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
| IDENTIFIER '[' CONST_INT ']' ASSIGN  expr { $$ = template("%s[%s] = %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' ASSIGN  expr { $$ = template("%s[%s] = %s", $1, $3, $6); }
| IDENTIFIER OP1 expr { $$ = template("%s += %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' OP1  expr { $$ = template("%s[%s] += %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' OP1  expr { $$ = template("%s[%s] += %s", $1, $3, $6); }
| IDENTIFIER OP2 expr { $$ = template("%s -= %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' OP2  expr { $$ = template("%s[%s] -= %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' OP2  expr { $$ = template("%s[%s] -= %s", $1, $3, $6); }
| IDENTIFIER OP3 expr { $$ = template("%s /= %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' OP3  expr { $$ = template("%s[%s] /= %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' OP3  expr { $$ = template("%s[%s] /= %s", $1, $3, $6); }
| IDENTIFIER OP4 expr { $$ = template("%s %%= %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' OP4  expr { $$ = template("%s[%s] %%= %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' OP4  expr { $$ = template("%s[%s] %%= %s", $1, $3, $6); }
| IDENTIFIER OP5 expr { $$ = template("%s *= %s", $1, $3); }
| IDENTIFIER '[' CONST_INT ']' OP5  expr { $$ = template("%s[%s] *= %s", $1, $3, $6); }
| IDENTIFIER '[' IDENTIFIER ']' OP5  expr { $$ = template("%s[%s] *= %s", $1, $3, $6); }
// := operator part
| IDENTIFIER OP6 '[' expr KW_FOR IDENTIFIER ':' expr ']' ':' data_type {
  $$ = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\nfor (int %s = 0; %s < %s; ++%s) {\n%s[%s] = %s;\n}",
                $11, $1, $11, $8, $11, $6, $6, $8, $6, $1, $6, $4);
    } 
| IDENTIFIER OP6 '[' expr KW_FOR IDENTIFIER ':' data_type KW_IN IDENTIFIER KW_OF CONST_INT ']' ':' data_type {
    char temp_expr[1024];
    snprintf(temp_expr, sizeof(temp_expr), "%s", $4);
    replace_string(temp_expr, $6, template("%s[%s_i]", $10, $6));
    $$ = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\nfor (int %s_i = 0; %s_i < %s; ++%s_i) {\n%s[%s_i] = %s;\n}",
                  $15, $1, $15, $12, $15, $6, $6, $12, $6, $1, $6, temp_expr);
    }    
;

//Lambda functions
la_func:
  FN_readInteger '(' ')'            { $$ = template("readInteger()"); }
| FN_readScalar '(' ')'           { $$ = template("readScalar()"); }
| FN_readStr '(' ')'         { $$ = template("readStr()"); }
| FN_readInteger '(' expr')'            { $$ = template("readInteger(%s)", $3); }
| FN_readScalar '('expr ')'           { $$ = template("readScalar(%s)", $3); }
| FN_readStr '(' expr')'         { $$ = template("readStr(%s)", $3); }
| FN_writeInteger '(' expr ')'      { $$ = template("writeInteger(%s)", $3); }
| FN_writeScalar '(' expr ')'     { $$ = template("writeScalar(%s)", $3); }
| FN_writeStr '(' expr ')'   { $$ = template("writeStr(%s)", $3); }
| FN_write '(' expr ')'   { $$ = template("write(%s)", $3); }
;

//Call user made functions
function_call:
    IDENTIFIER '(' args ')' { $$ = template("%s(%s)", $1, $3); }
;

args:
    %empty          { $$ = ""; }
| expr              { $$ = $1; }
| args ',' expr     { $$ = template("%s, %s", $1, $3); }
;

//If-else statement
if_stmt:
  KW_IF '(' expr ')' ':' cmp_stmt KW_ENDIF ';'       { $$ = template("if (%s) {\n%s\n}\n", $3, $6); }
| KW_IF '(' expr ')' ':' cmp_stmt  KW_ELSE ':' cmp_stmt KW_ENDIF ';'   { $$ = template("if (%s) {\n%s\n}\nelse {\n%s\n}\n", $3, $6, $9); }
;


//For statement
for_stmt:
  KW_FOR IDENTIFIER KW_IN '[' expr ':' expr ']' ':' cmp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s++) {\n%s\n}", $2, $5, $2, $7, $2, $10); }
| KW_FOR IDENTIFIER KW_IN '[' expr ':' expr ':' expr ']' ':' cmp_stmt KW_ENDFOR ';' { $$ = template("for (int %s = %s; %s <= %s; %s += %s) {\n%s\n}", $2, $5, $2, $7, $2, $9, $12); }
;

//While statement
while_stmt:
  KW_WHILE '(' expr ')' ':' cmp_stmt  KW_ENDWHILE';'    { $$ = template("while (%s) {\n%s\n}\n", $3, $6); }
;

%%

// Implementation of replace_string function
void replace_string(char *str, const char *old, const char *new) {

    char buffer[1024];
    char *p;

    if(!(p = strstr(str, old))) return;

    strncpy(buffer, str, p-str);
    buffer[p-str] = '\0';

    sprintf(buffer+(p-str), "%s%s", new, p+strlen(old));

    strcpy(str, buffer);
}

int main () {
  if ( yyparse() != 0 ){
    printf("\nLine %d: Syntax error!\n", line_num);
  }else{
    printf("\n/* Your program is syntactically correct! */\n");
  }
}
