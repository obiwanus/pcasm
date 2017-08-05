.SUFFIXES:
.SUFFIXES: .out .o .asm .cpp .c

AS=nasm
ASFLAGS= -f elf -d ELF_TYPE
CFLAGS= -m32
CC=gcc

asmfiles := $(shell find . -name "*.asm")
objfiles := $(patsubst %.asm, %.o, $(asmfiles))
outfiles := $(patsubst %.asm, %.out, $(asmfiles))

all: $(outfiles)

%.out : %.o
	$(CC) $(CFLAGS) -o $@ driver.c $< asm_io.o

%.o : %.asm asm_io.o
	$(AS) $(ASFLAGS) $<

.c.o:
	$(CC) -c $(CFLAGS) $*.c

asm_io.o : asm_io.asmlib
	$(AS) $(ASFLAGS) asm_io.asmlib

clean :
	rm -f *.o
	rm -f *.out
