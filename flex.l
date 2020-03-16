%{
/* Declaracoes C diversas */
unsigned rsc[1024];
int cursor = 1;
%}


%x THREAD DEFAULT CONTENT ID USER DATE REPLY
%%

<DEFAULT,THREAD>\<li\ class=\"comment\"\    { BEGIN THREAD; printf(",{"); rsc[cursor-1]++; }
<REPLY>\<li\ class=\"comment\"\             { BEGIN THREAD; rsc[cursor-1]++; }
<*>\<li\ class=\"comment\"\                 { BEGIN THREAD; printf("{"); rsc[cursor-1]++; }
<THREAD>\<\/ol\>                            { printf(", \"hasReplies\": %s, \"numberOfReplies\": %d}]", rsc[cursor] ? "true" : "false", rsc[cursor]); rsc[cursor--] = 0; }
<THREAD>\<\/form\>\r\n\<\/li\>\r\n          { printf(", \"hasReplies\": %s, \"numberOfReplies\": %d}", rsc[cursor] ? "true" : "false", rsc[cursor]); rsc[cursor]=0; BEGIN DEFAULT;}

<THREAD>data-comment-id=                    BEGIN ID;
<ID>[^\>]+                                  printf("\"id\": %s,", yytext);
<ID>\>                                      BEGIN THREAD;

<THREAD>\<p\>[\ \r\n]*                      { BEGIN CONTENT; printf("\"commentText\": \""); } 
<CONTENT>[^\"\r\n]                          ECHO;
<CONTENT>\"                                 printf("\'");
<CONTENT>\r\n/\r\n                          {;}
<CONTENT>\r                                 {;}
<CONTENT>\r\n\ *\<\/p\>\r\n                 { BEGIN THREAD; printf("\""); }
<CONTENT>\n                                 { printf("\\n"); }

<THREAD>\<a\ href[^\>]+\>                   BEGIN USER;
<USER>[^\<]+/\                              printf("\"user\": \"%s\",", yytext);
<USER>\<\/a\>\r\n                           BEGIN THREAD;

<THREAD>datetime=\"                         BEGIN DATE;
<DATE>[0-9\-]+[^T]                          printf("\"date\": \"%s\",", yytext);
<DATE>[0-9:.]+[^\"]                         printf("\"timestamp\": \"%s\",", yytext);
<DATE>\>\r\n                                BEGIN THREAD;

<THREAD>\<ol\ class[^\>]*\>\r\n             { BEGIN REPLY; printf(",\"replies\": [{"); cursor++; }
<*>\<\/li\>\r\n/\<li                        printf(", \"hasReplies\": %s, \"numberOfReplies\": %d}", rsc[cursor] ? "true" : "false", rsc[cursor]);

<*>.|\n                                     {;}

%%
int yywrap()
{ return(1); }

int main()
{ printf("{\"commentThread\": ["); yylex(); printf("]}\n"); return 0; }
