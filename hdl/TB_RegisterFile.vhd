-- TB_RegisterFile.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_RegisterFile is
end entity TB_RegisterFile;

architecture Testbench of TB_RegisterFile is
    signal ReadAddrA, ReadAddrB, WriteAddr: std_ulogic_vector(4 downto 0);
    signal ReadDataA, ReadDataB:            std_logic_vector(31 downto 0);
    signal WriteData, expReadDataA, expReadDataB: std_logic_vector(31 downto 0);
    signal Write, Clock:                    std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_RegisterFile_vec.txt.parsed";
begin
    DUV: entity work.RegisterFile(Behavior)
        port map (
            ReadDataA => ReadDataA,
            ReadDataB => ReadDataB,
            WriteData => WriteData,
            ReadAddrA => ReadAddrA,
            ReadAddrB => ReadAddrB,
            WriteAddr => WriteAddr,
            Write => Write,
            Clock => Clock
        );
    Stimulus: process
        variable inReadAddrA, inReadAddrB, inWriteAddr: std_ulogic_vector(4 downto 0);
        variable inWriteData, inReadDataA, inReadDataB: std_ulogic_vector(31 downto 0);
        variable inWrite: std_ulogic;
        variable L: line;
    begin
        Clock <= '0';
        wait for 40 ns;
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            read(L, inReadAddrA);
            ReadAddrA <= inReadAddrA;
            read(L, inReadAddrB);
            ReadAddrB <= inReadAddrB;
            read(L, inWriteAddr);
            WriteAddr <= inWriteAddr;
            hread(L, inWriteData);
            WriteData <= inWriteData;
            read(L, inWrite);
            Write <= inWrite;

            -- Outputs --
            hread(L, inReadDataA);
            expReadDataA <= inReadDataA;
            hread(L, inReadDataB);
            expReadDataB <= inReadDataB;

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
        assert ReadDataA = expReadDataA
            report "ERROR: Incorrect ReadDataA output for vector " & to_string(vecno)
            severity warning;
        assert ReadDataB = expReadDataB
            report "ERROR: Incorrect ReadDataB output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
