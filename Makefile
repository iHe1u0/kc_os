# Makefile

# 工具和文件定义
NASM = nasm
TRUNCATE = truncate
DD = dd
CAT = cat
CARGO = cargo
QEMU = qemu-system-x86_64

BOOT_ASM = boot.asm
LOADER_ASM = loader.asm
KERNEL_DIR = kernel
KERNEL_TARGET = kernel/target/os/debug/kernel

BOOT_BIN = boot.bin
LOADER_BIN = loader.bin
KERNEL_BIN = kernel.bin
OS_IMG = os.img

# 目标：默认all，生成os.img
all: os.img

# 组装boot.asm，生成boot.bin
$(BOOT_BIN): $(BOOT_ASM)
	$(NASM) -f bin $< -o $@

# 组装loader.asm，生成loader.bin
$(LOADER_BIN): $(LOADER_ASM)
	$(NASM) -f bin $< -o $@
	$(TRUNCATE) -s 512 $@

# 编译Rust内核
$(KERNEL_TARGET):
	$(CARGO) build --target os.json --manifest-path $(KERNEL_DIR)/Cargo.toml -Z build-std=core

# 拷贝Rust内核二进制到kernel.bin（偏移位置为0x600，即第3扇区）
$(KERNEL_BIN): $(KERNEL_TARGET)
	$(DD) if=target/os/debug/kernel of=$(KERNEL_BIN) bs=512 conv=notrunc

# 组合成最终镜像
os.img: $(BOOT_BIN) $(LOADER_BIN) $(KERNEL_BIN)
	$(CAT) $(BOOT_BIN) $(LOADER_BIN) $(KERNEL_BIN) > $@

# 启动QEMU（你需要自己执行此命令或者写个启动命令）
.PHONY: run
run: os.img
	$(QEMU) -drive format=raw,file=$(OS_IMG) -serial stdio

# 清理生成文件
.PHONY: clean
clean:
	rm -f $(BOOT_BIN) $(LOADER_BIN) $(KERNEL_BIN) $(OS_IMG)
	cd $(KERNEL_DIR) && $(CARGO) clean
