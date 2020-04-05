%%
<DEFAULT,THREAD>\<li\ class=\"comment\"\  { BEGIN THREAD; printf(",{"); rsc[cursor-1]++; }
<REPLY>\<li\ class=\"comment\"\           { BEGIN THREAD; rsc[cursor-1]++; }
<*>\<li\ class=\"comment\"\               { BEGIN THREAD; printf("{"); rsc[cursor-1]++; }
<THREAD>\<\/ol\>                          { char *bool = rsc[cursor] ? "true" : "false"; \
                                            char *reply = rsc[cursor] ? " " : "\"replies\": [], "; \
                                            printf \
                                              (",%s\"hasReplies\": %s, \"numberOfReplies\": %d, \"likes\": 0}]", \
                                                    reply, bool, rsc[cursor]); \
                                            rsc[cursor--] = 0; }
<THREAD>\<\/form\>\r\n\<\/li\>\r\n        { char *bool = rsc[cursor] ? "true" : "false"; \
                                            char *reply = rsc[cursor] ? " " : "\"replies\": [], "; \
                                            printf \
                                              (",%s\"hasReplies\": %s, \"numberOfReplies\": %d, \"likes\": 0}", \
                                                    reply, bool, rsc[cursor]); \
                                            rsc[cursor]=0; \
                                            BEGIN DEFAULT; }

<THREAD>data-comment-id=                  BEGIN ID;
<ID>[^\>]+                                printf("\"id\": %s,", yytext);
<ID>\>                                    BEGIN THREAD;

<THREAD>\<p\>[\ \r\n]*                    { BEGIN CONTENT; printf("\"commentText\": \""); } 
<CONTENT>[^\"\r\n]                        ECHO;
<CONTENT>\"                               printf("\'");
<CONTENT>\r                               {;}
<CONTENT>\r\n\ *\<\/p\>\r\n               { BEGIN THREAD; printf("\""); }
<CONTENT>\n                               { printf("\\n"); }

<THREAD>\<a\ href[^\>]+\>                 BEGIN USER;
<USER>[^\<]+/\                            printf("\"user\": \"%s\",", yytext);
<USER>\<\/a\>\r\n                         BEGIN THREAD;

<THREAD>datetime=\"                       BEGIN DATE;
<DATE>[0-9\-]+[^T]                        printf("\"date\": \"%s\",", yytext);
<DATE>[0-9:.]+[^\"]                       printf("\"timestamp\": \"%s\",", yytext);
<DATE>\>\r\n                              BEGIN THREAD;

<THREAD>\<ol\ class[^\>]*\>\r\n           { BEGIN REPLY; printf(",\"replies\": [{"); cursor++; }
<*>\<\/li\>\r\n/\<li                      { char *bool = rsc[cursor] ? "true" : "false"; \
                                            char *reply = rsc[cursor] ? " " : "\"replies\": [], "; \
                                            printf \
                                              (",%s\"hasReplies\": %s, \"numberOfReplies\": %d, \"likes\": 0}", \
                                                    reply, bool, rsc[cursor]); }

<*>.|\n                                   {;}
%%
