-- Author : Arun jeevaraj
-- Team   : Arun and Deepak Yadav  , Team Mentor : Liang Liu 
-- usage  : The multplier and adders are described here. Other than divider the entire control flow is modelled here.
-- DLM    : 6/21/2016   6:22 PM
-- Tested : modelsim student edition 10.4 a
-- error  : none.
-- warning: none. 



library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity mpma is 
port(  												              -- data from RAM.
		ram_data_in_1 : in std_logic_vector(31 downto 0);
        ram_data_in_2 : in std_logic_vector(31 downto 0);
		ram_data_in_3 : in std_logic_vector(31 downto 0);
		ram_data_in_4 : in std_logic_vector(31 downto 0);
																  --data from register array.
	reg_array_data_1  : in std_logic_vector(31 downto 0);		
	reg_array_data_2  : in std_logic_vector(31 downto 0);
	reg_array_data_3  : in std_logic_vector(31 downto 0);
	reg_array_data_4  : in std_logic_vector(31 downto 0);
																  -- data from the div register array.
	div_array_data_1  : in std_logic_vector(31 downto 0);
	div_array_data_2  : in std_logic_vector(31 downto 0);
	div_array_data_3  : in std_logic_vector(31 downto 0);
	div_array_data_4  : in std_logic_vector(31 downto 0);
									                              -- control signals used.
	m_muli_sel_reg    : in std_logic;                             -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  : in std_logic;     						  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  : in std_logic_vector(1 downto 0);		  -- mux at the odd stage1 adder input2.
	m_data_out_sel    : in std_logic_vector(1 downto 0);          -- mux at the output stage.

	s1_sub_e          : in std_logic;							  -- for add/ subtract operation.
    s1_acc_enable     : in std_logic;
	s2_acc_enable     : in std_logic;
	flush             : in std_logic;                             -- to flush out the accumulators
	dynamic_scale     : in std_logic_vector(1 downto 0);          -- for dynamic scaling at the output.
	
	clk               : in std_logic;
	rst               : in std_logic;
	
																   --output data to the RAM.
	ram_data_out_1    : out std_logic_vector(31 downto 0);
	ram_data_out_2    : out std_logic_vector(31 downto 0);
	ram_data_out_3    : out std_logic_vector(31 downto 0);
	ram_data_out_4    : out std_logic_vector(31 downto 0)	
	);
end mpma;
	  
architecture beh of mpma is 


--- constants

constant zeros_32bit       : signed(31 downto 0) := (others=>'0');
constant ones_32bit        : signed(31 downto 0) := (others=>'1');

--- used to typecast the input signals to signed.

signal s_ram_data_in_1   : signed(31 downto 0);
signal s_ram_data_in_2   : signed(31 downto 0);
signal s_ram_data_in_3   : signed(31 downto 0);
signal s_ram_data_in_4   : signed(31 downto 0);

signal s_reg_array_data_1  : signed(31 downto 0);
signal s_reg_array_data_2  : signed(31 downto 0);
signal s_reg_array_data_3  : signed(31 downto 0);
signal s_reg_array_data_4  : signed(31 downto 0);
                         
signal s_div_array_data_1  : signed(31 downto 0);
signal s_div_array_data_2  : signed(31 downto 0);
signal s_div_array_data_3  : signed(31 downto 0);
signal s_div_array_data_4  : signed(31 downto 0);

-- used before scaling.
signal bs_ram_data_out_1  : signed(63 downto 0);
signal bs_ram_data_out_2  : signed(63 downto 0);
signal bs_ram_data_out_3  : signed(63 downto 0);
signal bs_ram_data_out_4  : signed(63 downto 0);
-- used in the even path of adder.
signal s1_adder3_in1      : signed(63 downto 0);
signal s1_adder3_in2      : signed(63 downto 0);
signal s1_adder4_in1      : signed(63 downto 0);
signal s1_adder4_in2      : signed(63 downto 0);
-- used for the multiplier instances.
signal mul1_out,mul2_out,mul3_out,mul4_out : signed(63 downto 0);

