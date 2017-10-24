-- File   : mast_ctrl_v1.vhd
-- Author : Arun jeevaraj
-- Team   : Arun and Deepak Yadav  , Team Mentor : Liang Liu 
-- usage  : level 3 of control flow , has instruction cache; two modes of operations stored as debug and auto , that perform the neuman series operation for 
--          stages. The instructions can be writted to the instruction write register and by setting the operation mode to controlled mode. The controlled executes the
--          the list of instructions received. The controller has two stages during operation, to fetch and execute.  It can goto idle mode when it is not performing any tasks
--           
-- DLM    : 6/18/2016   7:49 AM 
-- Tested : modelsim student edition 10.4 a
-- Todo   : None
-- error  : none.
-- warning: none. 
-- copyright: Arun Jeevaraj .2016 Lund University.



library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;





entity mast_ctrl is 
port  ( 
    -- to start the processing of the  instruction set.
		start     : in std_logic;
		done      : out std_logic;		-- when it is done .
		clk       : in std_logic;
		rst       : in std_logic;
	--data_out_vld  : out std_logic;  moved to mat controller. It makes more sense there.
	
	-- decoded current instruction.
		mode      : out std_logic_vector(2 downto 0);
		op_1      : out std_logic_vector(3 downto 0);
		op_2      : out std_logic_vector(3 downto 0);
		op_r      : out std_logic_vector(3 downto 0);
	spec_command  : out std_logic_vector(2 downto 0);
	dynamic_scale : out std_logic_vector(5 downto 0);
	
	-- master controller, mode settings.
  data_to_instruction : in std_logic_vector(31 downto 0);	
	 instruction_vld  : in std_logic;
	 operation_mode   : in std_logic_vector(1 downto 0);
	 mat_order_in     : in std_logic_vector(5 downto 0); -- can support upto 64 matrix order.
	 mat_order_out    : out std_logic_vector(5 downto 0); -- can support upto 64 matrix order.
	 
	-- handshakes to other sub controllers. 
		start_matctrl : out std_logic;
		done_matctrl  : in std_logic ;
		start_top_inv : out std_logic;
		done_top_inv  : in std_logic
		);

end mast_ctrl;



architecture beh of mast_ctrl is

-- 24 bit instruction.
-- 3 bits mode, 12 bits operands, -3 bits for special commands, - 6 bits for dynamic scaling.
-- can store upto 32 instructions at a time.

component instruction_reg
port( current_instruction: out std_logic_vector(23 downto 0);   -- instruction to read from fifo.
      instruction_write  : in std_logic_vector (23 downto 0);	-- instruction to write to fifo 
	  write_i_en         : in std_logic;						--write to write reg array.
	  pc                 : in std_logic_vector(3 downto 0);
	  write_i_p          : in std_logic_vector(3 downto 0);		-- where to write to the write reg array.
	  clk                : in std_logic;
	  rst                : in std_logic;
	  instreg_mode       : in std_logic_vector(1 downto 0)		--- debug instreg_mode, auto instreg_mode, and controlled instreg_mode.
	);
end component;



signal instruction_write  : std_logic_vector (23 downto 0);
signal current_instruction: std_logic_vector(23 downto 0);
signal write_i_p,
       write_i_p_incr     : unsigned(3 downto 0);
signal instreg_mode       : std_logic_vector(1 downto 0);
signal pc ,pc_incr        : unsigned (3 downto 0);
--signal dynamic_scale      : std_logic_vector(5 downto 0); -- 6 bits
signal spec_command_r       : std_logic_vector(2 downto 0);
signal start_top_inv_ff,
	   start_top_inv_reg  : std_logic;

signal start_matctrl_ff,
	   start_matctrl_reg  : std_logic;
signal mode_r             : std_logic_vector(2 downto 0);
signal mat_order_reg,
       mat_order_reg_upd  : std_logic_vector(5 downto 0);	   

type system_state is (st_idle,							-- idle state.
					  st_debug,st_auto,st_controlled,	-- branches to different modes of operations. debug, and auto are realised for IC project.
					  st_fetch,							-- fecthes from the instruction reg, the new instruction.
					  st_exectute,						-- starts executing the current instruction.
					  st_done);							-- reached the end of instruction.

signal cs, ns   : system_state ;                		-- used for the state machine, next state and current state.
					  
begin

-- done signal output port to show that execution of instructions were done.
done <= '1' when cs = st_done else '0';

-- to read the output port signal , mode_r is used and is bypassed to mode, out port of the entity.
mode <= mode_r;

-- when in instruction mode, the data pins can be used to send the custom instruction set.
instruction_write <= data_to_instruction(23 downto 0);


-- start_top_inv
start_top_inv <= start_top_inv_reg;

-- start_matctrl handshake to mat controller . this shouldn't be initiated for the end of instruction command.
start_matctrl <= '0' when spec_command_r="111" else start_matctrl_reg;

-- 
spec_command <= spec_command_r;


--- instruction register inst..
--- ping pong register array, for instructions.
--- keeps a half of registers to write and the other half for instruction execution,
--- this allows the controller to work with a set of instructions, and at the same time,
--- the processor can write the instructions to do with which , controller can execute after it 
---has completed the present set of instructions.


-- to send to mat controller.
mat_order_out <= mat_order_reg;
-- used to set the matrix order at the time of start up.
mat_order_reg_upd <= mat_order_in when cs = st_auto or cs =st_controlled or cs = st_debug else mat_order_reg;

