%{
#include <stdio.h>
#include <unistd.h>
#include <string.h>
/* Declaracoes C diversas */
int yylex();
int yyerror(char* s);
void mkindex(char*);
void mkrev(char*);
char* findrev(char*);
FILE* file;
char* sujeito;
char* reverse[100];
int revptr;
char* curr_rev;
int is_a;
%}

%union {
    char* str;
}

%token INIT TR IMG MT INV
%token<str> STR CONTEUDO TIT URI 
%type<str> Sujeito Comp Comps Par Pares Conteudo Rinv

%%

Caderno : Conceitos
        ;

Conceitos   : Conceito
            | Conceitos Conceito

Conceito    : Documento MT Meta TR Triplos
            | Documento TR Triplos
            ;

Documento   : INIT Sujeito Titulo Conteudo          { fprintf(file, "%s", $4); 
                                                        free($4); free($2); revptr = 0; curr_rev = NULL; }
            ;

Meta : Meta URI INV URI '.'             { reverse[revptr++] = strdup($2); reverse[revptr++] = strdup($4); }
     | URI INV URI '.'                  { reverse[revptr++] = strdup($1); reverse[revptr++] = strdup($3); }
     ;

Triplos : Triplos Sujeito Pares '.'     { fprintf(file, "%s", $3); free($3); free($2); fclose(file); }
        | Sujeito Pares '.'             { fprintf(file, "%s", $2); free($2); free($1); fclose(file); }
        ;

Pares   : Par                           { asprintf(&$$, "<p>%s</p>\n", $1); free($1); }
        | Pares ';' Par                 { asprintf(&$$, "%s<p>%s</p>\n", $1, $3); free($1); }
        ;

Par     : Rinv Comps                    { asprintf(&$$, "%s: %s\n", $1, $2); free($2); free($1); curr_rev = NULL; }
        | Ra Comps                      { asprintf(&$$, "%s\n", $2); is_a = 0; free($2); curr_rev = NULL; }
        | IMG STR                       { asprintf(&$$, "<img src=%s alt=%s>\n", $2, $2); free($2); curr_rev = NULL; }
        ;

Comps   : Comp                          { asprintf(&$$, "%s", $1); free($1); }
        | Comps ',' Comp                { asprintf(&$$, "%s, %s", $3, $1); free($1); free($3); }
        ;

Comp    : URI                           { mkindex($1); 
                                            FILE* f = fopen($1, "a"); 
                                            if(is_a) fprintf(f, "<p><a href=\"%s\">%s</a></p>\n", sujeito, sujeito);
                                            fclose(f); mkrev($1); 
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

Rinv : URI                              { curr_rev = findrev($1); $$ = strdup($1); }

Conteudo : CONTEUDO                     { asprintf(&$$, "<p>%s</p>\n", $1); free($1); }
         | Conteudo CONTEUDO            { asprintf(&$$, "%s<p>%s</p>\n", $1, $2); free($1); free($2); }
         ;
%%

void mkindex(char* uri) {
    if(access(uri, F_OK) == -1) { 
        FILE* f = fopen("index.html", "a"); 
        fprintf(f, "<p><a href=\"%s\">%s</a></p>\n", uri, uri); 
        fclose(f);
        f = fopen(uri, "a");
        fprintf(f, "<p><a href=\"index.html\">Index</a></p>\n"); 
        fclose(f);
    }
}

void mkrev(char* uri) {
    if(curr_rev != NULL) {
        FILE* c = fopen(uri, "a");
        fprintf(c, "<p>%s: <a href=\"%s\">%s</a></p>\n", curr_rev, sujeito, sujeito);
        fclose(c);
    }
}

char* findrev(char* uri) {
    for(int i = 0; i < revptr - 1; i += 2) {
        if(!strcmp(reverse[i], uri)) return reverse[i+1];
        else if(!strcmp(reverse[i+1], uri)) return reverse[i];
    }
    return NULL;
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

