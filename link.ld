OUTPUT_ARCH( x86_64 )
ENTRY(_start)

SECTIONS
{
  .text : {
    *(.text*)
  }
  .rodata : {
    *(.rodata*)
  }
  .data : {
    *(.data*)
  }
  .bss : {
    *(.bss*)
  }
}
