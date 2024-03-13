/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test //declaram modul
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  ); //portur; genereaza semnale pentru dut care calculeaza si trimiterezultatul catre test

  timeunit 1ns/1ns; //o ns cu pas de o ns

  int seed = 555;

  result_t rezultat_test;
  instruction_t  iw_reg_test [0:31];
  
  parameter WR_NR = 20;
  parameter RD_NR = 3;
  parameter READ_ORDER = 2;
  parameter WRITE_ORDER = 1;

  initial begin
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU DON'T      ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles //e test clock din top  
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin io 06.03.2024
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin io 06.03.2024


    for (int i=0; i<=RD_NR-1; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      case(READ_ORDER)
      0: @(posedge clk) read_pointer = i;
      1: @(posedge clk) read_pointer = (31 - i%32);
      2: @(posedge clk) read_pointer = $unsigned($random)%32;
      default: @(posedge clk) read_pointer = i;
      endcase
      @(negedge clk) print_results;
        check_result;
    end


    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU DON'T      ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end


  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    if(WRITE_ORDER == 0)
      begin
        static int temp = 0; //la al doilea call nu aloca iar memorie pentru aceata variabila. practic modificarea se vede in ambele functii
        write_pointer = temp++;
      end
    else if(WRITE_ORDER == 1) begin
        static int temp = 31; //la al doilea call nu aloca iar memorie pentru aceata variabila. practic modificarea se vede in ambele functii
        write_pointer = temp--;
       end
      else if(WRITE_ORDER == 2) begin 
        write_pointer = $unsigned($random)%32;
      end
      else begin //default este incremental
        static int temp = 0; //la al doilea call nu aloca iar memorie pentru aceata variabila. practic modificarea se vede in ambele functii
        write_pointer = temp++;
      end

    //operand_t op_A, op_B;
    //opcode_t opCode;
        
    //op_A     = $random(seed)%16;                 // between -15 and 15 - random returneaza o valoare pe 32 de biti
    //op_B     = $unsigned($random)%16;            // between 0 and 15
    //opCode   = opcode_t'($unsigned($random)%8);

    operand_a     <= $random(seed)%16;                 // between -15 and 15 - random returneaza o valoare pe 32 de biti
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
   
    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b, {64{1'b0}}}; // <= nebloncanta = blocanta

    $display("Inainte de print");
    $display("salvez  opcode = %0d (%s) %0t", iw_reg_test[write_pointer].opc, iw_reg_test[write_pointer].opc.name, $time);
    $display("salvez  operand_a = %0d %0t",   iw_reg_test[write_pointer].op_a, $time);
    $display("salvez  operand_b = %0d %0t\n", iw_reg_test[write_pointer].op_b, $time);
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s) %0t", opcode, opcode.name, $time);
    $display("  operand_a = %0d %0t",   operand_a, $time);
    $display("  operand_b = %0d %0t\n", operand_b, $time);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  rezultat = %0d", instruction_word.rezultat);
  endfunction: print_results

  function void check_result;

    if((iw_reg_test[read_pointer].op_a == instruction_word.op_a) && 
       (iw_reg_test[read_pointer].op_b == instruction_word.op_b) && 
       (iw_reg_test[read_pointer].opc == instruction_word.opc)) begin

      $display("DATELE COMPARATE SUNT ACELEASI, CALCULEZ REZULTATUL..."); 
      case (iw_reg_test[read_pointer].opc)
        ZERO: rezultat_test = {64{1'b0}};
        PASSA: rezultat_test = iw_reg_test[read_pointer].op_a;
        PASSB: rezultat_test = iw_reg_test[read_pointer].op_b;
        ADD: rezultat_test = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
        SUB: rezultat_test = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
        MULT: rezultat_test = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
        DIV: if (iw_reg_test[read_pointer].op_b == {64{1'b0}})
               rezultat_test = {64{1'b0}}; 
             else
               rezultat_test = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
        MOD: rezultat_test = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
        default: rezultat_test = {64{1'b0}};
      endcase

      if(rezultat_test === instruction_word.rezultat) begin
        $display("Rezultatul asteptat: %0d", rezultat_test);
        $display("REZULTATUL ESTE CEL ASTEPTAT\n");
      end
      else
        $display("REZULTATUL NU ESTE CEL ASTEPTAT\n");
    
    end
    else
        $display("DATELE COMPARATE NU SUNT ACELEASI.\n"); 
  endfunction: check_result

endmodule: instr_register_test
