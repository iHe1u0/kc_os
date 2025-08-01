# 生成boot.bin（16位引导扇区）
nasm -f bin boot/boot.asm -o boot.bin

# 编译64位启动汇编
nasm -f elf64 src/long_mode.asm -o long_mode.o

# 编译Rust内核为目标文件（这里假设你已配置好x86_64-unknown-none目标）
rustc --target x86_64-unknown-none -Z build-std=core --crate-type staticlib src/main.rs -o main.o

# 链接生成内核二进制 kernel.bin
ld.lld -T linker.ld long_mode.o main.o -o kernel.bin

# 合成启动镜像：boot.bin + kernel.bin（内核放在1MB处）
dd if=boot.bin of=os-image.bin bs=512 count=1 conv=notrunc
dd if=kernel.bin of=os-image.bin bs=512 seek=2048 conv=notrunc
