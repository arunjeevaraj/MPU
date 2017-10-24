--Top entity of divider 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top_inverse is
    port(clk: in std_logic;
	     rst : in std_logic;
		 I_data_vld : in std_logic;
		 mat_order : in std_logic_vector(5 downto 0);
		 data_in : in std_logic_vector(31 downto 0);
		 addr_inp : in unsigned (7 downto 0);
		 done : out std_logic;
		 row_mode  : in std_logic_vector(1 downto 0);
         inp_out1 : out std_logic_vector ( 31 downto 0);
		 inp_out2 : out std_logic_vector ( 31 downto 0);
         inp_out3 : out std_logic_vector ( 31 downto 0);
         inp_out4 : out std_logic_vector ( 31 downto 0)
          
		 );
		 

end top_inverse;

architecture behav of top_inverse is

component diag_write is
port ( clk : in std_logic;
       rst : in std_logic;
	   mat_order : in std_logic_vector(5 downto 0);
       data_in_d : in std_logic_vector(31 downto 0);
	   I_data_vld : in std_logic;
	   finish_diag : out std_logic;
       data_diag : out std_logic_vector(31 downto 0)
	   );
end component;
component normal is
    port( clk : in std_logic;
	      rst : in std_logic;
	      data_diag : in std_logic_vector(31 downto 0);
		  
		  o_norm : out std_logic_vector(10 downto 0);
		  norm_sig : out std_logic_vector(1 downto 0);  --norm_sig is to determine how many bits required in de-normalization
	      o_xi : out std_logic_vector(15 downto 0)
		  );
end component;


component nr_div is 
port (clk : in std_logic;
      rst : in std_logic;
      
	  o_xi : in std_logic_vector(15 downto 0);
	  o_norm : in std_logic_vector(10 downto 0);
	  o_r  : out unsigned(30 downto 0)
	  );
end component;
component denorm is 
port (clk : in std_logic;
      rst : in std_logic;
      norm_sig : in std_logic_vector(1 downto 0);
	  o_r  : in unsigned(30 downto 0);
	  o_reci : out unsigned(31 downto 0)
	  );
end component;
component div_array is
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
end component;

signal finish_diag : std_logic := '0';
signal norm_sig : std_logic_vector(1 downto 0);
signal data_in_d,data_diag : std_logic_vector(31 downto 0);
signal o_norm : std_logic_vector(10 downto 0);
signal o_xi : std_logic_vector(15 downto 0);
signal o_r :  unsigned(30 downto 0);
signal o_reci :  unsigned(31 downto 0);
begin

inst_diag_write : diag_write 
port map ( clk => clk,
       rst  => rst,
	   mat_order => mat_order,
	   I_data_vld => I_data_vld,
       data_in_d  => data_in,
	   finish_diag => finish_diag,
       data_diag  => data_diag
	   );
inst_norm : normal
    port map ( clk => clk,
	       rst => rst,
	       o_norm => o_norm,
	      data_diag => data_diag,
		 
		  norm_sig => norm_sig,
	      o_xi => o_xi
		  );
inst_nr_div : nr_div 
    port map (clk => clk,
	  rst => rst,
      
	  o_xi => o_xi,
	  o_norm => o_norm,
	  o_r  => o_r
	  );

inst_denorm : denorm 
port map (clk => clk,
      rst => rst,
      norm_sig => norm_sig,
	  o_r  => o_r,
	  o_reci => o_reci
	  );
inst_d_array: div_array 
  port map ( clk => clk,
         rst => rst,
         I_data_vld => I_data_vld,
		 mat_order => mat_order,
		 done => done,
		 row_mode => row_mode,
         o_reci => o_reci,
         addr_inp => unsigned(addr_inp),
         inp_out1 => inp_out1,
		 inp_out2 => inp_out2,
		 inp_out3 => inp_out3,
		 inp_out4 => inp_out4
       );
		  
end behav;
