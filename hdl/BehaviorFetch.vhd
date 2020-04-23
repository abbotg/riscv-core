library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BehaviorFetch is
    port (
        Jaddr, Mdata:             in  std_ulogic_vector(31 downto 0);
        Address, Inst:            out std_ulogic_vector(31 downto 0);
        Clock, Jmp, Reset, Delay: in  std_ulogic;
        read:                     out std_ulogic
    );
end entity BehaviorFetch;


architecture Behavior of BehaviorFetch is  
    constant NOP: std_ulogic_vector(31 downto 0) := X"00_00_00_13";
    constant ZEROS: std_ulogic_vector(31 downto 0) := X"00_00_00_00";  
begin
    Inst <= NOP when (Delay or Jmp or Reset) else Mdata;
    Read <= Reset nor Jmp;
    process begin
        wait until rising_edge(Clock);
        Address <= 
            ZEROS       when Reset else
            std_ulogic_vector(unsigned(Address) + 4) when not (Jmp or Reset or Delay) else
            Jaddr       when Jmp;
    end process;
end architecture Behavior;
