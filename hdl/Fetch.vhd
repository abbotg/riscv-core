library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetch is
    port (
        Jaddr, Mdata:             in  std_ulogic_vector(31 downto 0);
        Address, Inst:            out std_ulogic_vector(31 downto 0);
        Clock, Jmp, Reset, Delay: in  std_ulogic;
        read:                     out std_ulogic
    );
end entity Fetch;


architecture Structure of Fetch is
    constant NOP: std_ulogic_vector(31 downto 0) := X"00_00_00_13";
    constant ZEROS: std_ulogic_vector(31 downto 0) := X"00_00_00_00";
    signal PCin: std_ulogic_vector(31 downto 0);
begin
    PC: entity work.Counter(Behavior)
        generic map (width => 32)
        port map (
            D => PCin,
            Q => Address,
            Clock => Clock,
            Enable => not (Jmp or Reset or Delay),
            Reset => Reset or Jmp,
            Inc => "11"
        );
    PCMux: entity work.Mux2(Behavior)
        generic map (width => 32)
        port map (
            In0 => Jaddr,
            In1 => ZEROS,
            Q => PCin,
            Sel => Reset
        );
    InstMux: entity work.Mux2(Behavior)
        generic map (width => 32)
        port map (
            In0 => Mdata,
            In1 => NOP,
            Q => Inst,
            Sel => Reset or Delay or Jmp
        );
    Read <= Reset nor Jmp;
end architecture Structure;


