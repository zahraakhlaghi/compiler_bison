%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parser.h"

	extern int yylex();
	extern int yyparse();
    void yyerror(char*);
    extern char *yytext;
	
int Adr = 0;

int size = 0;

int num_args = 0;

int cur_func_args = 0;

char cur_func[100];

int countLabel = 0;

extern int lineno;

FILE* fp;

struct symrec* sym_table = NULL;

struct symrec* global_sym_table = NULL;

struct FuncBlock* Func = NULL;

struct FuncBlock* Functions = NULL;

char case_variable[1000];
int label_switch;

%}
 
%union{
    int iconst;
	char cconst[5];
    char id[1000];
    struct stmtBlock* stmtptr; 
    struct stmtsBlock* stmtsptr;
    char code[10000];
    char nData[1000]; 
    int num_params; 
}
 
/* token definition */
%token CHAR INT IF ELSE WHILE FOR CONTINUE BREAK VOID MAIN RETURN SWITCH CASE DEFAULT
%token PLUSOP MINUSOP MULOP DIVOP POWOP ORBIN ANDBIN OROP ANDOP NOTOP EQUOP NEQUOP LT LE GT GE
%token LPAREN RPAREN LBRACK RBRACK DOT COMMA ASSIGN COLON
%token<id> ID 
%token<iconst> ICONST 
%token<cconst> CCONST

%type<stmtsptr> statements
%type<stmtptr> statement dec_statement assignment_statement while_statement for_statement if_statement function_call dec_only dec_assign return_statement  switch_statement case_statement  global_dec_statement global_dec_only global_dec_assign 
%type<code> bool_exp exp params_call function_call_assigned
%type<num_params> params
%type<nData> x x1 x2

%right ASSIGN
%left OROP ANDOP 
%left EQUOP NEQUOP LT LE GT GE
%left PLUSOP MINUSOP
%left MULOP DIVOP

%define parse.error verbose
 
%start prog
 
%%

prog :  global;

global : global_dec_statement global | functions;

global_dec_statement :  global_dec_only DOT
                    {
                        $$ = $1;
                    }
              |  global_dec_assign DOT
                    {
                        $$ = $1;
                    }
;


global_dec_only :  type ID
                    {
                        struct symrec* s;
                        s = global_putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"li $t0,0\nsw $t0,%s($t8)\n", s->addr);
                        $$->Next = NULL;
                        size = size + 4;
                    }
          | type ID LBRACK ICONST RBRACK
                    {
                        struct symrec* s;
                        s = global_putsym($2,$4,1);
                        $$ = NULL;
                        size = size + 4*$4;
                    }
;

global_dec_assign : type ID ASSIGN exp
                    {

                        struct symrec* s;
                        s = global_putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%ssw $t0,%s($t8)\n", $4, s->addr);
                        $$->Next = NULL;
                        size = size + 4;
                    }
			|type ID ASSIGN x2
                    {

                        struct symrec* s;
                        s = global_putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%s\nsw $t0,%s($t8)\n", $4, s->addr);
                        $$->Next = NULL;
                        size = size + 4;
                    }
;


functions : function functions | function | main_func;
// main function 
main_func : VOID MAIN LPAREN RPAREN
                    {
                        strcpy(cur_func,"main");
                        Func = GetFuncBlock();
                        strcpy(Func->name,cur_func);
                        sym_table = NULL;
                        Adr = -8;
                        size = 8;
                    }
            LT statements GT 
                    {
                        Func->size = size;
                        Func->Stmts = $7;
                        Func->Next = Functions;
                        Func->SymbolTable = sym_table;
                        Functions = Func;
                    }
;

params : type ID COMMA
                    {
                        struct symrec* s;
                        s = putsym($2,1,0);
                    }
         params
                    {
                        $$ = 1 + $5;
                    }
       | type ID
                    {
                        struct symrec* s;
                        s = putsym($2,1,0);
                        $$ = 1;
                    }
       |  
                    {
                        $$ = 0;
                    }
;
function : type ID LPAREN
                    {
                        strcpy(cur_func,$2);
                        Func = GetFuncBlock();
                        strcpy(Func->name,cur_func);
                        sym_table = Getsymrec();
                        Adr = -8;
                    }
            params RPAREN
                    {
                        size = 4*($5+2);
                        cur_func_args = $5;
                    }
            LT statements GT
                    {

                        Func->Stmts = $9;
                        Func->Next = Functions;
                        Func->SymbolTable = sym_table;
                        Func->num_args = $5;
                        Func->size = size;
                        Functions = Func;
                    }
