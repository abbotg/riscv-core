library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity WriteBackStage is
    port (
        -- From Memory stage --
        DataIn:     in  word_t;
        DestRegIn:  in  regaddr_t;
        Func:       in  RV32I_Op;
        -- To register file --
        DataOut:    out word_t;
        DestRegOut: out regaddr_t;
        Write:      out std_ulogic;
        -- Pipeline I/O --
        Clock:      in  std_ulogic
    );
end entity WriteBackStage;

architecture Behavior of WriteBackStage is
    signal bData:     word_t;
    signal bDestReg:  regaddr_t;
    signal bFunc:     RV32I_Op;
begin
    DataInBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => DataIn,
            Q      => bData,
            Enable => '1',
            Reset  => '0',
            Clock  => Clock 
        );
    DestRegBuffer: entity work.Reg(Behavior)
        generic map (width => 5)
        port map (
            D      => DestRegIn,
            Q      => bDestReg,
            Enable => '1',
            Reset  => '0',
            Clock  => Clock 
        );
    FuncBuffer: entity work.FuncReg(Behavior)
        port map (
            D      => Func,
            Q      => bFunc,
            Enable => '1',
            Reset  => '0',
            Clock  => Clock 
        );
    
    Write <= '0' when bFunc = NOP or bDestReg = ZERO5 else '1'; 
        -- writing to x0 always ignored
        -- NOP generated in decode stage on reg tracker delay or in mem stage from memdelay
    DataOut <= bData;
    DestRegOut <= bDestReg;

end architecture Behavior;
