# Makefile

# 工具定义
NASM		= nasm
TRUNCATE	= truncate
DD		    = dd
CAT		    = cat
CARGO	    = cargo
QEMU		= qemu-system-x86_64

# 路径定义
BOOT_ASM	  = boot/boot.asm
LOADER_ASM    = boot/loader.asm
KERNEL_DIR    = kernel
KERNEL_TARGET = $(KERNEL_DIR)/target/os/debug/kernel
KERNEL_FILE   = target/os/debug/kernel

# 输出文件
OUTPUT_DIR  = output
BOOT_BIN	= $(OUTPUT_DIR)/boot.bin
LOADER_BIN  = $(OUTPUT_DIR)/loader.bin
KERNEL_BIN  = $(OUTPUT_DIR)/kernel.bin
OS_IMG	  = $(OUTPUT_DIR)/os.img

# 默认目标
.PHONY: all
all: $(OS_IMG)

# 创建输出目录
$(OUTPUT_DIR):
	@mkdir -p $@

# 编译 boot.asm
$(BOOT_BIN): $(BOOT_ASM) | $(OUTPUT_DIR)
	@$(NASM) -f bin $< -o $@

# 编译 loader.asm
$(LOADER_BIN): $(LOADER_ASM) | $(OUTPUT_DIR)
	@$(NASM) -f bin $< -o $@
	@$(TRUNCATE) -s 512 $@

# 编译 Rust 内核
$(KERNEL_TARGET):
	@$(CARGO) build --target os.json --manifest-path $(KERNEL_DIR)/Cargo.toml -Z build-std=core

# 拷贝内核到 kernel.bin
$(KERNEL_BIN): $(KERNEL_TARGET) | $(OUTPUT_DIR)
	@$(DD) if=$(KERNEL_FILE) of=$@ bs=512 conv=notrunc status=none

# 生成最终镜像
$(OS_IMG): $(BOOT_BIN) $(LOADER_BIN) $(KERNEL_BIN)
	@$(CAT) $^ > $@

# 启动 QEMU
.PHONY: run
run: $(OS_IMG)
	@$(QEMU) -drive format=raw,file=$(OS_IMG) -serial stdio

# 清理构建文件
.PHONY: clean
clean:
	@rm -rf $(OUTPUT_DIR)
	@cd $(KERNEL_DIR) && $(CARGO) clean
