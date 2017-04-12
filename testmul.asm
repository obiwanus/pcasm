%include "asm_io.inc"

segment .data
prompt  db      "Please enter a number: ", 0
output  db      "The number you entered is ", 0

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

        call read_int
        mov [number], eax

        call print_nl

        mov eax, output
        call print_string

        mov eax, [number]
        call print_int

        call print_nl

; END

        popa
        mov     eax, 0            ; return back to C
        leave
        ret


