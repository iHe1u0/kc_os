#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let vga = 0xb8000 as *mut u8;
    unsafe {
        *vga.offset(0) = b'H';
        *vga.offset(1) = 0x0f;
        *vga.offset(2) = b'i';
        *vga.offset(3) = 0x0f;
    }

    loop {}
}

/// Panic处理函数，裸机环境必须定义
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
