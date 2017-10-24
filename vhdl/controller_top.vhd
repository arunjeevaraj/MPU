-- Author : Arun jeevaraj
-- Team   : Arun and Deepak Yadav  , Team Mentor : Liang Liu 
-- usage  : -- to wrap all the control blocks in one place.
-- DLM    : 6/21/2016   6:22 PM
-- Tested : modelsim student edition 10.4 a
-- error  : none.
-- warning: none. 
-- copyright : Arun Jeevaraj. 2016.


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;



entity controller_top is
port(  
       clk            : in std_logic;
	   rst            : in std_logic;
	  start           : in std_logic;
	  done            : out std_logic;
	i_data_vld        : in std_logic;  -- used for loading in matrix.
	o_data_vld        : out std_logic; -- used for loading out matrix.
	
   -- incoming instruction
	 i_instruction    : in std_logic_vector(31 downto 0);
	 i_instruction_vld: in std_logic;
   -- matrix size and operation mode control.
 ctrl_operation_mode  : in std_logic_vector(1 downto 0);
	 mat_order        : in std_logic_vector(5 downto 0);
	 mat_order_out_c    : out std_logic_vector(5 downto 0);
	 
	-- control signals to RAM.  
	  address         : out std_logic_vector(13 downto 0);
	  ram_sel         : out std_logic_vector(3 downto 0);
	  ram_wen         : out std_logic;
	  
	  
	-- register array control 
	        row_i    : out  std_logic_vector(5 downto 0);		-- used to write to register array.
	        reg_rwn  : out std_logic; 									-- to read or write to register array.
       reg_row_set   : out std_logic_vector(3 downto 0);                 -- should be connected row_offset.
	 
	-- data path control.
    m_muli_sel_reg    : out std_logic;                            -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  : out std_logic;     						  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  : out std_logic_vector(1 downto 0);		  -- mux at the odd stage1 adder input2.
	m_data_out_sel    : out std_logic_vector(1 downto 0);         -- mux at the output stage.

	s1_sub_e          : out std_logic;							  -- for add/ subtract operation.
    s1_acc_enable     : out std_logic;
	s2_acc_enable     : out std_logic;
	flush             : out std_logic;                            -- to flush out the accumulators
	dynamic_scale     : out std_logic_vector(1 downto 0);         -- for dynamic scaling at the output.
	
	-- divider handshake control signals
	    start_top_inv : out std_logic;
	    done_top_inv  : in std_logic;
	 data_in_sel_out  : out std_logic_vector(1 downto 0);         -- mux at the entrance of RAM.
     div_row_mode_out : out std_logic_vector(1 downto 0);
     div_address_out  : out std_logic_vector(7 downto 0)
	);
end entity;


architecture beh of controller_top is

-- 
-- Master controller... fetches and execute instructions.


component mast_ctrl is 
port  ( 
			start     : in std_logic;
			done      : out std_logic;
			clk       : in std_logic;
			rst       : in std_logic;
		--data_out_vld  : out std_logic;
	
			mode      : out std_logic_vector(2 downto 0);
			op_1      : out std_logic_vector(3 downto 0);
			op_2      : out std_logic_vector(3 downto 0);
			op_r      : out std_logic_vector(3 downto 0);
		spec_command  : out std_logic_vector(2 downto 0);
	    dynamic_scale : out std_logic_vector(5 downto 0);
		
  data_to_instruction : in std_logic_vector(31 downto 0);	
	 instruction_vld  : in std_logic;
	 operation_mode   : in std_logic_vector(1 downto 0);
	 mat_order_in     : in std_logic_vector(5 downto 0); -- can support upto 64 matrix order.
	 mat_order_out  : out std_logic_vector(5 downto 0); -- can support upto 64 matrix order.
	 
		start_matctrl : out std_logic;
		done_matctrl  : in std_logic ;
		start_top_inv : out std_logic;
		done_top_inv  : in std_logic
		);
end component;

-- matrix controller-- which controls the execution of the instruction fetched by mast_controller.
		