signal mul1_in1,mul1_in2,
       mul2_in1,mul2_in2,
	   mul3_in1,mul3_in2,
	   mul4_in1,mul4_in2 : signed(31 downto 0);
	   
-- used to pipeline at the output stage of multipliers.
signal p_mul1_out,p_mul2_out,
   p_mul3_out,p_mul4_out : signed(63 downto 0);

	   
-- stage 1 adders1 inputs and outputs.
signal s1_adder1_in1,s1_adder1_in2,
	   s1_adder2_in1,s1_adder2_in2 : signed(63 downto 0);
-- for negative numbers 
signal to_s1_adder1_in1,to_s1_adder2_in1,
       to_s1_adder3_in1,to_s1_adder4_in1 : signed(63 downto 0);	   
	   
signal s1_adder1_out,s1_adder2_out : signed(63 downto 0);						

-- stage 1 adders accumulators.

signal s1_adder1_acc, s1_adder2_acc,
	   s1_adder3_acc, s1_adder4_acc : signed(63 downto 0);
signal s1_adder1_acc_update, s1_adder2_acc_update,
	   s1_adder3_acc_update, s1_adder4_acc_update : signed(63 downto 0);
signal s1_adder3_out,s1_adder4_out : signed(63 downto 0);
-- stage 2 adders accumulators.

signal s2_adder1_out,s2_adder1_in1,
	    s2_adder1_in2,s2_adder1_acc,
		s2_adder1_acc_upd	: signed(63 downto 0);	
		
signal s2_adder2_out,s2_adder2_in1,
	    s2_adder2_in2,s2_adder2_acc,
		s2_adder2_acc_upd   : signed(63 downto 0);

-- stage 3 adders

signal s3_adder_out : signed(63 downto 0);		
	   
begin

-- typecasting all the std_logic to signed vector.

s_ram_data_in_1     <= signed(ram_data_in_1);
s_ram_data_in_2     <= signed(ram_data_in_2);
s_ram_data_in_3     <= signed(ram_data_in_3);
s_ram_data_in_4     <= signed(ram_data_in_4);
                       
s_reg_array_data_1  <= signed(reg_array_data_1); 
s_reg_array_data_2  <= signed(reg_array_data_2); 
s_reg_array_data_3  <= signed(reg_array_data_3); 
s_reg_array_data_4  <= signed(reg_array_data_4); 
                     
s_div_array_data_1  <= signed(div_array_data_1); 
s_div_array_data_2  <= signed(div_array_data_2); 
s_div_array_data_3  <= signed(div_array_data_3); 
s_div_array_data_4  <= signed(div_array_data_4); 


-- Mux at the input stage of the multipliers 
m_muli_mux_inst: process(m_muli_sel_reg,s_reg_array_data_1,s_reg_array_data_2,
						  s_reg_array_data_3,s_reg_array_data_4,
						  s_div_array_data_1,s_div_array_data_2,
						  s_div_array_data_3,s_div_array_data_4
						  )
begin
 if(m_muli_sel_reg='1') then
   mul1_in1 <= s_reg_array_data_1;
   mul2_in1 <= s_reg_array_data_2;
   mul3_in1 <= s_reg_array_data_3;
   mul4_in1 <= s_reg_array_data_4;
  else
   mul1_in1 <= s_div_array_data_1;
   mul2_in1 <= s_div_array_data_2;
   mul3_in1 <= s_div_array_data_3;
   mul4_in1 <= s_div_array_data_4;
  end if;

end process;

mul1_in2 <= s_ram_data_in_1;
mul2_in2 <= s_ram_data_in_2;
mul3_in2 <= s_ram_data_in_3;
mul4_in2 <= s_ram_data_in_4; 

--4 instances of 64 bit multipliers.
mul1_inst: process(mul1_in1,mul1_in2)
begin

