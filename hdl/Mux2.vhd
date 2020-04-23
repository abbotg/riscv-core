library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2 is
    generic (
        width : natural range 1 to 64 := 8
    );
    port (
        In0, In1: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Sel: in std_ulogic
    );
end entity Mux2;

architecture Behavior of Mux2 is
    constant x: std_ulogic_vector(width - 1 downto 0) := (others => 'X');
begin
    process (In0, In1, Sel)
    begin
        if Sel = '0' then
            Q <= In0;
        elsif Sel = '1' then
            Q <= In1;
        else
            Q <= x;
        end if;
    end process;
end architecture Behavior;
