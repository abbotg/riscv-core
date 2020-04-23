library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Increment is
    generic (
        width: natural range 1 to 64 := 8
    );
    port (
        D: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Inc: in std_ulogic_vector(1 downto 0)
    );
end entity Increment;

architecture Behavior of Increment is
begin
    process (D, Inc)
        variable sum: unsigned(width - 1 downto 0);
    begin
        case Inc is
            when "00" =>
                sum := unsigned(D);
            when "01" =>
                sum := unsigned(D) + 1;
            when "10" =>
                sum := unsigned(D) + 2;
            when "11" =>
                sum := unsigned(D) + 4;
            when others =>
                sum := unsigned(D);
        end case;
        Q <= std_ulogic_vector(sum);
    end process;
end architecture Behavior;
