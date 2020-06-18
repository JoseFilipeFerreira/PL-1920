%{
#include <stdio.h>
#include <unistd.h>
#include <strings.h>
/* Declaracoes C diversas */
int yylex();
int yyerror(char* s);
void mkindex(char*);
FILE* file;
char* sujeito;
int is_a;
#define _GNU_SOURCE
%}

%union {
    char* str;
}

%token INIT TR IMG
%token<str> STR CONTEUDO TIT URI
%type<str> Sujeito Comp Comps Par Pares Conteudo

%%

Caderno : Conceitos
        ;

Conceitos   : Conceito
            | Conceitos Conceito

Conceito    : Documento TR Triplos
            ;

Documento   : INIT Sujeito Titulo Conteudo          { fprintf(file, "%s", $4); 
                                                        fflush(file); free($4); free($2); }
            ;

Triplos : Triplos Sujeito Pares '.'     { fprintf(file, "%s", $3); free($3); free($2); }
        | Sujeito Pares '.'             { fprintf(file, "%s", $2); free($2); free($1); }
        ;

Pares   : Par                           { asprintf(&$$, "<p>%s</p>\n", $1); free($1); }
        | Pares ';' Par                 { asprintf(&$$, "%s<p>%s</p>\n", $1, $3); free($1); }
        ;

Par     : URI Comps                     { asprintf(&$$, "%s: %s\n", $1, $2); free($2); free($1); }
        | Ra Comps                      { asprintf(&$$, "%s\n", $2); is_a = 0; free($2); }
        | IMG STR                       { asprintf(&$$, "<img src=%s alt=%s>\n", $2, $2); free($2); }
        ;

Comps   : Comp                          { asprintf(&$$, "%s", $1); free($1); }
        | Comps ',' Comp                { asprintf(&$$, "%s, %s", $3, $1); free($1); free($3); }
        ;

Comp    : URI                           { mkindex($1); 
                                            FILE* f = fopen($1, "a"); 
                                            if(is_a) fprintf(f, "<p><a href=\"%s\">%s</a></p>\n", sujeito, sujeito);
                                            fclose(f); 
                                            asprintf(&$$, "<a href=\"%s\">%s</a>\n", $1, $1); 
                                            free($1);
                                        }
        | STR                           { $$ = strdup($1); free($1); }
        ;

Sujeito : URI                           { $$ = strdup($1); sujeito = $$; mkindex($1); file = fopen($1, "a"); free($1); }
        ;

Titulo  : TIT                           { fprintf(file, "<h1>%s</h1>\n", $1); free($1); }
        ;

Ra      : 'a'                           { is_a = 1; }
        ;

Conteudo : CONTEUDO                     { asprintf(&$$, "<p>%s</p>\n", $1); free($1); }
         | Conteudo CONTEUDO            { asprintf(&$$, "%s<p>%s</p>\n", $1, $2); free($1); free($2); }
         ;
%%

void mkindex(char* uri) {
    if(access(uri, F_OK) == -1) { 
        FILE* f = fopen("index.html", "a"); 
        fprintf(f, "<p><a href=\"%s\">%s</a></p>\n", uri, uri); 
        fclose(f);
    }
}

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