component mat_ctrl_v1 is
port (
			start     : in std_logic; 								-- handshake signals
			done      : out std_logic;
			clk       : in std_logic;					  
			rst       : in std_logic;
		
	-- control signals from master controller.	
			mode      : in std_logic_vector(2 downto 0);
			op_1      : in std_logic_vector(3 downto 0);
			op_2      : in std_logic_vector(3 downto 0);
			op_r      : in std_logic_vector(3 downto 0);
		spec_command  : in std_logic_vector(2 downto 0);	-- certain modes has more options, and used to set special mast_ctrl functions.
		mat_order_in  : in std_logic_vector(5 downto 0);    -- to set the max value of registers that decide the order of the matrix.
	  dynamic_scale_in: in std_logic_vector(5 downto 0);
	  
-- controls singals to mpma	
	m_muli_sel_reg    : out std_logic;                            -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  : out std_logic;     						  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  : out std_logic_vector(1 downto 0);		  -- mux at the odd stage1 adder input2.
	m_data_out_sel    : out std_logic_vector(1 downto 0);         -- mux at the output stage.                      
	s1_sub_e          : out std_logic;							  -- for add/ subtract operation.
    s1_acc_enable     : out std_logic;							  -- enable the accumulators at stage 1.
	s2_acc_enable     : out std_logic;							  -- enable the stage 2 accumulators
	flush             : out std_logic;                            -- to flush out the accumulators
	enc_dynamic_scale : out std_logic_vector(1 downto 0);         -- for dynamic scaling at the output. generated by master controller.

-- used for loading data in	
	i_data_vld        : in std_logic;
    data_out_vld      : out std_logic;
	
-- control signals to address decoder.	
	ram_sel_out       : out std_logic_vector(3 downto 0);
    write_en          : out std_logic;
	row_cnt_out       : out  std_logic_vector(5 downto 0);
    row_set_out       : out  std_logic_vector(3 downto 0);
	mat_index_out     : out  std_logic_vector(3 downto 0);
	
-- control signals for register array.
     row_i    		  : out  std_logic_vector(5 downto 0);		-- used to write to register array.
	 reg_rwn          : out  std_logic; 					    -- to read or write to register array.
   reg_row_set        : out  std_logic_vector(3 downto 0);       -- should be connected row_offset.	
   data_in_sel        : out std_logic_vector(1 downto 0);
   div_row_mode       : out std_logic_vector(1 downto 0);
   div_address        : out std_logic_vector(7 downto 0)
   );
end component;
		
		



-- address decoder. generates the address for the RAM. based on control signals from the mat control.
component address_decoder_v1 is 
port(
		address   : out std_logic_vector(13 downto 0);
		row_cnt   : in  std_logic_vector(5 downto 0);
		row_set   : in  std_logic_vector(3 downto 0);
	    mat_index : in  std_logic_vector(3 downto 0);
	    mat_order : in std_logic_vector(5 downto 0);
	    ram_sel_in: in std_logic_vector(3 downto 0);
	    to_ram_sel: out std_logic_vector(3 downto 0)	   
	);
end component;



-- signals to map mast_controller_inst1
signal 	mode              : std_logic_vector(2 downto 0);
signal 	op_1              : std_logic_vector(3 downto 0);
signal 	op_2              : std_logic_vector(3 downto 0);
signal 	op_r              : std_logic_vector(3 downto 0);
signal spec_command       : std_logic_vector(2 downto 0);
signal mat_order_out      : std_logic_vector(5 downto 0);
signal start_matctrl      : std_logic;
signal done_matctrl       : std_logic;
signal mast_start_top_inv : std_logic;
signal mast_done_top_inv  : std_logic;
signal dynamic_scale_mast : std_logic_vector(5 downto 0);

-- signals to map the mat controller.

signal m_muli_sel_reg_mat    :  std_logic;                      
signal m_s1_adder_seli1_mat  :  std_logic;     					
signal m_s1_adder_seli2_mat  :  std_logic_vector(1 downto 0);	
signal m_data_out_sel_mat    :  std_logic_vector(1 downto 0);   
                     
signal s1_sub_e_mat          :  std_logic;						
signal s1_acc_enable_mat     :  std_logic;						
signal s2_acc_enable_mat     :  std_logic;						
signal flush_mat             :  std_logic;                      
signal dynamic_scale_mat     :  std_logic_vector(1 downto 0);   

signal ram_sel_out_mat       :  std_logic_vector(3 downto 0);
signal write_en_mat          :  std_logic;
signal data_out_vld          :  std_logic;
signal row_cnt_out           :  std_logic_vector(5 downto 0);
signal row_set_out           :  std_logic_vector(3 downto 0);
signal mat_index_out         :  std_logic_vector(3 downto 0);
signal data_in_sel           :  std_logic_vector(1 downto 0);
signal div_row_mode          :  std_logic_vector(1 downto 0);
signal div_address           :  std_logic_vector(7 downto 0);

-- to address decoder.
signal address_ad         : std_logic_vector(13 downto 0);
signal ram_sel_ad         : std_logic_vector(3 downto 0);

-- 
signal     row_i_con      : std_logic_vector(5 downto 0);		-- used to write to register array.
signal	 reg_rwn_con      : std_logic; 					    -- to read or write to register array.
signal   reg_row_set_con  : std_logic_vector(3 downto 0);      -- should be connected row_offset.	

begin

-- wiring outputs from master controller to outputs of controller_top
o_data_vld         <= data_out_vld;
start_top_inv      <= mast_start_top_inv;
mast_done_top_inv  <= done_top_inv;



