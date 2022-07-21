package cpu_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    typedef enum  bit [3:0] {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, NU, BRZ,BRN,BRO,BRA} opcode_t;

    `include "command_transaction.sv"
    `include "command_monitor.sv"
    `include "coverage.sv"
    `include "driver.sv"

    `include "generator.sv"
    `include "env.sv"
    `include "random_test.sv"

endpackage  :  cpu_package