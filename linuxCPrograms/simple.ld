/* place your program at address 0x0 */
SECTIONS
{
  . = 0x0;
  .text : {
    KEEP(*(.text*))
  }
  . = ALIGN(4);
  .rodata : {
    KEEP(*(.rodata*))
  }
  . = ALIGN(4);
  .data : {
    KEEP(*(.data*))
  }
  . = ALIGN(4);
  .bss : {
    KEEP(*(.bss*))
  }
}