-- wiring outputs from mat controller to outputs of controller top
m_muli_sel_reg    <= m_muli_sel_reg_mat;   
m_s1_adder_seli1  <= m_s1_adder_seli1_mat; 
m_s1_adder_seli2  <= m_s1_adder_seli2_mat; 
m_data_out_sel    <= m_data_out_sel_mat;                                            
s1_sub_e          <= s1_sub_e_mat;         
s1_acc_enable     <= s1_acc_enable_mat;    
s2_acc_enable     <= s2_acc_enable_mat;    
flush             <= flush_mat;            
dynamic_scale     <= dynamic_scale_mat;    
ram_wen           <= not(write_en_mat);          -- RAM WEN is active low.
row_i    	      <= row_i_con;
reg_rwn           <= reg_rwn_con;
reg_row_set       <= reg_row_set_con;
data_in_sel_out   <= data_in_sel;
mat_order_out_c   <= mat_order_out;
div_address_out   <= div_address;
div_row_mode_out  <= div_row_mode;

-- signals to wire the address decoder.
--ram_sel           <= ram_sel_out_mat;  -- should be from address decoder.
address <= address_ad;
ram_sel <= ram_sel_ad;



--wiring master controller block.
mast_controller_inst1: mast_ctrl 
port map 
(
       			start      =>  start,
       			done       =>  done,
       			clk        =>  clk, 
       			rst        =>  rst,
       	--	data_out_vld   => data_out_vld,
       	
       			mode       => mode,
       			op_1       => op_1,
       			op_2       => op_2,
       			op_r       => op_r,
       		spec_command   => spec_command,
       	    dynamic_scale  => dynamic_scale_mast,
       data_to_instruction => i_instruction,
       instruction_vld     => i_instruction_vld,
       operation_mode      => ctrl_operation_mode,
	   
       mat_order_in        => mat_order,
       mat_order_out       => mat_order_out,
       	 
       		start_matctrl  => start_matctrl,
       		done_matctrl   => done_matctrl,
       		start_top_inv  => mast_start_top_inv,
       		done_top_inv   => mast_done_top_inv

);

-- wiring master controller block.
mat_controller_inst1: mat_ctrl_v1 
port map 
(
			start     => start_matctrl,						-- handshake signals
			done      => done_matctrl,
			clk       => clk, 
			rst       => rst, 
		
															-- control signals from master controller.	
			mode      => mode,
			op_1      => op_1,
			op_2      => op_2,
			op_r      => op_r, 
		spec_command  => spec_command,       				-- certain modes has more options, and used to set special mast_ctrl functions.
		mat_order_in  => mat_order_out,       				-- to set the max value of registers that decide the order of the matrix.
	 dynamic_scale_in => dynamic_scale_mast,				-- from master controller.
							-- controls singals to mpma	
	m_muli_sel_reg    =>m_muli_sel_reg_mat,                   -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  =>m_s1_adder_seli1_mat,            	  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  =>m_s1_adder_seli2_mat,            	  -- mux at the odd stage1 adder input2.
	m_data_out_sel    =>m_data_out_sel_mat,                   -- mux at the output stage.
                                                   
	s1_sub_e          =>s1_sub_e_mat,                    	  -- for add/ subtract operation.
    s1_acc_enable     =>s1_acc_enable_mat,               	  -- enable the accumulators at stage 1.
	s2_acc_enable     =>s2_acc_enable_mat,               	  -- enable the stage 2 accumulators
	flush             =>flush_mat,                            -- to flush out the accumulators
	enc_dynamic_scale =>dynamic_scale_mat,                    -- for dynamic scaling at the output. encoded to smaller bit length.

							-- used for loading data in	
	       i_data_vld => i_data_vld, 
         data_out_vld =>data_out_vld,
	
							-- control signals to address decoder.	
		ram_sel_out   => ram_sel_out_mat,
		write_en      => write_en_mat,     
		row_cnt_out   => row_cnt_out,  
		row_set_out   => row_set_out,  
		mat_index_out => mat_index_out,  
		                     -- control the register array.
		  row_i    	  => row_i_con,			 
		 reg_rwn      => reg_rwn_con,				 
		reg_row_set   => reg_row_set_con,
       data_in_sel    => data_in_sel,
        div_row_mode  => div_row_mode, 
	    div_address   => div_address  
);

ad_inst: address_decoder_v1 
port map
(
		address    => address_ad,   -- to output of top_controller.
		row_cnt    => row_cnt_out,  -- from mat controller. 
		row_set    => row_set_out,  -- from mat controller.
	    mat_index  => mat_index_out, -- from mat controller.
	    mat_order  => mat_order_out,   -- from master controller.
	    ram_sel_in => ram_sel_out_mat, -- from mat controller.
	    to_ram_sel => ram_sel_ad    -- to ramsel of controller.
);





end beh;