# Declare constants for the multiboot header.
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a header as in the Multiboot Standard.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Reserve a stack for the initial thread.
.section .bss
.align 4096
page_directory:
.skip 4096 # 4 KiB
page_table:
.skip 4096 # 4 KiB
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# The kernel entry point.
.section .text
.global _start
.type _start, @function
_start:
	movl $stack_top, %esp

	# Call the global constructors.
    call _init

    # Todo: protected mode is already turned on? Find out why
    call init_paging
continue_start:
	# Transfer control to the main kernel.
	call kernel_main

	# Hang if kernel_main unexpectedly returns.
	cli
1:	hlt
	jmp 1b
.size _start, . - _start

init_paging:
    mov $0, %eax
l1: # page_directory[i] = 0x00000002 (Not Present + Writable)
    mov $0x00000002, page_directory(,%eax, 4)
    inc %eax
    cmp $1024, %eax
    jne l1

    mov $0, %eax
    mov $0, %ebx
l2: # page_table[i] = 0x(address)003 (address is 4KiB aligned leaving 12 final bits for flags)
    mov %eax, %ecx
    or $3, %ecx
    mov %ecx, page_table(,%ebx, 4)
    add $0x1000, %eax # 4KiB pages
    inc %ebx
    cmp $0x1000, %ebx
    jne l2

    # page_directory[0] = page_table
    mov $page_table, %ecx
    or $0x3, %ecx # Present + Writable
    mov %ecx, page_directory

    # Set page directory
    mov $page_directory, %eax
    mov %eax, %cr3
    
    # Enable paging
    mov %cr0, %eax
    or $0x80000001, %eax
    mov %eax, %cr0
    # Must jump straight away
    jmp continue_start
