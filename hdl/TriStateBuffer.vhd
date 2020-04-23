library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TriStateBuffer is
    generic (
        width: natural range 1 to 64 := 8
    );
    port (
        A:    in  std_ulogic_vector(width - 1 downto 0);
        Q:    out std_ulogic_vector(width - 1 downto 0);
        E:    in  std_ulogic
    );
end entity TriStateBuffer;

architecture Behavior of TriStateBuffer is
begin

    Q <= A when E else (others => 'Z');

end architecture Behavior;
