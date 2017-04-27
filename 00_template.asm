%include "asm_io.inc"

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
; --------------------------------------------------------
segment .bss
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

