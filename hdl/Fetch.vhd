library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity Fetch is
    port (
        Jaddr, Mdata:             in  word_t;
        Address, Inst, PC:        out word_t; 
        Clock, Jmp, Reset,
        Stall1, Stall2, Stall3:   in  std_ulogic;
        read:                     out std_ulogic
    );
end entity Fetch;


architecture Structure of Fetch is
    signal PCin: word_t;
    signal Delay: std_ulogic;
begin
    ProgramCounter: entity work.Counter(Behavior)
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
            In1 => ZERO32,
            Q => PCin,
            Sel => Reset
        );
    InstMux: entity work.Mux2(Behavior)
        generic map (width => 32)
        port map (
            In0 => Mdata,
            In1 => NOP_inst,
            Q => Inst,
            Sel => Reset or Delay or Jmp
        );
    Read <= Reset nor Jmp;
    Delay <= Stall1 or Stall2 or Stall3;
end architecture Structure;


