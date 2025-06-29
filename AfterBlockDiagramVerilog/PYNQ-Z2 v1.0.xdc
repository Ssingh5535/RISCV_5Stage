##---------------------------------------------------------------------------
## PYNQ-Z2 Top-Level Constraints for riscv5stage_top
##---------------------------------------------------------------------------

## ----- LEDs -----
## user LED[0] → PACKAGE_PIN R14
set_property PACKAGE_PIN R14 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]

## user LED[1] → PACKAGE_PIN P14
set_property PACKAGE_PIN P14 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]

## user LED[2] → PACKAGE_PIN N16
set_property PACKAGE_PIN N16 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]

## user LED[3] → PACKAGE_PIN M14
set_property PACKAGE_PIN M14 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]


## ----- Switches -----
## slide switch SW0 → PACKAGE_PIN M20
set_property PACKAGE_PIN M20 [get_ports {switches[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]

## slide switch SW1 → PACKAGE_PIN M19
set_property PACKAGE_PIN M19 [get_ports {switches[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]

## slide switch SW2 → PACKAGE_PIN L20
set_property PACKAGE_PIN L20 [get_ports {switches[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]

## slide switch SW3 → PACKAGE_PIN L19
set_property PACKAGE_PIN L19 [get_ports {switches[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]


### - no PS-driven clocks or resets need PL-pins here -
### Clock signal (sysclk → top clk)
#set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]
#create_clock -period 8.000 -name sys_clk_pin -add [get_ports clk]

## reset on BTN0 (D19)
set_property PACKAGE_PIN D19 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PULLTYPE PULLDOWN [get_ports rst]

## Debug LED (L15 → debug_led)
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports debug_led]


#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 20 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {u_IF/IF_PC[12]} {u_IF/IF_PC[13]} {u_IF/IF_PC[14]} {u_IF/IF_PC[15]} {u_IF/IF_PC[16]} {u_IF/IF_PC[17]} {u_IF/IF_PC[18]} {u_IF/IF_PC[19]} {u_IF/IF_PC[20]} {u_IF/IF_PC[21]} {u_IF/IF_PC[22]} {u_IF/IF_PC[23]} {u_IF/IF_PC[24]} {u_IF/IF_PC[25]} {u_IF/IF_PC[26]} {u_IF/IF_PC[27]} {u_IF/IF_PC[28]} {u_IF/IF_PC[29]} {u_IF/IF_PC[30]} {u_IF/IF_PC[31]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
#set_property port_width 4 [get_debug_ports u_ila_0/probe1]
#connect_debug_port u_ila_0/probe1 [get_nets [list {io_leds_reg[0]} {io_leds_reg[1]} {io_leds_reg[2]} {io_leds_reg[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
#set_property port_width 4 [get_debug_ports u_ila_0/probe2]
#connect_debug_port u_ila_0/probe2 [get_nets [list {led_ring[0]} {led_ring[1]} {led_ring[2]} {led_ring[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
#set_property port_width 1 [get_debug_ports u_ila_0/probe3]
#connect_debug_port u_ila_0/probe3 [get_nets [list program_done]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]



connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/riscv5stage_core_0/inst/led_ring[0]} {design_1_i/riscv5stage_core_0/inst/led_ring[1]} {design_1_i/riscv5stage_core_0/inst/led_ring[2]} {design_1_i/riscv5stage_core_0/inst/led_ring[3]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[12]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[13]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[14]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[15]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[16]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[17]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[18]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[19]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[20]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[21]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[22]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[23]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[24]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[25]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[26]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[27]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[28]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[29]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[30]} {design_1_i/riscv5stage_core_0/inst/u_IF/IF_PC[31]}]]
connect_debug_port u_ila_0/probe4 [get_nets [list design_1_i/riscv5stage_core_0/inst/program_done]]
connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/riscv5stage_core_0/inst/tick_step_reg_n_0]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {leds_OBUF[0]} {leds_OBUF[1]} {leds_OBUF[2]} {leds_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/processing_system7_0/inst/FCLK_CLK_unbuffered[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 20 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[12]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[13]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[14]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[15]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[16]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[17]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[18]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[19]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[20]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[21]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[22]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[23]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[24]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[25]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[26]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[27]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[28]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[29]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[30]} {design_1_i/riscv5stage_Core_0/inst/u_IF/IF_PC[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/riscv5stage_Core_0/inst/led_ring[0]} {design_1_i/riscv5stage_Core_0/inst/led_ring[1]} {design_1_i/riscv5stage_Core_0/inst/led_ring[2]} {design_1_i/riscv5stage_Core_0/inst/led_ring[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list rst_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/riscv5stage_Core_0/inst/program_done]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK0]
