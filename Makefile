all: kernel.o boot.o
	i686-elf-gcc -T ${SRC}/linker.ld -o ${BUILD}/myos.bin -ffreestanding -O2 -nostdlib ${BUILD}/boot.o ${BUILD}/kernel.o -lgcc

run: all
	qemu-system-i386 -kernel ${BUILD}/myos.bin

kernel.o:
	i686-elf-gcc -c ${SRC}/kernel.c -o ${BUILD}/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

boot.o:
	i686-elf-as ${SRC}/boot.s -o ${BUILD}/boot.o

clean:
	rm -f ${BUILD}/*.o ${BUILD}/*.bin

SRC=src
BUILD=build