mul1_out <= mul1_in1 * mul1_in2;

end process;

mul2_inst: process(mul2_in1,mul2_in2)
begin

mul2_out <= mul2_in1 * mul2_in2;

end process;

mul3_inst: process(mul3_in1,mul3_in2)
begin

mul3_out <= mul3_in1 * mul3_in2;

end process;

mul4_inst: process(mul4_in1,mul4_in2)
begin

mul4_out <= mul4_in1 * mul4_in2;

end process;


--mux at the input 1 of the stage 1 adder 1 and 2.


to_s1_adder_in : process(s_ram_data_in_1,s_ram_data_in_3,s_ram_data_in_2,s_ram_data_in_4)
begin
--sign bit
   to_s1_adder1_in1(63) <= s_ram_data_in_1(31);
   to_s1_adder2_in1(63) <= s_ram_data_in_3(31);
   to_s1_adder3_in1(63) <= s_ram_data_in_2(31);
   to_s1_adder4_in1(63) <= s_ram_data_in_4(31);
   
--expanding to 64 bits signed data based on the sign.   
if(s_ram_data_in_1(31)='1') then
   to_s1_adder1_in1(62 downto 0) <= ones_32bit & s_ram_data_in_1(30 downto 0);
   
else
   to_s1_adder1_in1(62 downto 0) <= zeros_32bit & s_ram_data_in_1(30 downto 0);
   
end if;

if(s_ram_data_in_3(31)='1') then
   
   to_s1_adder2_in1(62 downto 0) <= ones_32bit & s_ram_data_in_3(30 downto 0);
else
   to_s1_adder2_in1(62 downto 0) <= zeros_32bit & s_ram_data_in_3(30 downto 0);
end if;

if(s_ram_data_in_1(31)='1') then
   to_s1_adder3_in1(62 downto 0) <= ones_32bit & s_ram_data_in_2(30 downto 0);
   
else
   to_s1_adder3_in1(62 downto 0) <= zeros_32bit & s_ram_data_in_2(30 downto 0);
   
end if;

if(s_ram_data_in_4(31)='1') then
   to_s1_adder4_in1(62 downto 0) <= ones_32bit & s_ram_data_in_4(30 downto 0);
   
else
   to_s1_adder4_in1(62 downto 0) <= zeros_32bit & s_ram_data_in_4(30 downto 0);
   
end if;
end process;


s1_adder_i1_mux_inst: process(m_s1_adder_seli1,p_mul1_out,p_mul3_out,
							  to_s1_adder1_in1,to_s1_adder2_in1)
begin
if(m_s1_adder_seli1='1') then
	s1_adder1_in1 <= p_mul1_out;
	s1_adder2_in1 <= p_mul3_out;
else
    s1_adder1_in1 <= to_s1_adder1_in1;
    s1_adder2_in1 <= to_s1_adder2_in1;
end if;

end process;

--mux at the input 2 of the stage 1 adder 1, 2,3,4. for the odd data paths.

s1_adder_i2_mux_inst: process(m_s1_adder_seli2,p_mul2_out,p_mul4_out,s1_adder2_acc,s1_adder1_acc,
								s1_adder3_acc,s1_adder4_acc)

