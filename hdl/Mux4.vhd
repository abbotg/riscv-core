library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Mux4 is
    generic (
        width : natural range 1 to 64 := 8
    );
    port (
        In0, In1, In2, In3: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Sel: in std_ulogic_vector(1 downto 0)
    );
end entity Mux4;

architecture Behavior of Mux4 is
begin
    with Sel select
        Q <=
            In0 when "00",
            In1 when "01",
            In2 when "10",
            In3 when "11",
            (others => 'X') when others;
end architecture Behavior;