;

statements :  statement statements 
                    {
                        $$ = GetstmtsBlock(); 
                        $$->left = $1; 
                        $$->right = $2; 
                        $$->RightNull = 0;
                    }
       | statement  
                    {
                        $$ = GetstmtsBlock();
                        $$->left = $1;
                        $$->right = NULL;
                        $$->RightNull = 1;
                    }
;


statement :  dec_statement
                    {
                        $$ = $1;
                    } 
      | assignment_statement DOT
                    {
                        $$ = $1;
                    } 
      | while_statement
                    {
                        $$ = $1;

                    }
      | for_statement
                    {
                        $$ = $1;
                    }
      | if_statement
                    {
                        $$ = $1;
                    }        
      | function_call
                    {
                        $$ = $1;
                    }
      | return_statement
                    {
                        $$ = $1;
                    }
      | switch_statement 
                   {
                        $$ = $1;
                   };

dec_statement :  dec_only DOT
                    {
                        $$ = $1;
                    }
              |  dec_assign DOT
                    {
                        $$ = $1;
                    }
;


dec_only :  type ID
                    {
                        struct symrec* s;
                        s = putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"li $t0,0\nsw $t0,%s($t8)\n", s->addr);
                        $$->Next = NULL;
                        /*
                        Int stores 4 bytes.
                        */
                        size = size + 4;
                    }
          | type ID LBRACK ICONST RBRACK
                    {
                        struct symrec* s;
                        s = putsym($2,$4,1);
                        $$ = NULL;
                        size = size + 4*$4;
                    }
;

dec_assign : type ID ASSIGN exp
                    {

                        struct symrec* s;
                        s = putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%ssw $t0,%s($t8)\n", $4, s->addr);
                        $$->Next = NULL;
                        size = size + 4;
                    }
			|type ID ASSIGN x2
                    {

                        struct symrec* s;
                        s = putsym($2,1,0);
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%s\nsw $t0,%s($t8)\n", $4, s->addr);
                        $$->Next = NULL;
                        size = size + 4;
                    }
;

assignment_statement : ID ASSIGN exp
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%s\nsw $t0,%s($t8)\n", $3, s->addr);
                        $$->Next = NULL;  
                    }
				|ID ASSIGN x2
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%s\nsw $t0,%s($t8)\n", $3, s->addr);
                        $$->Next = NULL;  
                    }
                | ID LBRACK x1 RBRACK ASSIGN exp
                    {
                        struct symrec* s;
                        // getsym gives the pointer to the variable
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%s\n%s\nmul $t2,$t2,4\nli $t3,%s\nadd $t3,$t3,$t8\nadd $t2,$t2,$t3\nsw $t0,0($t2)\n",$6,$3,s->addr);
                        $$->Next = NULL;
                    }
;

while_statement : WHILE LPAREN bool_exp RPAREN LT statements GT
                    {
                        $$ = GetstmtBlock();
                        $$->isTYPE = 1;
                        $$->Next = $6;
                        sprintf($$->Condition,"%s\n",$3);
                        sprintf($$->Jump,"beq $t0, $0,");
                    }
;

params_call : ID COMMA params_call
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        if (s->isarray == 1){
                            printf("%s is not an int\n",$1);
                            exit(0);  
                        }
                        int pos = -4*num_args;
                        num_args = num_args - 1;
                        sprintf($$, "lw $t0,%s($t8)\nsw $t0, %d($sp)\n%s",s->addr,pos,$3);
                    }
       | ID
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        if (s->isarray == 1){
                            printf("%s is not an int\n",$1);
                            exit(0);  
                        }
                        int pos = -4*num_args;
                        num_args = num_args - 1;
                        sprintf($$,"lw $t0,%s($t8)\nsw $t0, %d($sp)\n",s->addr,pos);
                    }
       |            {
                        sprintf($$,"\0");
                    }
;


function_call : ID LPAREN 
                    {
                        if (strcmp(cur_func,$1)==0){
                            num_args = cur_func_args + 2;
                        }
                        else{
                            num_args = getNumArgs($1) + 2;
                        }
                    }
                params_call RPAREN DOT
                    {   
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%sjal %s\n", $4,$1);
                        $$->Next = NULL;
                    }
;

function_call_assigned : ID LPAREN 
                    {
                        if (strcmp(cur_func,$1)==0){
                            num_args = cur_func_args + 2;
                        }
                        else{
                            num_args = getNumArgs($1) + 2;
                        }
                    }
                params_call RPAREN
                    {
                        sprintf($$,"%sjal %s\nmove $t0,$v0", $4,$1);
                    }

