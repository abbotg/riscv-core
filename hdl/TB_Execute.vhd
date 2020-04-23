-- TB_Execute.vhd
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.RV32I.all;

entity TB_Execute is
end entity TB_Execute;

architecture Testbench of TB_Execute is
    -- Inputs --
    signal Left, Right, Extra:           std_ulogic_Vector(31 downto 0);
    signal Clock:                        std_ulogic;
    signal Func:                         RV32I_Op;
    signal InstructionType:              InsType;
    -- Outputs --
    signal Address, Data, Jaddr, 
           expAddress, expData, expJaddr: std_ulogic_vector(31 downto 0);
    signal Jump, expJump:                std_ulogic;
    -- Testing --
    signal vecno: natural := 0;
    file test_vectors: text open read_mode is "TB_Execute_vec.txt.parsed";
begin
    DUV: entity work.Execute(Behavior)
        port map (
            inFunc => Func,
            InstructionType => InstructionType,
            Left => Left,
            Right => Right,
            Extra => Extra,
            Jaddr => Jaddr,
            Jump => Jump,
            Address => Address,
            Data => Data,
            outDestReg => open,
            outFunc => open,
            outRS1v => open,
            outRS2v => open,
            outRDv => open,
            inDestReg => "00000",
            inRS1v => '0',
            inRS2v => '0',
            inRDv => '0',
            Stall => '0',
            Clock => Clock
        );
    Stimulus: process
        variable L: line;
        variable inLeft, inRight, inExtra, 
                 inAddress, inData, inJaddr: std_ulogic_vector(31 downto 0);
        variable inFunc:                     Func_Name;
        variable inInstructionType:          Ins_Name;
        variable inJump:                     std_ulogic;
        variable mystrlen:                   natural;
    begin
        Clock <= '0';
        wait for 40 ns;
        readline(test_vectors, L);
        while not endfile(test_vectors) loop
            readline(test_vectors, L);

            -- Inputs --
            sread(L, inFunc, mystrlen);
            Func <= Ftype(inFunc);
            sread(L, inInstructionType, mystrlen);
            InstructionType <= Itype(inInstructionType);

            hread(L, inLeft); 
            Left <= inLeft;
            hread(L, inRight); 
            Right <= inRight;
            hread(L, inExtra); 
            Extra <= inExtra;

            -- Outputs
            hread(L, inAddress); 
            expAddress <= inAddress;
            hread(L, inData); 
            expData <= inData;

            read(L, inJump); 
            expJump <= inJump;
            hread(L, inJaddr); 
            expJaddr <= inJaddr;

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
        assert Data = expData
            report "ERROR: Incorrect Data output for vector " & to_string(vecno)
            severity warning;
        assert Jump = expJump
            report "ERROR: Incorrect Jump output for vector " & to_string(vecno)
            severity warning;
        assert Jaddr = expJaddr
            report "ERROR: Incorrect Jaddr output for vector " & to_string(vecno)
            severity warning;
        vecno <= vecno + 1;
    end process;
end architecture Testbench;
