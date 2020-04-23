-- TB_MemoryStage.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_MemoryStage is
end entity TB_MemoryStage;

architecture Testbench of TB_MemoryStage is
    -- Inputs --
    signal DataIn, AddrIn:  std_ulogic_vector(31 downto 0);
    signal Clock, MemDelay: std_ulogic;
    signal FuncIn:          RV32I_Op;
    -- Outputs --
    signal DataOut, MemAddr, MemDataOut,
           expDataOut, expMemAddr, expMemDataOut:      std_ulogic_vector(31 downto 0);
    signal MemRead, MemWrite, expMemRead, expMemWrite: std_ulogic;
    -- Testing --
    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_MemoryStage_vec.txt.parsed";
begin
    DUV: entity work.MemoryStage(Behavior)
        port map (
            DataIn => DataIn,
            AddrIn => AddrIn,
            DestRegIn => "00000",
            FuncIn => FuncIn,
            MemDataOut => MemDataOut,
            MemAddr => MemAddr,
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemDataIn => X"00_00_00_CC",
            MemDelay => MemDelay,
            DataOut => DataOut,
            DestRegOut => open,
            FuncOut => open,
            Stall => open,
            Clock => Clock
        );
    Stimulus: process
        variable L: line;
        variable inDataIn, inAddrIn, 
                 inDataOut, inMemAddr, inMemDataOut: std_ulogic_vector(31 downto 0);
        variable inFuncIn:                           Func_Name;
        variable inMemRead, inMemWrite, inMemDelay:  std_ulogic;
        variable mystrlen:                           natural;
    begin
        Clock <= '0';
        wait for 40 ns;
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            sread(L, inFuncIn, mystrlen);
            FuncIn <= Ftype(inFuncIn);

            hread(L, inDataIn); 
            DataIn <= inDataIn;
            hread(L, inAddrIn); 
            AddrIn <= inAddrIn;

            read(L, inMemDelay); 
            MemDelay <= inMemDelay;

            -- Outputs
            hread(L, inMemAddr); 
            expMemAddr <= inMemAddr;
            hread(L, inMemDataOut); 
            expMemDataOut <= inMemDataOut;

            read(L, inMemRead); 
            expMemRead <= inMemRead;
            read(L, inMemWrite); 
            expMemWrite <= inMemWrite;

            hread(L, inDataOut); 
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
        assert MemAddr = expMemAddr
            report "ERROR: Incorrect MemAddr output for vector " & to_string(vecno)
            severity warning;
        assert MemDataOut = expMemDataOut
            report "ERROR: Incorrect MemDataOut output for vector " & to_string(vecno)
            severity warning;
        assert MemRead = expMemRead
            report "ERROR: Incorrect MemRead output for vector " & to_string(vecno)
            severity warning;
        assert MemWrite = expMemWrite
            report "ERROR: Incorrect MemWrite output for vector " & to_string(vecno)
            severity warning;
        assert DataOut = expDataOut
            report "ERROR: Incorrect DataOut output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
