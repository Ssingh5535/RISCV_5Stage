#include <stdint.h>

// Memory-mapped I/O addresses (must match your VERILOG)
#define SWITCH_ADDR 0x10
#define LED_ADDR    0x14

// Pointers to the I/O registers
volatile uint32_t * const SW = (uint32_t *)SWITCH_ADDR;
volatile uint32_t * const LED = (uint32_t *)LED_ADDR;

// A little delay loop
static void delay(volatile int d) {
    while (d--) ;
}

int main() {
    // At reset, turn on LED3 (bit-3)
    *LED = (1 << 3);

    while (1) {
        uint32_t sw = *SW & 0xF;    // read switches[3:0]

        if (sw == 0x1) {
            // switch0→ do an add, light LED0
            *LED = (1 << 0);
            int a = 5;
            int b = 7;
            int c = a + b;
            // (we could store c somewhere if you like)
        }
        else if (sw == 0x2) {
            // switch1→ do a mul, light LED1
            *LED = (1 << 1);
            int a = 3;
            int b = 4;
            int c = a * b;
        }
        else {
            // no switch or other value→ turn off LED0/1
            *LED = 0;
        }

        // when computation is “done,” light LED4 (bit-4)
        *LED |= (1 << 4);

        // small delay then loop
        delay(50000);
    }

    // never reaches here
    return 0;
}

