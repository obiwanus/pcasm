%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
sum             dd      0
; --------------------------------------------------------
segment .bss
input           resd    1
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

; Pseudo-code
; i = 1
; sum = 0
; while (get_int(i, &input), input != 0) {
;   sum += input
;   i++;
; }
; print_sum(sum)

; START --------------------------------------------------

        mov ecx, 1                      ; ecx is i

while_input:
        push ecx
        push input
        call get_int
        add esp, 8

        cmp dword [input], 0
        je end_while_input

        mov eax, [sum]
        add eax, [input]
        mov [sum], eax                  ; sum += input

        inc ecx

        jmp while_input

end_while_input:

        push dword [sum]
        call print_sum
        add esp, 4

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



; subprogram get_int -------------------------------------
; params:
; - number of input (at [ebp + 12])
; - address of word to store input into (at [ebp + 8])
; Note: eax and ebx values are destroyed

segment .data
prompt          db      ") Enter an integer (0 to quit): ", 0

segment .text
get_int:
        push ebp
        mov ebp, esp

        mov eax, [ebp + 12]
        call print_int

        mov eax, prompt
        call print_string

        call read_int
        mov ebx, [ebp + 8]
        mov [ebx], eax                  ; store input

        pop ebp
        ret



; subprogram print_sum -------------------------------------
; params:
; - sum to print (at [ebp + 8])
; Note: eax destroyed

segment .data
result          db      "The sum is ", 0

segment .text
print_sum:
        push ebp
        mov ebp, esp

        mov eax, result
        call print_string

        mov eax, [ebp + 8]
        call print_int

        call print_nl

        pop ebp
        ret

