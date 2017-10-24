--Reading only diagonal elements from the input stream
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity diag_write is
port ( clk : in std_logic;
       rst : in std_logic;
	   mat_order : in std_logic_vector(5 downto 0);   --Matrix order
       data_in_d : in std_logic_vector(31 downto 0);  -- Incoming data
	   I_data_vld : in std_logic;                     -- Signal used to trigger FSM
	   finish_diag : out std_logic;
       data_diag : out std_logic_vector(31 downto 0)   --Diagonal data as output
	   );
end diag_write;

architecture behav of diag_write is 
type diag_state is (idle,writing, counting,finish);
signal current_state, next_state : diag_state;
signal count,next_count,pair,next_pair : std_logic_vector(5 downto 0) := (others => '0');
signal reg_diag, next_reg_diag : std_logic_vector(31 downto 0) := (others => '0');
signal mat_count : std_logic_vector(5 downto 0) := (others => '0');
begin
data_diag <= reg_diag;
mat_count <= mat_order;

reg :process(clk)
begin
  if rising_edge(clk) then
     if rst='1' then
	    reg_diag <= (others => '0');
		count <= (others => '0');
		pair <= (others => '0');
		current_state <= idle;
	 else
	    reg_diag <= next_reg_diag;
		count <= next_count;
		pair <= next_pair;
		current_state <= next_state;
	end if;
 end if;
end process;

comb: process (count,data_in_d,pair,I_data_vld
				,current_state,mat_count)
begin
   case current_state is
     when idle =>
	                   next_reg_diag <= data_in_d;
			   next_count <= count;
			   next_pair <= pair;
			   finish_diag <= '0';
			   if I_data_vld = '1' then     --Start fetching data when I_data_vld goes high
			         next_state <= writing;
				else
				    next_state <= idle;
			   end if;
     when writing =>
	                       next_reg_diag <= data_in_d;
				  next_count <= count;
				  next_pair <= pair;
				  next_state <= counting;
	                          finish_diag <= '0';
	 when counting =>
	        next_reg_diag <= data_in_d;
	        next_count <= count + "000001";
                next_pair <= pair;
            if (count = (mat_count - "000001") and pair /= (mat_count)) then  --Fetching only diagonal elements from incoming data stream
              next_state <= writing;
			  next_pair <= pair +"000001";
			  next_count <= (others => '0');
			  finish_diag <= '0';
            elsif pair = mat_count then       --Pair is used to find the last element, if its equal to mat_count, goes to finish state
			    next_state <= finish;
				finish_diag <= '1';
                            next_pair <= (others => '0');
			
            else
             next_state <= counting;	
            end if;
            finish_diag <= '0';
    when finish => 
	        finish_diag <= '1';
            next_count <= (others => '0');	
			next_pair <= (others => '0');
			next_state <= idle;
			next_reg_diag <= data_in_d;

    end case;
end process;
end behav;
			
			  
				  
	 
	 
	 
	 
	 
	    
