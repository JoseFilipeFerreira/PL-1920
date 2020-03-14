%{
/* Declaracoes C diversas */
%}


%x THREAD DEFAULT CONTENT ID USER DATE
%%

<*>\<li\ class=\"comment\"\     { BEGIN THREAD; printf("\t\{\n"); }
<*>\<\/form\>\r\n\<\/li\>\r\n   { printf("\t\},\n"); BEGIN DEFAULT;}

<THREAD>data-comment-id=        BEGIN ID;
<ID>[^\>]+                      printf("\t\t\"id\": %s,\n", yytext);
<ID>\>                          BEGIN THREAD;

<THREAD>\<p\>\ *\r\n            { BEGIN CONTENT; printf("\t\t\"commentText: \""); } 
<CONTENT>\ \ +                  {;}
<CONTENT>.|\r\n                 ECHO;
<CONTENT>\r\n/\r\n              {;}
<CONTENT>\r\n\ +\<\/p\>\r\n     { BEGIN THREAD; printf("\",\n"); }

<THREAD>\<a\ href[^\>]+\>       BEGIN USER;
<USER>[^\<]+/\                  printf("\t\t\"user\": \"%s\",\n", yytext);
<USER>\<\/a\>\r\n               BEGIN THREAD;

<THREAD>datetime=\"             BEGIN DATE;
<DATE>[0-9\-]+[^T]              printf("\t\t\"date\": \"%s\",\n", yytext);
<DATE>[0-9:.]+[^\"]             printf("\t\t\"timestamp\": \"%s\",\n", yytext);
<DATE>\>\r\n                    BEGIN THREAD;

<*>.|\n                         {;}

%%
int yywrap()
{ return(1); }

int main()
{ printf("\"commentThread\": [\n");yylex(); return 0; }
