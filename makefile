html2json: flex.l
	flex flex.l
	cc lex.yy.c -o html2json
