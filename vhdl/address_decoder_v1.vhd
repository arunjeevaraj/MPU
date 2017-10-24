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

entity address_decoder_v1 is 
port(
		address   : out std_logic_vector(13 downto 0);
		row_cnt   : in  std_logic_vector(5 downto 0);
		row_set   : in  std_logic_vector(3 downto 0);
	    mat_index : in  std_logic_vector(3 downto 0);
	    mat_order : in std_logic_vector(5 downto 0);
	    ram_sel_in: in std_logic_vector(3 downto 0);
	    to_ram_sel: out std_logic_vector(3 downto 0)
	);
end entity;


architecture beh of address_decoder_v1 is


-- used to fill up the LUT.
-- decimal to hex.. max 10 bits needed log2(O_60*14)
-- may use 13 bits of constant for row offset address. as it only needs 13 bits.
-- and for mat, index use seperate constants that are 14 bits long.
constant O_8   : unsigned(13 downto 0):="00"&x"008"; -- offset by 8.
constant O_12  : unsigned(13 downto 0):="00"&x"00c"; -- offset by 12.
constant O_16  : unsigned(13 downto 0):="00"&x"010"; -- offset by 16.
constant O_20  : unsigned(13 downto 0):="00"&x"014"; -- offest by 20.
constant O_24  : unsigned(13 downto 0):="00"&x"018"; -- offset by 24.
constant O_28  : unsigned(13 downto 0):="00"&x"01C"; -- offset by 28.
constant O_32  : unsigned(13 downto 0):="00"&x"020"; -- offset by 32.
constant O_36  : unsigned(13 downto 0):="00"&x"024"; -- offset by 36.
constant O_40  : unsigned(13 downto 0):="00"&x"028"; -- offset by 40.
constant O_44  : unsigned(13 downto 0):="00"&x"02c"; -- offset by 44.
constant O_48  : unsigned(13 downto 0):="00"&x"030"; -- offset by 48.
constant O_52  : unsigned(13 downto 0):="00"&x"034"; -- offset by 52.
constant O_56  : unsigned(13 downto 0):="00"&x"038"; -- offset by 52.
constant O_60  : unsigned(13 downto 0):="00"&x"03c"; -- offset by 60.
constant O_64  : unsigned(13 downto 0):="00"&x"040"; -- offset by 64.
constant O_80  : unsigned(13 downto 0):="00"&x"050"; -- offset by 80.
constant O_100 : unsigned(13 downto 0):="00"&x"064"; -- offset by 80.
constant O_144 : unsigned(13 downto 0):="00"&x"090"; -- offset by 80.
constant O_196 : unsigned(13 downto 0):="00"&x"0c4"; -- offset by 80.
constant O_256 : unsigned(13 downto 0):="00"&x"100"; -- offset by 80.
constant O_324 : unsigned(13 downto 0):="00"&x"144"; -- offset by 80.
constant O_400 : unsigned(13 downto 0):="00"&x"190"; -- offset by 80.
constant O_484 : unsigned(13 downto 0):="00"&x"1e4"; -- offset by 80.
constant O_576 : unsigned(13 downto 0):="00"&x"240"; -- offset by 80.
constant O_676 : unsigned(13 downto 0):="00"&x"2a4"; -- offset by 80.
constant O_784 : unsigned(13 downto 0):="00"&x"310"; -- offset by 80.
constant O_900 : unsigned(13 downto 0):="00"&x"384"; -- offset by 80.


constant c_test : unsigned(3 downto 0):="1010";
--- zeros bit to concatenate.
constant 
     ZEROS_8BL : unsigned(7 downto 0) :=(others=>'0');
-- mat_index address max bits needed .. 14 log2(60*15*15)
		
signal mat_index_address,                           -- add all these three addresses to get the address out.
	   row_set_address,
       row_cnt_address,
       address_out 	   :unsigned(13 downto 0);	    -- generate the offset addresses.

signal    enc_mat_order: std_logic_vector(3 downto 0); -- only multiples of 4 is used for LUT. so to optimize the LUT.
													-- encode the mat_order to a 4 bit value from the 6 bit value.											
begin

