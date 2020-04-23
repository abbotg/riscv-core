LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;

PACKAGE RV32I IS
  TYPE InsType IS (R, I, S, SB, U, UJ);
  ATTRIBUTE enum_encoding : string;
  ATTRIBUTE enum_encoding OF InsType : type is "000 001 010 011 100 101";

-- The attribute "enum_encoding" tells the synthesis tool how to encode the
-- values of an enumerated type. In this case, the encoding is straight binary
    
  TYPE RV32I_Op IS (LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU,
                    LB, LH, LW, LBU, LHU, SB, SH, SW,
                    ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
                    ADDr, SUBr, SLLr, SLTr, SLTUr, XORr, SRLr, SRAr, ORr, ANDr,
                    NOP, BAD);

  ATTRIBUTE enum_encoding OF RV32I_Op : type is  "000000 000001 000010 000011 000100 000101 000110 000111 001000 001001 001010 001011 001100 001101 001110 001111 010000 010001 010010 010011 010100 010101 010110 010111 011000 011001 011010 011011 011100 011101 011110 011111 100000 100001 100010 100011 100100 100101 100110";  
  
  SUBTYPE Func_Name IS STRING(5 DOWNTO 1);                                     
  SUBTYPE Ins_Name IS STRING(2 DOWNTO 1);
    
  SUBTYPE RV32I_OpField IS std_ulogic_vector(4 DOWNTO 0);
  SUBTYPE RV32I_Funct3 IS std_ulogic_vector(2 DOWNTO 0);
  SUBTYPE RV32I_Funct7 IS std_ulogic_vector(6 DOWNTO 0);
  
  CONSTANT RV32I_OP_LUI : RV32I_OpField := "01101";
  CONSTANT RV32I_OP_AUIPC : RV32I_OpField := "00101";
  CONSTANT RV32I_OP_JAL : RV32I_OpField := "11011";
  CONSTANT RV32I_OP_JALR : RV32I_OpField := "11001";
  CONSTANT RV32I_OP_BRANCH : RV32I_OpField := "11000";
  CONSTANT RV32I_OP_LOAD : RV32I_OpField := "00000";
  CONSTANT RV32I_OP_STORE : RV32I_OpField := "01000";
  CONSTANT RV32I_OP_ALUI : RV32I_OpField := "00100";
  CONSTANT RV32I_OP_ALU : RV32I_OpField := "01100";
  
  CONSTANT RV32I_FN3_JALR : RV32I_Funct3 := "000";  
  
  CONSTANT RV32I_FN3_BRANCH_EQ : RV32I_Funct3 := "000";
  CONSTANT RV32I_FN3_BRANCH_NE : RV32I_Funct3 := "001";
  CONSTANT RV32I_FN3_BRANCH_LT : RV32I_Funct3 := "100";
  CONSTANT RV32I_FN3_BRANCH_GE : RV32I_Funct3 := "101";
  CONSTANT RV32I_FN3_BRANCH_LTU : RV32I_Funct3 := "110";
  CONSTANT RV32I_FN3_BRANCH_GEU : RV32I_Funct3 := "111";
  
  CONSTANT RV32I_FN3_LOAD_B : RV32I_Funct3 := "000";
  CONSTANT RV32I_FN3_LOAD_H : RV32I_Funct3 := "001";
  CONSTANT RV32I_FN3_LOAD_W : RV32I_Funct3 := "010";
  CONSTANT RV32I_FN3_LOAD_BU : RV32I_Funct3 := "100";
  CONSTANT RV32I_FN3_LOAD_HU : RV32I_Funct3 := "101";

  CONSTANT RV32I_FN3_STORE_B : RV32I_Funct3 := "000";
  CONSTANT RV32I_FN3_STORE_H : RV32I_Funct3 := "001";
  CONSTANT RV32I_FN3_STORE_W : RV32I_Funct3 := "010";
  
  CONSTANT RV32I_FN3_ALU_ADD : RV32I_Funct3 := "000";
  CONSTANT RV32I_FN3_ALU_SLT : RV32I_Funct3 := "010";
  CONSTANT RV32I_FN3_ALU_SLTU : RV32I_Funct3 := "011";
  CONSTANT RV32I_FN3_ALU_XOR : RV32I_Funct3 := "100";
  CONSTANT RV32I_FN3_ALU_OR : RV32I_Funct3 := "110";
  CONSTANT RV32I_FN3_ALU_AND : RV32I_Funct3 := "111";
  CONSTANT RV32I_FN3_ALU_SLL : RV32I_Funct3 := "001";
  CONSTANT RV32I_FN3_ALU_SRL : RV32I_Funct3 := "101";
  CONSTANT RV32I_FN3_ALU_SRA : RV32I_Funct3 := "101";
  CONSTANT RV32I_FN3_ALU_SUB : RV32I_Funct3 := "000";
  
  CONSTANT RV32I_FN7_ALU : RV32I_Funct7 := "0000000";
  CONSTANT RV32I_FN7_ALU_SA : RV32I_Funct7 := "0100000";
  CONSTANT RV32I_FN7_ALU_SUB : RV32I_Funct7 := "0100000";
  
  CONSTANT NOP_inst : std_ulogic_vector(31 DOWNTO 0) := "00000000000000000000000000010011";
  CONSTANT ZEROS_32 : std_ulogic_vector(31 DOWNTO 0) := (OTHERS => '0');
  
  CONSTANT XLEN : POSITIVE := 32;
  
  FUNCTION Ftype(Func : Func_Name) RETURN RV32I_Op;
  FUNCTION Itype(Ins : Ins_Name) RETURN InsType;
   

