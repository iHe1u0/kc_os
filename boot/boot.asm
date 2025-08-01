; boot.asm - 16位启动扇区，无extern，纯bin格式
; nasm -f bin boot.asm -o boot.bin

BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 加载GDT
    lgdt [gdt_descriptor]

    ; 进入保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 远跳转到保护模式代码
    jmp 0x08:pm_start

[BITS 32]
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; 这里简化不启动分页，直接跳1MB处的64位代码
    jmp 0x08:0x100000

; GDT定义
gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1
    dd gdt_start

times 510 - ($-$$) db 0
dw 0xAA55
