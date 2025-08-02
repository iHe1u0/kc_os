[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Enable A20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; Load second-stage loader (1 sector from LBA 1 to 0x8000)
    mov ah, 0x02        ; INT 13h - Read sectors
    mov al, 0x01        ; Number of sectors
    mov ch, 0x00        ; Cylinder
    mov cl, 0x02        ; Sector (starts at 1)
    mov dh, 0x00        ; Head
    mov dl, 0x80        ; Drive (first HDD)
    mov bx, 0x8000      ; Buffer
    int 0x13
    jc disk_error

    jmp 0x0000:0x8000   ; Jump to second-stage loader

disk_error:
    mov si, error_msg
    call print_string
    jmp $

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

error_msg db "Disk read error!", 0

times 510 - ($ - $$) db 0
dw 0xAA55
