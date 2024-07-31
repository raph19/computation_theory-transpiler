%{

#include <stdio.h>
#include "myparser.tab.h"
#include <string.h>
#include "cgen.h"
#include <math.h>

int line_num = 1;


%}

%x comment


INTEGER           (([1-9]+[0-9]*)|0)
IDENTIFIER        [a-zA-Z_][0-9a-zA-Z_]*
NUMBER_CONSTANT   [[0-9]|{INTEGER}[.][0-9]+("e"|"E")?("+"|"-")?[0]?[1-9][0-9]*]
BOOL              [true|false]
ESCAPE_CHARACTER  ("\\n"|"\\t"|"\\r"|"\\\"|"\\"")
CHARACTER 		  [a-zA-Z0-9]|["!"|"("|" "|")"|"@"|"#"|"$"|"%"|"^"|"&"|"*"|"~"|"_"|"+"|"-"|":"|","|"/"]
CONSTANT_STRING   ("\""|"'")({CHARACTER}*|{ESCAPE_CHARACTER}*)("\""|"'")


%%


start   {printf("token KW_START: %s\n",yytext);    return KW_START;}
 
else   {printf("token KW_ELSE: %s\n",yytext);     return KW_ELSE;}
true   {printf("token KW_TRUE: %s\n",yytext);     return KW_TRUE;}  
return  {printf("token KW_RETURN: %s\n",yytext);    return KW_RETURN;}   
break  {printf("token KW_BREAK: %s\n",yytext);     return KW_BREAK;}
continue {printf("token KW_CONTINUE: %s\n",yytext);   return KW_CONTINUE;}
	     
if    {printf("token KW_IF: %s\n",yytext);     return KW_IF;}  
or    {printf("token KW_OR: %s\n",yytext);      return KW_OR;}  
and    {printf("token KW_AND: %s\n",yytext);     return KW_AND;} 
while   {printf("token KW_WHILE: %s\n",yytext);    return KW_WHILE;}
boolean  {printf("token KW_BOOLEAN: %s\n",yytext);   return KW_BOOLEAN;}   
not    {printf("token KW_NOT: %s\n",yytext);     return KW_NOT;}  
false   {printf("token KW_FALSE: %s\n",yytext);    return KW_FALSE;}    
for    {printf("token KW_FOR: %s\n",yytext);     return KW_FOR;}    
const    {printf("token KW_CONST: %s\n",yytext);   return KW_CONST;}    
var    {printf("token KW_VAR: %s\n",yytext);     return KW_VAR;}    
void    {printf("token KW_VOID: %s\n",yytext);    return KW_VOID;}   
number  {printf("token KW_NUMBER: %s\n",yytext);    return KW_NUMBER;}
string  {printf("token KW_STRING: %s\n",yytext);    return KW_STRING;}     
function  {printf("token KW_FUNCTION: %s\n",yytext);  return KW_FUNCTION;}

"=" {printf("token OP_ASSIGN: %s\n",yytext);  return OP_ASSIGN;}
"+" {printf("token OP_PLUS: %s\n",yytext);  return OP_PLUS;}
"-" {printf("token OP_MINUS: %s\n",yytext);  return OP_MINUS;}
"==" {printf("token OP_EQUAL_TO: %s\n",yytext);  return OP_EQUAL_TO;}
"!=" {printf("token OP_NOT_EQUAL_TO: %s\n",yytext);  return  OP_NOT_EQUAL_TO;}
"<" {printf("token OP_LESS_THAN: %s\n",yytext);  return   OP_LESS_THAN;}
"<=" {printf("token OP_LESS_OR_EQUAL_TO: %s\n",yytext);  return OP_LESS_OR_EQUAL_TO;}
"*" {printf("token OP_MULT: %s\n",yytext); return OP_MULT;}
"/" {printf("token OP_DIV: %s\n",yytext);  return OP_DIV;}
"%" {printf("token OP_MOD: %s\n",yytext);  return OP_MOD;}
"**" {printf("token OP_EXP: %s\n",yytext);  return OP_EXP;}  

"[" {printf("token OPEN_ARRAYBRACKET: %s\n",yytext);  return OPEN_ARRAYBRACKET;}
"]" {printf("token CLOSE_ARRAYBRACKET: %s\n",yytext);  return CLOSE_ARRAYBRACKET;}
":" {printf("token COLON: %s\n",yytext);  return COLON;}
"," {printf("token COMMA: %s\n",yytext);  return COMMA;}
";" {printf("token SEMICOLON: %s\n",yytext);  return SEMICOLON;}
"." {printf("token DOT: %s\n",yytext);  return DOT;}
"(" {printf("token OPEN_PARENTHESIS: %s\n",yytext);  return OPEN_PARENTHESIS;}
")" {printf("token CLOSE_PARENTHESIS: %s\n",yytext);  return CLOSE_PARENTHESIS;}
"{" {printf("token OPEN_BRACKETS: %s\n",yytext);  return OPEN_BRACKETS;}
"}" {printf("token CLOSE_BRACKETS: %s\n",yytext);  return CLOSE_BRACKETS;}

{IDENTIFIER}  {printf("token IDENTIFIER: %s\n",yytext); yylval.crepr = strdup(yytext); return IDENTIFIER;}

{NUMBER_CONSTANT} {printf("token NUMBER CONSTANT: %s\n",yytext); yylval.crepr = strdup(yytext); return NUMBER_CONSTANT;}
		    
{CONSTANT_STRING} {printf("token CONSTANT STRING: %s\n",yytext); yylval.crepr = strdup(yytext); return CONSTANT_STRING;}

{BOOL} {printf("token BOOL: %s\n",yytext); yylval.crepr = strdup(yytext); return BOOL;}
		    
	
"//"[^\n]*

"/*"			{BEGIN(comment);}
<comment>[^*\n]*        {}
<comment>"*"+[^*/\n]*   {}
<comment>\n		{++line_num;}
<comment>"*"+"/"	{BEGIN(INITIAL);}		
		     
[ \r\t]
\n			++line_num;

<<EOF>> 			return EOF;

.      {printf("Line %d Lexical error : unrecognized literal %s\n",line_num,yytext);} 

%%