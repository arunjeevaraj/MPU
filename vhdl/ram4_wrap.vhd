-- to be used with the asic flow.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ram4_wrap is 
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
end entity;



architecture beh of ram4_wrap is 

COMPONENT ram_wrapper IS
 PORT (
    addr     : in  unsigned(6 downto 0);
    data_out : out std_logic_vector(31 downto 0);
    data_in  : in  std_logic_vector(31 downto 0);
    CK       : in  std_logic;
    CS       : in  std_logic;
    WEB      : in  std_logic;
    OE       : in  std_logic
    );
END COMPONENT;

signal in_data_in1,in_data_in2,
	   in_data_in3,in_data_in4 : std_logic_vector(31 downto 0);
signal address_uns 			   : unsigned(6 downto 0); 
signal data_in 				   : std_logic_vector(31 downto 0);
signal web 				       : std_logic;






begin

address_uns <= unsigned(address(6 downto 0));
web <= write_en;


in_data_in1 <= data_in1;
in_data_in2 <= data_in2;
in_data_in3 <= data_in3;
in_data_in4 <= data_in4;


ram1: ram_wrapper port map( addr     => unsigned(address_uns(6 downto 0)),
                            data_out =>  data_out1,
                            data_in  =>  in_data_in1, 
                            CK       =>  clk,
							CS       =>  ram_sel(0),
							WEB      =>  web,
							OE       => '1'	);

ram2: ram_wrapper port map( addr     =>  unsigned(address_uns(6 downto 0)),
                            data_out =>  data_out2,
                            data_in  =>  in_data_in2, 
                            CK       =>  clk,
							CS       =>  ram_sel(1),
							WEB      =>  web,
							OE       => '1'	);
							
ram3: ram_wrapper port map( addr     =>  unsigned(address_uns(6 downto 0)),
                            data_out =>  data_out3,
                            data_in  =>  in_data_in3, 
                            CK       =>  clk,
							CS       =>  ram_sel(2),
							WEB      =>  web,
							OE       => '1'	);
							
ram4: ram_wrapper port map( addr     =>  unsigned(address_uns(6 downto 0)),
                            data_out =>  data_out4,
                            data_in  =>  in_data_in4, 
                            CK       =>  clk,
							CS       =>  ram_sel(3),
							WEB      =>  web,
							OE       => '1'	);							


end beh;