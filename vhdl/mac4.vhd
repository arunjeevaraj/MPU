--Multiplicationa and accumalate unit(MAC)
-- zero signal is used to start accumalating output with zero
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity mac4 is 
port(  
  data_a_1 : in std_logic_vector(31 downto 0);
  data_a_2 : in std_logic_vector(31 downto 0);
  data_a_3 : in std_logic_vector(31 downto 0);
  data_a_4 : in std_logic_vector(31 downto 0);
  data_b_1 : in std_logic_vector(31 downto 0);
  data_b_2 : in std_logic_vector(31 downto 0);
  data_b_3 : in std_logic_vector(31 downto 0);
  data_b_4 : in std_logic_vector(31 downto 0);
  clk      : in std_logic ;
  rst      : in std_logic;
  mac_write_vld : in std_logic;
  mac_vld  : in std_logic;
  write_en : in std_logic;
  data_out : out std_logic_vector(31 downto 0)
 );
end entity;


architecture beh of mac4 is

signal store : std_logic;
signal i_data_a_1 :  unsigned(31 downto 0);
signal i_data_a_2 :  unsigned(31 downto 0);
signal i_data_a_3 :  unsigned(31 downto 0);
signal i_data_a_4 :  unsigned(31 downto 0);
signal i_data_b_1 :  unsigned(31 downto 0);
signal i_data_b_2 :  unsigned(31 downto 0);
signal i_data_b_3 :  unsigned(31 downto 0);
signal i_data_b_4 :  unsigned(31 downto 0);
signal data_out_reg,
       data_out_reg_w : unsigned(63 downto 0); 
signal flush,flush_ff : std_logic;
begin

data_out <= std_logic_vector(data_out_reg_w(31 downto 0));

process(clk, rst)
begin

if(rst='1') then
   i_data_a_1  <= (others=>'0');
   i_data_a_2  <= (others=>'0');
   i_data_a_3  <= (others=>'0');
   i_data_a_4  <= (others=>'0');
   i_data_b_1  <= (others=>'0');
   i_data_b_2  <= (others=>'0');
   i_data_b_3  <= (others=>'0');
   i_data_b_4  <= (others=>'0');
   flush       <='0';
   flush_ff    <='0';
   data_out_reg<= (others=>'0');

elsif(rising_edge(clk)) then
	flush_ff <= flush;
	if(mac_vld='1') then
		i_data_a_1  <= unsigned(data_a_1);
	    i_data_a_2  <= unsigned(data_a_2);
		i_data_a_3  <= unsigned(data_a_3);
	    i_data_a_4  <= unsigned(data_a_4);
	    i_data_b_1	<= unsigned(data_b_1);
	    i_data_b_2  <= unsigned(data_b_2);
	    i_data_b_3  <= unsigned(data_b_3);
	    i_data_b_4  <= unsigned(data_b_4);
	end if;
	
	if(flush_ff='1') then
	 data_out_reg <=(others=>'0');
	
	end if;
	
	if(mac_write_vld='1' and mac_vld='1') then
	  data_out_reg <= data_out_reg_w;
	  flush <= not(flush);
	end if;

end if;


end process;

process(i_data_a_1,i_data_a_2,i_data_a_3,i_data_a_4,i_data_b_1,i_data_b_2,i_data_b_3,i_data_b_4,data_out_reg)
begin

data_out_reg_w <= data_out_reg + (i_data_a_1*i_data_b_1) + (i_data_a_2*i_data_b_2) 
							   + (i_data_a_3*i_data_b_3) + (i_data_a_4*i_data_b_4);
end process;




end beh;