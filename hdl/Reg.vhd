library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
    generic (
        width: natural range 1 to 64 := 8
    );
    port (
        D: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Clock, Enable, Reset: in std_ulogic
    );
end entity Reg;

architecture Behavior of Reg is
begin
    process (Clock, Reset)
    begin
        if rising_edge(Clock) and Enable = '1' then
            Q <= D;
        end if;
        if Reset = '1' then
            Q <= (others => '0');
        end if;
    end process;
end architecture Behavior;

