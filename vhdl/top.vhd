library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- memory top test...
entity top is 
port (
	  clk       : in std_logic;
	  rst		: in std_logic;
	  data_in   : in std_logic_vector(31 downto 0);
	  data_out  : out std_logic_vector(31 downto 0);
	  start     : in std_logic;
	  done      : out std_logic
);

end entity;


architecture beh of top is 
-- used by address deco and register array.
constant MATRIX_CNT    : integer := 3;
constant ADDRESS_WIDTH : integer :=12;
constant RAM_NUM       : integer :=4 ;
--used for register array.
constant DATA_O_WIDTH  : integer :=32;
constant DATA_I_WIDTH  : integer :=32;
constant ROW_CNT       : integer :=3;




component mast_ctrl is 
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
end component;


component d_mul4 is
port(
      data_in1  : in std_logic_vector (31 downto 0);
      data_in2  : in std_logic_vector (31 downto 0);
      data_in3  : in std_logic_vector (31 downto 0);
      data_in4  : in std_logic_vector (31 downto 0);
      diag_in_1   : in std_logic_vector (31 downto 0);
	  diag_in_2   : in std_logic_vector (31 downto 0);
	  diag_in_3   : in std_logic_vector (31 downto 0);
	  diag_in_4   : in std_logic_vector (31 downto 0);
      data_out1 : out std_logic_vector (31 downto 0);
      data_out2 : out std_logic_vector (31 downto 0);
      data_out3 : out std_logic_vector (31 downto 0);
      data_out4 : out std_logic_vector (31 downto 0)
	 );
end component;


component mac4 is 
port(  
  data_a_1 : in std_logic_vector(31 downto 0);
  data_a_2 : in std_logic_vector(31 downto 0);
  data_a_3 : in std_logic_vector(31 downto 0);
  data_a_4 : in std_logic_vector(31 downto 0);
  data_b_1 : in std_logic_vector(31 downto 0);
  data_b_2 : in std_logic_vector(31 downto 0);
  data_b_3 : in std_logic_vector(31 downto 0);
  data_b_4 : in std_logic_vector(31 downto 0);
  clk      : in std_logic ;
  rst      : in std_logic;
  mac_write_vld : in std_logic;
  mac_vld  : in std_logic;
  write_en : in std_logic;
  data_out : out std_logic_vector(31 downto 0)
 );
end component;



component top_inverse is
    port(clk: in std_logic;
	     rst : in std_logic;
		 read_diag : in std_logic;
		 data_in : in std_logic_vector(31 downto 0);
		 addr_inp : in unsigned (7 downto 0);
		 done : out std_logic;
		 row_mode  : in std_logic_vector(1 downto 0);
         inp_out1 : out unsigned ( 31 downto 0);
		 inp_out2 : out unsigned ( 31 downto 0);
         inp_out3 : out unsigned ( 31 downto 0);
         inp_out4 : out unsigned ( 31 downto 0)
		 );
end component;



component reg_array is

generic  (
		  MATRIX_CNT      : integer :=3;
		  DATA_O_WIDTH    : integer :=32;
		  DATA_I_WIDTH    : integer :=32;
		  ROW_CNT         : integer :=3;
		  RAM_NUM         : integer :=4
		  );
port (
		reg_in_1 : in  std_logic_vector(DATA_I_WIDTH-1 downto 0);
		reg_in_2 : in  std_logic_vector(DATA_I_WIDTH-1 downto 0);
		reg_in_3 : in  std_logic_vector(DATA_I_WIDTH-1 downto 0);
		reg_in_4 : in  std_logic_vector(DATA_I_WIDTH-1 downto 0);
		reg_out_1: out std_logic_vector(DATA_O_WIDTH-1 downto 0);
		reg_out_2: out std_logic_vector(DATA_O_WIDTH-1 downto 0);
		reg_out_3: out std_logic_vector(DATA_O_WIDTH-1 downto 0);
		reg_out_4: out std_logic_vector(DATA_O_WIDTH-1 downto 0);
		row_i    : in  std_logic_vector(ROW_CNT-1 downto 0);		
		clk      : in  std_logic;
		reg_rwn  : in std_logic; 
		reg_mre  : in std_logic_vector(0 downto 0);
   reg_ar_row    : in std_logic_vector(1 downto 0);
		rst      : in std_logic	
     );

end component;