begin
 case(m_s1_adder_seli2) is 
	when "00" => -- select pipelined multiplier output.
	  s1_adder1_in2 <= p_mul2_out;
	  s1_adder2_in2 <= p_mul4_out;
	  s1_adder3_in2 <= (others=>'0');
	  s1_adder4_in2 <= (others=>'0');
	when "01" =>
	  s1_adder1_in2 <= zeros_32bit & x"0000000"&"0001";
	  s1_adder2_in2 <= zeros_32bit & x"0000000"&"0001";
	  s1_adder3_in2 <= zeros_32bit & x"0000000"&"0001";
      s1_adder4_in2 <= zeros_32bit & x"0000000"&"0001"; 
	when "10" =>
	  s1_adder1_in2 <= (others=>'0');
	  s1_adder2_in2 <= (others=>'0');
	  s1_adder3_in2 <= (others=>'0');
      s1_adder4_in2 <= (others=>'0');
	when "11" =>
	  s1_adder1_in2 <= s1_adder1_acc;			
	  s1_adder2_in2 <= s1_adder2_acc;
	  s1_adder3_in2 <= s1_adder3_acc;
      s1_adder4_in2 <= s1_adder4_acc; 
	when others=>
	  s1_adder1_in2 <= (others=>'0');
	  s1_adder2_in2 <= (others=>'0');
	  s1_adder3_in2 <= (others=>'0');
      s1_adder4_in2 <= (others=>'0');
	  
	end case;  

end process;


-- No mux at the input of 2 of the stage 1 adder 1 and 2 of the even data paths.
s1_adder3_in1<= to_s1_adder3_in1;
s1_adder4_in1<= to_s1_adder4_in1;





-- 2 instances of 64 bit signed adder stage 1. for odd data paths.

s1_adder1_inst: process(s1_adder1_in1,s1_adder1_in2,s1_sub_e)

begin
if(s1_sub_e='1') then
 s1_adder1_out <= s1_adder1_in1 - s1_adder1_in2;
else
 s1_adder1_out <= s1_adder1_in1 + s1_adder1_in2;
end if;

end process;



s1_adder2_inst: process(s1_adder2_in1,s1_adder2_in2,s1_sub_e)

begin
if(s1_sub_e='1') then	-- subtract
   s1_adder2_out <= s1_adder2_in1 - s1_adder2_in2;
else
   s1_adder2_out <= s1_adder2_in1 + s1_adder2_in2;
end if;   

end process;

-- 2 instances of 64 bit signed adder stage 1 for even data paths.

s1_adder3_inst: process(s1_adder3_in1,s1_adder3_in2,s1_sub_e)

begin
if(s1_sub_e='1') then	-- subtract
   s1_adder3_out <= s1_adder3_in1 - s1_adder3_in2;
else
   s1_adder3_out <= s1_adder3_in1 + s1_adder3_in2;
end if;   

end process;

s1_adder4_inst: process(s1_adder4_in1,s1_adder4_in2,s1_sub_e)

begin
if(s1_sub_e='1') then	-- subtract
   s1_adder4_out <= s1_adder4_in1 - s1_adder4_in2;
else
   s1_adder4_out <= s1_adder4_in1 + s1_adder4_in2;
end if;   

end process;

-- stage 1 adder acc enable; only enabled on ram read wait state.
s1_adder_Acc_enabler_inst: process(s1_acc_enable,s1_adder1_acc,s1_adder2_acc,
									s1_adder3_acc,s1_adder4_acc,s1_adder1_out,
									s1_adder2_out,s1_adder3_out,s1_adder4_out,
									flush) 
begin
  if(flush='0') then
	if(s1_acc_enable='1') then
	 s1_adder1_acc_update <= s1_adder1_out;
	 s1_adder2_acc_update <= s1_adder2_out;
	 s1_adder3_acc_update <= s1_adder3_out;
	 s1_adder4_acc_update <= s1_adder4_out;
	else
	 s1_adder1_acc_update <= s1_adder1_acc;
	 s1_adder2_acc_update <= s1_adder2_acc;
	 s1_adder3_acc_update <= s1_adder3_acc;
	 s1_adder4_acc_update <= s1_adder4_acc;
	end if;
   else  -- flush out the registers.
     s1_adder1_acc_update <= (others=>'0');
	 s1_adder2_acc_update <= (others=>'0');
     s1_adder3_acc_update <= (others=>'0');
     s1_adder4_acc_update <= (others=>'0');
   end if;
end process;


--inputs for s2 adder
s2_adder1_in1 <= s1_adder1_out;
s2_adder1_in2 <= s1_adder1_acc;