END RV32I;



PACKAGE BODY RV32I IS
  
  FUNCTION Ftype(Func : Func_Name) RETURN RV32I_Op IS
    VARIABLE ret : RV32I_Op;
  BEGIN
    CASE Func IS
      WHEN "LUI--" => ret := LUI;
      WHEN "AUIPC" => ret := AUIPC;
      WHEN "JAL--" => ret := JAL;
      WHEN "JALR-" => ret := JALR;
      WHEN "BEQ--" => ret := BEQ;
      WHEN "BNE--" => ret := BNE;
      WHEN "BLT--" => ret := BLT;
      WHEN "BGE--" => ret := BGE;
      WHEN "BLTU-" => ret := BLTU;
      WHEN "BGEU-" => ret := BGEU;
      WHEN "LB---" => ret := LB;
      WHEN "LH---" => ret := LH;
      WHEN "LW---" => ret := LW;
      WHEN "LBU--" => ret := LBU;
      WHEN "LHU--" => ret := LHU;
      WHEN "SB---" => ret := SB;
      WHEN "SH---" => ret := SH;
      WHEN "SW---" => ret := SW;
      WHEN "ADDI-" => ret := ADDI;
      WHEN "SLTI-" => ret := SLTI;
      WHEN "SLTIU" => ret := SLTIU;
      WHEN "XORI-" => ret := XORI;
      WHEN "ORI--" => ret := ORI;
      WHEN "ANDI-" => ret := ANDI;
      WHEN "SLLI-" => ret := SLLI;
      WHEN "SRLI-" => ret := SRLI;
      WHEN "SRAI-" => ret := SRAI;
      WHEN "ADDr-" => ret := ADDr;
      WHEN "SUBr-" => ret := SUBr;
      WHEN "SLLr-" => ret := SLLr;
      WHEN "SLTr-" => ret := SLTr;
      WHEN "SLTUr" => ret := SLTUr;
      WHEN "XORr-" => ret := XORr;
      WHEN "SRLr-" => ret := SRLr;
      WHEN "SRAr-" => ret := SRAr;
      WHEN "ORr--" => ret := ORr;
      WHEN "ANDr-" => ret := ANDr;     
      WHEN OTHERS => ret := BAD;
    END CASE;
    RETURN ret;
  END;

-- TYPE InsType IS (R, I, S, SB, U, UJ);
  FUNCTION Itype(Ins : Ins_Name) RETURN InsType IS
      VARIABLE ret: InsType;
  BEGIN
      WITH Ins SELECT ret :=
             R  WHEN "R-",
             I  WHEN "I-",
             S  WHEN "S-",
             SB WHEN "SB",
             U  WHEN "U-",
             UJ WHEN OTHERS;
      RETURN ret;
  END;

END RV32I;

