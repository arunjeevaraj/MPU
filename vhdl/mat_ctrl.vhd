library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
----
-- mode 000 for loading the input matrix to ram, to op_1
-- mode 001 for performing mat_mult. op_1*op_2 = op_r
-- mode 010 for reading the mat col wise and writing col wise. used for diag special multiply-- diag_mat*op_1 => op_r
-- mode 011 for subi     -- set op_r matrix diagonal elements zero
-- mode 100 for mat copy --  op_1 to op_r.     
-- mode 101 for addi     -- set op_r matrix diagonal elements to one.
-- mode 110 for reading the mat row wise and writing row wise. used for diag special multiply.-- op_1 * diag_mat => op_r.
-- mode 111 for sending the result out serially through data out..

entity mat_ctrl is
port (  start     : in std_logic;
		done      : out std_logic;
		write_en  : out std_logic;
		mode      : in std_logic_vector(2 downto 0);
		op_1      : in std_logic_vector(3 downto 0);
		op_2      : in std_logic_vector(3 downto 0);
		op_r      : in std_logic_vector(3 downto 0);
		mat_index : out std_logic_vector(3 downto 0); 
		mm_switch : in std_logic;
		start_o   : out std_logic;
		done_o    : in std_logic;
		clk       : in std_logic;
		rst       : in std_logic;
	mac_write_vld : in std_logic;
	diag_wm_tog   : in std_logic;
	diag_wm       : out  std_logic_vector(1 downto 0);
	row_mode      : out std_logic_vector(1 downto 0)
		);
end entity;


architecture beh of mat_ctrl is

type system_state is (st_idle, st_load_mat,st_row_load, st_mac, st_mac_write,
					  st_diag_col,st_diag_col_wt,
					  st_diag_sel, st_diag_sel_wait,
					  st_done);
signal cs,ns : system_state;

signal mm_switch_ff : std_logic;

signal start_o_diag_col_mask,start_o_gen : std_logic;
signal diag_wm_i : std_logic_vector(1 downto 0);

begin


-- to fix irradic behavior of state switching of the address decoder.
process(cs,diag_wm_i)
begin
 if(cs= st_done or cs= st_idle) then 
  diag_wm <= "00";
 else
  diag_wm<= diag_wm_i;
 end if;
end process;


diag_wm_i <= "01" when mode= "010" or mode = "100" or mode ="110" else  -- diag_col operations
	         "11" when  mode = "011"  else		   -- for set i, operation 
		     "10" when  mode = "101"  
		   else "00"; -- for normal mat mul operation
		   
row_mode <= "01" when mode ="110" else "10";
            

done <='1' when cs= st_done else '0';
process(start_o_gen,start_o_diag_col_mask) 
begin
  start_o <= start_o_gen  and start_o_diag_col_mask;
end process;

start_o_diag_col_mask <= '0' when (cs = st_diag_col_wt) and (ns = st_done) else '1';

process(clk, rst) 
begin
if(rst='1') then
    cs 				 <= st_idle;
    mm_switch_ff     <= '0';
	
elsif(rising_edge(clk)) then
	cs 			 <= ns;
	mm_switch_ff <= mm_switch;
	
end if;
end process;


process(cs,start,mode,done_o,mm_switch,mac_write_vld,mm_switch_ff,diag_wm_tog) 
begin
case(cs) is
  when st_idle=>
   if(start='1') then
		if(mode="000") then
		 ns <= st_load_mat;
		elsif(mode="001") then
		 ns <= st_row_load;
		elsif(mode="010" or mode = "100" or mode ="110") then -- diag col read and col write and diag_row read and row write equivalent.
		 ns<= st_diag_col;					   -- mat copy.
		elsif(mode="011" or mode ="101" ) then -- subi and addi
		 ns<= st_diag_sel;
		else 
		 ns <= st_idle;
		end if;
   end if;
  when st_load_mat =>
		if(done_o='1') then
			ns <= st_done;
		else
		    ns <= st_load_mat;
		end if;
  when st_row_load =>
			if(mm_switch='1') then
			 ns <= st_mac;
			else
			  ns <= st_row_load;
			end if;
  when st_mac =>
	if(mac_write_vld='1') then
		ns <= st_mac_write;
	else
		ns <= st_mac;
	end if;	
  when st_mac_write =>
    if(done_o='1') then
        ns <= st_done; 
	else
	    if(mm_switch_ff='1') then
		  ns <= st_row_load;
		else
       	  ns <= st_mac; 
		end if;
	end if;	
  when st_diag_col =>
   if(diag_wm_tog='1') then
     
	   if(done_o ='1') then
		ns <= st_done;
	   else
		ns <= st_diag_col_wt;  
	   end if;
   else
     ns <= st_diag_col;
   end if;
  when st_diag_col_wt =>
   if(done_o ='1') then
   ns <= st_done;
   else
   ns <= st_diag_col;  
   end if;
  when st_diag_sel  =>
   if(done_o='1') then
    ns <= st_done;
   else
     ns <= st_diag_sel_wait;
   end if;
  when st_diag_sel_wait => 
   if(done_o='1') then
    ns <= st_done;
   else
     ns <= st_diag_sel_wait;
   end if;
  when st_done=>
   ns<= st_idle;
  when others =>
   ns<= st_idle;
end case;
end process;

process(cs,ns) 
begin
 case cs is
 when st_row_load=>
   write_en <='0';
   start_o_gen <= '1';
 when st_load_mat=>
   write_en <= '1';
   start_o_gen  <= '1';
 when st_mac =>
  write_en <= '0';
  start_o_gen  <= '1';
when st_mac_write =>
  write_en <= '1';
  start_o_gen  <= '1';
when st_diag_col =>
  
  write_en <= '0';
  start_o_gen  <=  '1'; 
when st_diag_col_wt =>
  write_en <= '1';
  start_o_gen  <= '1'; 
when st_diag_sel =>
  write_en <='1';
  start_o_gen <='1';
when st_diag_sel_wait =>
  if(ns= st_done) then
    write_en <='0';
  else  
	write_en <='1';
  end if;	
	
  start_o_gen <='0';   
 when others =>
   write_en <= '0';
   start_o_gen  <= '0';
 end case;
end process;

process(op_1,op_2,op_r,cs) 
begin
  case cs is 
	when st_load_mat=>
	 mat_index  <= op_1;
	when st_row_load=>
     mat_index  <= op_2;
    when st_mac =>
     mat_index <= op_1;	
	when st_mac_write =>
	 mat_index <= op_r;
	when st_diag_col =>
     mat_index <= op_1;	
	when st_diag_col_wt =>
     mat_index <= op_r;	
	when st_diag_sel =>
     mat_index <= op_r;
	when st_diag_sel_wait=>
	 mat_index <= op_r;
	when others     =>
     mat_index <=x"0";
	 
  end case;


end process;

end beh;