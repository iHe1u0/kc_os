#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn kernel_main() -> ! {
    let vga_buffer = 0xb8000 as *mut u8;
    let message = b"Hello, 64-bit Rust OS!";

    for (i, &byte) in message.iter().enumerate() {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = byte; // 字符
            *vga_buffer.offset(i as isize * 2 + 1) = 0x0f; // 颜色（白底黑字）
        }
    }

    loop {
        unsafe {
            core::arch::asm!("hlt");
        }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