-- only multiples of 4 is used for LUT. so to optimize the LUT.
-- encode the mat_order to a 4 bit value from the 6 bit value.
mat_order_encode: process(mat_order)
begin
  case mat_order is
	  when "001000"=> --8
	   enc_mat_order <=x"0";
	  when "001100"=> --12
	   enc_mat_order <=x"1";
	  when "010000"=> --16
	   enc_mat_order <=x"2";
	  when "010100"=>-- d20 
	   enc_mat_order <=x"3";
	  when "011000"=>-- d24 
	   enc_mat_order <=x"4";
	  when "010110"=>-- d28 
	   enc_mat_order <=x"5";
	  when "100000"=>-- d32 
	   enc_mat_order <=x"6";
	  when "100100"=>-- d36 
	   enc_mat_order <=x"7";
	  when "101000"=>-- d40 
	   enc_mat_order <=x"8";
	  when "101100"=>-- d44 
	   enc_mat_order <=x"9";
	  when "110000"=>-- d48
	   enc_mat_order <=x"a";
	  when "110100"=>-- d52
	   enc_mat_order <=x"b";
	  when "111000"=>-- d56
	   enc_mat_order <=x"c";
	  when "111100"=>-- d60
	   enc_mat_order <=x"d";
	   -- optional to encode 63 as 64... ? have to change the row_cnt_max and other max values in the mat controller if need be.
	  when others =>
	   enc_mat_order <= (others=>'0');
  end case;
  
end process;


-- get the offset address from mat_order- and row_set from mat controller.- A LUT is set up here for that.
-- this can be placed in a ram, but for this much of table a look up table should suffix.
row_set_address_gen: process(enc_mat_order,row_set)
begin
 case enc_mat_order is 
 
--	only making for multiples of d4.
--	for four no offset needed.
	when x"0"=>-- when mat_order is d8
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_8;
		when others=>
		row_set_address <= (others=>'0');
	  end case;
		
	when x"1"=>-- d12
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_12;
		when x"2"=>
		  row_set_address <= O_24;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
	when x"2"=>--d16
	 case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_16;
		when x"2"=>
		  row_set_address <= O_32;
		when x"3"=>
		  row_set_address <= O_48;
		when others=> -- is not used for the d16 case.
		row_set_address <= (others=>'0');
	  end case;	
	when x"3"=>-- d20 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_20;
		when x"2"=>
		  row_set_address <= O_40;
		when x"3"=>
		  row_set_address <= O_60;
		when x"4"=>
		  row_set_address <= O_80;
		when others=>
		row_set_address <= (others=>'0'); 
	  end case;	
	when x"4"=>-- d24 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_24;
		when x"2"=>
		  row_set_address <= O_48;
		when x"3"=>
		  row_set_address <= O_48 + O_24;			  --O_72.
		when x"4"=>
		  row_set_address <= O_48 + O_48; 	      --O_96.
		when x"5"=>
		  row_set_address <= O_48 + O_48 + O_48 + O_24; --O_120
		when others=>
		row_set_address <= (others=>'0'); 
	  end case;	
	when x"5"=>-- d28 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_28;
		when x"2"=>
		  row_set_address <= O_28 + O_28; --56.
		when x"3"=>
		  row_set_address <= O_28 + O_28 + O_28;
		when x"4"=>
		  row_set_address <= O_28 + O_28 + O_28 + O_28;
		when x"5"=>
		  row_set_address <= O_28 + O_28 + O_28 + O_28 + O_28;
		when x"6"=>
		  row_set_address <= O_28 + O_28 + O_28 + O_28 + O_28 + O_28;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
	when x"6"=>-- d32 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_32;
		when x"2"=>
		  row_set_address <= O_32 + O_32;
		when x"3"=>
		  row_set_address <= O_32 + O_32 + O_32;
		when x"4"=>
		  row_set_address <= O_32 + O_32 + O_32 + O_32;
		when x"5"=>
		  row_set_address <= O_32 + O_32 + O_32 + O_32 + O_32;
		when x"6"=>
		  row_set_address <= O_32 + O_32 + O_32 + O_32 + O_32 + O_32;
		when x"7"=>
		  row_set_address <= O_32 + O_32 + O_32 + O_32 + O_32 + O_32 + O_32;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
	when x"7"=>-- d36 
	 case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_36;
		when x"2"=>
		  row_set_address <= O_36 + O_36;
		when x"3"=>
		  row_set_address <= O_36 + O_36 + O_36;
		when x"4"=>
		  row_set_address <= O_36 + O_36 + O_36 + O_36;
		when x"5"=>
		  row_set_address <= O_36 + O_36 + O_36 + O_36 + O_36;
		when x"6"=>
		  row_set_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
		when x"7"=>
		  row_set_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
		when x"8"=>
		  row_set_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
	when x"8"=>-- d40 
	 case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_40;
		when x"2"=>
		  row_set_address <= O_40 + O_40;
		when x"3"=>
		  row_set_address <= O_40 + O_40 + O_40;
		when x"4"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40;
		when x"5"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40 + O_40;
		when x"6"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40 + O_40 + O_40;
		when x"7"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40;
		when x"8"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40;
		when x"9"=>
		  row_set_address <= O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40 + O_40;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
    when x"9"=>-- d44 
	 case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_44;
		when x"2"=>          
		  row_set_address <= O_44 + O_44;
		when x"3"=>          
		  row_set_address <= O_44 + O_44 + O_44;
		when x"4"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44;
		when x"5"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44;
		when x"6"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44 + O_44;
		when x"7"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44;
		when x"8"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44;
		when x"9"=>          
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44;
		when x"a"=>
		  row_set_address <= O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44 + O_44;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
	when x"a"=>-- d48 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_48;
		when x"2"=>          
		  row_set_address <= O_48 + O_48;
		when x"3"=>          
		  row_set_address <= O_48 + O_48 + O_48;
		when x"4"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48;
		when x"5"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48;
		when x"6"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when x"7"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when x"8"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when x"9"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when x"a"=>          
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when x"b"=>
		  row_set_address <= O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48 + O_48;
		when others=>
		row_set_address <= (others=>'0');
	  end case;	
    when x"b"=>-- d52 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_52;
		when x"2"=>          
		  row_set_address <= O_52 + O_52;
		when x"3"=>          
		  row_set_address <= O_52 + O_52 + O_52;
		when x"4"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52;
		when x"5"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52;
		when x"6"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"7"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"8"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"9"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"a"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"b"=>          
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when x"c"=>
		  row_set_address <= O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52 + O_52;
		when others=>
		row_set_address <= (others=>'0');
	  end case;
	when x"c"=>-- d56 
	 case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_56;
		when x"2"=>          
		  row_set_address <= O_56 + O_56;
		when x"3"=>          
		  row_set_address <= O_56 + O_56 + O_56;
		when x"4"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56;
		when x"5"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56;
		when x"6"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"7"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"8"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"9"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"a"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"b"=>          
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"c"=>
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when x"d"=>
		  row_set_address <= O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56 + O_56;
		when others=>
		row_set_address <= (others=>'0');
	  end case;
	when x"d"=>-- d60 
	  case row_set is
	    when x"0"=>
		  row_set_address <= (others=>'0');
	    when x"1"=>
		  row_set_address <= O_60;
		when x"2"=>          
		  row_set_address <= O_60 + O_60;
		when x"3"=>          
		  row_set_address <= O_60 + O_60 + O_60;
		when x"4"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60;
		when x"5"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60;
		when x"6"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"7"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"8"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"9"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"a"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"b"=>          
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"c"=>
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"d"=>
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when x"e"=>
		  row_set_address <= O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60 + O_60;
		when others=>
		row_set_address <= (others=>'0');
	  end case;
	when others =>
	   row_set_address <=(others =>'0');
		
	end case;
	
