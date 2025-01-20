# Single cycle RISC-V Processor

This repository contains the Verilog code for a custom Single cycle RISC-V processor, designed and verified as part of my next big project. The processor supports a subset of RISC-V instructions and includes all major components of a basic processor pipeline. Below, you will find a detailed description of each module and its functionality, as well as an overview of the design and verification process.

---

## Table of Contents

1. [Design Overview](#design-overview)  
2. [Modules Description](#modules-description)  
    - [Program Counter](#program-counter)  
    - [PC + 4](#pc--4)  
    - [Instruction Memory](#instruction-memory)  
    - [Register File](#register-file)  
    - [Immediate Generator](#immediate-generator)  
    - [Control Unit](#control-unit)  
    - [ALU](#alu)  
    - [Data Memory](#data-memory)  
3. [Verification](#verification)  
4. [How to Use](#how-to-use)  

---

## Design Overview

The processor consists of several interconnected modules to perform basic operations such as arithmetic calculations, memory access, and branching. It is designed to execute RISC-V instructions efficiently and includes the following features:

- Support for R-type, I-type, L-type, S-type, and SB-type instructions.
- A modular design approach for scalability and ease of debugging.
- Initialization of instruction and data memory with test cases to validate the processor's functionality.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/DataPath.PNG?raw=true)

---

## Modules Description

### 1. Program Counter
The **Program Counter (PC)** module is responsible for maintaining the address of the current instruction being executed. It increments to point to the next instruction or updates based on branch instructions.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/PC.PNG?raw=true)

**Inputs**:  
- `clk`: Clock signal.  
- `reset`: Resets the PC to `0`.  
- `PC_in`: The next instruction address.

**Output**:  
- `PC_out`: The current instruction address.

---

### 2. PC + 4
The **PC + 4** module calculates the next instruction address by incrementing the current PC value by 4.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/PC+4.PNG?raw=true)

**Inputs**:  
- `fromPC`: Current PC value.

**Output**:  
- `PC_next`: PC value incremented by 4.

---

### 3. Instruction Memory
The **Instruction Memory** module stores the program instructions. It supports initialization with specific test cases to verify the processor's functionality.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/InstructionMem.PNG?raw=true)

**Inputs**:  
- `clk`: Clock signal.  
- `reset`: Resets the memory to `0`.  
- `read_address`: Address to fetch the instruction from.

**Output**:  
- `instruction_out`: The instruction at the given address.

Supported instructions include R-type (e.g., `add`, `sub`), I-type (`addi`, `ori`), L-type (`lw`), S-type (`sw`), and SB-type (`beq`).

---

### 4. Register File
The **Register File** stores and provides register values for computation. It supports read and write operations based on control signals.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/RegFile.PNG?raw=true)

**Inputs**:  
- `clk`, `reset`: Clock and reset signals.  
- `RegWrite`: Control signal to enable writing to registers.  
- `Rs1`, `Rs2`, `Rd`: Source and destination registers.  
- `Write_data`: Data to write into the destination register.

**Outputs**:  
- `Read_data1`, `Read_data2`: Data read from source registers.

---

### 5. Immediate Generator
The **Immediate Generator** decodes immediate values from instructions for I-type, S-type, and SB-type formats.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ImmGen0.PNG?raw=true)

**Inputs**:  
- `Opcode`: Instruction type.  
- `instruction`: The current instruction.

**Output**:  
- `ImmExt`: The sign-extended immediate value.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ImmGen1.PNG?raw=true)

---

### 6. Control Unit
The **Control Unit** generates control signals for the processor based on the opcode of the instruction. It handles operations such as branching, memory access, and ALU operations.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ControlUnit0.PNG?raw=true)

**Input**:  
- `instruction`: Opcode of the instruction.

**Outputs**:  
- Various control signals, including `branch`, `MemRead`, `MemWrite`, `ALUSrc`, and `ALUOp`.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ControlUnit.PNG?raw=true)

---

### 7. ALU (Arithmetic Logic Unit)
The **ALU** performs arithmetic and logical operations based on the `ALUOp` control signal. It supports operations such as addition, subtraction, AND, and OR.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ALU1.PNG?raw=true)

**Inputs**:  
- `input1`, `input2`: Operands.  
- `ALUOp`: Control signal determining the operation.

**Outputs**:  
- `result`: Result of the operation.  
- `Zero`: Flag indicating if the result is zero.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/ALU2.PNG?raw=true)

---

### 8. Data Memory
The **Data Memory** module handles memory operations, including load (`lw`) and store (`sw`) instructions.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/DataMem.PNG?raw=true)

**Inputs**:  
- `clk`, `reset`: Clock and reset signals.  
- `MemWrite`, `MemRead`: Control signals for memory access.  
- `address`: Address for memory access.  
- `write_data`: Data to be written to memory.

**Outputs**:  
- `read_data`: Data read from memory.

---

## Verification

### Test Strategy
The processor was verified using test programs stored in the **Instruction Memory**. Each program includes a mix of R-type, I-type, L-type, S-type, and SB-type instructions to validate the following:
- Correct instruction decoding and execution.
- Proper operation of the ALU, Control Unit, and Immediate Generator.
- Accurate memory read and write operations.
- Correct branching and program counter updates.

```
 //R-type
        I_mem[0] = 32'b00000000000000000000000000000000 ; // no operation
        I_mem[4] = 32'b0000000_11001_10000_000_01101_0110011 ; // add x13, x16, x25
        I_mem[8] = 32'b0100000_00011_01000_000_00101_0110011 ; // sub x5, x8, x3
        I_mem[12] = 32'b0000000_00011_00010_111_00001_0110011 ; // and x1, x2, x3
        I_mem[16] = 32'b0000000_00101_00011_110_00100_0110011 ; // or x4, x3, x5

    //I-type
        I_mem[20] = 32'b000000000011_10101_000_10110_0010011 ; // addi x22, x21, 3
        I_mem[24] = 32'b000000000001_01000_110_01001_0010011 ; // ori x9, x8, 1 *

    //L-type
        I_mem[28] = 32'b000000001111_00010_010_01000_0000011 ; // lw x8, 15(x5)
        I_mem[32] = 32'b000000000011_00011_010_01001_0000011 ; // lw x9, 3(x3)

    //S-type
        I_mem[36] = 32'b0000000_01111_00011_010_01100_0100011 ; // sw x15, 12(x5)
        I_mem[40] = 32'b0000000_01110_00110_010_01010_0100011 ; // sw x14, 10(x6)

    //SB-type
        I_mem[44] = 32'h00948663 ; // beq x9, x9, 12
```

The registers were also initialised with random values for the verification process :

```
initial begin
Registers[0] = 0;
Registers[1] = 3;
Registers[2] = 2;
Registers[3] = 12;
Registers[4] = 20;
 ...
Registers[31] = 10;
end
```

### Test Cases
1. **Arithmetic Operations**: Validated addition, subtraction, AND, and OR operations using R-type instructions.  
2. **Immediate Operations**: Verified addi and ori instructions.  
3. **Memory Operations**: Tested load (`lw`) and store (`sw`) instructions.  
4. **Branching**: Ensured correct branching behavior using beq instructions.

### Results
All test cases passed successfully, confirming the correctness of the processor's design.

![FuncComp](https://github.com/activif99/RISC-V_Processor/blob/main/documentation/images/Wave.jpeg?raw=true)

---

## How to Use

### Running the Code
1. Clone this repository.  
2. Use any Verilog simulator (e.g., ModelSim, Vivado, or Icarus Verilog) to simulate the code, I used ModelSim.
3. Start a simulation with `top_tb_PLS` in the file `P_initialised.v` as the top module.  
4. Observe the simulation results to verify processor behavior.


