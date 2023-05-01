all: kernel.o boot.o
	i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

run: all
	qemu-system-i386 -kernel myos.bin

kernel.o:
	i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

boot.o:
	i686-elf-as boot.s -o boot.o

clean:
	rm -f *.o *.bin
