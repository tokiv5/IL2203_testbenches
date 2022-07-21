`include "cpu_if.sv"
import instr_package::*;
module top;
   bit clk;
   always #5 clk = ~clk;

   logic Din[15:0];
   logic Dout[15:0];
   logic [15:0]Address;
   logic RW;
   logic reset;

   bit [7:0] ST_Count=0;

/*
   cpu_if cpuif(clk);
   memory mem (cpuif);

  memory mem (.clk(cpuif.clk),
	.reset(cpuif.reset),
	.Din(cpuif.cb.Din),
	.Dout(cpuif.cb.Dout),
	.Address(cpuif.cb.Address),
	.RW(cpuif.cb.RW));

   initial begin
      cpuif.reset = 1'b0;
      @(posedge clk);
      cpuif.reset=1'b1;
      @(posedge clk);
      cpuif.reset=1'b0;
   end;      
*/
   controller #(.N(16),.M(3)) dut 
	(.clk(clk),
           .reset(reset),
           .Din(Din),
           .Dout(Dout),
           .Address(Address),
           .RW(RW));

  //test test(cpu_bus);   

  memory mem (.clk(clk),
	.reset(reset),
	.Din(Dout),
	.Dout(Din),
	.Address(Address),
	.RW(RW));

   initial begin
      reset = 1'b0;
      @(posedge clk);
      reset=1'b1;
      @(posedge clk);
      reset=1'b0;
   end;      

   // Instruction properties
/*
   assert property (
      @(posedge clk) ((dut.Instr[15:12]==ST) && (dut.uPC==1)) |-> ##2 !(RW)
   );
*/
always @(posedge clk)
begin
   case (dut.IR[15:12])
      ST: if (dut.uPC==3) assert (!(RW)) begin
		   $display("%0T: ST works ok",$time);
		   ST_Count++;
	        end
		else
		   $display("%0t: ST instruction has an error",$time);
      default:$display("%0t: Not a ST instruction",$time);

      
   endcase
end 

endmodule

