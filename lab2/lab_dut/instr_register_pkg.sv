/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg; //declara package
  timeunit 1ns/1ns;

  typedef enum logic [3:0] { //defineste un tip de data enumerare; mergea de la 2:0 -> utilizeaza mai buna de resurse
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t; //operatiile dut-ului

  typedef logic signed [31:0] operand_t;
  //daca nu specificam logic e unsigned
  typedef logic [4:0] address_t; //32 de adrese
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b; //adaug rezultat
  } instruction_t;

endpackage: instr_register_pkg
