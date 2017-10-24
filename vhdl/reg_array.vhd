-- File   : address_decoder_v1.vhd
-- Author : Arun jeevaraj
-- Team   : Arun and Deepak Yadav  Team Mentor : Liang Liu 
-- usage  : level 2 of control flow , interfaces the address decoder and master controller. , has statemachines for all the modes of instructions
--			supported by master controller. generates the required control signals for data flow and address decoder.
-- DLM    : 6/23/2016   7:36 AM 
-- Tested : modelsim student edition 10.4 a
-- Todo   : none.
-- error  : none.
-- warning: none. 
-- copyright : ArunJeevaraj. 2016. Lund University.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity reg_array is
port (
		-- data bus into register array.
		reg_in_1 : in  std_logic_vector(31 downto 0);
		-- data bus out of register array.
		reg_out_1: out std_logic_vector(31 downto 0);
		reg_out_2: out std_logic_vector(31 downto 0);
		reg_out_3: out std_logic_vector(31 downto 0);
		reg_out_4: out std_logic_vector(31 downto 0);
		-- from master controller. control signals.
		row_i    : in  std_logic_vector(5 downto 0);		-- used to write to register array.
	    reg_rwn  : in std_logic; 									-- to read or write to register array.
   reg_row_set   : in std_logic_vector(3 downto 0);                 -- should be connected row_offset.
		-- global clk and reset.
		clk      : in  std_logic;
		rst      : in std_logic
     );
end entity;


architecture reg_beh of reg_array is

constant DATA_WIDTH    : integer :=32;
constant ROW_CNT       : integer :=6;

-- only using one row of registers.. for storing 60 row element.

type register_array is array(0 to 63) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal row_register_cache: register_array;


signal row_is		  : unsigned (ROW_CNT-1 downto 0);
signal i_reg_row_set  : unsigned(3 downto 0);



begin
	i_reg_row_set<= unsigned(reg_row_set); -- need to be unsigned typecasted  to be typecasted again as indices.
        row_is   <= unsigned(row_i);

	
	
	-- reading from register array.
process( row_register_cache ,reg_rwn,i_reg_row_set) 
begin
 if(reg_rwn='0') then -- only when rwn is set to 1, reading is enabled.
	 reg_out_1 <= (others=>'0');
	 reg_out_2 <= (others=>'0');
	 reg_out_3 <= (others=>'0');
	 reg_out_4 <= (others=>'0');
 else
   case(i_reg_row_set) is
   when x"0" =>
     reg_out_1 <= row_register_cache(0);
	 reg_out_2 <= row_register_cache(1);
	 reg_out_3 <= row_register_cache(2);
	 reg_out_4 <= row_register_cache(3);
   when x"1" =>
     reg_out_1 <= row_register_cache(4);
	 reg_out_2 <= row_register_cache(5);
	 reg_out_3 <= row_register_cache(6);
	 reg_out_4 <= row_register_cache(7);
  when x"2" =>
     reg_out_1 <= row_register_cache(8);
	 reg_out_2 <= row_register_cache(9);
	 reg_out_3 <= row_register_cache(10);
	 reg_out_4 <= row_register_cache(11);
   when x"3" =>
     reg_out_1 <= row_register_cache(12);
	 reg_out_2 <= row_register_cache(13);
	 reg_out_3 <= row_register_cache(14);
	 reg_out_4 <= row_register_cache(15);
   when x"4" =>
     reg_out_1 <= row_register_cache(16);
	 reg_out_2 <= row_register_cache(17);
	 reg_out_3 <= row_register_cache(18);
	 reg_out_4 <= row_register_cache(19);
   when x"5" =>
     reg_out_1 <= row_register_cache(20);
	 reg_out_2 <= row_register_cache(21);
	 reg_out_3 <= row_register_cache(22);
	 reg_out_4 <= row_register_cache(23);
  when x"6" =>
     reg_out_1 <= row_register_cache(24);
	 reg_out_2 <= row_register_cache(25);
	 reg_out_3 <= row_register_cache(26);
	 reg_out_4 <= row_register_cache(27);
   when x"7" =>
     reg_out_1 <= row_register_cache(28);
	 reg_out_2 <= row_register_cache(29);
	 reg_out_3 <= row_register_cache(30);
	 reg_out_4 <= row_register_cache(31);
   when x"8" =>
     reg_out_1 <= row_register_cache(32);
	 reg_out_2 <= row_register_cache(33);
	 reg_out_3 <= row_register_cache(34);
	 reg_out_4 <= row_register_cache(35);
   when x"9" =>
     reg_out_1 <= row_register_cache(36);
	 reg_out_2 <= row_register_cache(37);
	 reg_out_3 <= row_register_cache(38);
	 reg_out_4 <= row_register_cache(39);
  when x"a" =>
     reg_out_1 <= row_register_cache(41);
	 reg_out_2 <= row_register_cache(41);
	 reg_out_3 <= row_register_cache(42);
	 reg_out_4 <= row_register_cache(43);
   when x"b" =>
     reg_out_1 <= row_register_cache(44);
	 reg_out_2 <= row_register_cache(45);
	 reg_out_3 <= row_register_cache(46);
	 reg_out_4 <= row_register_cache(47);
   when x"c" =>
     reg_out_1 <= row_register_cache(48);
	 reg_out_2 <= row_register_cache(49);
	 reg_out_3 <= row_register_cache(50);
	 reg_out_4 <= row_register_cache(51);
   when x"d" =>
     reg_out_1 <= row_register_cache(52);
	 reg_out_2 <= row_register_cache(53);
	 reg_out_3 <= row_register_cache(54);
	 reg_out_4 <= row_register_cache(55);
  when x"e" =>
     reg_out_1 <= row_register_cache(56);
	 reg_out_2 <= row_register_cache(57);
	 reg_out_3 <= row_register_cache(58);
	 reg_out_4 <= row_register_cache(59);
   when x"f" =>
     reg_out_1 <= row_register_cache(60);
	 reg_out_2 <= row_register_cache(61);
	 reg_out_3 <= row_register_cache(62);
	 reg_out_4 <= row_register_cache(63);
   
   when others=>
	 reg_out_1 <= (others=>'0');
	 reg_out_2 <= (others=>'0');
	 reg_out_3 <= (others=>'0');
	 reg_out_4 <= (others=>'0');
   end case;
 end if;
end process;

--- writing to register.
reg_proc: process(clk, rst) 
begin
	if(rst ='1') then
	  row_register_cache <= (others=>(others=>'0'));
	elsif( rising_edge(clk)) then
	  if(reg_rwn='0') then -- write is enabled. --- power grating..
	   row_register_cache(to_integer(row_is))<= reg_in_1;
	  
	  end if;
	end if;
end process;



end reg_beh;
	 