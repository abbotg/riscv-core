-- TB_RegisterTracker.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_RegisterTracker is
end entity TB_RegisterTracker;

architecture Testbench of TB_RegisterTracker is
    signal ReadAddrA, ReadAddrB, WriteAddr, FreeAddr: std_ulogic_vector(4 downto 0);
    signal ReadA, ReadB, Reserve, Free, Clock, Stall, expStall: std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_RegisterTracker_vec.txt.parsed";
begin
    DUV: entity work.RegisterTracker(Behavior)
        port map (
            ReadA => ReadA,
            ReadB => ReadB,
            Reserve => Reserve,
            Free => Free,
            Stall => Stall,
            ReadAddrA => ReadAddrA,
            ReadAddrB => ReadAddrB,
            WriteAddr => WriteAddr,
            FreeAddr => FreeAddr,
            Clock => Clock
        );
    Stimulus: process
        variable inReadAddrA, inReadAddrB, inWriteAddr, inFreeAddr: std_ulogic_vector(4 downto 0);
        variable inReadA, inReadB, inFree, inReserve, inStall: std_ulogic;
        variable L: line;
    begin
        Clock <= '0';
        wait for 40 ns;
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            read(L, inReadA);
            ReadA <= inReadA;
            read(L, inReadAddrA);
            ReadAddrA <= inReadAddrA;
            read(L, inReadB);
            ReadB <= inReadB;
            read(L, inReadAddrB);
            ReadAddrB <= inReadAddrB;
            read(L, inReserve);
            Reserve <= inReserve;
            read(L, inWriteAddr);
            WriteAddr <= inWriteAddr;
            read(L, inFree);
            Free <= inFree;
            read(L, inFreeAddr);
            FreeAddr <= inFreeAddr;
            read(L, inStall);
            expStall <= inStall;

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
        assert Stall = expStall
            report "ERROR: Incorrect Stall output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
