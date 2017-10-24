library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity top_tb is
end entity;

architecture beh of top_tb is

 constant PERIOD         : time := 10 ns;
 constant RST_DURATION   : time := 30 ns;

component top is 
port (
	  clk       : in std_logic;
	  rst		: in std_logic;
	  data_in   : in std_logic_vector(31 downto 0);
	  data_out  : out std_logic_vector(31 downto 0);
	  start     : in std_logic;
	  done      : out std_logic
);
end component;
   
   signal clk       : std_logic:='0';
   signal rst		: std_logic:='1';
   signal data_in   : std_logic_vector(31 downto 0);
   signal data_out  : std_logic_vector(31 downto 0);
   signal start     : std_logic;
   signal done      : std_logic;

 begin
 
 
 t1: top port map (
                     clk      =>   clk,      
                     rst	  =>   rst,		
                     data_in  =>   data_in,  
                     data_out =>   data_out, 
                     start    =>   start,    
                     done     =>   done       
					);
 
 
 clk <= not clk after PERIOD/2;
 rst<='0' after RST_DURATION;
 
 -- writing data to ram
 
 process 
 begin
 data_in <=(others=>'0');
 wait until falling_edge(rst);
 start <= '1';

 wait until falling_edge(clk);
 
 wait until rising_edge(clk);
 
 for i in 0 to 63 loop
 data_in <= data_in+1; 
  wait until rising_edge(clk);
 end loop;
  wait until falling_edge(done);
  data_in<=(others=>'0');
  wait until rising_edge(done);
 wait;
 end process;
 
end beh;