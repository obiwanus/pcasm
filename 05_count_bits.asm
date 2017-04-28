%include "asm_io.inc"

; #include <stdio.h>

; int count_bits(int num) {
;   unsigned int masks[] = {
;     0x55555555,
;     0x33333333,
;     0x0F0F0F0F,
;     0x00FF00FF,
;     0x0000FFFF,
;   };
;   for (int i = 0, shift = 1; i < 5; ++i, shift *= 2) {
;     unsigned int mask = masks[i];
;     num = (num & mask) + ((num >> shift) & mask);
;   }
;   return num;
; }

; int main() {
;   int num = 0xFFFF;
;   int bits = count_bits(num);
;   printf("Bits: %d\n", bits);
;   return 0;
; }

; --------------------------------------------------------
segment .data
error_message   db      "Error occurred", 0
enter_number    db      "Please enter a number: ", 0
print_result    db      "The number of bits is ", 0
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

        mov eax, enter_number
        call print_string
        call read_int

        push dword 0                    ; reserve space for return value
        push eax                        ; pass number to count_bits
        call count_bits
        pop ebx                         ; remove parameter
        pop ebx                         ; ebx = number of bits

        mov eax, print_result
        call print_string
        mov eax, ebx
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


; Subprogram count_bits
; params:
; - num : dword [ebp + 8]
; returns:
; - bit_count: dword [ebp + 12]
count_bits:
        push ebp
        mov ebp, esp
        sub esp, 20                     ; reserve 20 bytes for masks
        push eax
        push ecx

        mov dword [ebp - 4], 55555555h  ; masks
        mov dword [ebp - 8], 33333333h
        mov dword [ebp - 12], 0F0F0F0Fh
        mov dword [ebp - 16], 00FF00FFh
        mov dword [ebp - 20], 0000FFFFh

        xor ecx, ecx



        mov dword [ebp + 12], 5         ; save return value

        pop ecx
        pop eax
        mov esp, ebp
        pop ebp
        ret
; /count_bits
