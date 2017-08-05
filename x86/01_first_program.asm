%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0

input1          db      "Enter a number: ", 0
input2          db      "Enter another number: ", 0
plus            db      " + ", 0
equals          db      " = ", 0
; --------------------------------------------------------
segment .bss
number1         resd    1
number2         resd    1
; --------------------------------------------------------
segment .text
%ifdef ELF_TYPE
        global  asm_main
asm_main:
%else
        global  _asm_main
_asm_main:
%endif
        enter   0, 0                    ; setup routine
        pusha

; START --------------------------------------------------

        ; Read numbers
        mov eax, input1
        call print_string
        call read_int
        mov [number1], eax

        mov eax, input2
        call print_string
        call read_int
        mov [number2], eax

        ; Output their sum
        mov eax, [number1]
        call print_int
        mov eax, plus
        call print_string
        mov eax, [number2]
        call print_int
        mov eax, equals
        call print_string

        mov eax, [number1]
        add eax, [number2]
        call print_int

        call print_nl

; END ----------------------------------------------------

program_end:
        popa
        mov eax, 0                      ; return back to C
        leave
        ret

error:
        mov eax, error_message
        call print_string
        call print_nl
        jmp program_end

