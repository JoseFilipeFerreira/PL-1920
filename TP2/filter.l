%option noyywrap yylineno

%x TT CT
%%
===                     { return INIT; }
:reverse_of             { return INV; }
:[^\ ,;.\n]+            { yylval.str = strdup(yytext + 1); return URI; }

@tit:[\ \n]             { BEGIN TT; }
<TT>[^\n]+              { BEGIN CT; 
                            yylval.str = strdup(yytext);
                            return TIT; }

@triplos:[\ \n]         { return TR; }

<CT>@meta:[\ \n]        { BEGIN INITIAL; return MT; }


<CT>\#\ ([^@\n]+\n)+/[\n@]          { yylval.str = strdup(yytext + 2); return H2; }
<CT>\#\#\ ([^@\n]+\n)+/[\n@]        { yylval.str = strdup(yytext + 3); return H3; }
<CT>\#\#\#\ ([^@\n]+\n)+/[\n@]      { yylval.str = strdup(yytext + 4); return H4; }
<CT>([^@\n]+\n)+/[\n@]              { yylval.str = strdup(yytext); return CONTEUDO; }
<CT>@triplos:[\ \n]                 { BEGIN INITIAL; return TR; }
<CT>\n                  { }

[a,;.]                  { return yytext[0]; }
\".+\"                  { yylval.str = strdup(yytext); return STR; }
.|\n                    {  }
\/\/.*                  { }
%%
