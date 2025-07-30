# # File: boot/run.sh
# # This script compiles the bootloader and runs it using QEMU.
# # Ensure you have QEMU installed and available in your PATH.
#!/bin/bash
nasm -f bin boot.asm -o boot.bin
# Check if nasm command was successful
qemu-system-x86_64 -drive format=raw,file=boot.bin
if [ $? -ne 0 ]; then
    echo "QEMU failed to start. Please check your QEMU installation."
    exit 1
fi