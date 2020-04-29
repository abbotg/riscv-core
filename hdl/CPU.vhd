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

    -- From Fetch 
    signal f2ma_Address, f2d_Instruction, f2d_PC: word_t;
    signal f2ma_read: std_ulogic;

    -- From Decode
    signal d2e_Func: RV32I_Op;
    signal d2e_Left, d2e_Right, d2e_Extra: word_t;
    signal d_DestReg, d_RegAddrA, d_RegAddrB: regaddr_t; -- to both RF and RT
    signal d2rt_RS1v, d2rt_RS2v, d2rt_RDv: std_ulogic;
    signal d2e_InstructionType: InsType;

    -- From Execute
    signal e2f_Jaddr, e2ms_Address, e2ms_Data: word_t;
    signal e2ms_DestReg: regaddr_t;
    signal e2f_Jump: std_ulogic;

    -- From Memory Stage
    signal ms2wb_Func: RV32I_Op;
    signal ms2ma_MemData, ms2ma_MemAddr, ms2wb_Data: word_t;
    signal ms2wb_DestReg: regaddr_t;
    signal ms2ma_MemRead, ms2ma_MemWrite, ms_Stall: std_ulogic;

    -- From Write-back stage
    signal wb2rf_Data: word_t;
    signal wb_DestReg: regaddr_t; -- to both RF and RT
    signal wb_Write: std_ulogic; -- to both RF and RT

    -- From Memory arbiter
    signal ma2ms_Data, ma2f_Data: word_t;
    signal ma2ms_MemDelay, ma2f_MemDelay: std_ulogic;

    -- From Register Tracker
    signal rt_Stall: std_ulogic;

    -- From Register File
    signal rf2d_ReadDataA, rf2d_ReadDataB: word_t;

begin
    FetchStage: entity work.Fetch(Structure)
        port map (
            Jaddr   => e2f_Jaddr,
            Mdata   => ma2f_Data,
            Address => f2ma_Address,
            Inst    => f2d_Instruction,
            PC      => f2d_PC,
            Clock   => Clock,
            Jmp     => e2f_Jump,
            Reset   => '0',
            Stall1  => ma2f_MemDelay,
            Stall2  => ms_Stall,
            Stall3  => rt_Stall,
            read    => f2ma_read
        );
    DecodeStage: entity work.DecodeStage(Behavior)
        port map (
            Instruction => f2d_Instruction,
            PC => f2d_PC,
            Func => d2e_Func,
            Left => d2e_Left,
            Right => d2e_Right,
            Extra => d2e_Extra,
            DestReg => d_DestReg,
            RS1v => d2rt_RS1v,
            RS2v => d2rt_RS2v,
            RDv => d2rt_RDv,
            Stall1 => ms_Stall,
            Stall2 => rt_Stall,
            InstructionType => d2e_InstructionType,
            RegAddrA => d_RegAddrA,
            RegAddrB => d_RegAddrB,
            RegDataA => rf2d_RegDataA,
            RegDataB => rf2d_RegDataB,
            Clock => Clock
        );
    ExecuteStage: entity work.Execute(Behavior)
        port map (
            FuncIn => d2e_Func,
            InstructionType => d2e_InstructionType,
            Left => d2e_Left,
            Right => d2e_Right,
            Extra => d2e_Extra,
            DestRegIn => d_DestReg,
            Jaddr => e2f_Jaddr,
            Jump => e2f_Jump,
            Address => e2ms_Address,
            Data => e2ms_Data,
            DestRegOut => e2ms_DestReg,
            FuncOut => e2ms_Func,
            Clock => Clock,
            Stall => ms_Stall
        );
    MemoryStage: entity work.MemoryStage(Behavior)
        port map (
            DataIn => e2ms_Data,
            AddrIn => e2ms_Address,
            DestRegIn => e2ms_DestReg,
            FuncIn => e2ms_Func,
            MemDataOut => ms2ma_MemData,
            MemAddr => ms2ma_MemAddr,
            MemRead => ms2ma_MemRead,
            MemWrite => ms2ma_MemWrite,
            MemDataIn => ma2ms_Data,
            MemDelay => ma2ms_MemDelay,
            DataOut => ms2wb_Data,
            DestRegOut => ms2wb_DestReg,
            FuncOut => ms2wb_Func,
            Stall => ms_Stall,
            Clock => Clock
        );
    WriteBackStage: entity work.WriteBackStage(Behavior)
        port map (
            DataIn => ms2wb_Data,
            DestRegIn => ms2wb_DestReg,
            Func => ms2wb_Func,
            DataOut => wb2rf_Data,
            DestRegOut => wb_DestReg,
            Write => wb2rf_Write,
            Clock => Clock
        );
    MemoryArbiter: entity work.MemoryArbiter(Behavior)
        port map (
            MSDataIn => ms2ma_MemData,
            MSAddr => ms2ma_MemAddr,
            MSRead => ms2ma_MemRead,
            MSWrite => ms2ma_MemWrite,
            MSMemDelay => ma2ms_MemDelay,
            MSDataOut => ma2f_MemDelay,
            FAddr => f2ma_Address,
            FRead => f2ma_read,
            FMemDelay => ma2f_MemDelay,
            FDataOut => ma2f_Data,
            MemDataIn => MemDataIn,
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemDelay => MemDelay,
            MemDataOut => MemDataOut,
            MemAddr => MemAddr
        );
    RegisterTracker: entity work.RegisterTracker(Behavior)
        port map (
            ReadAddrA => d_ReadAddrA,
            ReadAddrB => d_ReadAddrB,
            WriteAddr => d_DestReg,
            FreeAddr => wb_DestReg,
            Stall => rt_Stall,
            Clock => Clock,
            ReadA => d2rt_RS1v,
            ReadB => d2rt_RS2v,
            Reserve => d2rt_RDv,
            Free => wb_Write
        );
    RegisterFile: entity work.RegisterFile(Behavior)
        port map (
            ReadDataA => rf2d_ReadDataA,
            ReadDataB => rf2d_ReadDataB,
            WriteData => wb2rf_Data,
            ReadAddrA => d_RegAddrA,
            ReadAddrB => d_RegAddrB,
            WriteAddr => wb_DestReg,
            Write => wb_Write,
            Clock => Clock
        );

end architecture Structure;

