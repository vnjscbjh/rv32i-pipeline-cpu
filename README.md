# RV32I Five-Stage Pipeline CPU

A 32-bit five-stage pipelined CPU based on the RISC-V RV32I ISA implemented in Verilog HDL.

## Features

- Five-stage pipeline architecture
- Hazard handling
  - Forwarding
  - Stall/Flush control
- Branch handling
- Address out-of-bound protection
- Functional verification with VCS and Verdi

## Architecture
![Architecture](image/Architecture.png)



## Directory Structure

rtl/    RTL source files
tb/     Testbench files
hex/    Instruction/data memory initialization files
sim/    Simulation scripts and generated files
image/  Architecture diagrams and waveform screenshots


## Tools

- Verilog HDL
- VCS
- Verdi
- Linux

## Author

Zhaowei Cai