for_statement : FOR LPAREN dec_assign DOT bool_exp DOT assignment_statement RPAREN LT statements GT
            {
                $$ = GetstmtBlock();
                $$->isTYPE = 2;
                $$->Next = $10;
                sprintf($$->Condition,"%s\n",$5);
                sprintf($$->Jump,"beq $t0, $0,");
                sprintf($$->dec_assign_1,"%s",$3->Body);
                sprintf($$->assignment_stmt_1,"%s",$7->Body);
            }
;


if_statement : 
            IF LPAREN bool_exp RPAREN LT statements GT ELSE LT statements GT
                    {
                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 3;
                        sprintf($$->Condition,"%s", $3);
                        sprintf($$->Jump,"beq $t0, $0,");   
                        $$->Next = $6;
                        $$->elseJump = $10;
                    }
            | IF LPAREN bool_exp RPAREN LT statements GT ELSE if_statement
                    {
                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 3;
                        sprintf($$->Condition,"%s", $3);
                        sprintf($$->Jump,"beq $t0, $0,");   
                        $$->Next = $6;
                        $$->elseJump = $9;
                    }       
            
            | IF LPAREN bool_exp RPAREN LT statements GT 
                    {
                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 3;
                        $$->Next =$6;
                        sprintf($$->Condition,"%s", $3);
                        sprintf($$->Jump,"beq $t0, $0,");   
                        $$->elseJump=NULL;
                    }

;

switch_statement : SWITCH LPAREN ID RPAREN LT case_statement GT
                    {
                        struct symrec* s;
                        s = getsym($3);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$3);
                            exit(0);
                        }
                        if (s->isarray == 1){
                            printf("%s is not an int\n",$3);
                            exit(0);                            
                        }
                        sprintf(case_variable, "lw $t0,%s($t8)",s->addr);
                        label_switch = countLabel;
                        countLabel = countLabel+1;

                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 4;
                        $$->Next =$6;
                        $$->is_case=-1;

                    }
case_statement : CASE ICONST COLON statements BREAK DOT case_statement 
                    {
                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 4;
                        $$->Next =$4;
                        sprintf($$->Condition,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\nli $t0,%d\nsw $t0,-4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nseq $t0,$t0,$t1\n",case_variable,$2);
                        sprintf($$->Jump,"beq $t0, $0,");
                        $$->is_case = 1;
                        $$->elseJump=$7;
                    }
                |   DEFAULT COLON statements BREAK DOT
                    {
                        $$ = GetstmtBlock(); 
                        $$->isTYPE = 4;
                        $$->Next =$3;
                        $$->is_case=0;

                    }  ;         

return_statement : RETURN exp DOT
                    {
                        /*
                        Return stmt of a function.
                        Callee restores the stack pointer
                        and base address of the caller.
                        */
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"%smove $v0,$t0\naddi $sp, $sp, %d\nlw $t8,-4($sp)\nlw $ra,-8($sp)\njr $ra\n",$2,size);
                        $$->Next = NULL;
                    }
            | RETURN DOT
                    {
                        $$ = GetstmtBlock();
                        $$->isTYPE = 0;
                        sprintf($$->Body,"addi $sp, $sp, %d\nlw $t8,-4($sp)\nlw $ra,-8($sp)\njr $ra\n",size);
                        $$->Next = NULL;  
                    }
;

bool_exp : exp EQUOP exp 
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0,-4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nseq $t0,$t0,$t1\n",$1,$3);
                    }
         | exp NEQUOP exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nsne $t0,$t0,$t1\n",$1,$3);
                    }
         | exp LT exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nslt $t0,$t0,$t1\n",$1,$3);
                    } 
         | exp LE exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nsle $t0,$t0,$t1\n",$1,$3);
                    } 
         | exp GT exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nsgt $t0,$t0,$t1\n",$1,$3);
                    } 
         | exp GE exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nsge $t0,$t0,$t1\n",$1,$3);
                    } 
         | bool_exp OROP bool_exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nor $t0,$t0,$t1\n",$1,$3);
                    } 
         | bool_exp ANDOP bool_exp
                    {
                        sprintf($$,"%ssw $t0,-4($sp)\naddi $sp,$sp,-4\n%s\nsw $t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nand $t0,$t0,$t1\n",$1,$3);
                    }   
         | LPAREN bool_exp RPAREN
                    {
                        sprintf($$,"%s",$2);
                    } 
;

type : INT | CHAR

