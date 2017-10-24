--- buid the test bench with file read and write access.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.classio.all;

-- test bench don't have a port.
entity mpu_tb is
end entity;


-- architecture of mpu_tb.
architecture beh of mpu_tb is

component top_design is
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
end component;



-- signal to connect the design.


signal 		data_in      : std_logic_vector(31 downto 0);
signal     i_data_vld    : std_logic;
signal 	   data_out      : std_logic_vector(31 downto 0);
signal 	   o_data_vld    : std_logic;
signal 	   start         : std_logic;
signal 	   done          : std_logic;

signal 	   mat_order     : std_logic_vector(5 downto 0);
signal 	   operation_mode: std_logic_vector(1 downto 0);
signal 	i_instruction_vld: std_logic;

signal 	   clk           : std_logic:='0';
signal 	   rst           : std_logic:='1';


signal write_done : std_logic;
signal read_done  : std_logic;




begin

-- writing no instructions into the module for now.
i_instruction_vld <='0';
operation_mode    <="00";     				  -- debug mode.
mat_order <="00"&x"8";        				  -- testing with order 8.
clk   <= not clk after 5 ns;  				  -- running the clk generator.
rst   <='0' after 15 ns;      				  -- reset sigal 
start <='0','1'after 25 ns,'0' after 35 ns;   -- give the start signal.





-- connect the design.

top_inst: top_design 
port  map( --I/O buses
		data_in      =>   data_in,      
       i_data_vld    =>   i_data_vld,    
	   data_out      =>   data_out,      
	   o_data_vld    =>   o_data_vld,    
	   start         =>   start,         
	   done          =>   done,          
	   mat_order     =>   mat_order,     
	   operation_mode=>   operation_mode,
	i_instruction_vld=>i_instruction_vld,
	   clk           =>   clk,           
	   rst           =>   rst           
	 );




-- read the matrix file here.

process is 
  file infile              : text;		        -- pointers to text file. 
  variable f_status        : FILE_OPEN_STATUS;  -- status of the file open.
  variable read_data       : std_logic_vector(31 downto 0);
  variable count 		   : integer:=63;	        -- count 

begin
i_data_vld  <='0';
read_done   <='0';
data_in     <=(others =>'0');
-- begin


file_open(f_status,infile,"./testfiles/test_file.txt",read_mode);     -- open the file to read from..
   wait until falling_edge(rst);
  -- wait until rising_edge(write_done); -- wait for the file to be written first.
   i_data_vld <='0';
   
   wait until falling_edge(clk);
   wait until falling_edge(clk);
   wait until falling_edge(clk);
   wait until falling_edge(clk);
   wait until falling_edge(clk);
   wait until falling_edge(clk);
   
   
 for i in 0 to 63 loop
  wait until falling_edge(clk);
  read_vld(infile,read_data);
  data_in <= read_data;
  i_data_vld <= '1';
 end loop;
 
 -- readin file is done. 
   
wait;
end process;









--- write a file for debug mode.
process is 
 file     outfile,load_mat_file,mat_copy_file,modelsim_console,
		  mat_diag_add_file, mat_mul_file: text;		             -- pointers to text file. 
 variable f_status: FILE_OPEN_STATUS;        -- status of the file open.
 variable buf_out : LINE;                    -- buffer between vhdl and file pointer.
 variable count   : integer;	             -- count 
 variable to_write_slv: std_logic_vector(31 downto 0);
 variable to_write : unsigned(31 downto 0);
 variable mat_size : integer;
begin

-- if you don't want to write a file.
--wait;
--open the infile
--- generating the file to test inside vhdl itself.
write_done <='0';
-- testing if it writes well.
file_open(f_status,outfile,"./testfiles/test_file.txt",write_mode);  -- open the file to write to.
file_open(f_status,load_mat_file,"./testfiles/load_mat_test.txt",write_mode); -- writes the file for load matrix to ram.
file_open(f_status,mat_copy_file,"./testfiles/mat_copy_test.txt",write_mode); -- writes the file for mat copy test.
file_open(f_status,mat_diag_add_file,"./testfiles/mat_add_test.txt",write_mode); -- writes the file for mat diag add test.
file_open(f_status,mat_mul_file,"./testfiles/mat_mul_test.txt",write_mode); -- writes the file for mat diag add test.
file_open(f_status,modelsim_console,"STD_OUTPUT",write_mode); -- writes the result in modelsim console.
to_write :=(others=>'0');
for i in 0 to 64 loop
to_write_slv := std_logic_vector(to_write);
write_vld(outfile,to_write_slv);              -- write one line of std_logic vector in the file.
to_write := to_write+1;
end loop;
file_close(outfile);                          -- close the file.
write(buf_out,string'("Writing text file for test is done.!"));
writeline(modelsim_console,buf_out);











--- test starts here.
wait until falling_edge(clk);
write_done <='1';

--- load ram test and data ram out test.
--wait until rising_edge(o_data_vld);
 
 for i in 0 to 63 loop
 wait until rising_edge(o_data_vld);  
 wait until falling_edge(clk);
 to_write_slv := data_out;
 write_vld(load_mat_file,to_write_slv );
 
 end loop; 
write(buf_out,string'("Writing text file for load mat is done.!"));
writeline(modelsim_console,buf_out); 
 
 
 --- matrix copy test.
 
 write(buf_out,string'("Writing text file for matrix copy is started.!"));
writeline(modelsim_console,buf_out); 
 for i in 0 to 63 loop
 wait until rising_edge(o_data_vld);
 wait until falling_edge(clk);
 to_write_slv := data_out;
 write_vld(mat_copy_file,to_write_slv );
 end loop; 
write(buf_out,string'("Writing text file for matrix copy is done.!"));
writeline(modelsim_console,buf_out); 
 
 -- do add_i test.
 
  write(buf_out,string'("Writing text file for matrix diag_Add is started.!"));
writeline(modelsim_console,buf_out); 
 for i in 0 to 63 loop
 wait until rising_edge(o_data_vld);
 wait until falling_edge(clk);
 to_write_slv := data_out;
 write_vld(mat_diag_add_file,to_write_slv );
 end loop; 
write(buf_out,string'("Writing text file for matrix diag_Add is done.!"));
writeline(modelsim_console,buf_out); 


 -- do  Matrix Multiply test.
 
  write(buf_out,string'("Writing text file for matrix Multiply is started.!"));
writeline(modelsim_console,buf_out); 
 for i in 0 to 63 loop
 wait until rising_edge(o_data_vld);
 wait until falling_edge(clk);
 to_write_slv := data_out;
 write_vld(mat_mul_file,to_write_slv );
 end loop; 
write(buf_out,string'("Writing text file for matrix Multiply is done.!"));
writeline(modelsim_console,buf_out); 
 
 

wait;
end process;
 
 
 
 








-- just a waiting process.
process

begin
wait;

end process;


end beh;




