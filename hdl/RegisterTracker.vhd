library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterTracker is
    port (
        ReadAddrA, ReadAddrB, WriteAddr, FreeAddr: in std_ulogic_vector(4 downto 0);
        Stall: out std_ulogic;
        Clock, ReadA, ReadB, Reserve, Free: in std_ulogic
    );
end entity RegisterTracker;

architecture Behavior of RegisterTracker is
    signal SemUp, SemDown, SemLocked: std_ulogic_vector(31 downto 0) := (others => '0');
    function index(i: std_ulogic_vector) return integer is begin
        return to_integer(unsigned(i));
    end;
begin
    SemArray: for i in 1 to 31 generate
    begin
        Sem: entity work.Semaphore(Behavior)
            generic map (bits => 2)
            port map (
                Up => SemUp(i),
                Down => SemDown(i),
                Locked => SemLocked(i),
                Clock => Clock
            );
    end generate;
    process (WriteAddr, Reserve) begin
        SemUp <= (others => '0');
        SemUp(index(WriteAddr)) <= Reserve; 
    end process;
    process (FreeAddr, Free) begin
        SemDown <= (others => '0');
        SemDown(index(FreeAddr)) <= Free;
    end process;
    Stall <= '1' when
           (SemLocked(index(ReadAddrA)) = '1' and ReadA = '1') -- and ReadAddrA /= WriteAddr)
        or (SemLocked(index(ReadAddrB)) = '1' and ReadB = '1') -- and ReadAddrB /= WriteAddr)
        else '0';
end architecture Behavior;
