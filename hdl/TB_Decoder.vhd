-- TB_Decoder.vhd
-- 
library ieee;
--library RV32I;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_Decoder is
end entity TB_Decoder;

architecture Testbench of TB_Decoder is
    signal instruction, Immediate, expImmediate:        std_ulogic_vector(31 downto 0);
    signal Func, expFunc:                               RV32I_Op;
    signal RS1, RS2, RD, expRS1, expRS2, expRD:         std_ulogic_vector(4 downto 0);
    signal RS1v, RS2v, RDv, expRS1v, expRS2v, expRDv:   std_ulogic;

    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_Decoder_vec.txt.parsed";
begin
    DUV: entity work.Decoder(Behavior)
        port map (
            instruction => instruction,
            Func => Func,
            RS1 => RS1,
            RS2 => RS2,
            RD => RD,
            RS1v => RS1v,
            RS2v => RS2v,
            RDv => RDv,
            Immediate => Immediate
        );
    Stimulus: process
        variable L: line;
        variable inInstruction, inImmediate: std_ulogic_vector(31 downto 0);
        variable inFunc: Func_Name;
        variable inRS1, inRS2, inRD: std_ulogic_vector(4 downto 0);
        variable inRS1v, inRS2v, inRDv: std_ulogic;
        variable mystrlen: natural;
    begin
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs
            read(L, inInstruction);
            instruction <= inInstruction;

            -- Outputs
            sread(L, inFunc, mystrlen);
            expFunc <= Ftype(inFunc);
            read(L, inRS1);
            expRS1 <= inRS1;
            read(L, inRS2);
            expRS2 <= inRS2;
            read(L, inRD);
            expRD <= inRD;

            read(L, inRS1v);
            expRS1v <= inRS1v;
            read(L, inRS2v);
            expRS2v <= inRS2v;
            read(L, inRDv);
            expRDv <= inRDv;

            hread(L, inImmediate);
            expImmediate <= inImmediate;

            wait for 100 ns;
        end loop;
        report "End of Testbench.";
        std.env.finish;
    end process;

    Check: process
    begin
        wait for 50 ns;
        assert Func = expFunc
            report "ERROR: Incorrect Func output for vector " & to_string(vecno)
            severity warning;
        assert RS1 = expRS1
            report "ERROR: Incorrect RS1 output for vector " & to_string(vecno)
            severity warning;
        assert RS2 = expRS2
            report "ERROR: Incorrect RS2 output for vector " & to_string(vecno)
            severity warning;
        assert RD = expRD
            report "ERROR: Incorrect RD output for vector " & to_string(vecno)
            severity warning;
        assert RS1v = expRS1v
            report "ERROR: Incorrect RS1v output for vector " & to_string(vecno)
            severity warning;
        assert RS2v = expRS2v
            report "ERROR: Incorrect RS2v output for vector " & to_string(vecno)
            severity warning;
        assert RDv = expRDv
            report "ERROR: Incorrect RDv output for vector " & to_string(vecno)
            severity warning;
        assert Immediate = expImmediate
            report "ERROR: Incorrect Immediate output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
        wait for 50 ns;
    end process;
end architecture Testbench;
