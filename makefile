all: ass3

ass3: ass3.o scheduler.o printer.o target.o drone.o
	gcc -m32 -Wall -g ass3.o scheduler.o printer.o target.o drone.o -o ass3

ass3.o: ass3.s
	nasm -f elf -w+all -g ass3.s -o ass3.o

scheduler.o: scheduler.s
	nasm -f elf -w+all -g scheduler.s -o scheduler.o

printer.o: printer.s
	nasm -f elf -w+all -g printer.s -o printer.o

target.o: target.s
	nasm -f elf -w+all -g target.s -o target.o

drone.o: drone.s
	nasm -f elf -w+all -g drone.s -o drone.o

.PHONY: clean

clean: 
	rm -f *.o ass3