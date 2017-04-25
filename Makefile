.SUFFIXES:
.SUFFIXES: .o .asm .cpp .c .out

AS=nasm
ASFLAGS= -f elf -d ELF_TYPE
CFLAGS= -m32
CC=gcc


%.o : %.asm asm_io.o
	$(AS) $(ASFLAGS) $<

%.out : %.o
	$(CC) $(CFLAGS) -o $@ driver.c $< asm_io.o

.c.o:
	$(CC) -c $(CFLAGS) $*.c

asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) asm_io.asm


clean :
	rm *.o
	rm *.out
