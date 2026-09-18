# 32-Bit Single-Cycle RISC-V (RV32I) Processor Core

![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog%20IEEE%201800--2012-blue)
![Simulator](https://img.shields.io/badge/Simulator-Icarus%20Verilog%20%2F%20vvp-orange)
![Architecture](https://img.shields.io/badge/Architecture-RV32I%20RISC--V-green)

A 32-bit single-cycle RISC-V CPU core designed in **SystemVerilog (IEEE 1800-2012)** from scratch. Built with a modular microarchitecture, hazard-free combinational wire-slicing, synchronized clocking, and self-checking testbenches.

---

## 🏗 Microarchitecture Overview

The datapath executes one full instruction per clock cycle using dedicated functional hardware blocks:

```text
               ┌────────────────────────────────────────────────────────┐
               │                  Instruction Memory                    │
               └───────────────────────────┬────────────────────────────┘
                                           │
                                           ▼
                                ┌─────────────────────┐
                                │ Instruction Decoder │
                                └──────────┬──────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         ▼                                 ▼                                 ▼
┌─────────────────┐             ┌─────────────────────┐            ┌───────────────────┐
│  Register File  │             │ Immediate Generator │            │   Control Unit    │
│  (32 x 32-bit)  │             └──────────┬──────────┘            └─────────┬─────────┘
└────────┬────────┘                        │                                 │
         │                                 ▼                                 │
         └──────────────────────► ┌─────────────────┐ ◄──────────────────────┘
                                  │ Arithmetic Unit │
                                  │     (ALU)       │
                                  └────────┬────────┘
                                           │
                                           ▼
                                  ┌─────────────────┐
                                  │   Data Memory   │
                                  └─────────────────┘
```

---

## 🔑 Key Architectural Features

* **Execution Pipeline:** Single-cycle execution model with dedicated Program Counter (`program_counter.sv`) increment logic ($PC + 4$).
* **Register File (`register_file.sv`):** 32 x 32-bit dual-read/single-write register array. Hardwired `x0` zeroing ensures reads on register 0 always yield `0x00000000`.
* **Instruction Decoder (`decoder.sv`):** Pure combinational wire slicing extracting `opcode`, `rd`, `rs1`, `rs2`, `funct3`, and `funct7` bitfields.
* **Immediate Generation (`immediate_generator.sv`):** Dynamic sign-extension for 12-bit I-type immediates up to 32 bits.
* **Control Unit (`control_unit.sv`):** Generates execution signals (`reg_write`, `alu_src`, `mem_write`, `mem_to_reg`, `branch`) across R-Type, I-Type, Load, Store, and Branch instructions.
* **Arithmetic Logic Unit (`alu.sv`):** Implements parameterized operations including `ADD`, `SUB`, `AND`, `OR`, `XOR`, and `SLT`.

---

## 📁 Repository Structure

```text
├── rtl/                        # Synthesizable SystemVerilog Source Files
│   ├── alu.sv                  # 32-bit Arithmetic Logic Unit
│   ├── control_unit.sv         # Main Decoder & Control Logic
│   ├── cpu.sv                  # Top-Level CPU Datapath Integration
│   ├── data_memory.sv          # RAM Data Storage
│   ├── decoder.sv              # Instruction Slicer
│   ├── immediate_generator.sv  # Sign-Extension Logic
│   ├── instruction_memory.sv   # ROM Instruction Storage
│   ├── program_counter.sv      # PC Register Logic
│   ├── register_file.sv        # 32-bit Clocked Register File
│   └── riscv_processor.sv      # Processor Wrapper Module
│
├── tb/                         # Self-Checking Testbenches
│   ├── alu_tb.sv
│   ├── cpu_tb.sv               # Top-Level CPU Verification Harness
│   ├── decoder_tb.sv
│   ├── immediate_generator_tb.sv
│   └── register_file_tb.sv
│
└── .gitignore
```

---

## 🛠 Toolchain & Build Verification

### Prerequisites
* **Icarus Verilog (`iverilog`)** — IEEE 1800-2012 standard compiler.
* **VVP Runtime Simulator (`vvp`)** — Simulation execution engine.

### Building & Running Full Processor Simulation

1. **Compile all RTL modules alongside the CPU testbench:**
   ```bash
   iverilog -g2012 -o cpu_sim.vvp rtl/*.sv tb/cpu_tb.sv
   ```

2. **Run the simulation runtime:**
   ```bash
   vvp cpu_sim.vvp
   ```

3. **Expected Simulation Output:**
   ```text
   PC = 0  | Instruction = 00a00293
   PC = 4  | Instruction = 01400313
   PC = 8  | Instruction = 006283b3
   
   ==============================
   CPU SIMULATION COMPLETE
   ==============================
   ```