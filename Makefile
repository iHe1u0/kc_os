KERNEL_DIR = kernel
TARGET = x86_64_os.json
ISO = $(KERNEL_DIR)/target/$(TARGET)/debug/bootimage-kernel.bin

all: $(ISO)

$(ISO):
	cargo bootimage --manifest-path=$(KERNEL_DIR)/Cargo.toml --target=$(KERNEL_DIR)/$(TARGET)

run: all
	qemu-system-x86_64 -drive format=raw,file=$(ISO)

clean:
	cargo clean --manifest-path=$(KERNEL_DIR)/Cargo.toml
	rm -rf $(KERNEL_DIR)/target

.PHONY: all run clean
