library ieee;
--library RV32I;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity Decoder is
    port (
        instruction:        in  word_t;
        Func:               out RV32I_Op;                        -- From RV32I_pkg
        RS1, RS2, RD:       out regaddr_t;   -- Register IDs
        RS1v, RS2v, RDv:    out std_ulogic;                      -- Valid indicators
        Immediate:          out word_t;  -- Immediate value
        InstructionType:    out InsType
    );
end entity Decoder;

architecture Behavior of Decoder is
begin

process (all) 
    procedure forward_rs1(valid: boolean) is begin
        RS1 <= rs1_of(instruction) when valid else (others => '0');
        RS1v <= '1' when valid else '0';
    end;
    procedure forward_rs2(valid: boolean) is begin
        RS2 <= rs2_of(instruction) when valid else (others => '0');
        RS2v <= '1' when valid else '0';
    end;
    procedure forward_rd(valid: boolean) is begin
        RD <= rd_of(instruction) when valid else (others => '0');
        RDv <= '1' when valid else '0';
    end;
    function immediate_I_type(instr: word_t) return word_t is 
        variable ret: word_t;
    begin
        -- Special function for generating immediates for I-types
        -- Because they're used for three different opcodes
        ret := (
            31 downto 11 => instr(31),
            10 downto 5  => instr(30 downto 25),
            4  downto 1  => instr(24 downto 21),
            0            => instr(20)
        );
        return ret;
    end;
begin
    if instruction(1 downto 0) /= "11" then
        -- zero instruction, as if CPU just reset
        -- simulate NOP: ADDI x0,x0,0
        InstructionType <= I;
        Func <= ADDI;
        RS1 <= ZERO_5;
        RS2 <= ZERO_5;
        RD <= ZERO_5;
        RS1v <= '1';
        RS2v <= '0';
        RDv <= '1';
        Immediate <= ZERO_32;
    else case opcode_of(instruction) is
        when RV32I_OP_LUI | RV32I_OP_AUIPC =>  -- U-type
            InstructionType <= U;
            forward_rs1(false);
            forward_rs2(false);
            forward_rd(true);
            Immediate <= (
                31 downto 12 => instruction(31 downto 12),
                11 downto 0  => '0'
            );
            Func <= LUI when opcode_of(instruction) = RV32I_OP_LUI else AUIPC;
        when RV32I_OP_JAL =>  -- J-type
            InstructionType <= UJ;
            forward_rs1(false);
            forward_rs2(false);
            forward_rd(true);
            Immediate <= (
                31 downto 20 => instruction(31),
                19 downto 12 => instruction(19 downto 12),
                11           => instruction(20),
                10 downto 5  => instruction(30 downto 25),
                4  downto 1  => instruction(24 downto 21),
                0            => '0'
            );
            Func <= JAL;
        when RV32I_OP_JALR =>
            InstructionType <= I;
            forward_rs1(true);
            forward_rs2(false);
            forward_rd(true);
            Immediate <= immediate_I_type(instruction);
            Func <= JALR;
        when RV32I_OP_BRANCH =>  -- B-type
            InstructionType <= SB;
            forward_rs1(true);
            forward_rs2(true);
            forward_rd(false);
            Immediate <= (
                31 downto 12 => instruction(31),
                11           => instruction(7),
                10 downto 5  => instruction(30 downto 25),
                4  downto 1  => instruction(11 downto 8),
                0            => '0'
            );
            with funct3_of(instruction) select
                Func <= BEQ  when RV32I_FN3_BRANCH_EQ,
                        BNE  when RV32I_FN3_BRANCH_NE,
                        BLT  when RV32I_FN3_BRANCH_LT,
                        BGE  when RV32I_FN3_BRANCH_GE,
                        BLTU when RV32I_FN3_BRANCH_LTU,
                        BGEU when others;
        when RV32I_OP_LOAD =>  -- I-type
            InstructionType <= I;
            forward_rs1(true);
            forward_rs2(false);
            forward_rd(true);
            Immediate <= immediate_I_type(instruction);
            with funct3_of(instruction) select
                Func <= LBU when RV32I_FN3_LOAD_BU,
                        LHU when RV32I_FN3_LOAD_HU,
                        LB  when RV32I_FN3_LOAD_B,
                        LH  when RV32I_FN3_LOAD_H,
                        LW  when others;
        when RV32I_OP_STORE =>  -- S-type
            InstructionType <= S;
            forward_rs1(true);
            forward_rs2(true);
            forward_rd(false);
            Immediate <= (
                31 downto 11 => instruction(31),
                10 downto 5  => instruction(30 downto 25),
                4  downto 1  => instruction(11 downto 8),
                0            => instruction(7)
            );
            with funct3_of(instruction) select
                Func <= SB when RV32I_FN3_STORE_B,
                        SH when RV32I_FN3_STORE_H,
                        SW when others;
        when RV32I_OP_ALU =>    -- R-type
            InstructionType <= R;
            forward_rs1(true);
            forward_rs2(true);
            forward_rd(true);
            Immediate <= (others => '0');
            case funct3_of(instruction) is        
                when RV32I_FN3_ALU_ADD =>  -- | RV32I_FN3_ALU_SUB
                    with funct7_of(instruction) select
                        Func <= SUBr when RV32I_FN7_ALU_SUB,
                                ADDr when others;
                when RV32I_FN3_ALU_SLT =>
                    Func <= SLTr;
                when RV32I_FN3_ALU_SLTU =>
                    Func <= SLTUr;
                when RV32I_FN3_ALU_XOR =>
                    Func <= XORr;
                when RV32I_FN3_ALU_OR =>
                    Func <= ORr;
                when RV32I_FN3_ALU_AND =>
                    Func <= ANDr;
                when RV32I_FN3_ALU_SLL =>
                    Func <= SLLr;
                when others => -- RV32I_FN3_ALU_SRL | RV32I_FN3_ALU_SRA
                    with funct7_of(instruction) select
                        Func <= SRAr when RV32I_FN7_ALU_SA,
                                SRLr when others;
            end case;
    when RV32I_OP_ALUI =>  -- I-type
        InstructionType <= I;
        forward_rs1(true);
        forward_rs2(false);
        forward_rd(true); 
        case funct3_of(instruction) is
            when RV32I_FN3_ALU_SLL | RV32I_FN3_ALU_SRL => -- | RV32I_FN3_ALU_SRA
                -- Special ting for immediate shifts
                Immediate <= (
                    31 downto 5 => '0',
                    4 downto 0  => instruction(24 downto 20)
                );
                if funct3_of(instruction) = RV32I_FN3_ALU_SLL then
                    Func <= SLLI;
                else
                    with funct7_of(instruction) select
                        Func <= SRAI when RV32I_FN7_ALU_SA,
                                SRLI when others;
                end if;
            when others => 
                Immediate <= immediate_I_type(instruction);
                with funct3_of(instruction) select
                    Func <= ADDI  when RV32I_FN3_ALU_ADD,
                            SLTI  when RV32I_FN3_ALU_SLT,
                            SLTIU when RV32I_FN3_ALU_SLTU,
                            XORI  when RV32I_FN3_ALU_XOR,
                            ORI   when RV32I_FN3_ALU_OR,
                            ANDI  when RV32I_FN3_ALU_AND,
                            SLLI  when others; -- RV32I_FN3_ALU_SLL
            end case;
    when others =>
        InstructionType <= UJ;
        Immediate <= (others => '0');
        forward_rs1(false);
        forward_rs2(false);
        forward_rd(false);
        Func <= BAD;
    end case;
    end if;
end process;
end architecture Behavior; 
