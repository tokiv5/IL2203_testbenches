class coverage extends uvm_subscriber #(bit[15:0]);
    `uvm_component_utils(coverage);
    opcode opcode_t;
    bit [2:0] target,first,second;
    bit [11:0] branch_offset;
    bit [9:0] immediate;

    function new();
        
    endfunction //new()
    covergroup CovOpcode;
        all_opcodes_executed: coverpoint opcode_t{
            bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, BRZ,BRN,BRO,BRA};}

        first: coverpoint first;
        second: coverpoint second;
        target: coverpoint target{
            bins targets[] = {[0:6]};
        }

        opcodes_with_three_fields: coverpoint opcode_t{
            bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR};}
        all_opcodes_executed_x_three_fields: cross opcodes_with_three_fields, target, first, second;

        branch_instructions: coverpoint opcode_t{
            bins opcodes[] = { BRZ,BRN,BRO,BRA};}

        branch_offset: coverpoint branch_offset{
            bins positive = {[1:$]};
            bins negative = {[$:0]};
        }

        immediate: coverpoint immediate{
            bins positive = {[1:$]};
            bins negative = {[$:0]};
        }
        
    endgroup // CovOpcode


    function new (string name, uvm_component parent);
        super.new(name, parent);
        CovOpcode = new();
    endfunction : new

    function void write(bit[15:0] t);
        opcode_t = t[15:12];
        first = t[8:6];
        second = t[5:3];
        target = t[11:9];
        branch_offset = t[11:0];
        immediate = t[8:0];
        CovOpcode.sample();
    endfunction : write
    
endclass //coverage extends uvm_component