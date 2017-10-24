

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity top_design is
port ( --I/O buses
		data_in      : in  std_logic_vector(31 downto 0);
       i_data_vld    : in  std_logic;
	   data_out      : out std_logic_vector(31 downto 0);
	   o_data_vld    : out std_logic;
	   start         : in  std_logic;
	   done          : out std_logic;
	   -- operation mode.
	   mat_order     : in  std_logic_vector(5 downto 0);
	   operation_mode: in  std_logic_vector(1 downto 0);
	i_instruction_vld: in  std_logic;
	   -- global clk and reset.
	   clk           : in  std_logic;
	   rst           : in  std_logic
	 );
end entity;


architecture beh of top_design is

--- controller.

component controller_top is
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
	 mat_order_out_c  : out std_logic_vector(5 downto 0);
	 
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
	 data_in_sel_out  : out std_logic_vector(1 downto 0);  -- used for mux at the input side of ram4 wrap.
	 div_row_mode_out : out std_logic_vector(1 downto 0);
	 div_address_out  : out std_logic_vector(7 downto 0)

	);
end component;

---- MPMA

component mpma is 
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
end component;

---- DIVIDER
component top_inverse is
    port(      clk : in std_logic;
	          rst  : in std_logic;
	   I_data_vld  : in std_logic;
		 mat_order : in std_logic_vector(5 downto 0);
		 data_in   : in std_logic_vector(31 downto 0);
		 addr_inp  : in unsigned (7 downto 0);
		 done      : out std_logic;
		 row_mode  : in std_logic_vector(1 downto 0);
         inp_out1  : out std_logic_vector ( 31 downto 0);
		 inp_out2  : out std_logic_vector ( 31 downto 0);
         inp_out3  : out std_logic_vector ( 31 downto 0);
         inp_out4  : out std_logic_vector ( 31 downto 0)
          
);
end component;
		 


----- RAM

component ram4_wrap is 
port (data_in1  : in std_logic_vector(31 downto 0);
	  data_in2  : in std_logic_vector(31 downto 0);
	  data_in3  : in std_logic_vector(31 downto 0);
	  data_in4  : in std_logic_vector(31 downto 0);
	  clk	    : in std_logic;
	  write_en  : in std_logic;
	  ram_sel   : in std_logic_vector(3 downto 0);
      address   : in std_logic_vector(12 downto 0);
      data_out1 : out std_logic_vector(31 downto 0);
	  data_out2 : out std_logic_vector(31 downto 0);
	  data_out3 : out std_logic_vector(31 downto 0);
	  data_out4 : out std_logic_vector(31 downto 0)
	);
end component;


----- Register cache.
component reg_array is
port (
		-- data bus into register array.
		reg_in_1 : in  std_logic_vector(31 downto 0);
		-- data bus out of register array.
		reg_out_1: out std_logic_vector(31 downto 0);
		reg_out_2: out std_logic_vector(31 downto 0);
		reg_out_3: out std_logic_vector(31 downto 0);
		reg_out_4: out std_logic_vector(31 downto 0);
		-- from master controller. control signals.
		row_i    : in  std_logic_vector(5 downto 0);		-- used to write to register array.
	    reg_rwn  : in std_logic; 									-- to read or write to register array.
   reg_row_set   : in std_logic_vector(3 downto 0);                 -- should be connected row_offset.
		-- global clk and reset.
		clk      : in  std_logic;
		rst      : in std_logic
     );
end component;

-- controller signal map
signal done_con      :  std_logic;
signal o_data_vld_con:  std_logic;
signal address_con   : std_logic_vector(13 downto 0);
signal ram_sel_con   : std_logic_vector(3 downto 0);
signal ram_wen_con   : std_logic;

signal         row_i_con    :  std_logic_vector(5 downto 0);	
signal        reg_rwn_con   :  std_logic; 						
signal    reg_row_set_con   :  std_logic_vector(3 downto 0);    
signal    mat_order_out_c   :  std_logic_vector(5 downto 0);
signal    div_row_mode_out  :  std_logic_vector(1 downto 0);
signal    div_address_out   :  std_logic_vector(7 downto 0); 




--signal to  data path contro
signal m_muli_sel_reg_con    : std_logic;                      
signal m_s1_adder_seli1_con  : std_logic;     					
signal m_s1_adder_seli2_con  : std_logic_vector(1 downto 0);	
signal m_data_out_sel_con    : std_logic_vector(1 downto 0);   

signal s1_sub_e_con          : std_logic;						
signal s1_acc_enable_con     : std_logic;
signal s2_acc_enable_con     : std_logic;
signal flush_con             : std_logic;                      
signal dynamic_scale_con     : std_logic_vector(1 downto 0);   
signal start_top_inv_con     : std_logic;
signal data_in_sel_out_con   : std_logic_vector(1 downto 0);
--- from divider

