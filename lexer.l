%option noyywrap
 
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parser.tab.h"
 
	extern int lineno = 1; // initialize to 1
    int yylex();
    void invalidToken();
%}
 
%x ML_COMMENT
 
alpha 		[a-zA-Z]
digit 		[0-9]
alnum 		{alpha}|{digit}|'_'
print		[ -~]
 
ID 			{alpha}+{alnum}*
ICONST		"0"|[0-9]{digit}*
CCONST	    \'{print}\'
 
%%
 
"$$".*					{ printf("Eat up comment at line %d\n", lineno); } 
 
"$*"					{ printf("Eat up comment from line %d ", lineno); BEGIN(ML_COMMENT); }
<ML_COMMENT>"*$" 		{ printf("to line %d\n", lineno); BEGIN(INITIAL); }
<ML_COMMENT>[^*\n]+		
<ML_COMMENT>"*"			
<ML_COMMENT>"\n"		{ lineno += 1; }
 
 
"char"|"CHAR"       	{ return CHAR; }
"int"|"INT"				{ return INT; }
"if"|"IF"				{ return IF; }
"else"|"ELSE"			{ return ELSE; }
"while"|"WHILE"			{ return WHILE; }
"for"|"FOR"				{ return FOR; }
"continue"|"CONTINUE"	{ return CONTINUE; }
"break"|"BREAK"			{ return BREAK; }
"void"|"VOID"			{ return VOID; }
"main"|"MAIN"           { return MAIN; }
"return"|"RETURN"		{ return RETURN; }
"switch"|"SWITCH"		{ return SWITCH;}
"case"|"CASE"           {return CASE;}
"default"|"DEFAULT"     {return DEFAULT; } 
"+"                     { return PLUSOP;}
"-"                     { return MINUSOP;}
"*"						{ return MULOP; }
"/"						{ return DIVOP; }
"^"                     { return POWOP; }
"|"                     { return ORBIN; }
"&"				        { return ANDBIN; }
"||"					{ return OROP; }
"&&"					{ return ANDOP; }
"!"						{ return NOTOP; }
"=="                    { return EQUOP; }
"!="				    { return NEQUOP; }
"<"                     { return LT;}
"<="                    { return LE;}
">"                     { return GT;}
">="                    { return GE;}
 
 
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"["				{ return LBRACK; }
"]"				{ return RBRACK; }
"."				{ return DOT; }
","				{ return COMMA; }
"="				{ return ASSIGN; }
":"             {return COLON; }
 
 
{ID} 			{  strcpy(yylval.id, yytext); return ID; }
{ICONST} 		{  sscanf(yytext,"%d",&yylval.iconst); return ICONST; }
{CCONST} 		{  strcpy(yylval.cconst, yytext); return CCONST; }
  
"\n"			{ lineno += 1; }
[ \t\r\f]+		/* eat up whitespace */
 
.				{ invalidToken(); }
 
%%

void invalidToken(){
    printf("Error in line %d : \n invalid token %s\n", lineno, yytext);
    exit(0);
}
