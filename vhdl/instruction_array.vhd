-- File   : instruction_array.vhd
-- Author : Arun jeevaraj
-- Team   : Arun and Deepak Yadav  , Team Mentor : Liang Liu 
-- usage  : used to store the instructions for the master controller.
--           
-- DLM    : 6/24/2016   7:49 AM 
-- Tested : modelsim student edition 10.4 a
-- Todo   : None
-- error  : none.
-- warning: none. 


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

---- A map of instruction to mode control signals that mat controller supports. 
-- mode 000 for loading the input matrix to ram, to op_r -- done
-- mode 001 for performing mat_mult. op_1*op_2 = op_r    -- doing now.
-- mode 010 for diag multiply operation spec_command = 000 --> diag to matrix  and spec_command= 001  --> matrix to diag mulitplication.
-- mode 011 for adding or subtraction identity matrix.     special command 000 for adding and special command 001 for subtraction.
-- mode 100 for mat copy --  op_1 to op_r.     
-- mode 101 -- reserved for matrix matrix addition.
-- mode 110 -- reserved for matrit matrix dot product.
-- mode 111 for sending the result out serially through data out col wise..


entity instruction_reg is 
port( current_instruction: out std_logic_vector(23 downto 0);   -- instruction to read from fifo.
      instruction_write  : in std_logic_vector (23 downto 0);	-- instruction to write to fifo 
	  write_i_en         : in std_logic;						--write to write reg array.
	  pc                 : in std_logic_vector(3 downto 0);
	  write_i_p          : in std_logic_vector(3 downto 0);		-- where to write to the write reg array.
	  clk                : in std_logic;
	  rst                : in std_logic;
	  instreg_mode       : in std_logic_vector(1 downto 0)		--- debug instreg_mode, auto instreg_mode, and controlled instreg_mode.
	);
end entity;

architecture beh of instruction_reg is 



--- constants to map the operation and mat indices.
constant m_mat_load : std_logic_vector(2 downto 0):="000"; -- loads matrix to op_r
constant m_mat_mul  : std_logic_vector(2 downto 0):="001"; -- do mat multiply op_r = op_1*op_2 
constant m_diag_mul : std_logic_vector(2 downto 0):="010"; -- diag multiply;  mode op_r= diag_mul * op_1 with s_diag_to_mat_m 
constant m_diag_add : std_logic_vector(2 downto 0):="011"; -- diag addition; op_R = op_1+eye with s_diag_addition
constant m_mat_copy : std_logic_vector(2 downto 0):="100"; -- op1 copied to op_r
constant m_mat_lout : std_logic_vector(2 downto 0):="111"; -- loads op_r out..


--- constants to map the spec command
constant s_end_of_prog  : std_logic_vector(2 downto 0):="111";  -- end of program.
constant s_mat_load_wd  : std_logic_vector(2 downto 0):="001";  -- without divider on.
constant s_mat_load_wod : std_logic_vector(2 downto 0):="010";  -- with divider on.
constant s_diag_subtract: std_logic_vector(2 downto 0):="001";  -- do diag subtraction instead of addition.
constant s_diag_addition: std_logic_vector(2 downto 0):="000";  -- do diag addition.
constant s_diag_to_mat_m: std_logic_vector(2 downto 0):="000";  -- z^-1* X.
constant s_mat_to_diag_m: std_logic_vector(2 downto 0):="001";  -- X*z^-1.
constant s_none         : std_logic_vector(2 downto 0):="000";  -- set to zero.

--- constants to mapt the mat index.
constant mat_i_0   : std_logic_vector(3 downto 0):=x"0";
constant mat_i_1   : std_logic_vector(3 downto 0):=x"1";
constant mat_i_2   : std_logic_vector(3 downto 0):=x"2";
constant mat_i_3   : std_logic_vector(3 downto 0):=x"3";
constant mat_i_4   : std_logic_vector(3 downto 0):=x"4";
constant mat_i_5   : std_logic_vector(3 downto 0):=x"5";
constant mat_i_6   : std_logic_vector(3 downto 0):=x"6";
constant mat_i_7   : std_logic_vector(3 downto 0):=x"7";
constant mat_i_8   : std_logic_vector(3 downto 0):=x"8";
constant mat_i_9   : std_logic_vector(3 downto 0):=x"9";
constant mat_i_a   : std_logic_vector(3 downto 0):=x"a";
constant mat_i_b   : std_logic_vector(3 downto 0):=x"b";
constant mat_i_c   : std_logic_vector(3 downto 0):=x"c";
constant mat_i_d   : std_logic_vector(3 downto 0):=x"d";
constant mat_i_e   : std_logic_vector(3 downto 0):=x"e";
constant mat_i_f   : std_logic_vector(3 downto 0):=x"f";

