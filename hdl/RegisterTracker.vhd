library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity RegisterTracker is
    port (
        ReadAddrA, ReadAddrB, WriteAddr, FreeAddr: in regaddr_t;
        Stall: out std_ulogic;
        Clock, ReadA, ReadB, Reserve, Free: in std_ulogic
    );
end entity RegisterTracker;

architecture Behavior of RegisterTracker is
    signal SemUp, SemDown, SemLocked: std_ulogic_vector(31 downto 0) := (others => '0');
    signal SemIsZero: std_ulogic_vector(31 downto 0) := (others => '1');
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
                IsZero => SemIsZero(i),
                Clock => Clock
            );
    end generate;
    process (WriteAddr, Reserve, SemIsZero, ReadAddrA, ReadAddrB) begin
        SemUp <= (others => '0');
        SemUp(index(WriteAddr)) <= Reserve when SemIsZero(index(ReadAddrA)) = '1'
                                            and SemIsZero(index(ReadAddrB)) = '1' else '0';
    end process;
    process (FreeAddr, Free) begin
        SemDown <= (others => '0');
        SemDown(index(FreeAddr)) <= Free;
    end process;
    Stall <= (SemLocked(index(ReadAddrA)) and ReadA) or
             (SemLocked(index(ReadAddrB)) and ReadB);
end architecture Behavior;
