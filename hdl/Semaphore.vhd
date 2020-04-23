library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Semaphore is
    generic (
        bits: natural range 1 to 64 := 2
    );
    port (
        --Op: in  std_ulogic; -- Operation select: 1=Up, 0=Down
        Up, Down: in  std_ulogic; -- Up and down operations, can be asserted at same time (will have no effect)
        Locked: out std_ulogic; -- State: 1=Locked, 0=Free
        Clock: in std_ulogic
    );
end entity Semaphore;

architecture Behavior of Semaphore is
    constant ZERO: std_ulogic_vector(bits - 1 downto 0) := (others => '0');
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
    Locked <= '0' when State = ZERO else '1';
--    process (Clock) begin
--        if rising_edge(Clock) then
--            Locked <= '0' when State = ZERO else '1';
--        end if;
--    end process;
end architecture Behavior;