---- constants to map dynamic scaling.
constant dynamic_scale_Nil : std_logic_vector(5 downto 0):="000000";





type array_type is array(0 to 15) of std_logic_vector(24-1 downto 0); -- 32 deep fifo.

signal instruction_reg, write_instruction_reg : array_type;	-- to store the instructions.

signal to_instruction_reg : array_type;



signal to_write_reg : std_logic_vector(23 downto 0);
signal i_write_i_p  : unsigned(3 downto 0);
signal i_pc         : unsigned(3 downto 0);

begin

i_write_i_p <= unsigned(write_i_p);
i_pc        <= unsigned(pc);
-- mux to decide what to be written to the instruction_reg array based on the instreg_mode.
process(instreg_mode, instruction_reg,write_instruction_reg )
begin
     to_instruction_reg <= (others=>(others=>'0'));
	case(instreg_mode) is
	when "00"=> -- debug instreg_mode.  --- place to write program data for debugging data.
		to_instruction_reg(0) <="000000100000000100000000";  -- load mat   -000 op 1 =001 op_2 = 000 op_r = 000 special mode= 000 dynamic shift = 000000
               --to_instruction_reg(0) <="000000100000000000000000";  -- load mat without divider -000 op 1 =001 op_2 = 000 op_r = 000 special mode= 100 dynamic shift = 000000
		to_instruction_reg(1) <="111000000000000000000000";  -- load matout -111 op 1= oo1 op_2 = 000 op_r = 000 special mode =000 dynamic shift - 000000;
		to_instruction_reg(2) <="100000000000001000000000";  -- copy matrix - mat 0 to mat 1
		to_instruction_reg(3) <="111000000000001000000000";  -- load matout -load mat 1 out.
		to_instruction_reg(4) <="011000100000001000000000";  -- matrix diagonal addition. mode 011 and store it in mat 1.
		to_instruction_reg(5) <="111000000000001000000000";  -- load matout -load mat 1 out.
		to_instruction_reg(6) <=m_mat_mul  & mat_i_0 & mat_i_1 & mat_i_3 & s_none & dynamic_scale_Nil;  -- matrix mulitplication 
		to_instruction_reg(7) <=m_mat_lout & mat_i_0 & mat_i_1 & mat_i_3 & s_none & dynamic_scale_Nil;  -- load matout -load mat 1 out.
		to_instruction_reg(8) <=m_diag_mul & mat_i_3 & mat_i_0 & mat_i_0 & s_diag_to_mat_m & dynamic_scale_Nil;
		to_instruction_reg(9) <=m_mat_lout & mat_i_0 & mat_i_0 & mat_i_0 & s_none & dynamic_scale_Nil;
		to_instruction_reg(10)<=m_diag_mul & mat_i_3 & mat_i_0 & mat_i_1 & s_none & dynamic_scale_Nil;
		to_instruction_reg(11)<=m_mat_lout & mat_i_0 & mat_i_0 & mat_i_1 & s_none & dynamic_scale_Nil;
		to_instruction_reg(12)<="000000100000000111000000";  -- end of instruction.. xxx--special special mode=111 --xxx rest are dont care.
		to_instruction_reg(13)<=(others=>'0');
		to_instruction_reg(14)<=(others=>'0');
		to_instruction_reg(15)<=(others=>'0');
	when "01"=> -- auto instreg_mode. -- place to write program data for normal operation.
	        
		to_instruction_reg(0) <= m_mat_load & mat_i_0 & mat_i_1 & mat_i_3 & s_none & dynamic_scale_Nil;
		to_instruction_reg(1) <= m_diag_mul & mat_i_0 & mat_i_1 & mat_i_3 & s_diag_to_mat_m & dynamic_scale_Nil;
		to_instruction_reg(2) <= m_diag_add & mat_i_3 & mat_i_1 & mat_i_3 & s_none & dynamic_scale_Nil;
		to_instruction_reg(3) <= m_mat_copy & mat_i_3 & mat_i_1 & mat_i_4 & s_none & dynamic_scale_Nil;
		to_instruction_reg(4) <= m_mat_mul & mat_i_3 & mat_i_4 & mat_i_1 & s_none & dynamic_scale_Nil;
		to_instruction_reg(5) <= m_diag_mul & mat_i_1 & mat_i_0 & mat_i_5 & s_diag_to_mat_m & dynamic_scale_Nil;
		to_instruction_reg(6) <= m_mat_lout & mat_i_5 & mat_i_0 & mat_i_5 & s_none & dynamic_scale_Nil;
		to_instruction_reg(7) <="000000100000000111000000";
		to_instruction_reg(8) <=(others=>'0');
		to_instruction_reg(9)<=(others=>'0');
		to_instruction_reg(10)<=(others=>'0');
		to_instruction_reg(11)<=(others=>'0');
		to_instruction_reg(12)<=(others=>'0');
		to_instruction_reg(13)<=(others=>'0');
		to_instruction_reg(14)<=(others=>'0');	
                to_instruction_reg(15) <=(others=>'0');    
	when "10"=> -- controller instreg_mode.-- when instruction is send by a master processor.
	    to_instruction_reg(0) <=   write_instruction_reg(0); 
		to_instruction_reg(1)  <=  write_instruction_reg(1);
		to_instruction_reg(2)  <=  write_instruction_reg(2); 
		to_instruction_reg(3)  <=  write_instruction_reg(3); 
		to_instruction_reg(4)  <=  write_instruction_reg(4); 
		to_instruction_reg(5)  <=  write_instruction_reg(5); 
		to_instruction_reg(6)  <=  write_instruction_reg(6); 
		to_instruction_reg(7)  <=  write_instruction_reg(7); 
		to_instruction_reg(8)  <=  write_instruction_reg(8); 
		to_instruction_reg(9)  <=  write_instruction_reg(9); 
		to_instruction_reg(10) <=  write_instruction_reg(10);
		to_instruction_reg(11) <=  write_instruction_reg(11);
		to_instruction_reg(12) <=  write_instruction_reg(12);
		to_instruction_reg(13) <=  write_instruction_reg(13);
		to_instruction_reg(14) <=  write_instruction_reg(14);
		to_instruction_reg(15) <=  write_instruction_reg(15); 
	    
	when others=> -- normal operation. no trasnfer of instruction to instruction reg.
	    to_instruction_reg(0) <=   instruction_reg(0); 
		to_instruction_reg(1)  <=  instruction_reg(1);
		to_instruction_reg(2)  <=  instruction_reg(2); 
		to_instruction_reg(3)  <=  instruction_reg(3); 
		to_instruction_reg(4)  <=  instruction_reg(4); 
		to_instruction_reg(5)  <=  instruction_reg(5); 
		to_instruction_reg(6)  <=  instruction_reg(6); 
		to_instruction_reg(7)  <=  instruction_reg(7); 
		to_instruction_reg(8)  <=  instruction_reg(8); 
		to_instruction_reg(9)  <=  instruction_reg(9); 
		to_instruction_reg(10) <=  instruction_reg(10);
		to_instruction_reg(11) <=  instruction_reg(11);
		to_instruction_reg(12) <=  instruction_reg(12);
		to_instruction_reg(13) <=  instruction_reg(13);
		to_instruction_reg(14) <=  instruction_reg(14);
		to_instruction_reg(15) <=  instruction_reg(15); 
	end case;
	

