library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
    generic (
        width: natural range 1 to 64 := 8
    );
    port (
        D: in std_ulogic_vector(width - 1 downto 0);
        Q: out std_ulogic_vector(width - 1 downto 0);
        Clock, Enable, Reset : in std_ulogic;
        Inc: in std_ulogic_vector(1 downto 0)
    );
end entity Counter;

architecture Behavior of Counter is
    signal RegIn, RegOut, IncOut: std_ulogic_vector(width - 1 downto 0);
begin
    MyReg: entity work.Reg(Behavior)
        generic map (width => width)
        port map (
            D => RegIn, 
            Q => RegOut, 
            Clock => Clock, 
            Enable => Reset or Enable, 
            Reset => '0'
        );
    MyMux: entity work.Mux2(Behavior)
        generic map (width => width)
        port map (
            Q => RegIn, 
            In0 => IncOut, 
            In1 => D, 
            Sel => Reset
        );
    MyInc: entity work.Increment(Behavior)
        generic map (width => width)
        port map (
            D => RegOut, 
            Q => IncOut, 
            Inc => Inc
        );
    Q <= RegOut;
end architecture Behavior;

