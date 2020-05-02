library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity SOC is
end entity SOC;

architecture Structure of SOC is
    signal DataFromMem, DataToMem, Address: word_t;
    signal MemRead, MemWrite, Delay, Clock: std_ulogic;
begin
    CPU: entity work.CPU(Structure)
        port map (
            MemDataIn => DataFromMem,
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemDelay => Delay,
            MemDataOut => DataToMem,
            MemAddr => Address,
            Clock => Clock
        );
    Memory: entity work.MemorySystem(behavior)
        port map (
            Address => Address,
            DataIn => DataToMem,
            Clock => Clock,
            WriteEnable => MemWrite,
            ReadEnable => MemRead,
            MemDelay => Delay,
            DataOut => DataFromMem
        );
    Clocking: process begin
        Clock <= '0';
        wait for 50 ns;
        Clock <= '1';
        wait for 50 ns;
    end process;
        
end architecture Structure;

