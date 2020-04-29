library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity MemoryArbiter is
    port (
        -- Memory stage --
        MSDataIn, MSAddr:    in  word_t;
        MSRead, MSWrite:     in  std_ulogic;
        MSMemDelay:          out std_ulogic;
        MSDataOut:           out word_t;
        -- Fetch stage --
        FAddr:               in  word_t;
        FRead:               in  std_ulogic;
        FMemDelay:           out std_ulogic;
        FDataOut:            out word_t;
        -- Memory system --
        MemDataIn:           in  word_t;
        MemRead, MemWrite:   out std_ulogic;
        MemDelay:            in  std_ulogic;
        MemDataOut, MemAddr: out word_t
    );
end entity MemoryArbiter;

architecture Behavior of MemoryArbiter is
begin
    -- Outputs to memory system --
    MemDataOut <= MSDataIn;
    MemWrite   <= MSWrite;
    MemAddr    <= MSAddr when MSRead or MSWrite else FAddr;
    MemRead    <= MSRead when MSRead or MSWrite else FRead;

    -- Outputs to Fetch or Memory stage --
    MSDataOut  <= MemDataIn;
    FDataOut   <= MemDataIn;
    FMemDelay  <= MSRead or MSWrite or MemDelay;
    MSMemDelay <= MemDelay;
end architecture Behavior;
