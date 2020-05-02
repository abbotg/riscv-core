library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity FuncReg is
    port (
        D: in  RV32I_Op;
        Q: out RV32I_Op := NOP;
        Clock, Enable, Reset: in std_ulogic
    );
end entity FuncReg;

architecture Behavior of FuncReg is
begin
    process (Clock, Reset)
    begin
        if rising_edge(Clock) and Enable = '1' then
            Q <= D;
        end if;
        if Reset = '1' then
            Q <= BAD;
        end if;
    end process;
end architecture Behavior;

