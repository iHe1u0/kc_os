; boot.asm - 64位操作系统启动引导程序
; 编译：nasm -f bin boot.asm -o boot.bin

BITS 16
ORG 0x7C00         ; BIOS 加载 bootloader 的地址

start:
    cli             ; 关闭中断
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; 设置堆栈指针

    ; 打印字符 (可选，用于调试)
    mov si, boot_msg
.print_char:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print_char
.done:

    ; 加载GDT
    lgdt [gdt_descriptor]

    ; 启用A20线
    call enable_a20

    ; 打开保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 跳转到32位保护模式入口（使用段寄存器更新）
    jmp CODE_SEG:init_pm32

; -------------------------------
; 32-bit Protected Mode (临时)
; -------------------------------
[BITS 32]
init_pm32:
    ; 设置段寄存器
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 开启分页，启用Long Mode
    call setup_paging

    ; 进入 Long Mode
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; 跳转到 Long Mode
    jmp 08h:long_mode_start

; -------------------------------
; 64-bit Long Mode
; -------------------------------
[BITS 64]
long_mode_start:
    ; 可以直接跳转或加载参数，不用设置 ds/ss
    mov rsi, 0x100000
    jmp rsi

; -------------------------------
; 打印信息
; -------------------------------
boot_msg db "Booting x86_64 OS...", 0

; -------------------------------
; GDT 定义
; -------------------------------
gdt_start:
    dq 0                           ; null
    dq 0x00af9a000000ffff          ; code segment
    dq 0x00af92000000ffff          ; data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

; -------------------------------
; 启用 A20 的简单方式
; -------------------------------
enable_a20:
    in al, 0x92
    or al, 00000010b
    out 0x92, al
    ret

; -------------------------------
; 设置分页，启用长模式
; （简单的1:1映射）
; -------------------------------
setup_paging:
    [BITS 32]                 ; 强制为32位代码

    ; 使用1级页表 (仅映射 0~2MB)
    ; 页表起始地址：0x9000
    mov eax, 0x00000003      ; Present + Write
    mov dword [0x9000], eax  ; PML4[0]
    mov dword [0xA000], eax  ; PDPT[0]
    mov eax, 0x00000083      ; Present + Write + 1GB page
    mov dword [0xB000], eax  ; PD[0]

    ; 设置 CR3 = PML4 地址
    mov eax, 0x9000
    mov cr3, eax

    ; 启用 PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; 启用 Long Mode 和分页
    mov ecx, 0xC0000080      ; IA32_EFER MSR
    rdmsr
    or eax, 1 << 8           ; Long mode enable
    wrmsr

    ret

; -------------------------------
; 填满512字节
; -------------------------------
times 510-($-$$) db 0
dw 0xAA55     ; 启动签名
