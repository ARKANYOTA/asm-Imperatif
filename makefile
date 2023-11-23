all: clean
	rm -f main.o main
	nasm -f elf64 -o main.o main.asm
	ld -o main main.o
	./main

clean:
	rm -f main.o main

