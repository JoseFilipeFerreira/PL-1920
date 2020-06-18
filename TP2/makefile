CFLAGS= -W -Wall -Wextra -O2 -D_GNU_SOURCE `pkg-config --cflags --libs glib-2.0`
EXEC=turtle

$(EXEC): grammar.y filter.l
	yacc grammar.y
	flex filter.l
	cc y.tab.c -o $(EXEC) $(CFLAGS)