exp : x
                    {
                        sprintf($$,"%s\n",$1);
                    }
    | exp PLUSOP exp
                    {
                        sprintf($$,"%ssw $t0 -4($sp)\naddi $sp,$sp,-4\n%s\nsw,$t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nadd $t0,$t0,$t1\n",$1,$3);
                    }
    | exp MINUSOP exp
                    {
                        sprintf($$,"%ssw $t0 -4($sp)\naddi $sp,$sp,-4\n%s\nsw,$t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nsub $t0,$t0,$t1\n",$1,$3);
                    }
    | exp MULOP exp
                    {
                        sprintf($$,"%ssw $t0 -4($sp)\naddi $sp,$sp,-4\n%s\nsw,$t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\nmul $t0,$t0,$t1\n",$1,$3);
                    }
    | exp DIVOP exp
                    {
                        sprintf($$,"%ssw $t0 -4($sp)\naddi $sp,$sp,-4\n%s\nsw,$t0 -4($sp)\naddi $sp,$sp,-4\nlw $t1,0($sp)\naddi $sp,$sp,4\nlw $t0,0($sp)\naddi $sp,$sp,4\ndiv $t0,$t0,$t1\n",$1,$3);
                    }      
    | LPAREN exp RPAREN
                    {
                        sprintf($$,"%s",$2);
                    }
    | function_call_assigned
                    {
                        sprintf($$,"%s\n",$1);
                    }
;

x : ICONST
                    {
                        sprintf($$,"li $t0,%d",$1);
                    }
  | ID
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        if (s->isarray == 1){
                            printf("%s is not an int\n",$1);
                            exit(0);                            
                        }
                        sprintf($$, "lw $t0,%s($t8)",s->addr);
                    }

  | ID LBRACK x1 RBRACK
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        if (s->isarray == 0){
                            printf("%s is not an array\n",$1);
                            exit(0);                            
                        }
                        sprintf($$,"%s\nmul $t2,$t2,4\nli $t3,%s\nadd $t3,$t3,$t8\nadd $t2,$t2,$t3\nlw $t0,0($t2)",$3,s->addr);
                    }
; 
x1 : ICONST
                    {
                        sprintf($$,"li $t2,%d",$1);
                    }
   | ID
                    {
                        struct symrec* s;
                        s = getsym($1);
                        if (s == NULL){
                            printf("Undefined Reference to %s\n",$1);
                            exit(0);
                        }
                        if (s->isarray == 1){
                            printf("Using Array %s as Index.\n",$1);
                            exit(0);                            
                        }
                        sprintf($$, "lw $t2,%s($t8)",s->addr);
                    }
;

x2 : CCONST {sprintf($$,"li $t2,%s",$1);};
%%

struct symrec* putsym(char* sym_name,int size,int isarray){

    struct symrec* ptr = (struct symrec*)malloc(sizeof(struct symrec));
    ptr->name = (char*)malloc(strlen(sym_name)+1);
    Adr = Adr - 4*size;
    strcpy(ptr->name,sym_name);
    sprintf(ptr->addr,"%d",Adr);
    ptr->isarray = isarray;
    ptr->next = (struct symrec*)sym_table;
    sym_table = ptr;
    return ptr;
}

struct symrec* global_putsym(char* sym_name,int size,int isarray){

    struct symrec* ptr = (struct symrec*)malloc(sizeof(struct symrec));
    ptr->name = (char*)malloc(strlen(sym_name)+1);
    Adr = Adr - 4*size;
    strcpy(ptr->name,sym_name);
    sprintf(ptr->addr,"%d",Adr);
    ptr->isarray = isarray;
    // Inserting New Node at the head of the list
    ptr->next = (struct symrec*)global_sym_table;
    global_sym_table = ptr;
    return ptr;
}

struct symrec* getsym(char* sym_name){
    struct symrec* ptr;
    for(ptr = sym_table; ptr!=NULL; ptr = (struct symrec *)ptr->next){
        if (strcmp(ptr->name,sym_name) == 0){
            return ptr;
        }
    }
    for(ptr = global_sym_table; ptr!=NULL; ptr = (struct symrec *)ptr->next){
        if (strcmp(ptr->name,sym_name) == 0){
            return ptr;
        }
    }
   // Variable Absent.
    return NULL;
}

