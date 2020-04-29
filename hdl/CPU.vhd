library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity CPU is
    port (
        MemDataIn:           in  word_t;
        MemRead, MemWrite:   out std_ulogic;
        MemDelay:            in  std_ulogic;
        MemDataOut, MemAddr: out word_t   
        Clock:               in  std_ulogic;
    );
end entity CPU;

architecture Structure of CPU is
    ---- Signal short name legend ----
    --  f : fetch                   --
    --  d : decode                  --
    --  e : execute                 --
    -- ms : memory stage            --
    -- wb : write back stage        --
    -- ma : memory arbiter          --
    -- rf : register file           --
    -- rt : register tracker        --
    ----------------------------------

    -- From Fetch --
    signal f2ma_Address, f2d_Instruction, f2d_PC: word_t;
    signal f2ma_read: std_ulogic;

    -- From Decode --
    signal d2e_Func: RV32I_Op;
    signal d2e_Left, d2e_Right, d2e_Extra: word_t;
    signal d2e_DestReg, d2rf_RegAddrA, d2rf_RegAddrB: regaddr_t;
    signal d2rt_RS1v, d2rt_RS2v, d2rt_RDv: std_ulogic;
    signal d2e_InstructionType: InsType;

    -- From Execute
    signal e2f_Jaddr, e2ms_Address, e2ms_Data: word_t;
    signal e2ms_DestReg: regaddr_t;
    signal e2f_Jump: std_ulogic;

    -- From Memory Stage
    signal ms2ma_MemData, ms2ma_MemAddr, ms2wb_Data: word_t;
    signal 



begin
    ----         ----
    ----  FETCH  ----  
    ----         ----
    Fetch: entity work.Fetch(Structure)
        port map (
            Jaddr => 
    
    
end architecture Structure;

