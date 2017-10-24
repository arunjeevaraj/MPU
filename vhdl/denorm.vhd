--This will de-normalize the output from NR-equation
--A de-normalization flag is being used to determine the factor of de-normalization

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity denorm is 
port (clk : in std_logic;
      rst : in std_logic;
      norm_sig : in std_logic_vector(1 downto 0);  --DIrection bits to de-normalize
	  o_r  : in unsigned(30 downto 0);   --Normalize output from previous block
	  o_reci : out unsigned(31 downto 0)  --Denormalize output, actual answer
	  );
end denorm;

architecture behav of denorm is

begin
process(rst, norm_sig,o_r)
begin
if rst ='1' then
o_reci <= (others => '0');
elsif norm_sig ="10" then 
  o_reci <= '0' & o_r(28 downto 0) & "00";
elsif norm_sig = "01" then
  o_reci <= '0' & o_r(29 downto 0) & '0';
elsif norm_sig = "00" then
  o_reci <= '0' & o_r;
elsif norm_sig = "11" then  --For sign bit 
  o_reci <= '1' & o_r;
else
 o_reci <= '0' & o_r;
end if;
end process;
end behav;
   
