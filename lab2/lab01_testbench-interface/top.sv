/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top; 
  timeunit 1ns/1ns; //o ns cu pas de o ns

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables - declaram variabile
  logic clk; //determina automat wire sau reg
  logic test_clk;

  // interconnecting signals
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test ( //modul = tipul, instanta = obiect
    .clk(test_clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // clock oscillators
  initial begin              //structura care spune compilatorului ca trb sa se execute cod din timpul 0;
    clk <= 0;                //moment 0 simulare
    forever #5  clk = ~clk;  //la 5 unitati de timp = 5 ns; dupa 5 ns 1 dupa 5 ns 0 -> perioada 10ns
  end

  initial begin              //timp de simulare 0
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin         //astept 4ns   se executa o singura data
      #2ns test_clk = 1'b1;  // mereu la +2 se face 1 si la +8 se face 0
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
