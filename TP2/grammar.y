%{
#include <stdio.h>
#include <strings.h>
/* Declaracoes C diversas */
int yylex();
int yyerror(char* s);
#define _GNU_SOURCE
%}

%union {
    char* str;
}

%token INIT TR 
%token<str> STR CONTEUDO TIT URI
%%

Caderno : Conceitos
        ;

Conceitos   : Conceito
            | Conceitos Conceito

Conceito    : Documento TR Triplos
            ;

Documento   : INIT Sujeito Titulo CONTEUDO          { printf("<p>%s</p>\n", $4); }
            ;

Triplos : Triplos Sujeito Pares '.'
        | Sujeito Pares '.'
        ;

Pares   : Par
        | Pares ';' Par
        ;

Par     : Rel Comps
        ;

Comps   : Comp                          {}
        | Comps ',' Comp
        ;

Comp    : URI                           { printf("<a href=\"%s\">%s</a>\n", $1, $1); }
        | STR
        ;

Sujeito : URI
        ;

Rel     : URI
        | 'a'
        ;

Titulo  : TIT                           { printf("<h1>%s</h1>\n", $1); }
        ;
%%

#include "lex.yy.c"

int yyerror(char *s)
{
  fprintf(stderr, "ERRO: %s \n", s);
}

int main()
{
    yyparse();
    return(0);
}