instruction_reg_inst: instruction_reg
port map( 
	  current_instruction=> current_instruction,
      instruction_write  => instruction_write,
	  write_i_en         => instruction_vld,
	  pc                 => std_logic_vector(pc),
	  write_i_p          => std_logic_vector(write_i_p),
	  clk                => clk,
	  rst                => rst,
	  instreg_mode       => instreg_mode
	);


-- mapping current instruction to control signals to mat controller.
mode_r        <= current_instruction(23 downto 21);   -- 3 bits for the mode of operations for the mat controller.
op_1          <= current_instruction(20 downto 17);   -- first mat index for the operands
op_2          <= current_instruction(16 downto 13);   -- mat index for operands
op_r          <= current_instruction(12 downto 9);    -- resultant operand
spec_command_r  <= current_instruction(8 downto 6);     -- 3 bits for special modes. used in some modes to set values, or add or sub
dynamic_scale <= current_instruction(5 downto 0);     -- 6 bits for dynamic scaling. for fixed point.


-- start handshake generate for  div controller.
process( cs,start_top_inv_reg,mode_r,spec_command_r)
begin
	if( mode_r ="000" and spec_command_r="100" 
	             and  cs = st_exectute) then
			start_top_inv_ff    <= '0';
	elsif(cs= st_done or cs = st_idle)  then         -- soft reset the divider block 
		    start_top_inv_ff <= '1';
	else
		    start_top_inv_ff <= start_top_inv_reg;
	end if;

end process;
	
-- write ip is incremented everytime the controller receives a new instruction. the instruction is stored to register array
-- when the controller sees the instruction_vld signal .	

write_i_p_incr_gen: process(instruction_vld, write_i_p)
begin
	if(instruction_vld='1') then
	 write_i_p_incr <= write_i_p+1;
	else
	  write_i_p_incr <= write_i_p;
	end if;  

end process;


--- start handshake generation for the mat controller block.

process (cs,ns) 
begin

if (ns = st_exectute and (cs= st_fetch or cs = st_auto 
			  or cs = st_controlled or cs = st_debug)) then
	start_matctrl_ff <= '1';
else
    start_matctrl_ff <='0';
end if;	

end process;


-- pc increments at the end of each execution stage.
-- it is reset to zero when the controller reaches the end of the instructions sets.
-- max number of instructions supported is 16 for now.



pc_incr_gen: process(pc, cs) 
begin
	if(cs = st_done) then
	    pc_incr <= x"0";
	elsif(cs= st_fetch and pc < x"f") then
	    pc_incr <= pc +1;
		
	else
		pc_incr <=pc;
	end if;
end process;



--- instreg_mode is set based on what type of operation mode the master controller is set to perform.
--- used to initialize the instruction reg array, to set the new register array to instruction reg array.


instreg_mode_gen: process(cs)
begin
	case cs is
	  when st_auto =>
	    instreg_mode <= "01";
	  when st_debug =>
	    instreg_mode <= "00";
	  when st_controlled=>
	    instreg_mode <= "10";
	  when others =>
	    instreg_mode <= "11";
	end case;  


end process;




-- sequential part of the state machine.
st_machine_seq: process(clk,rst)
begin
	if(rst='1') then

		  write_i_p         <= (others=>'0');
		  pc                <= (others=>'0');
		  cs                <= st_idle;
		  start_top_inv_reg <= '0';
		  start_matctrl_reg <= '0';
		  mat_order_reg     <= (others=>'0');  -- order set to 12 for now.
	elsif(rising_edge(clk)) then
	      cs                <= ns;
		  write_i_p         <= write_i_p_incr;
		  pc                <= pc_incr;
		  start_top_inv_reg <= start_top_inv_ff;
		  start_matctrl_reg <= start_matctrl_ff;
		  mat_order_reg     <= mat_order_reg_upd; -- need to be updated with the value at the start up.
	end if;	  
end process;



--combinational part of the state machine.
process(cs,start,operation_mode,mode_r,spec_command_r,done_matctrl,done_top_inv)
begin
	 case(cs) is
	 when st_idle =>
		if(start ='1') then
			case operation_mode is
			 when "00" =>
			  ns <= st_debug;
			 when "01" =>
			  ns <= st_auto;
			 when "10" =>
			  ns <= st_controlled;
			 when others => 								-- reserved for later use
			  ns <= st_idle;
			 end case;
		else
		 ns <= st_idle;
		end if;
	 when st_debug =>
	  ns <= st_exectute;
	 when st_auto =>
	  ns <= st_exectute;
	 when st_controlled=>
	  ns <= st_exectute;
	 when st_exectute =>
	   if(spec_command_r="111") then 							--- notify the end of instructions.
		   ns <= st_done;
	   elsif(mode_r ="000" and spec_command_r="100") then     -- special load mat option.
			 if(done_top_inv ='1')	then					-- only used when the matrix is input matrix for 
															-- which inverse needs to be found and waits for div to be done.
				ns <= st_fetch;
			 else
				ns <= st_exectute;
		 end if;
	   else													--- normal handshake.
		  if(done_matctrl='1') then
			ns <= st_fetch;
		  else
			ns <= st_exectute;
		  end if;
		
	   end if;
	 when st_fetch  =>
		 ns <= st_exectute;
	 
	 when st_done =>
	  ns <= st_idle;
	 when others=>
	  ns <= st_idle;
	 end case;

end process;



end beh;