component mat_ctrl is
port (  start     : in std_logic;
		done      : out std_logic;
		write_en  : out std_logic;
		mode      : in std_logic_vector(2 downto 0);
		op_1      : in std_logic_vector(3 downto 0);
		op_2      : in std_logic_vector(3 downto 0);
		op_r      : in std_logic_vector(3 downto 0);
		mat_index :out std_logic_vector(3 downto 0);
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
end component;

component address_deco is
generic  (MATRIX_CNT    : integer :=3;
		  ADDRESS_WIDTH : integer :=12;
		  RAM_NUM       : integer :=4
		 );

port(	mat_index : in  std_logic_vector(MATRIX_CNT downto 0);
		rnw		  : in  std_logic;
		ram_sel	  : out std_logic_vector(RAM_NUM-1 downto 0);
		start 	  : in  std_logic;
		done 	  : out std_logic;
		address   : out std_logic_vector(ADDRESS_WIDTH downto 0);
		clk		  : in  std_logic;
		diag_wm   : in  std_logic_vector(1 downto 0);
	diag_wm_tog   : out std_logic;
		reg_wen   : out std_logic;
		reg_mre   : out std_logic_vector(0 downto 0);
		mac_vld   : out std_logic;
		mm_switch : out std_logic;
	mac_write_vld : out std_logic;
	reg_ar_row    : out std_logic_vector(1 downto 0);
	top_inv_addr_inp  : out std_logic_vector(2 downto 0);
		rst		  : in  std_logic;
	row_mode      : in std_logic_vector(1 downto 0)
	);
end component;	

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

signal ram_sel : std_logic_vector(3 downto 0);
signal address : std_logic_vector(12 downto 0);
signal rnw : std_logic;

signal i_data_out1 : std_logic_vector(31 downto 0);
signal i_data_out2 : std_logic_vector(31 downto 0);
signal i_data_out3 : std_logic_vector(31 downto 0);
signal i_data_out4 : std_logic_vector(31 downto 0);

signal data_out1 : std_logic_vector(31 downto 0);
signal data_out2 : std_logic_vector(31 downto 0);
signal data_out3 : std_logic_vector(31 downto 0);
signal data_out4 : std_logic_vector(31 downto 0);
signal mm_switch : std_logic;
signal mac_vld   : std_logic;
----- signal for mat_ctrl.

signal reg_ar_row:  std_logic_vector(1 downto 0);
signal write_en  :  std_logic;
signal mat_index :  std_logic_vector(3 downto 0); 
signal start_o   :  std_logic;
signal done_o    :  std_logic;
signal mac_write_vld: std_logic;


---- signal for reg_Array
signal reg_in :  std_logic_vector(DATA_I_WIDTH-1 downto 0);
signal reg_out:  std_logic_vector(DATA_O_WIDTH-1 downto 0);
signal row_i  :  std_logic_vector(2 downto 0); 
signal reg_mre:  std_logic_vector(0 downto 0);
 
-- signal for mat_mac

constant W : natural := 12;
constant O : natural := 24;

signal  i_m1   : std_logic_vector (W-1 downto 0);
signal  i_m2   : std_logic_vector (W-1 downto 0);
signal  i_zero : std_logic;
signal  o_mout1 : std_logic_vector ( O-1 downto 0);
signal  o_mout2 : std_logic_vector ( O-1 downto 0);
signal  o_mout3 : std_logic_vector ( O-1 downto 0);
signal  o_mout4 : std_logic_vector ( O-1 downto 0);

signal reg_out_1 : std_logic_vector(DATA_I_WIDTH-1 downto 0);
signal reg_out_2 : std_logic_vector(DATA_I_WIDTH-1 downto 0);
signal reg_out_3 : std_logic_vector(DATA_I_WIDTH-1 downto 0);
signal reg_out_4 : std_logic_vector(DATA_I_WIDTH-1 downto 0);


signal diag_wm   :  std_logic_vector(1 downto 0);
signal	reg_wen   :  std_logic; 
--signal reg_rwn : std_logic;

-- made when the MAC was introduced.
signal data_in_ram1,
       data_in_ram2,
	   data_in_ram3,
	   data_in_ram4 :  std_logic_vector(DATA_I_WIDTH-1 downto 0);

signal data_out_mac : std_logic_vector(DATA_I_WIDTH-1 downto 0);


--- diag4_mul

signal diag_data_out1 : std_logic_vector (31 downto 0);
signal diag_data_out2 : std_logic_vector (31 downto 0);
signal diag_data_out3 : std_logic_vector (31 downto 0);
signal diag_data_out4 : std_logic_vector (31 downto 0);
-- to be used on the master ctrl


signal mode      :  std_logic_vector(2 downto 0);
signal op_1      :  std_logic_vector(3 downto 0);
signal op_2      :  std_logic_vector(3 downto 0);
signal op_r      :  std_logic_vector(3 downto 0);

signal start_matctrl : std_logic;
signal done_matctrl  : std_logic;
signal start_top_inv : std_logic;
signal done_top_inv  : std_logic;
signal diag_wm_tog   : std_logic;

-- signal for top_inv

signal   addr_inp : unsigned (7 downto 0);
signal   addr_inp_slv : std_logic_vector(2 downto 0);
signal   inp_out1 : unsigned (31 downto 0);
signal   inp_out2 : unsigned (31 downto 0);
signal   inp_out3 : unsigned (31 downto 0);
signal   inp_out4 : unsigned (31 downto 0);
signal row_mode  :  std_logic_vector(1 downto 0);
-- signal for addi and subi.
signal eye : std_logic_vector(31 downto 0);

-- signal for 
 signal   i_diag_in_1   :  std_logic_vector (31 downto 0);
 signal	  i_diag_in_2   :  std_logic_vector (31 downto 0);
 signal	  i_diag_in_3   :  std_logic_vector (31 downto 0);
 signal	  i_diag_in_4   :  std_logic_vector (31 downto 0);

begin


process(row_mode,inp_out1,inp_out2,inp_out3,inp_out4)
begin
if(row_mode="10") then
     
	 i_diag_in_1 <= std_logic_vector(inp_out1);
	 i_diag_in_2 <= std_logic_vector(inp_out1);
	 i_diag_in_3 <= std_logic_vector(inp_out1);
	 i_diag_in_4 <= std_logic_vector(inp_out1);
else -- row_mode ="01" for reading the row wise, need all the 4 diag elements.
     i_diag_in_1 <= std_logic_vector(inp_out1);
     i_diag_in_2 <= std_logic_vector(inp_out2);
     i_diag_in_3 <= std_logic_vector(inp_out3);
     i_diag_in_4 <= std_logic_vector(inp_out4);
   
end if;

end process;





addr_inp<="00000"&unsigned(addr_inp_slv);

data_out1 <= i_data_out1;
data_out2 <= i_data_out2;
data_out3 <= i_data_out3;
data_out4 <= i_data_out4;

--reg_wen <= not()

process (mode, data_in, data_out_mac,
		diag_data_out1,diag_data_out2,diag_data_out3,diag_data_out4,
		i_data_out1,i_data_out2,i_data_out3,i_data_out4,
		eye
		)
begin
	if(mode="000") then  -- for loading mat data to Ram from data in.
		data_in_ram1 <= data_in ;
		data_in_ram2 <= data_in ;
		data_in_ram3 <= data_in ;
		data_in_ram4 <= data_in ;
	elsif(mode="010" or mode ="110")	then -- colwise diag operation. and row wise operation
	    data_in_ram1 <= diag_data_out1 ;
		data_in_ram2 <= diag_data_out2 ;
		data_in_ram3 <= diag_data_out3 ;
		data_in_ram4 <= diag_data_out4 ;
		 
	elsif(mode="011" or mode ="101") then -- for addi and subi.
	   data_in_ram1 <=  eye;
	   data_in_ram2 <=  eye;
	   data_in_ram3 <=  eye;
	   data_in_ram4 <=  eye;
	elsif(mode="100") then -- for mat copy.
		data_in_ram1 <= i_data_out1;
		data_in_ram2 <= i_data_out2;
		data_in_ram3 <= i_data_out3;
		data_in_ram4 <= i_data_out4;   
	else-- exception... shouldn't be here..
		data_in_ram1 <= data_out_mac;
		data_in_ram2 <= data_out_mac;
		data_in_ram3 <= data_out_mac;
		data_in_ram4 <= data_out_mac;
		
	end if;
end process;

	  
	  
rnw <= not(write_en);

add_dec1: address_deco 
generic map(MATRIX_CNT    =>MATRIX_CNT ,   
            ADDRESS_WIDTH =>ADDRESS_WIDTH, 
            RAM_NUM       =>RAM_NUM       
			)
port map(   mat_index => mat_index,
            rnw		  => rnw,
            ram_sel	  => ram_sel,
            start 	  => start_o,
			done 	  => done_o,
            address   => address,
            clk		  => clk, 
			diag_wm   => diag_wm,
		  diag_wm_tog => diag_wm_tog,
			reg_wen   => reg_wen,
			reg_mre   => reg_mre,
			mm_switch => mm_switch,
			mac_vld   => mac_vld,
	    mac_write_vld => mac_write_vld,
		   reg_ar_row => reg_ar_row,
	top_inv_addr_inp  => addr_inp_slv,
			rst		  => rst,
			row_mode  => row_mode
		    );  

ram_tot: ram4_wrap
port map (  
            data_in1   => data_in_ram1,
			data_in2   => data_in_ram2,
			data_in3   => data_in_ram3,
			data_in4   => data_in_ram4,
			clk	       => clk,
			write_en   => write_en,
            ram_sel    => ram_sel,
            address    => address,
            data_out1  => i_data_out1,
            data_out2  => i_data_out2,
            data_out3  => i_data_out3,
            data_out4  => i_data_out4			
		);	

reg_row: reg_array 
generic map (
			  MATRIX_CNT      => MATRIX_CNT,
			  DATA_O_WIDTH    => DATA_O_WIDTH,
			  DATA_I_WIDTH    => DATA_I_WIDTH,
			  ROW_CNT         => ROW_CNT,
			  RAM_NUM         => RAM_NUM
		  )
port map (
			reg_in_1  => i_data_out1,
			reg_in_2  => i_data_out2,
			reg_in_3  => i_data_out3,
			reg_in_4  => i_data_out4,
			reg_out_1 => reg_out_1,
			reg_out_2 => reg_out_2,
			reg_out_3 => reg_out_3,
			reg_out_4 => reg_out_4,
			row_i     => address(2 downto 0),
			clk       => clk,
			reg_rwn   => reg_wen,
			reg_mre   => reg_mre,
			reg_ar_row=> reg_ar_row,
			rst       => rst
         );

mat_controller: mat_ctrl 
port map   ( 
			start     => start_matctrl,
			done      => done_matctrl,
			write_en  => write_en,
			mode      => mode,
			op_1      => op_1,
			op_2      => op_2,
			op_r      => op_r,
			mat_index => mat_index,
			mm_switch => mm_switch,
			start_o   => start_o,
			done_o    => done_o,
			clk       => clk,
			rst       => rst,
		 mac_write_vld=>mac_write_vld,
         diag_wm_tog => diag_wm_tog,
		 diag_wm   => diag_wm,
         row_mode   => row_mode 	 
	  	    );	 
			
multAacc:mac4  
port map(  
  data_a_1  => reg_out_1,
  data_a_2  => reg_out_2,
  data_a_3  => reg_out_3,
  data_a_4  => reg_out_4,
  data_b_1  => i_data_out1,
  data_b_2  => i_data_out2,
  data_b_3  => i_data_out3,
  data_b_4  => i_data_out4,
  clk       => clk,
  rst       => rst,
  mac_write_vld => mac_write_vld,
  mac_vld   => mac_vld,
  write_en  => write_en,
  data_out  => data_out_mac
 );

mast_ctrl_inst: mast_ctrl 
port map  ( 
		start     => start,
		done      => done,
		clk       => clk,
		rst       => rst,
		mode      => mode,
		op_1      => op_1,
		op_2      => op_2,
		op_r      => op_r,
	start_matctrl => start_matctrl,
    done_matctrl  => done_matctrl,
	start_top_inv => start_top_inv,
	done_top_inv  => done_top_inv,
	eye           => eye
		);

d_mul4_ints: d_mul4 
port map(
      data_in1  => i_data_out1, 
      data_in2  => i_data_out2,
      data_in3  => i_data_out3, 
      data_in4  => i_data_out4, 
      diag_in_1   => i_diag_in_1,
      diag_in_2   => i_diag_in_2,
      diag_in_3   => i_diag_in_3,
      diag_in_4   => i_diag_in_4,	  
      data_out1 => diag_data_out1,
      data_out2 => diag_data_out2,
      data_out3 => diag_data_out3,
      data_out4 => diag_data_out4
	 );
		
top_inverse_inst: top_inverse 
port map(     clk => clk,
	          rst => start_top_inv,
	    read_diag =>'0',
		  data_in => data_in,
		 addr_inp => addr_inp,
		     done => done_top_inv,
		  row_mode=> row_mode, 
         inp_out1 => inp_out1,
		 inp_out2 => inp_out2,
		 inp_out3 => inp_out3,
		 inp_out4 => inp_out4

		 );
	
				
end beh; 				