void StmtHandle(struct stmtBlock* Node){
    if (Node!=NULL)
    {
        if (Node->isTYPE == 1){ 
            // while statement
            int startLabel = countLabel;
            int endLabel = countLabel;
            countLabel++;
            fprintf(fp, "WhileLoopStart%d:\n%s%sNext%d\n", startLabel,Node->Condition,Node->Jump,endLabel);
            TreeTraversal(Node->Next);
            fprintf(fp,"j WhileLoopStart%d \nNext%d:",startLabel,endLabel);
        }
        else if (Node->isTYPE==2){
            // for statement
            int startLabel = countLabel;
            int endLabel = countLabel;
            countLabel++;
            fprintf(fp, "%s\n", Node->dec_assign_1);                  
            fprintf(fp, "ForLoopStart%d:\n",startLabel);                  
            fprintf(fp,"%s\n", Node->Condition);                 
            fprintf(fp, "%s ForLoopEnd%d\n",Node->Jump,endLabel);  
            TreeTraversal(Node->Next);                                
            fprintf(fp, "%s\n",Node->assignment_stmt_1);                 
            fprintf(fp,"j ForLoopStart%d\nForLoopEnd%d:",startLabel,endLabel); 
        }
        else if (Node->isTYPE==3){
            // if-else statement
            int endLabel = countLabel;
            fprintf(fp,"%s\n", Node->Condition);
            if (Node->elseJump != NULL) {
                // if without else
                int elseLabel = countLabel;
                countLabel++; 
                fprintf(fp, "%s else%d\n",Node->Jump,elseLabel);    
                TreeTraversal(Node->Next);                                     
                fprintf(fp,"j ifEnded%d\nelse%d:\n",endLabel, elseLabel);  
                TreeTraversal(Node->elseJump);                                    
                fprintf(fp,"ifEnded%d:\n",endLabel);                        
            }
            else{
                // if with else 
                countLabel++;
                fprintf(fp, "%s ifEnded%d\n",Node->Jump,endLabel);    
                TreeTraversal(Node->Next);                                   
                fprintf(fp,"j ifEnded%d\nifEnded%d:\n",endLabel, endLabel);         
            }
        
        }
        else if(Node->isTYPE==4){
           //switch_case
           if (Node->is_case == 1) {
            //case 
            fprintf(fp,"%s\n", Node->Condition);
            int switchLabel = countLabel++;
            fprintf(fp, "%s case%d\n",Node->Jump,switchLabel); 
            TreeTraversal(Node->Next); 
            fprintf(fp,"j endSwitch%d\ncase%d:\n",label_switch,switchLabel); 
            StmtHandle(Node->elseJump);        
           }
           else if (Node->is_case == 0){
            //default
            TreeTraversal(Node->Next); 
            fprintf(fp,"j endSwitch%d\nendSwitch%d:\n",label_switch,label_switch);
           } 

           else{
               
            StmtHandle(Node->Next); 
           }
        }    
        else{
            fprintf(fp,"%s",Node->Body);
        }
    }
}

void TreeTraversal(struct stmtsBlock* Node){
    if (Node!=NULL){
        if (Node->RightNull == 1){
            StmtHandle(Node->left);
        }
        else{
            StmtHandle(Node->left);
            TreeTraversal(Node->right);
        }
    }
}

void FuncHandle(struct FuncBlock* Node){
    if (Node!=NULL){
        fprintf(fp,"%s:\n",Node->name);
        fprintf(fp,"sw $t8,-4($sp)\n");
        fprintf(fp,"sw $ra,-8($sp)\n");
        fprintf(fp,"move $t8, $sp\n");
        fprintf(fp,"addi $sp, $sp,-%d\n",Node->size);
        TreeTraversal(Node->Stmts);
        if (strcmp("main",Node->name)==0){
            fprintf(fp,"li $v0, 10\nsyscall\n");
        }
        FuncHandle(Node->Next);
    }
}


int getNumArgs(char* func_name){
    struct FuncBlock* Func = Functions;
    while(Func!=NULL){
        if (strcmp(Func->name,func_name)==0){
            // Function Present.
            return Func->num_args;
        }
        Func = Func->Next;
    }
    return -1;
}

int getSize(char* func_name){
    struct FuncBlock* Func = Functions;
    while(Func!=NULL){
        if (strcmp(Func->name,func_name)==0){
            // Function Present.
            return Func->size;
        }
        Func = Func->Next;
    }
    return -1;
}

void main(){
    fp = fopen("mips.asm","w");
    fprintf(fp,".data\n     newline: .asciiz \" \" \n.text\n");
    yyparse();
    FuncHandle(Functions);
    fclose(fp);
}

void yyerror(char* s){
    printf("%s\nline number : %d\n", s,lineno);
}