end process;


 -- current instruction where pc is pointing to.
process(instruction_reg,i_pc)
begin
current_instruction <= instruction_reg(to_integer(i_pc));
end process;


process(write_i_en, i_write_i_p, instruction_write,write_instruction_reg) begin
  if(write_i_en='1') then
   to_write_reg <= instruction_write;
  else
   to_write_reg <= write_instruction_reg(to_integer(i_write_i_p));
  end if;
end process;





--- sequential part, where registers are reset and written.

process(clk, rst)
begin
	if(rst='1') then
		instruction_reg <= (others=>(others=>'0'));
		write_instruction_reg <= (others=>(others=>'0'));

	elsif(rising_edge(clk)) then
	 
	 -- transfer to write_instruction_reg array
		write_instruction_reg(to_integer(i_write_i_p))<= to_write_reg;
		
	 -- transfers to instruction array.
		instruction_reg(0) <=   to_instruction_reg(0) ;
		instruction_reg(1) <=   to_instruction_reg(1) ;
		instruction_reg(2) <=   to_instruction_reg(2) ;
		instruction_reg(3) <=   to_instruction_reg(3) ;
		instruction_reg(4) <=   to_instruction_reg(4) ;
		instruction_reg(5) <=   to_instruction_reg(5) ;
		instruction_reg(6) <=   to_instruction_reg(6) ;
		instruction_reg(7) <=   to_instruction_reg(7) ;
		instruction_reg(8) <=   to_instruction_reg(8) ;
		instruction_reg(9) <=   to_instruction_reg(9) ;
		instruction_reg(10)<=   to_instruction_reg(10);
		instruction_reg(11)<=   to_instruction_reg(11);
		instruction_reg(12)<=   to_instruction_reg(12);
		instruction_reg(13)<=   to_instruction_reg(13);
		instruction_reg(14)<=   to_instruction_reg(14);
		instruction_reg(15)<=   to_instruction_reg(15);
	end if; 
end process;

end beh; 													-- end of architecture
