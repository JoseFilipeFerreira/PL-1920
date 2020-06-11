%option noyywrap

%x TT CT
%%
===             { return INIT; }
:[^\ ,;.\n]+    { yylval.str = strdup(yytext + 1); return URI; }

@tit:[\ \n]     { BEGIN TT; };
<TT>[^\n]+      { BEGIN CT; 
                yylval.str = strdup(yytext);
                return TIT; }

@triplos:[\ \n] { return TR; };


<CT>[^@]+      { yylval.str = strdup(yytext); 
                    return CONTEUDO; }

<CT>@triplos:[\ \n] { BEGIN INITIAL; return TR; };

[a,;.]          { return yytext[0]; }

\".+\"          { return STR; }

.|\n            {  }
%%
