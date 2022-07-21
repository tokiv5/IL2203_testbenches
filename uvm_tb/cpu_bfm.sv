interface cpu_bfm;
    //`define REG_LENGTH 16;
    //import uvm_pkg::*;
    import cpu_package::*;
    bit clk;
    bit reset;
    bit RW;
    wire done;
    bit [15:0] Din_tmp;
    wire [15:0] Din;
    wire [15:0] Dout;
    wire [15:0] Address;

    command_monitor command_monitor_h;

    assign Din = Din_tmp;

    task automatic reset_cpu();
        reset = 1;
        @(negedge clk);
        reset = 0;
    endtask : reset_cpu //automatic

    task automatic send_op(input opcode_t opcode, input bit[2:0] first, 
        input bit[2:0] second, input bit[2:0] target, input bit[11:0] branch_offset, input bit[9:0] immediate);
        do
            @(negedge clk);
        while(done == 0);
        if (opcode<iNOT) begin
            Din_tmp[15:12]=opcode;
            Din_tmp[11:9]=target;
            Din_tmp[8:6]=first;
            Din_tmp[5:3]=second;
        end 
        else if ((opcode == iNOT) || (opcode == MOV)) begin
            Din_tmp[15:12]=opcode;
            Din_tmp[11:9]=target;
            Din_tmp[8:6]=first;
        end 
        else if (opcode == LD) begin
            Din_tmp[15:12]=opcode;
            Din_tmp[11:9]=target;
            Din_tmp[8:6]=first;
        end 
        else if (opcode == ST) begin
            Din_tmp[15:12]=opcode;
            Din_tmp[8:6]=first;
            Din_tmp[5:3]=second;
        end 
        else if (opcode == LDI) begin
            Din_tmp[15:12]=opcode;
            Din_tmp[11:9]=target;
            Din_tmp[8:0]=immediate;
        end 
        else begin
            Din_tmp[15:12]=opcode;
            Din_tmp[11:0]=branch_offset;
        end
        
    endtask //automatic

    always @(posedge clk) begin : command_monitor
        if (done) begin
            command_monitor_h.ap.write(Din_tmp);
        end
    end : command_monitor

    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
   end
    
endinterface //cpu_bfm