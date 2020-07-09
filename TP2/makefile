LEX= flex
YACC= yacc
CC= cc
CFLAGS= -D_GNU_SOURCE `pkg-config --cflags --libs glib-2.0`

EXEC= turtle
REVERSE= reverse

install: $(EXEC)
	sudo mv $(EXEC) /usr/local/bin
	cp $(REVERSE) ~/.turtle || exit 0

uninstall:
	rm /usr/local/bin/$(EXEC)

$(EXEC): y.tab.c lex.yy.c
	$(CC) y.tab.c -o $(EXEC) $(CFLAGS)

y.tab.c: grammar.y
	$(YACC) grammar.y

lex.yy.c: filter.l
	$(LEX) filter.l
