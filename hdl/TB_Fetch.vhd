-- TB_Fetch.vhd
-- 
-- Reset 1, Delay 1/0: Inst=NOP, Read=1
-- Jmp, Delay 1/0:
-- 
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;

entity TB_Fetch is
end entity TB_Fetch;

architecture Testbench of TB_Fetch is
    constant NOP: std_ulogic_vector(31 downto 0) := X"00_00_00_13";
    constant ZEROS: std_ulogic_vector(31 downto 0) := X"00_00_00_00"; 
    signal Jaddr, Mdata, Address, Inst, expAddress, expInst: std_ulogic_vector(31 downto 0);
    signal Clock, Jmp, Reset, Delay, MemRead, expRead: std_ulogic;
    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_Fetch_vec.txt.parsed";
begin
    DUV: entity work.Fetch(Structure)
        port map (
            Jaddr   => Jaddr,
            Mdata   => Mdata,
            Address => Address,
            Inst    => Inst,
            Clock   => Clock,
            Jmp     => Jmp,
            Reset   => Reset,
            Delay   => Delay,
            read    => MemRead
        );
    Stimulus: process
        variable L: line;
        variable inJaddr, inMdata, inAddress, inInst: std_ulogic_vector(31 downto 0);
        variable inJmp, inReset, inDelay, inRead: std_ulogic;
    begin
        Clock <= '0';
        wait for 40 ns;
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            hread(L, inJaddr);
            Jaddr <= inJaddr;
            hread(L, inMdata);
            Mdata <= inMdata;

            read(L, inJmp);
            Jmp <= inJmp;
            read(L, inReset);
            Reset <= inReset;
            read(L, inDelay);
            Delay <= inDelay;

            hread(L, inAddress);
            expAddress <= inAddress;
            hread(L, inInst);
            expInst <= inInst;

            read(L, inRead);
            expRead <= inRead;

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
        assert Address = expAddress
            report "ERROR: Incorrect Address output for vector " & to_string(vecno)
            severity warning;
        assert Inst = expInst
            report "ERROR: Incorrect Inst output for vector " & to_string(vecno)
            severity warning;
        assert MemRead = expRead
            report "ERROR: Incorrect MemRead output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
