class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)
    uvm_analysis_port #(bit[15:0]) ap;
    virtual tinyalu_bfm bfm;

    function new (string name, uvm_component parent);
        if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
	`uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        bfm.command_monitor_h = this;
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        ap  = new("ap",this);
    endfunction : build_phase

endclass //command_monitor extends uvm_component