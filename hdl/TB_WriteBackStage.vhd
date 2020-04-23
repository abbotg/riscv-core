-- TB_WriteBackStage.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_WriteBackStage is
end entity TB_WriteBackStage;

architecture Testbench of TB_WriteBackStage is
    -- Inputs --
    signal Func:      RV32I_Op;
    signal DestRegIn: std_ulogic_vector(4 downto 0);
    -- Outputs --
    signal Write, expWrite, Clock: std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_WriteBackStage_vec.txt.parsed";
begin
    DUV: entity work.WriteBackStage(Behavior)
        port map (
            DataIn => X"00_00_00_00",
            DestRegIn => DestRegIn,
            Func => Func,
            DataOut => open,
            DestRegOut => open,
            Write => Write,
            Clock => Clock
        );
    Stimulus: process
        -- Inputs --
        variable inFunc: Func_Name;
        variable inDestRegIn: std_ulogic_vector(4 downto 0);
        -- Outputs --
        variable inWrite: std_ulogic;
        variable L: line;
        variable mystrlen: natural;
    begin
        Clock <= '0';
        wait for 40 ns;
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            sread(L, inFunc, mystrlen);
            Func <= Ftype(inFunc);
            read(L, inDestRegIn); 
            DestRegIn <= inDestRegIn;

            -- Outputs
            read(L, inWrite); 
            expWrite <= inWrite;

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
        assert Write = expWrite
            report "ERROR: Incorrect Write output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
