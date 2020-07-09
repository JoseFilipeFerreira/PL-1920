LEX= flex
YACC= yacc
CC= cc
CFLAGS= -D_GNU_SOURCE `pkg-config --cflags --libs glib-2.0`

EXEC= turtle
REVERSE= reverse


$(EXEC): y.tab.c lex.yy.c
	$(CC) y.tab.c -o $(EXEC) $(CFLAGS)

y.tab.c: grammar.y
	$(YACC) grammar.y

lex.yy.c: filter.l
	$(LEX) filter.l

clean:
	rm -f y.tab.c lex.yy.c $(EXEC)

install: $(EXEC)
	sudo mv $(EXEC) /usr/local/bin
	- cp $(REVERSE) $(HOME)/.turtle

uninstall:
	rm /usr/local/bin/$(EXEC)

dist:
	tar -czf $(EXEC).tgz grammar.y filter.l makefile reverse example_input
