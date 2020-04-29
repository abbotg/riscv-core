library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Semaphore is
    generic ( bits: natural range 1 to 64 := 2 );
    port (
        Up, Down, Clock: in  std_ulogic; -- Up and down operations
        Locked, IsZero:    out std_ulogic  -- State: 1=Locked, 0=Free
    );
end entity Semaphore;

architecture Behavior of Semaphore is
    constant ZERO: std_ulogic_vector(bits - 1 downto 0) := (others => '0');
    constant ONE: std_ulogic_vector(bits - 1 downto 0) := (0 => '1', others => '0');
    signal State: std_ulogic_vector(bits - 1 downto 0) := ZERO;
begin
    process begin
        wait until rising_edge(Clock);
        if Up = '1' and Down = '0' then
            State <= std_ulogic_vector(unsigned(State) + 1);
        elsif Up = '0' and Down = '1' and (State /= ZERO) then
            State <= std_ulogic_vector(unsigned(State) - 1);
        end if;
    end process;
    Locked <= '0' when State = ZERO or (State = ONE and Up = '1' and Down = '1') else '1';
    IsZero <= '1' when State = ZERO else '0';
end architecture Behavior;
