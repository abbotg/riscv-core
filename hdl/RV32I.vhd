library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package RV32I is
    type InsType is (R, I, S, SB, U, UJ);
    attribute enum_encoding: string;
    attribute enum_encoding OF InsType: type is "000 001 010 011 100 101";

-- The attribute "enum_encoding" tells the synthesis tool how to encode the
-- values of an enumerated type. In this case, the encoding is straight binary
    
    type RV32I_Op is (LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU,
                      LB, LH, LW, LBU, LHU, SB, SH, SW,
                      ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
                      ADDr, SUBr, SLLr, SLTr, SLTUr, XORr, SRLr, SRAr, ORr, ANDr,
                      NOP, BAD);

    attribute enum_encoding OF RV32I_Op: type is  "000000 000001 000010 000011 000100 000101 000110 000111 001000 001001 001010 001011 001100 001101 001110 001111 010000 010001 010010 010011 010100 010101 010110 010111 011000 011001 011010 011011 011100 011101 011110 011111 100000 100001 100010 100011 100100 100101 100110";  
  
    subtype Func_Name is string(5 downto 1);                                     
    subtype Ins_Name is string(2 downto 1);
      
    subtype RV32I_OpField is std_ulogic_vector(4 downto 0);
    subtype RV32I_Funct3 is std_ulogic_vector(2 downto 0);
    subtype RV32I_Funct7 is std_ulogic_vector(6 downto 0);
    
    constant RV32I_OP_LUI:          RV32I_OpField := "01101";
    constant RV32I_OP_AUIPC:        RV32I_OpField := "00101";
    constant RV32I_OP_JAL:          RV32I_OpField := "11011";
    constant RV32I_OP_JALR:         RV32I_OpField := "11001";
    constant RV32I_OP_BRANCH:       RV32I_OpField := "11000";
    constant RV32I_OP_LOAD:         RV32I_OpField := "00000";
    constant RV32I_OP_STORE:        RV32I_OpField := "01000";
    constant RV32I_OP_ALUI:         RV32I_OpField := "00100";
    constant RV32I_OP_ALU:          RV32I_OpField := "01100";
    
    constant RV32I_FN3_JALR:        RV32I_Funct3 := "000";  
    
    constant RV32I_FN3_BRANCH_EQ:   RV32I_Funct3 := "000";
    constant RV32I_FN3_BRANCH_NE:   RV32I_Funct3 := "001";
    constant RV32I_FN3_BRANCH_LT:   RV32I_Funct3 := "100";
    constant RV32I_FN3_BRANCH_GE:   RV32I_Funct3 := "101";
    constant RV32I_FN3_BRANCH_LTU:  RV32I_Funct3 := "110";
    constant RV32I_FN3_BRANCH_GEU:  RV32I_Funct3 := "111";
    
    constant RV32I_FN3_LOAD_B:      RV32I_Funct3 := "000";
    constant RV32I_FN3_LOAD_H:      RV32I_Funct3 := "001";
    constant RV32I_FN3_LOAD_W:      RV32I_Funct3 := "010";
    constant RV32I_FN3_LOAD_BU:     RV32I_Funct3 := "100";
    constant RV32I_FN3_LOAD_HU:     RV32I_Funct3 := "101";
 
    constant RV32I_FN3_STORE_B:     RV32I_Funct3 := "000";
    constant RV32I_FN3_STORE_H:     RV32I_Funct3 := "001";
    constant RV32I_FN3_STORE_W:     RV32I_Funct3 := "010";
    
    constant RV32I_FN3_ALU_ADD:     RV32I_Funct3 := "000";
    constant RV32I_FN3_ALU_SLT:     RV32I_Funct3 := "010";
    constant RV32I_FN3_ALU_SLTU:    RV32I_Funct3 := "011";
    constant RV32I_FN3_ALU_XOR:     RV32I_Funct3 := "100";
    constant RV32I_FN3_ALU_OR:      RV32I_Funct3 := "110";
    constant RV32I_FN3_ALU_AND:     RV32I_Funct3 := "111";
    constant RV32I_FN3_ALU_SLL:     RV32I_Funct3 := "001";
    constant RV32I_FN3_ALU_SRL:     RV32I_Funct3 := "101";
    constant RV32I_FN3_ALU_SRA:     RV32I_Funct3 := "101";
    constant RV32I_FN3_ALU_SUB:     RV32I_Funct3 := "000";
    
    constant RV32I_FN7_ALU:         RV32I_Funct7 := "0000000";
    constant RV32I_FN7_ALU_SA:      RV32I_Funct7 := "0100000";
    constant RV32I_FN7_ALU_SUB:     RV32I_Funct7 := "0100000";
    
    
    constant XLEN: positive := 32;
    
    function Ftype(Func: Func_Name) return RV32I_Op;
    function Itype(Ins: Ins_Name) return InsType;

    subtype word_t is std_ulogic_vector(31 downto 0);
    subtype regaddr_t is std_ulogic_vector(4 downto 0);

    constant ZERO32: word_t := (others => '0');
    constant ZERO_32: word_t := ZERO32;
    constant ZERO5: regaddr_t := (others => '0');
    constant ZERO_5: word_t := ZERO5;
    constant NOP_inst: word_t := "00000000000000000000000000010011";

    function opcode_of(instr: word_t) return std_ulogic_vector;
    function rd_of(instr: word_t) return regaddr_t;
    function rs1_of(instr: word_t) return regaddr_t;
    function rs2_of(instr: word_t) return regaddr_t;
    function funct3_of(instr: word_t) return std_ulogic_vector;
    function funct7_of(instr: word_t) return std_ulogic_vector;

    function is_load (f: RV32I_Op) return boolean;
    function is_store(f: RV32I_Op) return boolean;

