@echo off

chcp 65001 >nul
setlocal enabledelayedexpansion

@REM cargo install bootimage

cargo bootimage
@REM cargo +nightly bootimage
qemu-system-x86_64 -drive format=raw,file=target/x86_64-kc_os/debug/bootimage-kernel.bin

