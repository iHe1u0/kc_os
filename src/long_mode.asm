; long_mode.asm - 64位启动汇编，准备环境，跳Rust
; nasm -f elf64 src/long_mode.asm -o long_mode.o

BITS 64
global _start

extern kernel_main

section .text
_start:
    ; 设置段寄存器为0
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; 调用 Rust 内核入口
    call kernel_main

.hang:
    hlt
    jmp .hang
