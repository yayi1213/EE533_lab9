# EE533_lab9

## Description

This project implements an ARM CPU with GPU accelerator components for EE533 Lab 9. The system includes a pipelined ARM processor, a dot product accelerator, an accumulator using BRAM, a convertible FIFO for data transfer, and supporting modules.

## Files

- `ARM_CPU.v`: Main ARM CPU module with instruction and data memories, register file, and pipeline stages (ID, EX, MEM, WB).
- `GPU.v`: Dot product module (`dot4`) that computes the sum of four 16-bit multiplications.
- `GPU_accumulator_bram.v`: Accumulator module that performs iterative dot products using BRAM for data storage.
- `convertible_fifo.v`: Convertible FIFO with support for streaming input/output and processor MMIO access.
- `regfile64.v`: 64-bit register file with 4 registers, supporting read and write operations.
- `tb_Lab09_1.v`: Testbench for the ARM CPU, including memory initialization and simulation setup.

## How to Run

1. Ensure you have a Verilog simulator installed (e.g., Icarus Verilog or ModelSim).
2. Compile and run the testbench:
   ```
   iverilog -o tb_Lab09_1 tb_Lab09_1.v ARM_CPU.v GPU.v GPU_accumulator_bram.v convertible_fifo.v regfile64.v
   vvp tb_Lab09_1
   ```
   Or in ModelSim:
   ```
   vlib work
   vlog *.v
   vsim tb_ARM_CPU
   run -all
   ```
3. The testbench initializes memories and registers, loads instructions and data, and simulates the ARM CPU execution.

## Requirements

- Verilog simulator (Icarus Verilog, ModelSim, etc.)
- Basic understanding of ARM instruction set and Verilog HDL

## Notes

- The testbench assumes hierarchical access to internal memories (IM, DM, RF) for initialization.
- Waveform dumping is enabled for debugging with `wave.vcd`.