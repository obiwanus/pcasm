%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
prompt          db      "Find primes up to: ", 0
repeat_prompt   db      "Please enter a number greater than 3", 0
; --------------------------------------------------------
segment .bss
limit           resd    1
guess           resd    1
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

read_number:
        mov eax, prompt
        call print_string
        call read_int
        mov [limit], eax

        ; validate input
        cmp eax, 3
        jg find_primes
        mov eax, repeat_prompt
        call print_string
        call print_nl
        jmp read_number

find_primes:
        ; print 2 and 3
        mov dword eax, 2
        call print_int
        call print_nl
        mov dword eax, 3
        call print_int
        call print_nl

        ; find other primes
        mov dword ebx, 5                ; ebx is guess
while_limit:
        cmp ebx, [limit]
        jg program_end

        mov ecx, 3                      ; ecx is factor
while_factor:
        mov eax, ecx
        mul eax                         ; edx:eax = eax * eax
        cmp eax, [guess]
        jge end_while_factor
        mov eax, [guess]
        mov dword edx, 0
        div ecx                         ; edx = guess % factor
        cmp edx, 0
        je end_while_factor
        add ecx, 2
        jmp while_factor

end_while_factor:
        mov eax, [guess]
        mov dword edx, 0
        div ecx                         ; edx = guess % factor
        cmp edx, 0
        je not_prime
        mov eax, [guess]
        call print_int
        call print_nl
not_prime:
        add dword [guess], 2
        jmp while_limit


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

