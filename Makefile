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

asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) -d ELF_TYPE asm_io.asm

first: driver.o first.o asm_io.o
	$(CC) $(CFLAGS) -ofirst.out driver.o first.o asm_io.o

first.o: asm_io.inc first.asm

testmul: driver.o testmul.o asm_io.o
	$(CC) $(CFLAGS) -otestmul.out driver.o testmul.o asm_io.o

testmul.o: asm_io.inc testmul.asm

prime: driver.o prime.o asm_io.o
	$(CC) $(CFLAGS) -oprime.out driver.o prime.o asm_io.o

prime.o: asm_io.inc prime.asm



clean :
	rm *.o
	rm *.out
