class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)
    rand opcode_t opcode;
    rand bit [2:0] target,first,second; // target, R1 and R2 of the opcode
    rand bit [11:0] branch_offset;
    rand bit [8:0] immediate;

    constraint no_NU {(opcode != NU);}
    constraint no_BRA_to_self { !((opcode==BRA) && (branch_offset<=0)); }
    constraint no_target_to_PC { !(target==7); }
    constraint no_ST_in_PC {!((opcode==ST) && (first==7)); }
    constraint no_LD_from_PC {!((opcode==LD) && (first==7)); }
    constraint no_BR_1 {branch_offset != 1;}
    function new(string name = "");
        super.new(name);
    endfunction //new()

    function void do_copy(uvm_object rhs);
        command_transaction copied_transaction_h;

        if(rhs == null) 
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
        
        super.do_copy(rhs); // copy all parent class data

    endfunction

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        command_transaction compared_transaction_h;
        bit   same;
        
        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                    "Tried to do comparison to a null pointer");
        
        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) && 
                (compared_transaction_h.opcode == opcode) &&
                (compared_transaction_h.target == target) &&
                (compared_transaction_h.first == first) &&
                (compared_transaction_h.second == second) &&
                (compared_transaction_h.branch_offset == branch_offset) &&
                (compared_transaction_h.immediate == immediate) ;
                
        return same;
    endfunction : do_compare

    function string convert2string();
        string s;
        s = $sformatf("first: %2h second: %2h target: %2h op: %s",
                            first, second, target, opcode.name());
        return s;
    endfunction : convert2string
endclass //command_transaction extends superClass