end process;

--LUT for the MAT index.
-- have to generate matrix offset address based on mat_index and mat_order.

mat_index_address_gen: process(mat_index,enc_mat_order)
begin
 case enc_mat_order is 
 
	when x"0"=>-- when mat_order is d8
	  case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_16;  -- 8*8/2
	   when x"2" =>
	    mat_index_address <= O_16  +  O_16;
	   when x"3" =>
	    mat_index_address <= O_16 + O_16 + O_16;
	   when x"4" =>
	    mat_index_address <= O_16 + O_16 + O_16 + O_16;
	   when x"5" =>
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"6" =>                   
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"7" =>                             
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"8" =>                             
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"9" =>                                      
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"a" =>                                      
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"b" =>                                               
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"c" =>                                               
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"d" =>                                                        
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"e" =>                                                        
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when x"f" =>                                                                 
	    mat_index_address <= O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16 + O_16;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"1"=>-- when 12
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_36;  --12 *12/4
	   when x"2" =>
	    mat_index_address <= O_36 + O_36;
	   when x"3" =>
	    mat_index_address <= O_36 + O_36 + O_36;
	   when x"4" =>
	    mat_index_address <= O_36 + O_36 + O_36 + O_36;
	   when x"5" =>                   
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"6" =>                   
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"7" =>                             
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"8" =>                            
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"9" =>                                       
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"a" =>                                       
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"b" =>                                                 
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"c" =>                                                 
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"d" =>                                                           
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"e" =>                                                           
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when x"f" =>                                                                     
	    mat_index_address <= O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36 + O_36;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"2"=> --16
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_64; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_64 + O_64;
	   when x"3" =>
	    mat_index_address <= O_64 + O_64 + O_64;
	   when x"4" =>
	    mat_index_address <= O_64 + O_64 + O_64 + O_64;
	   when x"5" =>                   
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"6" =>                   
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"7" =>                             
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"8" =>                             
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"9" =>                                       
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"a" =>                                       
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"b" =>                                                
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"c" =>                                                
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"d" =>                                                         
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"e" =>                                                         
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when x"f" =>                                                                  
	    mat_index_address <= O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64 + O_64;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"3"=> --20
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_100; --20*20/4 = 100
	   when x"2" =>
	    mat_index_address <= O_100 + O_100;
	   when x"3" =>
	    mat_index_address <= O_100 + O_100 + O_100;
	   when x"4" =>
	    mat_index_address <= O_100 + O_100 + O_100 + O_100;
	   when x"5" =>                   
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"6" =>                   
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"7" =>                             
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"8" =>                             
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"9" =>                                       
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"a" =>                                       
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"b" =>                                                
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"c" =>                                                
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"d" =>                                                         
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"e" =>                                                         
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when x"f" =>                                                                  
	    mat_index_address <= O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100 + O_100;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"4"=> --24
	    case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_144; --24*24/4 = 64
	   when x"2" =>
	    mat_index_address <= O_144 + O_144;
	   when x"3" =>
	    mat_index_address <= O_144 + O_144 + O_144;
	   when x"4" =>
	    mat_index_address <= O_144 + O_144 + O_144 + O_144;
	   when x"5" =>                   
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"6" =>                   
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"7" =>                             
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"8" =>                             
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"9" =>                                       
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"a" =>                                       
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"b" =>                                                
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"c" =>                                                
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"d" =>                                                         
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"e" =>                                                         
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when x"f" =>                                                                  
	    mat_index_address <= O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144 + O_144;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"5"=> --28
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_196; --28*28/4 = 64
	   when x"2" =>
	    mat_index_address <= O_196 + O_196;
	   when x"3" =>
	    mat_index_address <= O_196 + O_196 + O_196;
	   when x"4" =>
	    mat_index_address <= O_196 + O_196 + O_196 + O_196;
	   when x"5" =>                   
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"6" =>                   
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"7" =>                             
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"8" =>                             
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"9" =>                                       
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"a" =>                                       
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"b" =>                                                
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"c" =>                                                
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"d" =>                                                         
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"e" =>                                                         
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when x"f" =>                                                                  
	    mat_index_address <= O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196 + O_196;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"6"=> --32
	    case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_256; --32*32/4 = 64
	   when x"2" =>
	    mat_index_address <= O_256 + O_256;
	   when x"3" =>
	    mat_index_address <= O_256 + O_256 + O_256;
	   when x"4" =>
	    mat_index_address <= O_256 + O_256 + O_256 + O_256;
	   when x"5" =>                   
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"6" =>                   
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"7" =>                             
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"8" =>                             
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"9" =>                                       
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"a" =>                                       
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"b" =>                                                
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"c" =>                                                
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"d" =>                                                         
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"e" =>                                                         
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when x"f" =>                                                                  
	    mat_index_address <= O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256 + O_256;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"7"=> --36
	  case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_324; --36*36/4 = 64
	   when x"2" =>
	    mat_index_address <= O_324 + O_324;
	   when x"3" =>
	    mat_index_address <= O_324 + O_324 + O_324;
	   when x"4" =>
	    mat_index_address <= O_324 + O_324 + O_324 + O_324;
	   when x"5" =>                   
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"6" =>                   
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"7" =>                             
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"8" =>                             
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"9" =>                                       
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"a" =>                                       
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"b" =>                                                
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"c" =>                                                
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"d" =>                                                         
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"e" =>                                                         
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when x"f" =>                                                                  
	    mat_index_address <= O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324 + O_324;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"8"=>
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_400; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_400 + O_400;
	   when x"3" =>
	    mat_index_address <= O_400 + O_400 + O_400;
	   when x"4" =>
	    mat_index_address <= O_400 + O_400 + O_400 + O_400;
	   when x"5" =>                   
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"6" =>                   
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"7" =>                             
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"8" =>                             
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"9" =>                                       
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"a" =>                                       
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"b" =>                                                
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"c" =>                                                
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"d" =>                                                         
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"e" =>                                                         
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when x"f" =>                                                                  
	    mat_index_address <= O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400 + O_400;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"9"=>
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_484; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_484 + O_484;
	   when x"3" =>
	    mat_index_address <= O_484 + O_484 + O_484;
	   when x"4" =>
	    mat_index_address <= O_484 + O_484 + O_484 + O_484;
	   when x"5" =>                   
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"6" =>                   
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"7" =>                             
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"8" =>                             
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"9" =>                                       
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"a" =>                                       
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"b" =>                                                
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"c" =>                                                
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"d" =>                                                         
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"e" =>                                                         
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when x"f" =>                                                                  
	    mat_index_address <= O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484 + O_484;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"a"=>
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_576; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_576 + O_576;
	   when x"3" =>
	    mat_index_address <= O_576 + O_576 + O_576;
	   when x"4" =>
	    mat_index_address <= O_576 + O_576 + O_576 + O_576;
	   when x"5" =>                   
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"6" =>                   
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"7" =>                             
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"8" =>                             
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"9" =>                                       
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"a" =>                                       
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"b" =>                                                
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"c" =>                                                
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"d" =>                                                         
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"e" =>                                                         
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when x"f" =>                                                                  
	    mat_index_address <= O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576 + O_576;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"b"=>
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_676; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_676 + O_676;
	   when x"3" =>
	    mat_index_address <= O_676 + O_676 + O_676;
	   when x"4" =>
	    mat_index_address <= O_676 + O_676 + O_676 + O_676;
	   when x"5" =>                   
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"6" =>                   
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"7" =>                             
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"8" =>                             
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"9" =>                                       
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"a" =>                                       
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"b" =>                                                
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"c" =>                                                
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"d" =>                                                         
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"e" =>                                                         
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when x"f" =>                                                                  
	    mat_index_address <= O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676 + O_676;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"c"=>
	   case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_784; --16*16/4 = 64
	   when x"2" =>
	    mat_index_address <= O_784 + O_784;
	   when x"3" =>
	    mat_index_address <= O_784 + O_784 + O_784;
	   when x"4" =>
	    mat_index_address <= O_784 + O_784 + O_784 + O_784;
	   when x"5" =>                   
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"6" =>                   
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"7" =>                             
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"8" =>                             
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"9" =>                                       
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"a" =>                                       
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"b" =>                                                
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"c" =>                                                
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"d" =>                                                         
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"e" =>                                                         
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when x"f" =>                                                                  
	    mat_index_address <= O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784 + O_784;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when x"d"=> --60
	  case mat_index is
	   when x"0" => 
	    mat_index_address <= (others=>'0');
	   when x"1" => 
	    mat_index_address <= O_900; --60*60/4 = 64
	   when x"2" =>
	    mat_index_address <= O_900 + O_900;
	   when x"3" =>
	    mat_index_address <= O_900 + O_900 + O_900;
	   when x"4" =>
	    mat_index_address <= O_900 + O_900 + O_900 + O_900;
	   when x"5" =>                   
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"6" =>                   
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"7" =>                             
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"8" =>                             
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"9" =>                                       
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"a" =>                                       
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"b" =>                                                
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"c" =>                                                
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"d" =>                                                         
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"e" =>                                                         
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when x"f" =>                                                                  
	    mat_index_address <= O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900 + O_900;
	   when others=>
	    mat_index_address <= (others=>'0');
	   end case;
	when others=>
    mat_index_address <=(others =>'0');
	
	end case;
end process;

-- row_cnt_address_generate.
row_cnt_address <= ZEROS_8BL & unsigned(row_cnt);

-- ram_sel_generate.
ram_sel_out_gen: process(ram_sel_in)
begin
 if(ram_sel_in(3 downto 2)="01") then		-- select all the RAMS.
	to_ram_sel <="1111";
 elsif(ram_sel_in(3 downto 2)="10") then	-- deselect all the RAMS.
        to_ram_sel <="0000";
 else
	  case ram_sel_in(1 downto 0) is
		  when "00"=>
			to_ram_sel<="0001";
		  when "01"=>
			to_ram_sel<="0010";
		  when "10"=>
			to_ram_sel<="0100";
		  when "11"=>
			to_ram_sel<="1000";
		  when others=>
			to_ram_sel<=(others=>'0');
	  end case;
  end if;
   
end process;

address <= std_logic_vector(address_out);
-- decode the final address for the RAM.
address_gen : process (mat_index_address,row_set_address,row_cnt_address)
begin
  address_out <= mat_index_address + row_set_address + row_cnt_address;
end process;
  
end beh;	