signal done_top_inv_con : std_logic;


-- from RAM



signal data_out1_ram : std_logic_vector(31 downto 0);
signal data_out2_ram : std_logic_vector(31 downto 0);
signal data_out3_ram : std_logic_vector(31 downto 0);
signal data_out4_ram : std_logic_vector(31 downto 0);


signal to_ram_data_in1 : std_logic_vector(31 downto 0);
signal to_ram_data_in2 : std_logic_vector(31 downto 0);
signal to_ram_data_in3 : std_logic_vector(31 downto 0);
signal to_ram_data_in4 : std_logic_vector(31 downto 0);

signal reg_array_data_in : std_logic_vector(31 downto 0);

-- signal from register array

signal reg_out_1_con : std_logic_vector(31 downto 0);
signal reg_out_2_con : std_logic_vector(31 downto 0);
signal reg_out_3_con : std_logic_vector(31 downto 0);
signal reg_out_4_con : std_logic_vector(31 downto 0);

-- signal from divider


signal       inp_out1 : std_logic_vector ( 31 downto 0);
signal 		 inp_out2 : std_logic_vector ( 31 downto 0);
signal 		 inp_out3 : std_logic_vector ( 31 downto 0);
signal 		 inp_out4 : std_logic_vector ( 31 downto 0);

-- signal from pmpa
signal ram_data_out_1_p  : std_logic_vector(31 downto 0);
signal ram_data_out_2_p  : std_logic_vector(31 downto 0);
signal ram_data_out_3_p  : std_logic_vector(31 downto 0);
signal ram_data_out_4_p  : std_logic_vector(31 downto 0);




begin


-- controller to top design
done           <= done_con;
o_data_vld     <= o_data_vld_con;

controller_inst: controller_top 
port map(  
       clk            => clk,
	   rst            => rst,
	  start           => start,
	  done            => done_con,
	i_data_vld        =>i_data_vld,  -- used for loading in matrix.
	o_data_vld        => o_data_vld_con,
	
   -- incoming instruction
	 i_instruction    => data_in,
	 i_instruction_vld=> i_instruction_vld,
	 
   -- matrix size and operation mode control.
 ctrl_operation_mode  => operation_mode,
	 mat_order        => mat_order,
	 mat_order_out_c  => mat_order_out_c,
	 
	-- control signals to RAM.  
	  address         => address_con,
	  ram_sel         => ram_sel_con,
	  ram_wen         => ram_wen_con,
	  
	  
	-- register array control 
	        row_i    => row_i_con,		              -- used to write to register array.
	        reg_rwn  => reg_rwn_con, 				  -- to read or write to register array.
       reg_row_set   => reg_row_set_con,              -- should be connected row_offset.
	 
	-- data path control.
    m_muli_sel_reg    => m_muli_sel_reg_con,          -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  => m_s1_adder_seli1_con,  	  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  => m_s1_adder_seli2_con,  	  -- mux at the odd stage1 adder input2.
	m_data_out_sel    => m_data_out_sel_con,          -- mux at the output stage.
                     
	s1_sub_e          => s1_sub_e_con,          	  -- for add/ subtract operation.
    s1_acc_enable     => s1_acc_enable_con,     
	s2_acc_enable     => s2_acc_enable_con,     
	flush             => flush_con,                   -- to flush out the accumulators
	dynamic_scale     => dynamic_scale_con,           -- for dynamic scaling at the output.
	                    
	-- divider handshake-- divider handsha
	    start_top_inv => start_top_inv_con, 
	    done_top_inv  => done_top_inv_con,
	  data_in_sel_out => data_in_sel_out_con,
	  div_row_mode_out=> div_row_mode_out,
	  div_address_out => div_address_out 
);



ram_inst: ram4_wrap  
port map (
	  data_in1  =>to_ram_data_in1,
	  data_in2  =>to_ram_data_in2,
	  data_in3  =>to_ram_data_in3,
	  data_in4  =>to_ram_data_in4,
	  clk	    => clk,
	  write_en  => ram_wen_con,
	  ram_sel   => ram_sel_con,
	  address   => address_con(12 downto 0),
	  data_out1 =>data_out1_ram, 
	  data_out2 =>data_out2_ram, 
	  data_out3 =>data_out3_ram, 
	  data_out4 =>data_out4_ram 
);

