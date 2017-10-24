--Here newton-raphson equation is used to calculate the reciprocal of the normalize input
-- x(i+1) = xi*(2- xi*norm_input),, NR-equation
-- Only one iteraion is used but to improve the accuracy no of iteraions need to be increased.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity nr_div is 
port (clk : in std_logic;
      rst : in std_logic;
      
	  o_xi : in std_logic_vector(15 downto 0);  --Initial estimate from look up table 
	  o_norm : in std_logic_vector(10 downto 0);  --Normalize output from previous stage
	  o_r  : out unsigned(30 downto 0)   --Normalize answer
	  );
end nr_div;
architecture behav of nr_div is
signal temp_r,temp_r_bar : unsigned(26 downto 0) := (others => '0');
signal temp_r1 : unsigned(26 downto 0) := (others => '0');
signal temp_r2 : unsigned(42 downto 0) := (others => '0');
signal o_r_reg : unsigned(30 downto 0) := (others => '0');
begin
o_r <= o_r_reg;
reg : process(clk)
begin
if rising_edge (clk) then
   if rst ='1' then
    o_r_reg <= (others => '0');
	else
	 o_r_reg <= temp_r2(42 downto 12);  --Only taking 32 bits from data
	end if;
end if;
end process;
--stage1 of nr equation
op_st_1 : process(o_xi,o_norm)
begin
    temp_r <= unsigned(o_norm)*unsigned(o_xi);
end process;
--stage2 of nr equation
op_st_2 : process(temp_r,temp_r_bar)
begin
	temp_r_bar <= (not temp_r) +1;
	temp_r1 <= "0000000000010" + temp_r_bar;
end process;
--stage3 of nr equation

op_st_3 : process(temp_r1,o_xi)
begin
	temp_r2 <= temp_r1*unsigned(o_xi);

end process;

end behav;
   

