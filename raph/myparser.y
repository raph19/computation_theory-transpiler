%{
#include <stdio.h>
#include "cgen.c"
#include <string.h>
#include <stdarg.h>
#include "mslib.h"
extern int yylex(void);
extern int line_num;

%}


%union
{
      char* crepr;
}

%token  KW_NULL
%token  KW_CONTINUE
%token  KW_ELSE
%token  KW_TRUE
%token  KW_RETURN
%token  KW_BREAK
%token  KW_IF
%token  KW_WHILE
%token  KW_VAR
%token  KW_BOOLEAN
%token  KW_FOR
%token  KW_FALSE
%token  KW_NUMBER
%token  KW_START
%token  KW_CONST
%token  KW_VOID
%token  KW_STRING
%token  KW_FUNCTION

%token  OP_ASSIGN
%token  OP_EXP
%token  OPEN_ARRAYBRACKET
%token  CLOSE_ARRAYBRACKET
%token  OPEN_BRACKETS
%token  CLOSE_BRACKETS
%token  COMMA
%token  COLON
%token  SEMICOLON
%token  DOT
%token  OPEN_PARENTHESIS
%token  CLOSE_PARENTHESIS

%right KW_NOT
%left  KW_AND
%left  KW_OR
%right OP_PLUS
%right OP_MINUS
%left  OP_MULT
%left  OP_DIV
%left  OP_MOD
%left  OP_EQUAL_TO
%left  OP_NOT_EQUAL_TO
%left  OP_LESS_THAN
%left  OP_LESS_OR_EQUAL_TO
%left  PLUS
%left  MINUS

%token <crepr> IDENTIFIER
%token <crepr> NUMBER_CONSTANT
%token <crepr> CHARACTER
%token <crepr> INTEGER
%token <crepr> ESCAPE_CHARACTER
%token <crepr> CONSTANT_STRING
%token <crepr> BOOL


%start program

%type <crepr> outside_decl
%type <crepr> global_decl
%type <crepr> variable_decl
%type <crepr> list_names
%type <crepr> set_value
%type <crepr> body
%type <crepr> const_list_names
%type <crepr> commands
%type <crepr> common_expressions
%type <crepr> call_function
%type <crepr> type
%type <crepr> initArray
%type <crepr> assignment
%type <crepr> parameters
%type <crepr> function_parameters
%type <crepr> functions
%type <crepr> many_commands_supp
%type <crepr> for_statement
%type <crepr> if_statement
%type <crepr> while_statement
%type <crepr> expression

%%


program: outside_decl KW_FUNCTION KW_START OPEN_PARENTHESIS CLOSE_PARENTHESIS COLON KW_VOID OPEN_BRACKETS body CLOSE_BRACKETS {
if (yyerror_count == 0) {
	puts(c_prologue);
	printf("/*produced C program*/ \n\n");
	printf("%s\n", $1);
	printf("void main(){\n%s\n} \n", $9);
}
}
;

body: many_commands_supp 															{$$ = template("%s",$1);}
|																					{$$ = template("");}
;	


outside_decl:
global_decl {$$ = template("%s",$1);}
|outside_decl global_decl {$$=template("%s %s",$1,$2);}

;	

global_decl:
variable_decl {$$=template("%s\n",$1);}
|functions {$$=template("%s\n",$1);}
;
	
	
variable_decl:
KW_VAR list_names COLON type SEMICOLON {$$=template("%s %s;",$4,$2);}
|KW_CONST const_list_names  COLON type SEMICOLON {$$ = template("%s %s;",$2,$4);}
;
	

const_list_names:
IDENTIFIER set_value {$$=template("%s %s", $1,$2);}
|IDENTIFIER OPEN_ARRAYBRACKET INTEGER CLOSE_ARRAYBRACKET set_value {$$=template("%s[%s] %s",$1,$3,$5);}



list_names: IDENTIFIER 																{$$ = template("%s",$1);}
|IDENTIFIER set_value 																{$$ = template("%s %s", $1,$2);}
|IDENTIFIER OPEN_ARRAYBRACKET INTEGER CLOSE_ARRAYBRACKET 							{$$ = template("%s[%s]",$1,$3);}
|IDENTIFIER OPEN_ARRAYBRACKET INTEGER CLOSE_ARRAYBRACKET set_value 					{$$ = template("%s[%s] %s",$1,$3,$5);}
|list_names COMMA IDENTIFIER 														{$$ = template("%s, %s",$1,$3);}
|list_names COMMA IDENTIFIER set_value 												{$$ = template("%s, %s %s",$1,$3,$4);}
;

functions: KW_FUNCTION IDENTIFIER OPEN_PARENTHESIS function_parameters CLOSE_PARENTHESIS COLON type OPEN_BRACKETS body CLOSE_BRACKETS SEMICOLON {$$=template("%s %s(%s){\n%s\n}",$7,$2,$4,$9);}
;

many_commands_supp: commands														{$$ = template("%s",$1);}
|many_commands_supp commands 														{$$ = template("%s\n%s",$1,$2);}
;  												
  												
