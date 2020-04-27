--
-- vhdl architecture cad_lib.MemorySystem.behavior
--
-- created:
--          by - gta.unknown (desktop-fuqimb8)
--          at - 03:27:10 04/27/2020
--
-- using mentor graphics hdl designer(tm) 2018.2 (build 19)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity MemorySystem is
    port ( 
        Address, DataIn:                in  std_ulogic_vector(31 downto 0);
        Clock, WriteEnable, ReadEnable: in  std_ulogic;
        MemDelay:                       out std_ulogic;
        DataOut:                        out std_ulogic_vector(31 downto 0)
    );
end entity MemorySystem;

--
architecture behavior of MemorySystem is
  constant loadfilename : string := "memorydivide.txt";
  
  subtype st_mem_addr is std_ulogic_vector(29 downto 0);
  subtype st_mem_data is std_ulogic_vector(31 downto 0);
  
  constant UNDEFINED : st_mem_data := (others => 'X');
  
  type t_mem_page is array(0 to 1023) of st_mem_data; -- memory page
 
begin
  
  mem : process(Address, Clock)
    variable memloaded : boolean := false;
    variable page : t_mem_page;
    variable wordnumber : integer range 0 to 1023;
    variable pagenumber : natural;
    variable maddr : st_mem_addr;
    variable mdata : st_mem_data;
    variable invalid_addr : boolean;
    variable findex : natural;
    variable l : line;
    variable bv : bit_vector(31 downto 0);
    variable iv : integer;
    file load_file : text open read_mode is loadfilename;
  begin
    if (not memloaded) then
      memloaded := true;
      for w in t_mem_page'range loop
        page(w) := UNDEFINED; -- mark data on page UNDEFINED
      end loop;
      findex := 0;
      while ((not endfile(load_file)) and (findex < 1024)) loop -- load page zero
        readline(load_file,l);
        read(l,bv);
        page(findex) := to_stdlogicvector(bv);
        findex := findex + 1;
      end loop;
      -- page zero initialized     
    end if;
    
    maddr := Address(31 downto 2);
    invalid_addr := is_x(maddr);
    
    if not invalid_addr then
      pagenumber := conv_integer(maddr(29 downto 10));
      wordnumber := conv_integer(maddr(9 downto 0));
    end if;     
    
    if (rising_edge(Clock) and (WriteEnable = '1') and not invalid_addr) then
      if (pagenumber = 0) then
        mdata := DataIn;
        page(wordnumber) := mdata;
        report "writing " & to_string(DataIn) & " to address " & to_string(Address);
      else
        report "writing " & to_string(DataIn) & " to address " & to_string(Address) & " ** no memory **";
      end if;
    end if;
    
    if invalid_addr then
      DataOut <= UNDEFINED;
    else
      if (pagenumber = 0) then
        DataOut <= page(wordnumber);
      else
        DataOut <= UNDEFINED;
      end if;
    end if;   
  end process;

  MemDelay <= '0';
  
end architecture behavior;

