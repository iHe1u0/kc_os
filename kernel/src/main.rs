#![no_std]
#![no_main]

use bootloader::{entry_point, BootInfo};
use core::panic::PanicInfo;
use volatile::Volatile;

entry_point!(kernel_main);

fn kernel_main(_boot_info: &'static BootInfo) -> ! {
    let vga_buffer = 0xb8000 as *mut Volatile<u16>;

    for (i, byte) in b"Hello, OS in Rust!".iter().enumerate() {
        unsafe {
            (*vga_buffer.add(i)).write(0x0f00 | *byte as u16);
        }
    }

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
