--Producing four output at a time based on given address 
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity div_array is
  port ( clk : in std_logic;
         rst : in std_logic;
         I_data_vld : in std_logic;
	    mat_order : in std_logic_vector(5 downto 0);
         row_mode  : in std_logic_vector(1 downto 0);
         o_reci : in unsigned(31 downto 0);
         addr_inp : in unsigned (7 downto 0);
         inp_out1 : out std_logic_vector ( 31 downto 0);
         inp_out2 : out std_logic_vector ( 31 downto 0);
         inp_out3 : out std_logic_vector ( 31 downto 0);
         inp_out4 : out std_logic_vector ( 31 downto 0);
	    done     : out std_logic
          
         
       );
end div_array;

architecture behav of div_array is
  type reg_file is array (63 downto 0) of unsigned (31 downto 0);
  type writestat is (idle,writing, w_done, reading, read_four);
  signal current_state, next_state : writestat;
  signal next_inp_out1,inp_out11, next_inp_out2,inp_out22,next_inp_out3,inp_out33,next_inp_out4,inp_out44 : unsigned (31 downto 0) := (others => '0')  ;
  signal array_reg : reg_file  ;
  signal next_array_reg : unsigned (31 downto 0) := (others => '0');
  signal count1,next_count,count2,next_count2 : std_logic_vector(5 downto 0) :=(others => '0');
  signal reg_inp : unsigned(31 downto 0);
  signal write_en : std_logic := '0';
  signal mat_diag_count : std_logic_vector(5 downto 0) := (others => '0');
begin
reg_inp <= o_reci;
inp_out1 <= std_logic_vector(inp_out11);
inp_out2 <= std_logic_vector(inp_out22);
inp_out3 <= std_logic_vector(inp_out33);
inp_out4 <= std_logic_vector(inp_out44);
mat_diag_count <= mat_order;

reg : process(clk )
begin
  if   rising_edge(clk) then
               if( rst='1') then 
               inp_out11 <= (others => '0');
               inp_out22 <= (others => '0');
               inp_out33 <= (others => '0');
               inp_out44 <= (others => '0');
              
               count1 <= (others => '0');
			   count2 <= (others => '0');
			    
               current_state <= idle;
              else
                inp_out11 <= next_inp_out1;
                inp_out22 <= next_inp_out2;
                inp_out33 <= next_inp_out3;
                inp_out44 <= next_inp_out4;
                count1 <= next_count;
			count2 <= next_count2;
				 
                current_state <= next_state;
                if(write_en='1') then
                array_reg(conv_integer(count1))<= next_array_reg;  --Stores data based on count1 value in the array register
              end if; 
                
end if;            
   end if;
end process;

comb: process ( current_state,addr_inp,count1,count2,
				 array_reg,reg_inp,
				mat_order,row_mode,I_data_vld)
begin
  next_array_reg <= reg_inp;
  next_count2 <= (others => '0');
  next_count <= (others => '0');
  done <= '0';
  write_en <= '0';
 next_inp_out1 <= (others => '0');
 next_inp_out2 <=  (others => '0');
next_inp_out3 <=  (others => '0');
next_inp_out4 <=  (others => '0');
next_state <= idle;

  case current_state is
  when idle =>
    next_count2<=(others => '0');
    next_count <= (others => '0');
	write_en<='0';
	done <= '0';
	next_array_reg <= reg_inp;
	if I_data_vld = '1' then 
	  next_state <= writing;
	else 
	  next_state <= idle;
	  end if;
  when writing => 
      next_count2 <= count2 +1;
	 
      write_en<='1';
	if count2 =(mat_order - "000001") then   --output is    generating based on mat_order, count2 is used for it.
    next_array_reg <= reg_inp;
	next_count <= count1+1;
	next_count2 <= (others => '0');
  elsif (count1 < (mat_order))  then   --count1 counts the number of register in the array based on mat_order
    next_state<= writing;
  else
    next_state <= w_done;
    write_en<='0';
	done <= '1';
  end if;
  --set done signal to high when writing completes
  --row_mode 01 for fetching same data over four outputs
  --row_mode 10 for fetching different data from different location
  
when w_done =>      
	   write_en <= '0';
       if row_mode = "01" then
       next_state <= reading;
       elsif row_mode = "10" then
         next_state <= read_four;
       else 
         next_state <= w_done;
        end if;
--Reading same data location over four outputs based on addr_inp

    when reading =>  
    next_state <= idle;
    done <= '0';
    next_count <= (others => '0');
    next_count2 <= (others => '0');
    write_en<='0';
    next_inp_out1 <= array_reg(to_integer(addr_inp));
    next_inp_out2 <= array_reg(to_integer(addr_inp));
    next_inp_out3 <= array_reg(to_integer(addr_inp));
    next_inp_out4 <= array_reg(to_integer(addr_inp));

--Reading different data location over four outputs based on addr_inp
    when read_four =>  
    next_state <= idle;	
    done <= '0';
    next_count <= (others => '0');
    next_count2 <= (others => '0');
    write_en<='0';
    next_inp_out1 <= array_reg(to_integer(addr_inp));
    next_inp_out2 <= array_reg(to_integer(addr_inp+1));
    next_inp_out3 <= array_reg(to_integer(addr_inp+2));
    next_inp_out4 <= array_reg(to_integer(addr_inp+3));
     
 
when others =>
     next_state<= idle;
     write_en<='0';
     next_count <= (others => '0');
	 next_count2 <= (others => '0');
     next_inp_out1 <= array_reg(to_integer(addr_inp));
     next_inp_out2 <= array_reg(to_integer(addr_inp));
    next_inp_out3 <= array_reg(to_integer(addr_inp));
    next_inp_out4 <= array_reg(to_integer(addr_inp));
    
end case;   
end process;
end behav;
