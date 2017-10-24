library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
----
-- mode 000 for loading the input matrix to ram, to op_1
-- mode 001 for performing mat_mult. op_1*op_2 = op_r
-- mode 010 for reading the mat col wise and writing col wise. used for diag special multiply-- diag_mat*op_1 => op_r
-- mode 011 for seti     -- set op_r matrix diagonal elements zero or one based on value of eye.
-- mode 100 for mat copy --  op_1 to op_r.     
-- mode 101 for addi     -- read and write back col wise ..add one or subtract one.
-- mode 110 for reading the mat row wise and writing row wise. used for diag special multiply.-- op_1 * diag_mat => op_r.
-- mode 111 for sending the result out serially through data out col wise..


entity mast_ctrl is 
port  ( 
		start     : in std_logic;
		done      : out std_logic;
		clk       : in std_logic;
		rst       : in std_logic;
		
		mode      : out std_logic_vector(2 downto 0);
		op_1      : out std_logic_vector(3 downto 0);
		op_2      : out std_logic_vector(3 downto 0);
		op_r      : out std_logic_vector(3 downto 0);
		
		
		start_matctrl : out std_logic;
		done_matctrl  : in std_logic ;
		start_top_inv : out std_logic;
		done_top_inv  : in std_logic;
		eye           : out std_logic_vector(31 downto 0)
		);

end mast_ctrl;


architecture beh of mast_ctrl is

type mast_ctrl_state is (st_idle,st_mat_load,st_diag_gen,
						 st_diag_col,st_diag_row,
						 st_seti_1,st_seti_2,
						 st_addi,
						 st_copy1,st_copy2,
						 st_mat_mul,
						st_done);
					
signal cs,ns : mast_ctrl_state ;

signal start_top_inv_ff :std_logic;

signal start_mat_load,
	   start_diag_col, start_diag_col_ff,
	   start_copy,start_copy_ff,
	   start_seti, start_addi,
       start_mat_mul	   
			            : std_logic;

signal eye_reg : std_logic;

begin

start_top_inv <= start_top_inv_ff;

eye <= "000"&x"0000000"&'1' when eye_reg  = '1' else (others=>'0') ;

process (cs)
begin
if(cs= st_seti_1 or cs= st_addi) then
	eye_reg <='1';
else
	eye_reg <='0';
end if;
end process;

--- signal generation based on the state and to represent state change edges.
done <='1' when cs = st_done else '0';

		   
start_mat_load <='1' when (cs = st_idle and ns = st_mat_load) else '0';
start_diag_col <='1' when (cs = st_diag_gen and ns = st_diag_row) else '0';
start_seti     <='1' when ((cs = st_seti_1 and ns = st_seti_1) or (cs = st_seti_2 and ns = st_seti_2)) else '0';
start_copy     <='1' when ((cs = st_copy1 and ns = st_copy1) or (cs=st_copy2 and cs=st_copy2)) else '0';
start_mat_mul  <='1' when (cs= st_mat_mul and ns = st_mat_mul) else '0';


start_gen: process	(start_mat_load, start_diag_col_ff,
					  start_seti,start_copy_ff,start_mat_mul)
begin					 
   start_matctrl <= start_mat_load or start_diag_col_ff
					 or start_seti or start_copy_ff
					 or start_mat_mul;	
   
end process;	
					 
process(clk,rst)
begin
	if(rst='1') then
	 cs <= st_idle;
	 start_top_inv_ff <= '1';
	 start_diag_col_ff<= '0';
	 start_copy_ff  <='0';
	elsif(rising_edge(clk)) then
	  cs <= ns;
	  start_copy_ff <= start_copy;
	  start_diag_col_ff<= start_diag_col;
	    if(cs = st_idle and start ='1') then
			start_top_inv_ff <= '0';
	    end if;
	end if; 
	
end process;


