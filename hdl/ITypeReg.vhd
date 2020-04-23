library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity ITypeReg is
    port (
        D: in  InsType;
        Q: out InsType;
        Clock, Enable, Reset: in std_ulogic
    );
end entity ITypeReg;

architecture Behavior of ITypeReg is
begin
    process (Clock, Reset)
    begin
        if rising_edge(Clock) and Enable = '1' then
            Q <= D;
        end if;
        if Reset = '1' then
            Q <= UJ;
        end if;
    end process;
end architecture Behavior;