reg_arr_inst: reg_array 
port map (
		-- data bus into register array.
		reg_in_1 => reg_array_data_in,
		-- data bus out of register array.
		reg_out_1=> reg_out_1_con,
		reg_out_2=> reg_out_2_con,
		reg_out_3=> reg_out_3_con,
		reg_out_4=> reg_out_4_con,
		-- from master controller. control signals.
		row_i    => row_i_con,		-- used to write to register array.
	    reg_rwn  => reg_rwn_con, 									-- to read or write to register array.
   reg_row_set   => reg_row_set_con,                 -- should be connected row_offset.
		-- global clk and reset.
		clk      => clk,
		rst      => rst
     );


mpma_inst: mpma 
port map(  												              -- data from RAM.
		ram_data_in_1 => data_out1_ram,
        ram_data_in_2 => data_out2_ram,
		ram_data_in_3 => data_out3_ram,
		ram_data_in_4 => data_out4_ram,
																  --data from register array.
	reg_array_data_1  => reg_out_1_con,		
	reg_array_data_2  => reg_out_2_con,
	reg_array_data_3  => reg_out_3_con,
	reg_array_data_4  => reg_out_4_con,
																  -- data from the div register array.
	div_array_data_1  => inp_out1,
	div_array_data_2  => inp_out2,
	div_array_data_3  => inp_out3,
	div_array_data_4  => inp_out4,
									                              -- control signals used.
	m_muli_sel_reg    => m_muli_sel_reg_con,            -- mux at multiply inputs , active to select the register array.
    m_s1_adder_seli1  => m_s1_adder_seli1_con,		  -- mux at the odd stage1 adder input1, 1 chooses the ram_data_in_1.
	m_s1_adder_seli2  => m_s1_adder_seli2_con,		  -- mux at the odd stage1 adder input2.
	m_data_out_sel    => m_data_out_sel_con,            -- mux at the output stage.

	s1_sub_e          => s1_sub_e_con,     		  -- for add/ subtract operation.
    s1_acc_enable     => s1_acc_enable_con,
	s2_acc_enable     => s2_acc_enable_con,
	flush             => flush_con,                  -- to flush out the accumulators
	dynamic_scale     => dynamic_scale_con,          -- for dynamic scaling at the output.
	
	clk               => clk,
	rst               => rst,
	
																   --output data to the RAM.
	ram_data_out_1    => ram_data_out_1_p,
	ram_data_out_2    => ram_data_out_2_p,
	ram_data_out_3    => ram_data_out_3_p,
	ram_data_out_4    => ram_data_out_4_p	
	);

div_inst:  top_inverse 
    port map(      clk => clk,
				   rst => rst,
		   I_data_vld  => i_data_vld,
			 mat_order => mat_order_out_c,
			 data_in  => data_in,
			 addr_inp => unsigned(div_address_out),
			 done     => done_top_inv_con,
			 row_mode => div_row_mode_out,
			 inp_out1 => inp_out1,
			 inp_out2 => inp_out2,
			 inp_out3 => inp_out3,
			 inp_out4 => inp_out4      
);


	
	
	
	
-- will have to move this to ram wrap.

process(data_in,data_in_sel_out_con,ram_data_out_1_p,
		ram_data_out_2_p,ram_data_out_3_p,ram_data_out_4_p,
		data_out1_ram,data_out2_ram,data_out3_ram,data_out4_ram
		) 
begin
	if(data_in_sel_out_con="00") then -- load mat.
		to_ram_data_in1  <= data_in;
		to_ram_data_in2  <= data_in;
		to_ram_data_in3  <= data_in;
		to_ram_data_in4  <= data_in;
	elsif(data_in_sel_out_con="01") then -- mat copy.
		to_ram_data_in1	  <= data_out1_ram;
		to_ram_data_in2	  <= data_out2_ram;
		to_ram_data_in3	  <= data_out3_ram;
		to_ram_data_in4	  <= data_out4_ram;

	else-- when pmpa is driving the ram data in .
	   to_ram_data_in1  <= ram_data_out_1_p; -- put the signal data out from pmpa here.
	   to_ram_data_in2  <= ram_data_out_2_p;
	   to_ram_data_in3  <= ram_data_out_3_p;
	   to_ram_data_in4  <= ram_data_out_4_p;
	end if;




end process;

-- will have to move this to register array.

process(ram_sel_con,data_out1_ram,data_out2_ram,data_out3_ram,data_out4_ram)
begin
case ram_sel_con is
	when "0001"=>
	reg_array_data_in <= data_out1_ram;
	data_out          <= data_out1_ram;
	when "0010"=>
	reg_array_data_in <= data_out2_ram;
	data_out          <= data_out2_ram;
	when "0100"=>
	reg_array_data_in <= data_out3_ram;
	data_out          <= data_out3_ram;
	when "1000"=>
	reg_array_data_in <= data_out4_ram;
	data_out          <= data_out4_ram;
	when others=>
	reg_array_data_in <=(others=>'0');
	data_out          <=(others=>'0');
end case;

end process;








end beh;