-- TB_Semaphore.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_Semaphore is
end entity TB_Semaphore;

architecture Testbench of TB_Semaphore is
    signal Up, Down, Locked, expLocked, Clock: std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_Semaphore_vec.txt.parsed";
begin
    DUV: entity work.Semaphore(Behavior)
        port map (
            Up => Up,
            Down => Down,
            Locked => Locked,
            Clock => Clock
        );
    Stimulus: process
        variable inUp, inDown, inLocked: std_ulogic;
        variable L: line;
    begin
        Clock <= '0';
        wait for 40 ns;
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            read(L, inUp);
            Up <= inUp;
            read(L, inDown);
            Down <= inDown;
            read(L, inLocked);
            expLocked <= inLocked;

            wait for 10 ns;
            Clock <= '1';
            wait for 50 ns;
            Clock <= '0';
            wait for 40 ns;
        end loop;
        report "End of Testbench.";
        std.env.finish;
    end process;

    Check: process
    begin
        wait until falling_edge(Clock);
        assert Locked = expLocked
            report "ERROR: Incorrect Locked output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
