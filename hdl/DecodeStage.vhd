library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity DecodeStage is
    port (
        -- Pipeline i/o --
        Instruction, PC:    in  std_ulogic_vector(31 downto 0);  -- From fetch
        Func:               out RV32I_Op;
        Left, Right, Extra: out std_ulogic_vector(31 downto 0);
        DestReg:            out std_ulogic_vector(4 downto 0);   -- dest reg address
        RS1v, RS2v, RDv:    out std_ulogic;
        Stall:              in  std_ulogic;
        InstructionType:    out InsType;
        -- Register file i/o
        RegAddrA, RegAddrB: out std_ulogic_vector(4 downto 0);   -- Reg A, B addresses
        RegDataA, RegDataB: in  std_ulogic_vector(31 downto 0);   -- Reg A, B data
        -- Global i/o --
        Clock:              in  std_ulogic
    );
end entity DecodeStage;

architecture Behavior of DecodeStage is
    signal BufferedInstruction,
           BufferedPC, 
           Immediate: std_ulogic_vector(31 downto 0);
    constant FOUR: std_ulogic_vector(31 downto 0) := X"00_00_00_04";
begin
    InstructionBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => Instruction,
            Q      => BufferedInstruction,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    PCBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => PC,
            Q      => BufferedPC,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    Decoder: entity work.Decoder(Behavior)
        port map (
            instruction => BufferedInstruction,
            Func => Func,
            RS1  => RegAddrA,
            RS2  => RegAddrB,
            RD   => DestReg,
            RS1v => RS1v,
            RS2v => RS2v,
            RDv  => RDv,
            Immediate => Immediate,
            InstructionType => InstructionType
        );
process (all)
    function uadd(
        a: std_ulogic_vector;
        b: std_ulogic_vector
    ) return std_ulogic_vector is begin
        return std_ulogic_vector(unsigned(a) + unsigned(b));
    end function;
begin
    -- Assign RegDataA, RegDataB, Immediate to outputs Left, Right, and Extra
    -- Also do math for branches, jumps, and AUIPC
    case InstructionType is
        when R =>  -- ALU
            Left  <= RegDataA;
            Right <= RegDataB;
            Extra <= (others => '0');
        when I =>  -- Loads, ALU immediates, JALR
            Left  <= RegDataA;
            Right <= Immediate;
            Extra <= uadd(BufferedPC, FOUR) when Func = JALR else (others => '0');
        when S =>  -- Stores
            Left  <= Immediate;
            Right <= RegDataA;
            Extra <= RegDataB;
        when SB =>  -- Branches (B-type)
            Left  <= RegDataA;
            Right <= RegDataB;
            Extra <= uadd(BufferedPC, Immediate);
        when U =>  -- LUI, AUIPC
            Left  <= (others => '0');
            Right <= (others => '0');
            Extra <= uadd(BufferedPC, Immediate) when Func = AUIPC else Immediate;
        when UJ =>  -- JAL
            --Right <= (others => '0');
            Left  <= Immediate;
            Right <= BufferedPC;
            Extra <= uadd(BufferedPC, FOUR);
        when others =>
            Left  <= (others => 'X');
            Right <= (others => 'X');
            Extra <= (others => 'X');
    end case;
end process;
end architecture Behavior; 