s2_adder2_in1 <= s1_adder2_out;
s2_adder2_in2 <= s1_adder2_acc;


-- s2 adder.

s2_adder1_inst:process(s2_adder1_in1,s2_adder1_in2)
begin
s2_adder1_out <= s2_adder1_in1+ s2_adder1_in2;
end process;

s2_adder2_inst:process(s2_adder2_in1,s2_adder2_in2)
begin
s2_adder2_out <= s2_adder2_in1+ s2_adder2_in2;
end process;

-- s2 acc update process

process (s2_acc_enable,s2_adder1_acc,s2_adder1_out,
		 s2_adder2_acc,s2_adder2_out,flush)
begin

if(flush='0') then
	if(s2_acc_enable='1') then
		s2_adder1_acc_upd <= s2_adder1_out;
		s2_adder2_acc_upd <= s2_adder2_out;
	else
	    s2_adder1_acc_upd<=s2_adder1_acc;
		s2_adder2_acc_upd<=s2_adder2_acc;
	end if;
else -- flush it out
		s2_adder1_acc_upd<= (others=>('0'));
        s2_adder2_acc_upd<= (others=>('0'));
end if;


end process;

-- s3 adder.
-- will provide the result matrix multiply.

process(s2_adder1_out,s2_adder2_out)
begin
	s3_adder_out <= s2_adder1_out + s2_adder2_out;
	
end process;


-- dataout mux 

process(m_data_out_sel,s1_adder2_out,s1_adder3_out,s1_adder1_out,s1_adder4_out,
		mul1_out,mul2_out,mul3_out,mul4_out, s3_adder_out) 
begin
 case(m_data_out_sel) is
    when "00" => -- matrix multiply output.
	 bs_ram_data_out_1 <= s3_adder_out;
	 bs_ram_data_out_2 <= s3_adder_out;
	 bs_ram_data_out_3 <= s3_adder_out;
	 bs_ram_data_out_4 <= s3_adder_out;
	when "01" => -- matrix add/subtract output.
	 bs_ram_data_out_1 <= s1_adder1_out;
	 bs_ram_data_out_2 <= s1_adder3_out;
	 bs_ram_data_out_3 <= s1_adder2_out;
	 bs_ram_data_out_4 <= s1_adder4_out;
	when "10" => -- diag multiply operation.
	 bs_ram_data_out_1 <= mul1_out;
	 bs_ram_data_out_2 <= mul2_out;
	 bs_ram_data_out_3 <= mul3_out;
	 bs_ram_data_out_4 <= mul4_out;
	when "11" =>	-- reserved, to reset the data of the memory to zero.
	 bs_ram_data_out_1 <= (others=>'0');
	 bs_ram_data_out_2 <= (others=>'0');
	 bs_ram_data_out_3 <= (others=>'0');
	 bs_ram_data_out_4 <= (others=>'0');
	when others =>
	 bs_ram_data_out_1 <= (others=>'0');
	 bs_ram_data_out_2 <= (others=>'0');
	 bs_ram_data_out_3 <= (others=>'0');
	 bs_ram_data_out_4 <= (others=>'0');
 end case;
end process;

--- dynamic scaling.
--- as a proof of concept.


