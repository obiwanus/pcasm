.SUFFIXES:
.SUFFIXES: .o .asm .cpp .c

AS=nasm
ASFLAGS= -f elf
CFLAGS= -m32
CC=gcc


%.o : %.asm
	$(AS) $(ASFLAGS) $<

.c.o:
	$(CC) -c $(CFLAGS) $*.c

first: driver.o first.o asm_io.o
	$(CC) $(CFLAGS) -ofirst.out driver.o first.o asm_io.o

first.o: asm_io.inc first.asm


asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) -d ELF_TYPE asm_io.asm

clean :
	rm *.o
	rm *.out
