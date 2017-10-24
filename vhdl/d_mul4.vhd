library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;



entity d_mul4 is
port(data_in1  : in std_logic_vector (31 downto 0);
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
end entity;

architecture beh of d_mul4 is 

signal i_diag_in_1,
       i_diag_in_2,
       i_diag_in_3,
       i_diag_in_4: unsigned(31 downto 0);


signal i_data_in1,
       i_data_in2,
       i_data_in3,
       i_data_in4,
	   i_diag_in   : unsigned (31 downto 0);
	   
signal mul_data_out1,
       mul_data_out2,
	   mul_data_out3,
	   mul_data_out4 : unsigned(63 downto 0);

begin
		
		i_data_in1 <=   unsigned(data_in1);
		i_data_in2 <=   unsigned(data_in2);
        i_data_in3 <=   unsigned(data_in3);
        i_data_in4 <=   unsigned(data_in4);
		
        i_diag_in_1  <=   unsigned(diag_in_1 );
		i_diag_in_2  <=   unsigned(diag_in_2 );
		i_diag_in_3  <=   unsigned(diag_in_3 );
		i_diag_in_4  <=   unsigned(diag_in_4 );

      process(i_data_in1,i_data_in2,i_data_in3,i_data_in4, i_diag_in_1,i_diag_in_2,i_diag_in_3,i_diag_in_4)
	  begin
		  mul_data_out1 <= i_data_in1 * i_diag_in_1;
		  mul_data_out2 <= i_data_in2 * i_diag_in_2;
		  mul_data_out3 <= i_data_in3 * i_diag_in_3;
		  mul_data_out4 <= i_data_in4 * i_diag_in_4;
	  end process;

      data_out1   <= std_logic_vector(mul_data_out1(31 downto 0));
	  data_out2   <= std_logic_vector(mul_data_out2(31 downto 0));
	  data_out3   <= std_logic_vector(mul_data_out3(31 downto 0));
	  data_out4   <= std_logic_vector(mul_data_out4(31 downto 0));

end beh;