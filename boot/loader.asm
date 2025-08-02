[BITS 16]
[ORG 0x8000]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    ; Enable A20 again (safe redundancy)
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:protected_mode

; GDT
gdt_start:
    dq 0x0000000000000000
    dq 0x00AF9A000000FFFF
    dq 0x00AF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

[BITS 32]
protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up paging and long mode (same as your original code)
    ; ...

    ; Jump to long mode
    jmp CODE_SEG:long_mode_entry

[BITS 64]
long_mode_entry:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov rsp, 0x80000
    call kernel_main

.loop:
    hlt
    jmp .loop

; You can include kernel_main here or link it later
kernel_main:
    mov si, msg
    call print_string
    ret

print_string:
    mov ah, 0x0E
.next_char:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .next_char
.done:
    ret

msg db "Hello from long mode!", 0
