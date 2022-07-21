// get command from generator and send to bfm
class driver extends uvm_component;
    `uvm_component_utils(driver)
    virtual cpu_bfm bfm;

    uvm_get_port #(command_transaction) command_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
        command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_transaction    command;
        bfm.reset_cpu();
        forever begin : command_loop
            command_port.get(command);
            bfm.send_op(command.opcode, command.first, command.second, command.target, command.branch_offset, command.immediate);
        end : command_loop
    endtask : run_phase
endclass //driver extends uvm_component