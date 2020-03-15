%{
/* Declaracoes C diversas */
%}


%x THREAD DEFAULT CONTENT ID USER DATE REPLY
%%

<DEFAULT,THREAD>\<li\ class=\"comment\"\    { BEGIN THREAD; printf(",{"); }
<REPLY>\<li\ class=\"comment\"\         BEGIN THREAD;
<*>\<li\ class=\"comment\"\             { BEGIN THREAD; printf("{"); }
<THREAD>\<\/ol\>                        printf("}]");
<THREAD>\<\/form\>\r\n\<\/li\>\r\n      { printf("}"); BEGIN DEFAULT;}

<THREAD>data-comment-id=        BEGIN ID;
<ID>[^\>]+                      printf("\"id\": %s,", yytext);
<ID>\>                          BEGIN THREAD;

<THREAD>\<p\>[\ \r\n]*          { BEGIN CONTENT; printf("\"commentText\": \""); } 
<CONTENT>[^\"\r\n]              ECHO;
<CONTENT>\"                     printf("\'");
<CONTENT>\r\n/\r\n              {;}
<CONTENT>\r\n\ *\<\/p\>\r\n     { BEGIN THREAD; printf("\""); }
<CONTENT>\r                     {;}
<CONTENT>\n                     { printf("\\n"); }

<THREAD>\<a\ href[^\>]+\>       BEGIN USER;
<USER>[^\<]+/\                  printf("\"user\": \"%s\",", yytext);
<USER>\<\/a\>\r\n               BEGIN THREAD;

<THREAD>datetime=\"             BEGIN DATE;
<DATE>[0-9\-]+[^T]              printf("\"date\": \"%s\",", yytext);
<DATE>[0-9:.]+[^\"]             printf("\"timestamp\": \"%s\",", yytext);
<DATE>\>\r\n                    BEGIN THREAD;

<THREAD>\<ol\ class[^\>]*\>\r\n     { BEGIN REPLY; printf(",\"replies\": [{"); }
<*>\<\/li\>\r\n/\<li                printf("}");

<*>.|\n                         {;}

%%
int yywrap()
{ return(1); }

int main()
{ printf("{\"commentThread\": ["); yylex(); printf("]}\n"); return 0; }