process(start, cs, done_matctrl,done_top_inv)
begin
	case cs is
	
	when st_idle =>
		if(start='1') then
		  ns <= st_mat_load;
		else
		  ns <= st_idle;
		end if;
	when st_mat_load =>
         if(done_matctrl='1') then
		   ns <=  st_diag_gen;
		 else
		   ns <= st_mat_load ;
		 end if;
	when st_diag_gen =>
		if(done_top_inv='1') then
		 ns <= st_diag_row;
		else
		 ns <= st_diag_gen;
		end if;
	when st_diag_row=>
	  if(done_matctrl='1') then
		 ns <= st_copy1;
		else
		 ns <= st_diag_row;
	  end if;
	
	when st_copy1 =>
        if(done_matctrl='1') then
		 ns <= st_seti_1;
		else
		 ns <= st_copy1;
		end if;	
	when st_seti_1 =>
	 if( done_matctrl='1') then
	    ns <= st_copy2;
	 else
	    ns <= st_seti_1;
	 end if;
    when st_copy2 =>
	 if( done_matctrl='1') then
	    ns <= st_seti_2;
	 else
	    ns <= st_copy2;
	 end if;
	when st_seti_2=>
       if( done_matctrl='1') then
	    ns <= st_mat_mul;
	 else
	    ns <= st_seti_2;
	 end if;
    when st_mat_mul =>
       if( done_matctrl='1') then
	    ns <= st_addi;
	 else
	    ns <= st_mat_mul;
	    
	 end if;	
	when st_addi =>
		if( done_matctrl='1') then
	    ns <= st_addi;
	 else
	    ns <= st_addi;
	 end if;
		
	when st_diag_col=>
      if( done_matctrl='1') then	
	 	ns <= st_seti_1;
	  else 
	    ns <= st_diag_col;
	  end if;
	  
	when others =>
	    ns <= st_idle;
	end case ;


end process;


process (cs) begin


 case cs is 
 when st_idle =>
	op_1 <=(others => '0');
	op_2 <=(others => '0');
	op_r <=(others => '0');
	mode <=(others => '0');
 when st_mat_load => -- loads the matrix to op_1 
    op_1 <= x"0";
	op_2 <= x"0";
	op_r <= x"0"; 
	mode <= "000"; -- mode 0 to start the load the mat to ram stage.
 when st_diag_row =>	-- performs the mat with diag multiplication. where rows are multiplied with the diagonal elements.
     op_1 <= x"0";		-- mato 0 with diag elements. and stores in mat index 1.
	 op_2 <= x"0";
	 op_r <= x"1";
	 mode <= "110";
 when st_copy1 =>	-- copies the mat op_1 to mat op_r
     op_1 <= x"1";	-- copies 1 to 2
     op_2 <= x"0";
     op_r <= x"2";
	 mode <= "100";
 when st_copy2 =>	
     op_1 <= x"1";	-- copies 1 to 3
     op_2 <= x"0";
     op_r <= x"3";
	 mode <= "100"; 
 when st_addi => -- sets the diagonal elements of op_r to one.
    op_1 <= x"0";
    op_2 <=	x"0";
	op_r <= x"2";
	mode <= "101";	 
 when st_diag_col => -- reads the col of the matrix op_1 and multiply with diagonal elements and store the result col wise.
    op_1 <= x"0";
	op_2 <= x"0";
	op_r <= x"1";
	mode <= "010"; 
 when st_seti_1 => -- sets the diagonal elements of op_r to zero.
    op_1 <= x"0";
	op_2 <= x"0";
    op_r <= x"1";
    mode <= "011";
 when st_seti_2 =>	-- sets the diagonal elements of op_r to zero.
    op_1 <= x"0";
	op_2 <= x"0";
    op_r <= x"3";
    mode <= "011";
 when st_mat_mul =>
    op_1 <= x"0";
	op_2 <= x"0";
    op_r <= x"3";
    mode <= "001";
 
 
 when others =>
    op_1 <=(others => '0');
	op_2 <=(others => '0');
	op_r <=(others => '0');
	mode <= "000";
 end case;
end process;


end beh;