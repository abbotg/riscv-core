library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity DecodeStage is
    port (
        -- Pipeline i/o --
        Instruction, PC:      in  word_t;  -- From fetch
        Func:                 out RV32I_Op;
        Left, Right, Extra:   out word_t;
        DestReg:              out regaddr_t;   -- dest reg address
        Stall1, Stall2, Jump: in  std_ulogic; -- stalls from reg tracker or memory stage
        InstructionType:      out InsType;
        -- Register tracker --
        RS1v, RS2v, RDv:    out std_ulogic; -- readA, readB, and reserve control lines
        RTWriteAddr:        out regaddr_t;
        -- Register file i/o
        RegAddrA, RegAddrB: out regaddr_t;   -- Reg A, B addresses
        RegDataA, RegDataB: in  word_t;   -- Reg A, B data
        -- Global i/o --
        Clock:              in  std_ulogic
    );
end entity DecodeStage;

architecture Behavior of DecodeStage is
    signal bInstruction, bPC, Immediate: word_t;
    signal Stall: std_ulogic;
    signal iFunc: RV32I_Op;
    signal iDestReg: regaddr_t;
    --signal iRDv: std_ulogic;
    constant FOUR: word_t := X"00_00_00_04";
begin
    InstructionBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => Instruction,
            Q      => bInstruction,
            Enable => not Stall,
            Reset  => Jump,
            Clock  => Clock 
        );
    PCBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => PC,
            Q      => bPC,
            Enable => not Stall,
            Reset  => Jump,
            Clock  => Clock 
        );
    Decoder: entity work.Decoder(Behavior)
        port map (
            instruction => bInstruction,
            Func => iFunc,
            RS1  => RegAddrA,
            RS2  => RegAddrB,
            RD   => iDestReg,
            RS1v => RS1v,
            RS2v => RS2v,
            RDv  => RDv,
            Immediate => Immediate,
            InstructionType => InstructionType
        );
process (all)
    function add(
        a: std_ulogic_vector;
        b: std_ulogic_vector
    ) return std_ulogic_vector is begin
        return std_ulogic_vector(unsigned(a) + unsigned(b));
    end function;
begin
    -- Assign RegDataA, RegDataB, Immediate to outputs Left, Right, and Extra
    -- Also do math for branches, jumps, and AUIPC
    RTWriteAddr <= iDestReg;
    
    if Stall then
        Func    <= NOP; -- Send NOP down pipeline 
        --RDv     <= '0'; -- De-asserted on stall so that the reg tracker increments the semaphore only once
        DestReg <= (others => '0'); -- Simulate a NOP (ADDI x0,x0,0) (NOP should have no side-effects in execute stage
        Left    <= (others => '0'); -- so this is technically pointless
        Right   <= (others => '0');
        Extra   <= (others => '0');
        -- RS1v, RS2v remain asserted so that the reg tracker will continue to stall until freed
    else
        -- Fwd normal intermediate values from decoder
        Func    <= NOP when bInstruction = NOP_inst or bInstruction(1 downto 0) /= "11" else iFunc; 
        --RDv     <= iRDv;
        DestReg <= iDestReg;
        case InstructionType is
            when R =>  -- ALU
                Left  <= RegDataA;
                Right <= RegDataB;
                Extra <= (others => '0');
            when I =>  -- Loads, ALU immediates, JALR
                Left  <= RegDataA;
                Right <= Immediate;
                Extra <= add(bPC, FOUR) when Func = JALR else (others => '0');
            when S =>  -- Stores
                Left  <= Immediate;
                Right <= RegDataA;
                Extra <= RegDataB;
            when SB =>  -- Branches (B-type)
                Left  <= RegDataA;
                Right <= RegDataB;
                Extra <= add(bPC, Immediate);
            when U =>  -- LUI, AUIPC
                Left  <= (others => '0');
                Right <= (others => '0');
                Extra <= add(bPC, Immediate) when Func = AUIPC else Immediate;
            when UJ =>  -- JAL
                --Right <= (others => '0');
                Left  <= Immediate;
                Right <= bPC;
                Extra <= add(bPC, FOUR);
            when others =>
                Left  <= (others => 'X');
                Right <= (others => 'X');
                Extra <= (others => 'X');
        end case;
    end if;
end process;

Stall <= Stall1 or Stall2;

end architecture Behavior; 
