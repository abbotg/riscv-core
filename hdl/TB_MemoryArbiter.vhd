-- TB_MemoryArbiter.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_MemoryArbiter is
end entity TB_MemoryArbiter;

architecture Testbench of TB_MemoryArbiter is
    -- Inputs --
    signal MSRead, MSWrite, FRead, MemDelay: std_ulogic;
    signal MSAddr, FAddr: std_ulogic_vector(31 downto 0);
    -- Outputs --
    signal MemAddr, expMemAddr: std_ulogic_vector(31 downto 0);
    signal MemRead, MemWrite, MSMemDelay, FMemDelay,
           expMemRead, expMemWrite, expMSMemDelay, expFMemDelay: std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_MemoryArbiter_vec.txt.parsed";
begin
    DUV: entity work.MemoryArbiter(Behavior)
        port map (
            MSDataIn => (others => '0'),
            MSAddr => MSAddr,
            MSRead => MSRead,
            MSWrite => MSWrite,
            MSMemDelay => MSMemDelay,
            MSDataOut => open,
            FAddr => FAddr,
            FRead => FRead,
            FMemDelay => FMemDelay,
            FDataOut => open,
            MemDataIn => (others => '0'),
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemDelay => MemDelay,
            MemDataOut => open,
            MemAddr => MemAddr
        );
    Stimulus: process
        -- Inputs --
        variable inMSRead, inMSWrite, inFRead, inMemDelay: std_ulogic;
        variable inMSAddr, inFAddr: std_ulogic_vector(31 downto 0);
        -- Outputs --
        variable inMemAddr: std_ulogic_vector(31 downto 0);
        variable inMemRead, inMemWrite, inMSMemDelay, inFMemDelay: std_ulogic;

        variable L: line;
    begin
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            hread(L, inMSAddr); 
            MSAddr <= inMSAddr;
            hread(L, inFAddr); 
            FAddr <= inFAddr;
            read(L, inMSRead); 
            MSRead <= inMSRead;
            read(L, inMSWrite); 
            MSWrite <= inMSWrite;
            read(L, inFRead); 
            FRead <= inFRead;
            read(L, inMemDelay); 
            MemDelay <= inMemDelay;

            -- Outputs
            hread(L, inMemAddr); 
            expMemAddr <= inMemAddr;
            read(L, inMemRead); 
            expMemRead <= inMemRead;
            read(L, inMemWrite); 
            expMemWrite <= inMemWrite;
            read(L, inMSMemDelay); 
            expMSMemDelay <= inMSMemDelay;
            read(L, inFMemDelay); 
            expFMemDelay <= inFMemDelay;

            wait for 100 ns;
        end loop;
        report "End of Testbench.";
        std.env.finish;
    end process;

    Check: process
    begin
        wait for 50 ns;
        assert MemAddr = expMemAddr
            report "ERROR: Incorrect MemAddr output for vector " & to_string(vecno)
            severity warning;
        assert MemRead = expMemRead
            report "ERROR: Incorrect MemRead output for vector " & to_string(vecno)
            severity warning;
        assert MemWrite = expMemWrite
            report "ERROR: Incorrect MemWrite output for vector " & to_string(vecno)
            severity warning;
        assert MSMemDelay = expMSMemDelay
            report "ERROR: Incorrect MSMemWrite output for vector " & to_string(vecno)
            severity warning;
        assert FMemDelay = expFMemDelay
            report "ERROR: Incorrect FMemDelay output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
        wait for 50 ns;
    end process;
end architecture Testbench;
