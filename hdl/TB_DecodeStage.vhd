-- TB_DecodeStage.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_DecodeStage is
end entity TB_DecodeStage;

architecture Testbench of TB_DecodeStage is
    -- Inputs --
    signal Instruction, PC:     std_ulogic_Vector(31 downto 0);
    signal RegDataA, RegDataB:  std_ulogic_Vector(31 downto 0); 
    signal Stall, Clock:        std_ulogic;
    -- Outputs --
    signal Func, expFunc:                              RV32I_Op;
    signal RS1v, RS2v, RDv, expRS1v, expRS2v, expRDv:  std_ulogic;
    signal RegAddrA, RegAddrB, DestReg,
           expRegAddrA, expRegAddrB, expDestReg:       std_ulogic_Vector(4 downto 0); 
    signal Left, Right, Extra, 
           expLeft, expRight, expExtra:                std_ulogic_vector(31 downto 0);
    -- Testing --
    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_DecodeStage_vec.txt.parsed";
begin
    DUV: entity work.DecodeStage(Behavior)
        port map (
            Instruction => Instruction,
            PC => PC,
            Func => Func,
            Left => Left,
            Right => Right,
            Extra => Extra,
            DestReg => DestReg,
            RS1v => RS1v,
            RS2v => RS2v,
            RDv => RDv,
            Stall => Stall,
            RegAddrA => RegAddrA,
            RegAddrB => RegAddrB,
            RegDataA => RegDataA,
            RegDataB => RegDataB,
            Clock => Clock
        );
    Stimulus: process
        variable L: line;
        -- Pipeline i/o --
        variable inInstruction, inPC:       std_ulogic_vector(31 downto 0);  -- From fetch
        variable inFunc:                    Func_Name;
        variable inLeft, inRight, inExtra:  std_ulogic_vector(31 downto 0);
        variable inDestReg:                 std_ulogic_vector(4 downto 0);   -- dest reg address
        variable inRS1v, inRS2v, inRDv:     std_ulogic;
        variable inStall:                   std_ulogic;
        -- Register file i/o
        variable inRegAddrA, inRegAddrB:    std_ulogic_vector(4 downto 0);   -- Reg A, B addresses
        variable inRegDataA, inRegDataB:    std_ulogic_vector(31 downto 0);   -- Reg A, B data

        variable mystrlen: natural;
    begin
        Clock <= '0';
        wait for 40 ns;
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            -- Instruction in binary, stall is a boolean,
            -- all other inputs are 32-bit hex
            read(L, inInstruction); 
            Instruction <= inInstruction;
            
            -- Outputs
            sread(L, inFunc, mystrlen);
            expFunc <= Ftype(inFunc);


            read(L, inRegAddrA); 
            expRegAddrA <= inRegAddrA;
            read(L, inRegAddrB); 
            expRegAddrB <= inRegAddrB;
            read(L, inDestReg); 
            expDestReg <= inDestReg;

            read(L, inRS1v);
            expRS1v <= inRS1v;
            read(L, inRS2v);
            expRS2v <= inRS2v;
            read(L, inRDv);
            expRDv <= inRDv;

            hread(L, inLeft); 
            expLeft <= inLeft;
            hread(L, inRight); 
            expRight <= inRight;
            hread(L, inExtra); 
            expExtra <= inExtra;

            hread(L, inRegDataA);
            RegDataA <= inRegDataA;
            hread(L, inRegDataB);
            RegDataB <= inRegDataB;
            hread(L, inPC);
            PC <= inPC;
            read(L, inStall); 
            Stall <= inStall;

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
        assert Func = expFunc
            report "ERROR: Incorrect Func output for vector " & to_string(vecno)
            severity warning;
        assert Left = expLeft
            report "ERROR: Incorrect Left output for vector " & to_string(vecno)
            severity warning;
        assert Right = expRight
            report "ERROR: Incorrect Right output for vector " & to_string(vecno)
            severity warning;
        assert Extra = expExtra
            report "ERROR: Incorrect Extra output for vector " & to_string(vecno)
            severity warning;
        assert DestReg = expDestReg
            report "ERROR: Incorrect DestReg output for vector " & to_string(vecno)
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
        assert RegAddrA = expRegAddrA
            report "ERROR: Incorrect RegAddrA output for vector " & to_string(vecno)
            severity warning;
        assert RegAddrB = expRegAddrB
            report "ERROR: Incorrect RegAddrB output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
