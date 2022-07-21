module top;
    import uvm_pkg::*;
    import cpu_package::*;

    cpu_bfm bfm();
    cpu DUT(.clk(bfm.clk), .reset(bfm.reset), .RW(bfm.RW), .done(bfm.done), .Din(bfm.Din), .Dout(bfm.Dout), .Address(bfm.Address));
initial begin
    uvm_config_db #(virtual cpu_bfm)::set(null, "*", "bfm", bfm);
    run_test();
    // bfm.reset_cpu();
    // bfm.send_op(iNOT, 0, 0, 2, 0, 0);
end
endmodule