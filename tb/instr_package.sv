`default_nettype none

package instr_package;
   // Enumerate all the opcodes
   typedef enum  bit [3:0] {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, NU, BRZ,BRN,BRO,BRA} opcode_t;

   localparam num_tests = 1000;

   typedef bit [7:0] u_byte_t; // Unsigned byte

   function void print_time_string(input string my_string);
      $display("%0t: %0s", $time, my_string);
   endfunction // print_time_string
               
class Instruction;
   rand opcode_t opcode;
   rand bit [2:0] target,first,second; // target, R1 and R2 of the opcode
   rand var signed [11:0] branch_offset;
   rand var signed [9:0] immediate; // Data returned by the 3rd memory access of a read
   static bit [7:0] count = 0; // Count to keep track of the memory address
   static string    opcode_str; // To be able to view the instruction in the viewer.
   bit [7:0]   address; // Starting memory address for the Instruction

   constraint no_NU {(opcode != NU);}
   constraint no_BRA_to_self { !((opcode==BRA) && (branch_offset<=0)) || (address == 254); }
   constraint no_target_to_PC { !(target==7); }
   constraint no_ST_in_PC {!((opcode==ST) && (first==7)); }
   constraint no_LD_from_PC {!((opcode==LD) && (first==7)); }
   constraint BR_in_range { ((address+branch_offset <= 255) && (address+branch_offset >= 0)); }
   constraint no_BR_1 {branch_offset != 1;}
   constraint Covered_in_static_target {!((opcode <= MOV) && (target == 0));}
   constraint Covered_in_static_first {!((opcode <= MOV) && (first == 1));}
   constraint Covered_in_static_target2 {!((opcode == iNOT || opcode == MOV) && (target == 5));}
   constraint Covered_in_static_first2 {!((opcode == iNOT || opcode == MOV) && (first == 2));}
   constraint Covered_in_static_second {!((opcode <= MOV) && (second == 2));}
   constraint Covered_ST {!((opcode==ST && first==1) || (opcode==ST && second==2));}
   constraint Covered_LD {!(opcode==LD && first==1);}
   function void print_instruction;
      // Print out the assembly instructions
      if (opcode<iNOT) 
        $display("%0h: %s R%0h,R%0h,R%0h", address, opcode,target,first,second);
      else if ((opcode == iNOT) || (opcode == MOV))
        $display("%0h: %s R%0h,R%0h", address, opcode, target, first);
      else if (opcode == LD)
        $display("%0h: %s R%0h,<R%0h>", address, opcode, target, first);
      else if (opcode == ST)
        $display("%0h: %s <R%0h>,R%0h", address, opcode, first, second);
      else if (opcode == LDI)
        $display("%0h: %s R%0h, #%0h", address,opcode, target, immediate);
      else
        $display("%0h: %s #%0h", address, opcode, branch_offset);
       
   endfunction // print_instruction

/*
   function string Assemble();
      string ret_value;
      if (opcode<iNOT) 
        $sformat("%0h: %s R%0h,R%0h,R%0h", address, opcode,target,first,second);
      else if ((opcode == iNOT) || (opcode == MOV))
        $sformat("%0h: %s R%0h,R%0h", address, opcode, target, first);
      else if (opcode == LD)
        $sformat("%0h: %s R%0h,<R%0h>", address, opcode, target, first);
      else if (opcode == ST)
        $sformat("%0h: %s <R%0h>,R%0h", address, opcode, first, second);
      else if (opcode == LDI)
        $sformat("%0h: %s R%0h, #%0h", address,opcode, target, immediate);
      else
        $sformat("%0h: %s #%0h", address, opcode, branch_offset);
      return ret_value;
   endfunction
*/
   
   function int Compile();
     bit [15:0] ret_value;
     ret_value=16'h7000; // NOP
      if (opcode<iNOT) begin
          ret_value[15:12]=opcode;
          ret_value[11:9]=target;
          ret_value[8:6]=first;
          ret_value[5:3]=second;
      end 
      else if ((opcode == iNOT) || (opcode == MOV)) begin
          ret_value[15:12]=opcode;
          ret_value[11:9]=target;
          ret_value[8:6]=first;
      end 
      else if (opcode == LD) begin
          ret_value[15:12]=opcode;
          ret_value[11:9]=target;
          ret_value[8:6]=first;
      end 
      else if (opcode == ST) begin
          ret_value[15:12]=opcode;
          ret_value[8:6]=first;
          ret_value[5:3]=second;
      end 
      else if (opcode == LDI) begin
          ret_value[15:12]=opcode;
          ret_value[11:9]=target;
          ret_value[8:0]=immediate;
      end 
      else begin
          ret_value[15:12]=opcode;
          ret_value[11:0]=branch_offset;
      end
      return ret_value;
   endfunction

   function new();
      address = count++;
   endfunction // new

   function void post_randomize;
      // Add directed tests here by overwriting instructions on selected target addresses
      if (address==255) begin
         opcode=BRA;
         branch_offset=12'b0;
      end
      if (address==1) begin
         opcode=iAND;
         target=0;
         first=1;
         second=2;
      end
      if (address==2) begin
         opcode=LD;
         target=0;
         first=1;
      end
      if (address==3) begin
         opcode=ST;
         first=1;
         second=2;
      end
      if (address==4) begin
         opcode=iNOT;
         target=0;
         first=1;
      end
      if (address==5) begin
         opcode=ADD;
         target=0;
         first=1;
         second=2;
      end
      if (address==6) begin
         opcode=iSUB;
         target=0;
         first=1;
         second=2;
      end
      if (address==7) begin
         opcode=iOR;
         target=0;
         first=1;
         second=2;
      end
      if (address==8) begin
         opcode=iXOR;
         target=0;
         first=1;
         second=2;
      end
      if (address==9) begin
         opcode=MOV;
         target=0;
         first=1;
      end
      if (address==10) begin
         opcode=LDI;
         target=0;
         immediate=114;
      end
      if (address==30) begin
         opcode=BRZ;
         branch_offset=-3;
      end
      if (address==100) begin
         opcode=BRN;
         branch_offset=-5;
      end
      if (address==50) begin
         opcode=BRO;
         branch_offset=-2;
      end
      if (address==12 || address==14) begin
         opcode=NOP;
      end
      if (address==120) begin
         opcode=LDI;
         immediate=-114;
      end
      if (address==114) begin
         opcode=iNOT;
         target=5;
         first=2;
      end
      if (address==214) begin
         opcode=MOV;
         target=5;
         first=2;
      end
      opcode_str = opcode.name;
   endfunction
   
endclass

// Typedef a mailbox of type Instruction
typedef mailbox #(Instruction) instr_mbox;

   // Handle to an instruction and old instruction
   Instruction instr;
   Instruction old_instr;

   covergroup CovOpcode;
      option.auto_bin_max = 256; // Don't restrict number of auto bins
      type_option.merge_instances = 1; // to show bins
      //All opcodes have been executed, except NU.
      all_opcodes_executed: coverpoint instr.opcode{
         bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, BRZ,BRN,BRO,BRA};}

      // The source for every opcode must have been R0..R7
      // First create a covergroup with opcodes that have a three fields
      opcodes_with_three: coverpoint instr.opcode{
         bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR};}
      first: coverpoint instr.first;
      second: coverpoint instr.second;
      target: coverpoint instr.target{
         bins targets[] = {[0:6]};
      }
      all_opcodes_executed_x_target: cross opcodes_with_three, target;
  
/*    
      // The destination for every opcode must have been R0..R7
      // first create a coverpoint with opcodes that have a dest field
      opcodes_with_target: coverpoint instr.opcode{
         bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,LD,LDI};}
      dest: coverpoint instr.dest;
      all_opcodes_executed_x_dest: cross  opcodes_with_dest, dest;
*/
      // Every instruction has been preceded and followed by every other instruction.
      all_opcodes_executed_old: coverpoint old_instr.opcode{
         bins old_opcodes[] = {ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, BRZ,BRN,BRO,BRA};}
      all_permutations_opcodes: cross  all_opcodes_executed_old, all_opcodes_executed;

      kinds_opcodes_executed: coverpoint instr.opcode{
         bins three = {ADD,iSUB,iAND,iOR,iXOR};
         bins two = {iNOT,MOV};
         bins nop = {NOP};
         bins RW = {LD,ST,LDI};
         bins branch = {BRZ,BRN,BRO,BRA};}

      kinds_opcodes_executed_old: coverpoint old_instr.opcode{
         bins three = {ADD,iSUB,iAND,iOR,iXOR};
         bins two = {iNOT,MOV};
         bins nop = {NOP};
         bins RW = {LD,ST,LDI};
         bins branch = {BRZ,BRN,BRO,BRA};}

      kinds_permutations_opcodes: cross  kinds_opcodes_executed_old, kinds_opcodes_executed;

      // For opcodes that have both a three fields, all permutations 
      // of the three fields have been executed.
      // First create a coverpoint with opcodes that have three fields
      opcodes_with_three_fields: coverpoint instr.opcode{
	 bins opcodes[] = {ADD,iSUB,iAND,iOR,iXOR};}
      all_opcodes_executed_x_three_fields: cross opcodes_with_three_fields, target, first, second;

      opcode_with_two_fields: coverpoint instr.opcode{
	 bins opcodes[] = {iNOT,MOV};}
      opcodes_two_field_x_first: cross opcode_with_two_fields, first;
      opcodes_two_field_x_target: cross opcode_with_two_fields, target;

      opcode_with_no_fields: coverpoint instr.opcode{
	 bins opcodes[] = {NOP};}

      branch_instructions: coverpoint instr.opcode{
	 bins opcodes[] = { BRZ,BRN,BRO,BRA};}

      branch_offset: coverpoint instr.branch_offset{
    bins positive = {[1:$]};
    bins negative = {[$:0]};
      }

      immediate_instructions: coverpoint instr.opcode{
         bins opcode = {LDI};
      }
      immediate: coverpoint instr.immediate{
         bins positive = {[1:$]};
         bins negative = {[$:0]};
      }

      non_immediate_instruction: coverpoint instr.opcode{
         bins opcode = {LD};
      }
      load_first: coverpoint instr.first{
         bins first[] = {[0:6]};
      }

      load_x_first: cross non_immediate_instruction, load_first;

      LDI_x_immediate: cross immediate_instructions, immediate;

      branch_x_offset: cross branch_instructions, branch_offset;


      load_instructions: coverpoint instr.opcode{
	 bins opcodes[] = { LD,LDI };}
      load_x_target: cross load_instructions, target;
      store_instructions: coverpoint instr.opcode{
	 bins opcodes[] = { ST };}
      store_first: coverpoint instr.first{
         bins first[] = {[0:6]};
      }
      store_x_first: cross store_instructions, store_first;
      store_x_second: cross store_instructions, second;

/*
      // All memory locations have been written.
      // First create a coverpoint with opcodes WR only
      // Then a coverpoint of memory_location
      opcodes_wr: coverpoint instr.opcode{
	 bins opcodes[] = {WR};}
      memory_loc: coverpoint instr.memory_location;
      all_mem_written: cross opcodes_wr, memory_loc;

      // All memory locations have been read by a RD instruction.
      opcodes_rd: coverpoint instr.opcode{
	 bins opcodes[] = {RD};}
      all_mem_read: cross opcodes_rd, memory_loc;
*/      
   endgroup // CovOpcode
   
  // Abstract driver callback class.
  virtual 	 class Driver_cbs;
      pure virtual task post_tx(Instruction cb_instr);
   endclass // Driver_cbs

   // Callback to collect coverage
class Driver_cbs_cover extends Driver_cbs;

    // Handle to covergroup
   CovOpcode cov;
   
   function new();
      this.cov = new();
      old_instr = new();
   endfunction // new
   
   
   virtual task post_tx(Instruction cb_instr);

      // Copy instruction passed to task to instr for collecting coverage.
      instr = cb_instr;
      
      cov.sample();
      old_instr = instr; // copy to old instruction
      	 if ((cov.all_opcodes_executed.get_coverage() == 100) && 
            (cov.all_opcodes_executed_x_three_fields.get_coverage() == 100) &&
            (cov.all_permutations_opcodes.get_coverage() == 100)) begin
	    print_time_string("All coverage requirements complete");
	    $finish;
	 end

   endtask // pre_tx
   
endclass // Driver_cbs

endpackage