library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity ALU is
    port (
        Func: in RV32I_Op;
        Left, Right: in word_t;
        ALUResult: out word_t
    );
end entity ALU;

architecture Behavior of ALU is
constant ONE: word_t := X"00_00_00_01";
begin

process (Func, Left, Right)
variable tmp: word_t;
begin
case Func is
    when JALR =>
        tmp := std_ulogic_vector(signed(Left) + signed(Right));
        ALUResult <= (
            31 downto 1 => tmp(31 downto 1),
            0 => '0'
        );
    when JAL | LB | LH | LW | LBU | LHU | SB | SH | SW | ADDI | ADDr =>
        ALUResult <= std_ulogic_vector(signed(Left) + signed(Right));
    when SUBr =>
        ALUResult <= std_ulogic_vector(signed(Left) - signed(Right));
    when BEQ =>
        ALUResult <= ONE when signed(Left) = signed(Right) else ZERO32;
    when BNE =>
        ALUResult <= ONE when signed(Left) /= signed(Right) else ZERO32;
    when BGE =>
        ALUResult <= ONE when signed(Left) >= signed(Right) else ZERO32;
    when BGEU =>
        ALUResult <= ONE when unsigned(Left) >= unsigned(Right) else ZERO32;
    when BLT | SLTI | SLTr =>
        ALUResult <= ONE when signed(Left) < signed(Right) else ZERO32;
    when BLTU | SLTIU | SLTUr =>
        ALUResult <= ONE when unsigned(Left) < unsigned(Right) else ZERO32;
    when XORI | XORr =>
        ALUResult <= Left xor Right;
    when ORI | ORr =>
        ALUResult <= Left or  Right;
    when ANDI | ANDr =>
        ALUResult <= Left and Right;
    when SLLI | SLLr =>
        ALUResult <= Left sll to_integer(unsigned(Right));
    when SRLI | SRLr =>
        ALUResult <= Left srl to_integer(unsigned(Right));
    when SRAI | SRAr =>
        ALUResult <= std_ulogic_vector(signed(Left) sra to_integer(unsigned(Right)));
    when AUIPC | LUI | NOP =>
        ALUResult <= ZERO32;
    when others =>
        ALUResult <= X"XX_XX_XX_XX";
end case;
end process;
end architecture Behavior;
