library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity MemoryStage is
    port (
        -- From Execute stage --
        DataIn, AddrIn:         in  word_t;
        DestRegIn:              in  regaddr_t;
        FuncIn:                 in  RV32I_Op;
        -- Memory interface --
        MemDataOut, MemAddr:    out word_t;
        MemRead, MemWrite:      out std_ulogic;
        MemDataIn:              in  word_t;
        MemDelay:               in  std_ulogic;
        -- To Write Back stage --
        DataOut:                out word_t;
        DestRegOut:             out regaddr_t;
        FuncOut:                out RV32I_Op;
        -- Pipeline I/O --
        Stall:                  out std_ulogic;
        Clock:                  in  std_ulogic
    );
end entity MemoryStage;

architecture Behavior of MemoryStage is
    signal bData, bAddr: word_t;
    signal bDestReg:     regaddr_t;
    signal bFunc:        RV32I_Op;
begin
    DataInBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => DataIn,
            Q      => bData,
            Enable => not MemDelay,
            Reset  => '0',
            Clock  => Clock 
        );
    AddrInBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => AddrIn,
            Q      => bAddr,
            Enable => not MemDelay,
            Reset  => '0',
            Clock  => Clock 
        );
    DestRegBuffer: entity work.Reg(Behavior)
        generic map (width => 5)
        port map (
            D      => DestRegIn,
            Q      => bDestReg,
            Enable => not MemDelay,
            Reset  => '0',
            Clock  => Clock 
        );
    FuncBuffer: entity work.FuncReg(Behavior)
        port map (
            D      => FuncIn,
            Q      => bFunc,
            Enable => not MemDelay,
            Reset  => '0',
            Clock  => Clock 
        );
    
    -- Outputs to memory --
    MemAddr    <= bAddr when is_load(bFunc) or is_store(bFunc) else (others => '0');
    MemDataOut <= bData when is_store(bFunc) else (others => '0');
    MemWrite   <= '1' when is_store(bFunc) else '0';
    MemRead    <= '1' when is_load(bFunc) else '0';

    -- Outputs to Write Back stage --
    DataOut    <= MemDataIn when is_load(bFunc) and MemDelay = '0' else (others => '0');
    DestRegOut <= bDestReg when MemDelay = '0' else (others => '0');
    FuncOut    <= bFunc when MemDelay = '0' else NOP;

    -- Outputs to Pipeline --
    Stall <= MemDelay;

end architecture Behavior;
