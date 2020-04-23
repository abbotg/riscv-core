library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity WriteBackStage is
    port (
        -- From Memory stage --
        DataIn:     in  std_ulogic_vector(31 downto 0);
        DestRegIn:  in  std_ulogic_vector(4 downto 0);
        Func:       in  RV32I_Op;
        -- To register file --
        DataOut:    out std_ulogic_vector(31 downto 0);
        DestRegOut: out std_ulogic_vector(4 downto 0);
        Write:      out std_ulogic;
        -- Pipeline I/O --
        Clock:      in  std_ulogic
    );
end entity WriteBackStage;

architecture Behavior of WriteBackStage is
    signal bData:     std_ulogic_vector(31 downto 0);
    signal bDestReg:  std_ulogic_vector(4 downto 0);
    signal bFunc:     RV32I_Op;
    constant ZERO_5b: std_ulogic_vector(4 downto 0) := (others => '0');
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
    
    Write <= '0' when bFunc = NOP or bDestReg = ZERO_5b else '1'; -- writing to x0 always ignored
    DataOut <= bData;
    DestRegOut <= bDestReg;

end architecture Behavior;
