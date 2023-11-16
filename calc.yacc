/* First is the definition section which is composed of: %{code%}, substitutions, and the start states */

%{

#include<stdio.h>

int regs[26]; /* array of size = number of alphabet characters (a – z) */
int base; /* are octal or decimal numbers */

%}

/* input goes into 2 stacks (type and value stacks). Base of value stack is regs[] is $1 */
%start list    /* start state is an empty list */

//%union { int a; } //if removed. it compiles
//%type <a> LETTER   problematic 2 lines...

%token DIGIT     /* these are substitutions for pattern matching */
%token LETTER    

/* rules; values are in yylval */

%left '|'         /* lowest precedence */
%left '&'         /* higher precedence over ‘|’*/
%left '+' '-'     /* higher precedence over ‘&’ */
%left '*' '/' '%'     /* higher precedence over ‘+’ and ‘-‘ */
%left UMINUS  /*supplies precedence for unary minus */

%%                   /* end of declarations/definitions and beginning of rules section */

list:                       /*empty */
         |                  /* | means OR */
        list stat '\n'
         |
        list error '\n'
         {
           yyerrok;       /* action for an error */
         }
         ;
stat:    expr             /* Terminal expr */
         {
           printf("%d\n",$1);
         }
         |
         LETTER '=' expr        /* e.g., m = 4 */
         {
           regs[$1] = $3;       /* store the letter (m) value into the array[letter]*/
         }

         ;

expr:    '(' expr ')'
         {
           $$ = $2;
         }
         |
         expr '*' expr
         {

           $$ = $1 * $3;
         }
         |
         expr '/' expr
         {
           $$ = $1 / $3;
         }
         |
         expr '%' expr
         {
           $$ = $1 % $3;
         }
         |
         expr '+' expr
         {
           $$ = $1 + $3;
         }
         |
         expr '-' expr
         {
           $$ = $1 - $3;
         }
         |
         expr '&' expr
         {
           $$ = $1 & $3;
         }
         |
         expr '|' expr
         {
           $$ = $1 | $3;
         }
         |

        '-' expr %prec UMINUS     /* this rule is ‘-‘ expr but with precedence of UMINUS */
         {
           $$ = -$2;
         }
         |
         LETTER
         {
           $$ = regs[$1];         /* $$ <- content of array entry regs[LETTER] -> integer */
         }

         |
         number
         ;

number:  DIGIT
         {
           $$ = $1;                   /* $1 = first digit */
           base = ($1==0) ? 8 : 10;   /* $1 = 0 means Octal, $1 != 0 means decimal */
         }       |
         number DIGIT               /* we are adding digit to number based on the numeric base */
         {
           $$ = base * $1 + $2;     /* base is global set 8 or 10 */
         }
         ;

%%
main()
{
 return(yyparse());
}

yyerror(s)
char *s;
{
  fprintf(stderr, "%s\n",s);
}

yywrap()
{
  return(1);
}