end RV32I;


package body RV32I is
    function Ftype(Func: Func_Name) return RV32I_Op is
        variable ret: RV32I_Op;
    begin
        case Func is
            when "LUI--" => ret := LUI;
            when "AUIPC" => ret := AUIPC;
            when "JAL--" => ret := JAL;
            when "JALR-" => ret := JALR;
            when "BEQ--" => ret := BEQ;
            when "BNE--" => ret := BNE;
            when "BLT--" => ret := BLT;
            when "BGE--" => ret := BGE;
            when "BLTU-" => ret := BLTU;
            when "BGEU-" => ret := BGEU;
            when "LB---" => ret := LB;
            when "LH---" => ret := LH;
            when "LW---" => ret := LW;
            when "LBU--" => ret := LBU;
            when "LHU--" => ret := LHU;
            when "SB---" => ret := SB;
            when "SH---" => ret := SH;
            when "SW---" => ret := SW;
            when "ADDI-" => ret := ADDI;
            when "SLTI-" => ret := SLTI;
            when "SLTIU" => ret := SLTIU;
            when "XORI-" => ret := XORI;
            when "ORI--" => ret := ORI;
            when "ANDI-" => ret := ANDI;
            when "SLLI-" => ret := SLLI;
            when "SRLI-" => ret := SRLI;
            when "SRAI-" => ret := SRAI;
            when "ADDr-" => ret := ADDr;
            when "SUBr-" => ret := SUBr;
            when "SLLr-" => ret := SLLr;
            when "SLTr-" => ret := SLTr;
            when "SLTUr" => ret := SLTUr;
            when "XORr-" => ret := XORr;
            when "SRLr-" => ret := SRLr;
            when "SRAr-" => ret := SRAr;
            when "ORr--" => ret := ORr;
            when "ANDr-" => ret := ANDr;     
            when others => ret := BAD;
        end case;
        return ret;
    end function;
 
    -- type InsType is (R, I, S, SB, U, UJ);
    function Itype(Ins: Ins_Name) return InsType is
        variable ret: InsType;
    begin
        with Ins select ret :=
            R  when "R-",
            I  when "I-",
            S  when "S-",
            SB when "SB",
            U  when "U-",
            UJ when others;
        return ret;
    end function;

    function opcode_of(instr: word_t) return std_ulogic_vector is begin
        return instr(6 downto 2);
    end;
    function rd_of(instr: word_t) return regaddr_t is begin
        return instr(11 downto 7);
    end;
    function rs1_of(instr: word_t) return regaddr_t is begin
        return instr(19 downto 15);
    end;
    function rs2_of(instr: word_t) return regaddr_t is begin
        return instr(24 downto 20);
    end;
    function funct3_of(instr: word_t) return std_ulogic_vector is begin
        return instr(14 downto 12);
    end;
    function funct7_of(instr: word_t) return std_ulogic_vector is begin
        return instr(31 downto 25);
    end; 

    function is_load(f: RV32I_Op) return boolean is 
        variable ret: boolean;
    begin
        with f select ret :=
            true  when LB | LH | LW | LBU | LHU,
            false when others;
        return ret;
    end function;

    function is_store(f: RV32I_Op) return boolean is 
        variable ret: boolean;
    begin
        with f select ret :=
            true  when SB | SH | SW,
            false when others;
        return ret;
    end function;

end RV32I;

