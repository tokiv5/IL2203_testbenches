// create command transaction and send it to driver
class generator extends uvm_component;
    `uvm_component_utils (generator)

    uvm_put_port #(command_transaction) command_port;
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_transaction  command;

        phase.raise_objection(this);
        
        command = command_transaction::type_id::create("command");
        repeat (10) begin 
            assert(command.randomize());
            command_port.put(command);
        end
        #500;
        phase.drop_objection(this);
    endtask : run_phase
endclass //generator extends uvm_component