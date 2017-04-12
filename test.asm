%include "asm_io.inc"

segment .data
prompt  db      "Please enter a number: ", 0
output  db      "The number of ON bits in the number you entered is ", 0

segment .bss
number  resd    1

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

; START

        mov eax, prompt
        call print_string

        call read_int           ; number is read into eax

        mov ecx, 32             ; loop counter
        mov ebx, 0              ; bit counter
        clc
count_loop:
        shr eax, 1              ; shift bit into carry
        adc ebx, 0
        loop count_loop

        call print_nl
        mov eax, output
        call print_string
        mov eax, ebx
        call print_int

        call print_nl

; END

        popa
        mov     eax, 0            ; return back to C
        leave
        ret


