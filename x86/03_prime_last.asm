%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
prompt          db      "Find last prime before: ", 0
; --------------------------------------------------------
segment .bss
limit           resd    1
guess           resd    1
last            resd    1
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

        mov eax, prompt
        call print_string
        call read_int
        mov [limit], eax                ; read limit

        mov dword [guess], 5                  ; initial guess
        mov dword [last], 0

while_limit:
        mov eax, [guess]
        cmp eax, [limit]
        jg end_while_limit              ; while (guess <= limit)

        mov ebx, 3                      ; factor is ebx (= 3)

while_factor:
        mov eax, ebx
        mul eax
        jo error                        ; if factor*factor won't fit in 32 bits
        cmp eax, [guess]
        jge end_while_factor            ; while ( factor * factor < guess )
        mov edx, 0
        mov eax, [guess]
        div ebx                         ; edx:eax / factor
        cmp edx, 0                      ; check the remainder
        je end_while_factor             ; while ( guess % factor != 0 )

        add ebx, 2                      ; factor += 2

        jmp while_factor
end_while_factor:

        mov edx, 0
        mov eax, [guess]
        div ebx
        cmp edx, 0
        je not_prime
        mov eax, [guess]
        mov [last], eax
not_prime:
        mov eax, [guess]
        add eax, 2
        mov [guess], eax

        jmp while_limit
end_while_limit:

        mov eax, [last]                 ; output last
        call print_int
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
        mov eax, 0                      ; return back to C
        leave
        ret


