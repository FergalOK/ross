#include <stdio.h>
#include <string.h>

#include <kernel/tty.h>

void kernel_main(void) {
	terminal_initialize();

	// This cause page fault :)
	// int* ptr = (int*)0xdeadbeaf;
	// *ptr = 0x41;

	printf("Hello, kernel World!\n");
}
