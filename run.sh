!/bin/bash

cargo build -Z build-std=core,alloc --target x86_64-kc_os.json
# rustc +nightly -Z unstable-options --print target-spec-json --target x86_64-unknown-none

# cargo bootimage
# cargo run --target x86_64-unknown-none.json
qemu-system-x86_64 -drive format=raw,file=target/x86_64-kc_os/debug/kc_os -serial stdio -smp 4
# qemu-system-x86_64 -drive format=raw,file=target/x86_64-kc_os/debug/bootimage-kc_os.bin -serial stdio -display none
