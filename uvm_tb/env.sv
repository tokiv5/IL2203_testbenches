class env extends uvm_env;
    `uvm_component_utils(env)
    generator generator_h;
    driver driver_h;
    coverage coverage_h;
    command_monitor command_monitor_h;
    uvm_tlm_fifo #(command_transaction) command_f;
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_f = new("command_f", this);
        command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
        coverage_h = coverage::type_id::create("coverage_h", this);
        generator_h = generator::type_id::create("generator_h",this);
        driver_h = driver::type_id::create("driver_h",this);        
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        driver_h.command_port.connect(command_f.get_export);
        generator_h.command_port.connect(command_f.put_export);  
        command_monitor_h.ap.connect(coverage_h.analysis_export);
    endfunction : connect_phase
endclass //env extends uvm_env