process(dynamic_scale,bs_ram_data_out_1,bs_ram_data_out_2,bs_ram_data_out_3,bs_ram_data_out_4)
begin
  
 --signbit is preserved. 
  ram_data_out_1(31) <= bs_ram_data_out_1(63);
  ram_data_out_2(31) <= bs_ram_data_out_2(63);
  ram_data_out_3(31) <= bs_ram_data_out_3(63);
  ram_data_out_4(31) <= bs_ram_data_out_4(63);
  
 case (dynamic_scale) is
    when "00" => -- takes the lowest 32 bits of the result.
		ram_data_out_1(30 downto 0) <= std_logic_vector(bs_ram_data_out_1(30 downto 0));
		ram_data_out_2(30 downto 0) <= std_logic_vector(bs_ram_data_out_2(30 downto 0));
		ram_data_out_3(30 downto 0) <= std_logic_vector(bs_ram_data_out_3(30 downto 0));
		ram_data_out_4(30 downto 0) <= std_logic_vector(bs_ram_data_out_4(30 downto 0));
	when "01" => -- takes the  32 bits of the result after shifting by 1.
		ram_data_out_1(30 downto 0) <= std_logic_vector(bs_ram_data_out_1(31 downto 1));
		ram_data_out_2(30 downto 0) <= std_logic_vector(bs_ram_data_out_2(31 downto 1));
		ram_data_out_3(30 downto 0) <= std_logic_vector(bs_ram_data_out_3(31 downto 1));
		ram_data_out_4(30 downto 0) <= std_logic_vector(bs_ram_data_out_4(31 downto 1));
	when "10" => -- takes  32 bits of the result after shifting by 2.
		ram_data_out_1(30 downto 0) <= std_logic_vector(bs_ram_data_out_1(32 downto 2));
		ram_data_out_2(30 downto 0) <= std_logic_vector(bs_ram_data_out_2(32 downto 2));
		ram_data_out_3(30 downto 0) <= std_logic_vector(bs_ram_data_out_3(32 downto 2));
		ram_data_out_4(30 downto 0) <= std_logic_vector(bs_ram_data_out_4(32 downto 2));
    when "11" => --  32 bits of the result after shifting by 3.
		ram_data_out_1(30 downto 0) <= std_logic_vector(bs_ram_data_out_1(33 downto 3));
		ram_data_out_2(30 downto 0) <= std_logic_vector(bs_ram_data_out_2(33 downto 3));
		ram_data_out_3(30 downto 0) <= std_logic_vector(bs_ram_data_out_3(33 downto 3));
		ram_data_out_4(30 downto 0) <= std_logic_vector(bs_ram_data_out_4(33 downto 3));		
	when others =>   -- 32 bits of the result after shifting by 4.
	    ram_data_out_1(30 downto 0) <= std_logic_vector(bs_ram_data_out_1(34 downto 4));
		ram_data_out_2(30 downto 0) <= std_logic_vector(bs_ram_data_out_2(34 downto 4));
		ram_data_out_3(30 downto 0) <= std_logic_vector(bs_ram_data_out_3(34 downto 4));
		ram_data_out_4(30 downto 0) <= std_logic_vector(bs_ram_data_out_4(34 downto 4));
  end case;		
end process;



-- registers used for the processing elements.
-- p_mul1_out are pipeline register to reduce the combinational path.. of multipliers and adders.
process(clk,rst)
begin
	if(rst='1') then
		 p_mul1_out <= (others=>'0');
		 p_mul2_out <= (others=>'0');
		 p_mul3_out <= (others=>'0');
		 p_mul4_out <= (others=>'0');
		 s1_adder1_acc <=(others =>'0');
		 s1_adder2_acc <=(others =>'0');
		 s1_adder3_acc <=(others =>'0');
		 s1_adder4_acc <=(others =>'0');
		 s2_adder1_acc <=(others =>'0');
		 s2_adder2_acc <=(others =>'0');
	elsif(rising_edge(clk)) then
		-- used for pipelining 
		 p_mul1_out  <= mul1_out;
		 p_mul2_out  <= mul2_out;
		 p_mul3_out  <= mul3_out;
		 p_mul4_out  <= mul4_out;
		 
		-- for accumulators 
		 s1_adder1_acc <=s1_adder1_acc_update;
		 s1_adder2_acc <=s1_adder2_acc_update;
		 s1_adder3_acc <=s1_adder3_acc_update;
		 s1_adder4_acc <=s1_adder4_acc_update;
		 
		 s2_adder1_acc <= s2_adder1_acc_upd;
		 s2_adder2_acc <= s2_adder2_acc_upd;
	end if;
end process;
end beh;
