%{
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <gmodule.h>
/* Declaracoes C diversas */
int yylex();
int yyerror(char* s);
void mkrev(char*);
char* findrev(char*);
FILE* file;
char* sujeito;
char* reverse[100];
int revptr;
char* curr_rev;
int is_a;

struct cmp {
    int type;
    char* str;
};


GHashTable* props;
GHashTable* suj;

GHashTable* get_or_insert_hash(char*);
GArray* get_or_insert_list(char*, GHashTable*);
GHashTable* mkindex(char*);
%}

%union {
    char* str;
    struct cmp* comp;
    GArray* comps;
}

%token INIT TR IMG MT INV
%token<str> STR CONTEUDO TIT URI 
%type<str> Sujeito Par Pares Conteudo Rinv
%type<comp> Comp
%type<comps> Comps

%%

Caderno : Conceitos
        ;

Conceitos   : Conceito
            | Conceitos Conceito

Conceito    : Documento MT Meta TR Triplos
            | Documento TR Triplos
            ;

Documento   : INIT Sujeito Titulo Conteudo          { fprintf(file, "%s", $4); fclose(file); 
                                                        free($4); free($2); revptr = 0; curr_rev = NULL; }
            ;

Meta : Meta URI INV URI '.'             { reverse[revptr++] = strdup($2); reverse[revptr++] = strdup($4); }
     | URI INV URI '.'                  { reverse[revptr++] = strdup($1); reverse[revptr++] = strdup($3); }
     ;

Triplos : Triplos Sujeito Pares '.'     { fclose(file); }
        | Sujeito Pares '.'             { fclose(file); }
        ;

Pares   : Par                           { }
        | Pares ';' Par                 { }
        ;

Par     : Rinv Comps                    { GArray* list = get_or_insert_list($1, suj); g_array_append_vals(list, $2->data, $2->len); curr_rev = NULL; }
        | Ra Comps                      { GArray* list = get_or_insert_list("a", suj); g_array_append_vals(list, $2->data, $2->len); curr_rev = NULL; }
        | IMG Comps                     { GArray* list = get_or_insert_list("IMG", suj); g_array_append_vals(list, $2->data, $2->len); curr_rev = NULL; }
        ;

Comps   : Comp                          { $$ = g_array_new(FALSE, FALSE, sizeof(struct cmp*)); g_array_append_val($$, $1); }
        | Comps ',' Comp                { $$ = $1; g_array_append_val($$, $3); }
        ;

Comp    : URI                           { mkindex($1); 
                                            mkrev($1);
                                            $$ = malloc(sizeof(struct cmp));
                                            $$->str = strdup($1);
                                            $$->type = 1;
                                            free($1);
                                        }
        | STR                           { $$ = malloc(sizeof(struct cmp)); $$->str = strdup($1); $$->type = 0; free($1); }
        ;

Sujeito : URI                           { suj = mkindex($1); $$ = strdup($1); sujeito = $$; file = fopen($1, "a"); free($1); }
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

#include "lex.yy.c"

GHashTable* get_or_insert_table(char* uri) {
    GHashTable* r = g_hash_table_lookup(props, uri);
    if(r == NULL) {
        r = g_hash_table_new(g_str_hash, g_str_equal);
        g_hash_table_insert(props, strdup(uri), r);
    }
    return r;
}

GArray* get_or_insert_list(char* uri, GHashTable* p) {
    GArray* r = g_hash_table_lookup(p, uri);
    if(r == NULL) {
        r = g_array_new(FALSE, TRUE, sizeof(struct cmp*));
        g_hash_table_insert(p, strdup(uri), r);
    }
    return r;
}

GHashTable* mkindex(char* uri) {
    GHashTable* r = get_or_insert_table(uri);
    if(access(uri, F_OK) == -1) { 
        FILE* f = fopen("index.html", "a"); 
        fprintf(f, "<p><a href=\"%s\">%s</a></p>\n", uri, uri); 
        fclose(f);
        f = fopen(uri, "a");
        fprintf(f, "<p><a href=\"index.html\">Index</a></p>\n"); 
        fclose(f);
        g_hash_table_insert(props, strdup(uri), r);
    }
    return r;
}

void mkrev(char* uri) {
    if(curr_rev != NULL) {
        GHashTable* h = get_or_insert_table(uri);
        GArray* a = get_or_insert_list(curr_rev, h);
        struct cmp* aa = malloc(sizeof(struct cmp));
        aa->str = strdup(sujeito);
        aa->type = 1;
        g_array_append_val(a, aa);
    }
}

char* findrev(char* uri) {
    for(int i = 0; i < revptr - 1; i += 2) {
        if(!strcmp(reverse[i], uri)) return reverse[i+1];
        else if(!strcmp(reverse[i+1], uri)) return reverse[i];
    }
    return NULL;
}

void run_table_2(char* key, GArray* value, void* v) {
    struct cmp* t;
    FILE* f = fopen(v, "a");
    fprintf(f, "<p>%s: ", key);
    for(int i = 0; i < value->len; i++) {
        t = g_array_index(value, struct cmp*, i);
        if(!t->type)
            fprintf(f, "%s ", t->str);
        else
            fprintf(f, "<a href=\"%s\">%s</a> ", t->str, t->str);
    }
    fprintf(f, "</p>\n");
}

void run_table(char* key, void* value, void* v) {
    FILE* f = fopen(key, "a");
    struct cmp* t;
    void* k;
    GArray* val;

    if(g_hash_table_steal_extended(value, "IMG", k, &val)) {
        fprintf(f, "<p>", key);
        for(int i = 0; i < val->len; i++) {
            t = g_array_index(val, struct cmp*, i);
            fprintf(f, "<img src=%s alt=%s>\n", t->str, t->str);
        }
        fprintf(f, "</p>\n");
    }

    if(g_hash_table_steal_extended(value, "a", k, &val)) {
        fprintf(f, "<p>", key);
        for(int i = 0; i < val->len; i++) {
            t = g_array_index(val, struct cmp*, i);
            fprintf(f, "<a href=\"%s\">%s</a> ", t->str, t->str);
            FILE* fr = fopen(t->str, "a");
            fprintf(fr, "<p><a href=\"%s\">%s</a></p>\n", key, key);
            fclose(fr);
        }
        fprintf(f, "</p>\n");
    }
    fclose(f);

    g_hash_table_foreach(value, run_table_2, key);
}

int yyerror(char *s)
{
  fprintf(stderr, "ERRO: %s \n", s);
}

int main()
{
    props = g_hash_table_new(g_str_hash, g_str_equal);
    yyparse();
    g_hash_table_foreach(props, run_table, NULL);
    return(0);
}

