library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I.all;

entity Execute is
    port (
        -- From Decode stage --
        FuncIn:                   in  RV32I_Op;
        InstructionType:          in  InsType;
        Left, Right, Extra:       in  word_t;
        DestRegIn:                in  regaddr_t;
        -- To Fetch stage --
        Jaddr:                    out word_t;
        Jump:                     out std_ulogic;
        -- To Memory stage --
        Address, Data:            out word_t;
        DestRegOut:               out regaddr_t;
        FuncOut:                  out RV32I_Op;
        -- Global i/o --
        Clock, Stall:             in  std_ulogic
    );
end entity Execute;

architecture Behavior of Execute is
    signal bLeft, bRight, bExtra, ALUResult: word_t;
    signal bFunc: RV32I_Op;
    signal bInstructionType: InsType;
    signal bDestReg: regaddr_t;
begin
    LeftBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => Left,
            Q      => bLeft,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    RightBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => Right,
            Q      => bRight,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    ExtraBuffer: entity work.Reg(Behavior)
        generic map (width => 32)
        port map (
            D      => Extra,
            Q      => bExtra,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    DestRegBuffer: entity work.Reg(Behavior)
        generic map (width => 5)
        port map (
            D      => DestRegIn,
            Q      => bDestReg,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    FuncBuffer: entity work.FuncReg(Behavior)
        port map (
            D      => FuncIn,
            Q      => bFunc,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    ITypeBuffer: entity work.ITypeReg(Behavior)
        port map (
            D      => InstructionType,
            Q      => bInstructionType,
            Enable => not Stall,
            Reset  => '0',
            Clock  => Clock 
        );
    ALU: entity work.ALU(Behavior)
        port map (
            Func => bFunc,
            Left => bLeft,
            Right => bRight,
            ALUResult => ALUResult
        );
process (all) begin
    DestRegOut <= bDestReg;
    FuncOut <= bFunc;

    -- Default assignments (may be overwritten below) --
    Jump <= '0'; -- only set for JALR, JAL, and B-type functions
    Jaddr <= (others => '0'); -- same as above
    Address <= (others => '0'); -- only set for loads/stores
    Data <= (others => '0'); -- set by all except loads and branches

    case bInstructionType is
        when R =>  -- ALU
            Data <= ALUResult;
        when I =>  -- Loads, ALU immediates, JALR
            case bFunc is
                when LB | LH | LW =>
                    Address <= ALUResult;
                when JALR => 
                    Data <= bExtra; -- pc+4
                    Jump <= '1';
                    Jaddr <= ALUResult;
                when others => -- ALU immediates (including STL etc)
                    Data <= ALUResult;
            end case;
        when S =>  -- Stores
            Address <= ALUResult;
            Data <= bExtra; -- Data to be stored
        when SB =>  -- Branches (B-type)
            Jaddr <= bExtra; -- target branch address
            Jump <= ALUResult(0);
        when U =>  -- LUI, AUIPC
            Data <= bExtra; -- already calculated in decode stage
        when UJ =>  -- JAL
            Data <= bExtra; -- pc+4
            Jump <= '1';
            Jaddr <= ALUResult;
        when others =>
    end case;
end process;
end architecture Behavior;

