# IITB RISC Pipelined Processor

## Overview
A fully functional RISC based processor design based in IITB RISC whose ISA is provided below. IITB RISC is a 8 - register, 16-bit architecture using 6 stage pipelined implementation. These stages are as follows, Instruction fetch, instruction decode, register read, execute, memory access, and write back. It also includes hazard mitigation techniques like data forwarding.
[Report](https://github.com/ShubhamBirange/iitb_risc_pipelined/blob/main/docs/report.pdf)

A multi cycle implementation of the same [here](https://github.com/ShubhamBirange/iitb_risc)

<p align="center">
  <img src="https://github.com/ShubhamBirange/iitb_risc_pipelined/blob/main/docs/isa.jpg?raw=true" alt="IITB RISC ISA" title="IITB RISC ISA" width="80%"/>
</p>
<p align="center">
    <em>IITB RISC ISA</em>
</p>

<p align="center">
  <img src="https://github.com/ShubhamBirange/iitb_risc_pipelined/blob/main/docs/dataflow.png?raw=true" alt="Dataflow" title="Dataflow" width="100%"/>
</p>
<p align="center">
    <em>Dataflow</em>
</p>
