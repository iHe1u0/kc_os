// src/main.rs
#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;

#[no_mangle]
pub extern "C" fn kernel_main() -> ! {
    unsafe {
        *VGA_BUFFER = b'H';
        *VGA_BUFFER.add(1) = 0x0f; // 白色前景，黑色背景
    }
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    kernel_main();
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

//
#[no_mangle]
pub unsafe extern "C" fn memcpy(dest: *mut u8, src: *const u8, n: usize) -> *mut u8 {
    let mut i = 0;
    while i < n {
        *dest.add(i) = *src.add(i);
        i += 1;
    }
    dest
}
#[no_mangle]
pub unsafe extern "C" fn memset(s: *mut u8, c: i32, n: usize) -> *mut u8 {
    let mut i = 0;
    while i < n {
        *s.add(i) = c as u8;
        i += 1;
    }
    s
}
