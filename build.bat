@echo off

setlocal

chcp 65001 >nul


REM 编译16位启动扇区（纯二进制）
nasm -f bin boot\boot.asm -o boot.bin
if errorlevel 1 goto error

REM 编译64位启动汇编（elf64）
nasm -f elf64 src\long_mode.asm -o long_mode.o
if errorlevel 1 goto error

REM 编译Rust内核（假设已经安装并配置好x86_64-unknown-none目标）
@REM rustc --target x86_64-unknown-none -Z build-std=core --crate-type staticlib src\main.rs -o main.o
rustc --target x86_64-unknown-none --crate-type staticlib src\main.rs -o main.o
if errorlevel 1 goto error

REM 链接64位启动汇编和Rust内核
lld-link /entry:_start /subsystem:console /out:kernel.bin long_mode.o main.o /libpath:%LIBPATH%
if errorlevel 1 goto error

echo 编译成功，请运行 combine.ps1 合并镜像

pause
exit /b 0

:error
echo 编译失败！
pause
exit /b 1