commands:variable_decl 														            	{$$ = template("%s",$1);}
|assignment SEMICOLON 																{$$ = template("%s;",$1);}
|KW_RETURN SEMICOLON																{$$ = template("return ;");}
|KW_RETURN expression SEMICOLON 													{$$ = template("return %s;",$2);}
|KW_BREAK SEMICOLON 																{$$ = template("break;");}
|KW_CONTINUE SEMICOLON 																{$$ = template("continue;");}
|call_function SEMICOLON															{$$ = template("%s;",$1);}
|if_statement 																		{$$ = template("%s;",$1);}
|for_statement 																		{$$ = template("%s;",$1);}
|while_statement SEMICOLON															{$$ = template("%s;",$1);}
;

if_statement: KW_IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS SEMICOLON {$$=template("if(%s){\n%s\n}",$3,$6);}
|KW_IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS SEMICOLON KW_ELSE OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS SEMICOLON {$$=template("if (%s)\n{\n%s\n}\nelse %s",$3,$6,$11);}
|KW_IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS  SEMICOLON KW_ELSE if_statement {$$=template("if (%s)\n{\n%s\n}\nelse %s",$3,$6,$10);}


while_statement: KW_WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS {$$=template("while(%s){\n%s\n}",$3,$6);}
;

for_statement: KW_FOR OPEN_PARENTHESIS assignment SEMICOLON expression SEMICOLON assignment CLOSE_PARENTHESIS  OPEN_BRACKETS many_commands_supp CLOSE_BRACKETS SEMICOLON {$$=template("for ( %s ; %s ; %s ){\n%s}",$3,$5,$7,$10);}
;

initArray: common_expressions {$$=template("%s",$1);}
;

call_function: IDENTIFIER OPEN_PARENTHESIS parameters CLOSE_PARENTHESIS  {$$=template("%s(%s)",$1,$3); }
;

function_parameters: IDENTIFIER COLON type		 {$$ = template("%s %s",$3,$1);}
|function_parameters COMMA IDENTIFIER COLON type {$$ = template("%s,%s %s",$1,$5,$3);}
|initArray COLON type 							 {$$ = template ("%s%s",$3,$1);}
|initArray COLON OPEN_ARRAYBRACKET CLOSE_ARRAYBRACKET type  {$$ = template ("%s%s",$5,$1);}

;

assignment: IDENTIFIER OP_ASSIGN expression  	{$$ = template("%s = %s",$1,$3);}
|IDENTIFIER OP_ASSIGN call_function          	{$$ = template("%s = %s",$1,$3);}
;  
  
parameters: 									{$$ = template("");}
|expression 									{$$ = template("%s",$1);}
|parameters COMMA expression					{$$ = template("%s,%s",$1,$3);}
;			  
			  
set_value: OP_ASSIGN expression 				{$$ = template("=%s",$2);}
;			
			
type: 										
KW_NUMBER				     					{$$ = template("double");}
|KW_BOOLEAN 									{$$ = template("int");}
|KW_STRING 										{$$ = template("char *");}
;			
			
common_expressions: 
INTEGER											{$$ = template("%s",$1);}
|NUMBER_CONSTANT				                {$$ = template("%s",$1);}
|CONSTANT_STRING 								{$$ = template("%s",$1);}
|IDENTIFIER 									{$$ = template("%s",$1);}
|KW_TRUE 										{$$ = template("1");}
|KW_FALSE 										{$$ = template("0");}
;			
		
expression : common_expressions 				{$$ = template("%s",$1);}
|call_function 									{$$ = template("%s",$1);}
|OPEN_ARRAYBRACKET initArray CLOSE_ARRAYBRACKET {$$=template("[%s]",$2);}
|OPEN_PARENTHESIS expression CLOSE_PARENTHESIS 	{$$ = template("(%s)",$2);}
|KW_NOT expression  							{$$ = template("not %s",$2);}
|OP_PLUS expression 							{$$ = template("+(%s)",$2);}
|OP_MINUS expression 							{$$ = template("-(%s)",$2);}
|expression OP_MINUS expression 				{$$ = template("%s - %s",$1,$3);}
|expression OP_EQUAL_TO expression 				{$$ = template ("%s == %s",$1,$3);}
|expression KW_AND expression 					{$$ = template("%s && %s", $1,$3);}
|expression OP_NOT_EQUAL_TO expression 			{$$ = template ("%s != %s",$1,$3);}
|expression OP_PLUS expression 					{$$ = template ("%s + %s",$1,$3);}
|expression OP_LESS_OR_EQUAL_TO expression 		{$$ = template ("%s <= %s",$1,$3);}
|expression OP_LESS_THAN expression 			{$$ = template ("%s < %s",$1,$3);}
|expression OP_MULT expression 					{$$ = template ("%s * %s",$1,$3);}
|expression OP_DIV expression 					{$$ = template ("%s / %s",$1,$3);}
|expression KW_OR expression 					{$$ = template ("%s || %s",$1,$3);}
|expression OP_MOD expression 					{$$ = template ("%s % %s",$1,$3);}
|expression OP_EXP expression 					{$$ = template ("%s ^ %s",$1,$3);}
;

%%
int main() {
	if(yyparse() != 0 )
	printf("Rejected!\n");
}
