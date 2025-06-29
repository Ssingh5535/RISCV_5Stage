# RISC-V 5-Stage Pipeline on PYNQ-Z2

> A fully synthesizable, memory-mapped RISC-V CPU implemented in Verilog, verified in simulation, and deployed on a PYNQ-Z2 FPGA. This repository walks through all stages—from RTL design and memory testing to block-design integration, hardware bring-up, and debug.

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Repository Layout](#repository-layout)  
3. [Prerequisites](#prerequisites)  
4. [1. RTL Design](#1-rtl-design)  
   - 1.1 [Verilog Modules](#11-verilog-modules)  
   - 1.2 [Pipeline Stages](#12-pipeline-stages)  
   - 1.3 [Memory-Mapped I/O](#13-memory-mapped-io)  
5. [2. Simulation & Memory Testing](#2-simulation--memory-testing)  
   - 2.1 [Instruction Memory Initialization](#21-instruction-memory-initialization)  
   - 2.2 [Data Memory Initialization](#22-data-memory-initialization)  
   - 2.3 [Testbench Structure](#23-testbench-structure)  
   - 2.4 [Waveform Inspection & Coverage](#24-waveform-inspection--coverage)  
6. [3. FPGA Integration (Block Diagram)](#3-fpga-integration-block-diagram)  
   - 3.1 [Zynq Processing System Reset & Clocking](#31-zynq-processing-system-reset--clocking)  
   - 3.2 [Custom IP: riscv5stage_core](#32-custom-ip-riscv5stage_core)  
   - 3.3 [BRAM Generators for IMEM & DMEM](#33-bram-generators-for-imem--dmem)  
   - 3.4 [Memory-Mapped Switches & LEDs](#34-memory-mapped-switches--leds)  
7. [4. Hardware Bring-Up on PYNQ-Z2](#4-hardware-bring-up-on-pynq-z2)  
   - 4.1 [Constraints & I/O Planning](#41-constraints--io-planning)  
   - 4.2 [Bitstream Generation & Programming](#42-bitstream-generation--programming)  
   - 4.3 [On-Board Verification with LEDs](#43-on-board-verification-with-leds)  
8. [5. Test & Debug](#5-test--debug)  
   - 5.1 [Internal Logic Analyzer (Chipscope/ILA)](#51-internal-logic-analyzer-chipscopeila)  
   - 5.2 [Common Issues & Resolutions](#52-common-issues--resolutions)  
   - 5.3 [Lessons Learned](#53-lessons-learned)  
9. [6. Final Hardware Report](#6-final-hardware-report)  
   - 6.1 [Power Consumption](#61-power-consumption)  
   - 6.2 [Clocking Summary](#62-clocking-summary)  
   - 6.3 [Resource Utilization & Timing](#63-resource-utilization--timing)  
   - 6.4 [Schematic & Block Diagram](#64-schematic--block-diagram)  
10. [License & Acknowledgments](#license--acknowledgments)  

---

## Project Overview

This project implements a 32-bit, 5-stage pipelined RISC-V CPU with:
- **Instruction Fetch** (IMEM via Block RAM)  
- **Decode & Register File**  
- **Execute** (ALU, forwarding, hazard detection)  
- **Memory Access** (DMEM via Block RAM)  
- **Write-Back**  
- **Memory-Mapped I/O** (switches & LEDs)  
- **Success Indicator** (LED ring after `DONE_PC`)

All stages are written in synthesizable Verilog, verified in ModelSim/Vivado simulator, then packaged as an IP core and integrated into a Vivado block design on the PYNQ-Z2.

---

## Repository Layout

```text
/
├── rtl/                     # Verilog RTL source
│   ├── IF_stage.v
│   ├── IF_ID.v
│   ├── ID_stage.v
│   ├── ID_EX.v
│   ├── EX_stage.v
│   ├── EX_MEM.v
│   ├── MEM_WB.v
│   ├── forwarding_unit.v
│   ├── hazard_unit.v
│   └── riscv5stage_top.v
├── tb/                      # Testbenches and memory hex files
│   ├── tb_riscv5stage.v
│   ├── imem.hex
│   └── dmem.hex
├── scripts/                 # COE conversion, simulation setup, etc.
├── hw/                      # Vivado block-design and constraints
│   ├── design_1.bd
│   ├── PYNQ-Z2_v1.0.xdc
│   └── riscvcore/           # Packaged IP for riscv5stage_core
├── docs/                    # Schematics, timing reports, screenshots
├── README.md                # ← you are here
└── LICENSE
