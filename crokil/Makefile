#!/bin/make

all: crokil

lex.yy.c: crokil.l
	flex crokil.l

crokil.c: crokil.y
	bison -d crokil.y

crokil.o: crokil.c crokil.h

crokilops.o: crokilops.c crokil.h

crokil.tab.o: crokil.tab.c crokil.h crokil.tab.h

lex.yy.o: lex.yy.c crokil.h crokil.c

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

crokil: lex.yy.o crokil.tab.o crokilops.o main.o
	gcc $^ -lfl -lm -o crokil

clean:
	rm *.o lex.yy.c crokil.tab.c *~
