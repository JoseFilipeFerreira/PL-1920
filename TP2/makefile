CFLAGS= -D_GNU_SOURCE
EXEC=turtle

$(EXEC): grammar.y filter.l
	yacc grammar.y
	flex filter.l
	cc y.tab.c -o $(EXEC) $(CFLAGS)
