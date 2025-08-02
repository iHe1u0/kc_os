# Assemble bootloader and loader
nasm -f bin boot.asm -o boot.bin
nasm -f bin loader.asm -o loader.bin

# Pad loader to 512-byte sector alignment
truncate -s 512 loader.bin

# Compile the Rust kernel
cd kernel
cargo build --target os.json -Z build-std=core --verbose
cd ..

# Copy Rust kernel to correct offset (e.g., sector 3 = 0x600)
dd if=kernel/target/os/debug/kernel of=kernel.bin bs=512 conv=notrunc

# Combine all into one image
cat boot.bin loader.bin kernel.bin > os.img

# Start QEMU with the OS image
# qemu-system-x86_64 -drive format=raw,file=os.img -serial stdio