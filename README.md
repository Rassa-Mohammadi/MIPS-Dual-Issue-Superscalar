# MIPS Superscalar Pipeline Processor

> A Logisim implementation of a MIPS Superscalar Pipeline Processor with comprehensive testbenches.

## Overview

This project implements a **superscalar pipelined MIPS processor** using **Logisim**. The processor is capable of issuing 2 instructions per cycle while handling pipeline hazards, forwarding, and control flow. The project also includes a collection of testbenches to verify the correctness of every component and the complete processor.

## Team Members

| Name | Student ID |
|------|------------------|
| Rassa Mohammadi | 403106657 |
| Yasaman Farrokhi | 403110409 |
| Parsa Shahmohammadi | 403110506 |
| Sobhan Behzadipour | 403107031 |

---

## Features

- Superscalar instruction issue
- Five-stage MIPS pipeline
- Hazard detection
- Data forwarding
- Branch handling
- Register file
- ALU
- Instruction memory
- Data memory
- Pipeline registers
- Comprehensive testbenches

---

## Supported Instructions

| Category | Instructions |
|-----------|--------------|
| Arithmetic | ADD, SUB, ADDI |
| Logical | AND, OR, XOR |
| Shift | SLL, SRL |
| Memory | LW, SW |
| Branch | BNE, BNEZ |
| Jump | J, JR |

---

## Pipeline

| Stage | Description |
|--------|-------------|
| IF | Instruction Fetch |
| ID | Instruction Decode |
| EX | Execute |
| MEM | Memory Access |
| WB | Write Back |

---

## Hazard Handling

- Forwarding
- Stall insertion
- **Dispatcher Unit**

---

## Prerequisites

Before running the project, make sure **Docker** is installed and running on your system, as the provided `judge.sh` script executes the tests inside a Docker container.

---

## Running the Project

### Scenario 1

```bash
./judge.sh CPU_dual.circ tb_scenario1.v
```

### Scenario 2

```bash
./judge.sh CPU_dual.circ tb_scenario2.v
```

### Scenario 3

```bash
# Single-path pipeline
./judge.sh CPU_single.circ tb_scenario3_single.v

# Dual-path pipeline
./judge.sh CPU_dual.circ tb_scenario3_dual.v
```

### Fibonacci

```bash
# Single-path pipeline
./judge.sh CPU_single.circ tb_fibo_single.v

# Dual-path pipeline
./judge.sh CPU_dual.circ tb_fibo_dual.v
```