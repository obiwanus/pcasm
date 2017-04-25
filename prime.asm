%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
prompt          db      "Find primes up to: ", 0
; --------------------------------------------------------
segment .bss
limit   resd    1
guess   resd    1
; --------------------------------------------------------
segment .text
%ifdef ELF_TYPE
        global  asm_main
asm_main:
%else
        global  _asm_main
_asm_main:
%endif
        enter   0,0               ; setup routine
        pusha

; START --------------------------------------------------

        mov eax, prompt
        call print_string

        call read_int
        mov [limit], eax

        mov dword [guess], 5          ; initial guess

while_limit:
        mov eax, [guess]
        cmp eax, [limit]
        ja end_while_limit      ; while (guess <= limit)

        mov ebx, 3              ; factor is ebx

while_factor:
        mov eax, ebx            ; eax = factor
        mul ebx                 ; edx:eax = factor * factor
        jo error                ; if the result won't fit in eax
        cmp eax, [guess]
        jae end_while_factor    ; while factor * factor < guess

        mov edx, 0              ; guess is edx:eax
        mov eax, [guess]        ;
        div ebx                 ; edx = guess % factor
        cmp edx, 0
        je end_while_factor     ; while guess % factor != 0

        add ebx, 2              ; factor += 2

        jmp while_factor

end_while_factor:

        ; edx = guess % factor
        mov edx, 0              ; guess is edx:eax
        mov eax, [guess]
        div ebx
        cmp edx, 0              ; if (guess % factor != 0)
        je inc_guess
        mov eax, [guess]        ; guess is prime, print
        call print_int
        call print_nl
inc_guess:
        mov eax, [guess]
        add eax, 2
        mov [guess], eax

        jmp while_limit

end_while_limit:

        call print_nl

        jmp program_end

; END ----------------------------------------------------

error:
        mov eax, error_message
        call print_string
        call print_nl
        jmp program_end

program_end:

        popa
        mov     eax, 0            ; return back to C
        leave
        ret


