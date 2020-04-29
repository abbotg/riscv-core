library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity RegisterFile is
    port (
        ReadDataA, ReadDataB: out std_logic_vector(31 downto 0);
        WriteData: in word_t;
        ReadAddrA, ReadAddrB, WriteAddr: in regaddr_t;
        Write, Clock: in std_ulogic
    );
end entity RegisterFile;

architecture Behavior of RegisterFile is
    function index(i: std_ulogic_vector) return integer is begin
        return to_integer(unsigned(i));
    end;
    signal WriteSelect, ReadSelectA, ReadSelectB: word_t;
begin
    x0_BufA: entity work.TriStateBuffer(Behavior)
        generic map (width => 32)
        port map (
            A => (others => '0'),
            E => ReadSelectA(0),
            Q => ReadDataA
        );
    x0_BufB: entity work.TriStateBuffer(Behavior)
        generic map (width => 32)
        port map (
            A => (others => '0'),
            E => ReadSelectB(0),
            Q => ReadDataB
        );
    RegArray: for i in 1 to 31 generate
        signal RegOut: std_logic_vector(31 downto 0);
    begin
        Reg: entity work.Reg(Behavior)
            generic map (width => 32)
            port map (
                D      => WriteData,
                Q      => RegOut,
                Enable => WriteSelect(i) and Write,
                Reset  => '0',
                Clock  => Clock 
            );
        BufA: entity work.TriStateBuffer(Behavior)
            generic map (width => 32)
            port map (
                A => RegOut,
                E => ReadSelectA(i),
                Q => ReadDataA
            );
        BufB: entity work.TriStateBuffer(Behavior)
            generic map (width => 32)
            port map (
                A => RegOut,
                E => ReadSelectB(i),
                Q => ReadDataB
            );
    end generate RegArray;
  
    process (WriteAddr) begin
        WriteSelect <= (others => '0');
        WriteSelect(index(WriteAddr)) <= '1';
    end process;

    process (ReadAddrA) begin
        ReadSelectA <= (others => '0');
        ReadSelectA(index(ReadAddrA)) <= '1';
    end process;

    process (ReadAddrB) begin
        ReadSelectB <= (others => '0');
        ReadSelectB(index(ReadAddrB)) <= '1';
    end process;

end architecture Behavior;
