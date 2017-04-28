.SUFFIXES:
.SUFFIXES: .out .o .asm .cpp .c

AS=nasm
ASFLAGS= -f elf -d ELF_TYPE
CFLAGS= -m32
CC=gcc

%.out : %.o
	$(CC) $(CFLAGS) -o $@ driver.c $< asm_io.o

%.o : %.asm asm_io.o
	$(AS) $(ASFLAGS) $<

.c.o:
	$(CC) -c $(CFLAGS) $*.c

asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) asm_io.asm

clean :
	rm *.o
	rm *.out
