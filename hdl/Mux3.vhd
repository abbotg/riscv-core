library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Mux3 is
    generic (
        width : natural range 1 to 64 := 8
    );
    port (
        In0, In1, In2: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Sel: in std_ulogic_vector(1 downto 0)
    );
end entity Mux3;

architecture Behavior of Mux3 is
begin
    process (In0, In1, In2, Sel)
    begin
        with Sel select
            Q <=
                In0 when "00",
                In1 when "01",
                In2 when "10",
                (others => 'X') when others;
    end process;
end architecture Behavior;

