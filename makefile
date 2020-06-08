all: ass3

ass3: ass3.o
	gcc -m32 -Wall -g ass3.o -o ass3

ass3.o: ass3.s
	nasm -f elf -w+all -g ass3.s -o ass3.o

.PHONY: clean

clean: 
	rm -f *.o ass3