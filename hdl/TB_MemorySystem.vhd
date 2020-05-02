-- TB_MemorySystem.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_MemorySystem is
end entity TB_MemorySystem;

architecture Testbench of TB_MemorySystem is
    -- Inputs --
    signal Address, DataIn: word_t;
    signal Clock, WriteEnable, ReadEnable: std_ulogic;
    -- Outputs --
    signal DataOut, expDataOut: word_t;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_MemorySystem_vec.txt.parsed";
begin
    DUV: entity work.MemorySystem(Behavior)
        port map (
            Address => Address,
            DataIn => DataIn,
            DataOut => DataOut,
            WriteEnable => WriteEnable,
            ReadEnable => ReadEnable,
            MemDelay => open,
            Clock => Clock
        );
    Stimulus: process
        -- Inputs --
        variable inAddress, inDataIn: word_t;
        variable inWriteEnable, inReadEnable: std_ulogic;
        -- Outputs --
        variable inDataOut: word_t;

        variable L: line;
        variable mystrlen: natural;
    begin
        Clock <= '0';
        wait for 40 ns;
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            hread(L, inAddress); 
            Address <= inAddress;
            read(L, inDataIn); 
            DataIn <= inDataIn;
            read(L, inWriteEnable); 
            WriteEnable <= inWriteEnable;
            read(L, inReadEnable); 
            ReadEnable <= inReadEnable;

            -- Outputs
            read(L, inDataOut); 
            expDataOut <= inDataOut;

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
        assert DataOut = expDataOut
            report "ERROR: Incorrect DataOut output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
