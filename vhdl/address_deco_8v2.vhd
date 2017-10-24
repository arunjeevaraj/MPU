library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--- diag_wm = 00 for normal mul operation.
--- diag_wm = 01 for diag_row mode ,diag col mode and mat copy operations. --- reads col wise and stores col wise.
--- diag_wm = 10 to do, read diag sele elements and store eye + diag 
--- diag_wm = 11 for only diag selective write. no read done.

-- mode 000 for loading the input matrix to ram, to op_1
-- mode 001 for performing mat_mult. op_1*op_2 = op_r
-- mode 010 for reading the mat col wise and writing col wise. used for diag special multiply-- diag_mat*op_1 => op_r
-- mode 011 for subi     -- set op_r matrix diagonal elements zero
-- mode 100 for mat copy --  op_1 to op_r.     
-- mode 101 for addi     -- set op_r matrix diagonal elements to one.
-- mode 110 for reading the mat row wise and writing row wise. used for diag special multiply.-- op_1 * diag_mat => op_r.
-- mode 111 for sending the result out serially through data out..





entity address_deco is
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
top_inv_addr_inp  : out std_logic_vector(2 downto 0);	-- for 8 numbers.
		rst		  : in  std_logic;
    row_mode      : in std_logic_vector(1 downto 0)
	);
end entity;	
	
	
	
architecture beh of address_deco is

type system_st_read is ( st_idle, 
					st_read_row,st_read_row_wt,st_read_mat,st_read_mat_wt,
					st_done
					);
type system_st_write is (st_idle, 
					st_write1,st_write2,st_write3,st_write4,
					st_diag_el_wt,
					st_done,st_done_wt
					);		
					
signal csr,nsr : system_st_read;
signal csw,nsw : system_st_write;
	

signal mat_ind         : std_logic_vector(3 downto 0);
signal base_address    : std_logic_vector(ADDRESS_WIDTH downto 0);
signal rowset_address  : std_logic_vector(ADDRESS_WIDTH downto 0);
signal address_incr,
	   address_incr_w  : std_logic_vector(ADDRESS_WIDTH downto 0);
	   
constant COL_CNT_WIDTH : integer :=2;		
constant ones_col_cnt  : std_logic_vector(COL_CNT_WIDTH downto 0) :=(others=>'1');	--  log2( row_size)-1	   
constant ROW_SIZE      : std_logic_vector(COL_CNT_WIDTH downto 0) :=(others=>'1');   --  Matrix row size
constant COLSET_WIDTH  : integer :=0;   				     			     -- log2(row_size/4)-1
constant COLSET_MAX    : std_logic_vector(COLSET_WIDTH downto 0) :=(others=>'1');

signal colset,colset_ff
			,colset_ff_1: std_logic_vector(COLSET_WIDTH downto 0);

signal col_cnt         : std_logic_vector(COL_CNT_WIDTH downto 0);		-- needs to be changed as per the matrix size. 
constant zero_bit      : std_logic_vector(ADDRESS_WIDTH-COL_CNT_WIDTH-1 downto 0):=(others=>'0');


--- for reading.

signal rowset        : std_logic_vector(COLSET_WIDTH downto 0); -- for 8*8 mat two times to read row.
signal row_cnt       : std_logic_vector(COL_CNT_WIDTH downto 0);
signal rowset_m      : std_logic_vector(COLSET_WIDTH downto 0);-- for reading mat.

-- for reading number of time the matrix was read. it needs to be read 8 times so do that...
signal mat_tim       : std_logic_vector(COL_CNT_WIDTH downto 0);
signal ra_rd_i       : std_logic_vector(1 downto 0);


--- for diag excluvive write mode
signal   diag_cnt,diag_cnt_incr : std_logic_vector(COL_CNT_WIDTH downto 0);
constant diag_cnt_max  : std_logic_vector(COL_CNT_WIDTH downto 0) :=(others=>'1');
signal   diag_address  : std_logic_vector(ADDRESS_WIDTH downto 0);
signal   diag_decod_out : std_logic_vector(RAM_NUM-1 downto 0);
signal   done_read      : std_logic;


begin




-- done signal when it finishes the set operation.

done    <= done_read;
mm_switch <= '1' when ((csr= st_read_row_wt and nsr = st_read_mat) or (csr = st_read_mat_wt and nsr= st_read_row )) else '0';
mac_vld <= '1' when (csr =st_read_mat_wt) else '0';
done_read <=  '1' when (csw =st_done or csr = st_done) or (csw =st_write4 and nsr = st_done and diag_wm = "01")else '0'; 
-- used for writing the row register..
reg_wen <= '0' when (csr =st_read_row_wt) else '1';

-- used for reading from the row register.
reg_mre <= rowset_m;

-- used for storing the result after the multiply and accumulate step.
mac_write_vld <= '1' when (csr= st_read_mat_wt and rowset_m="1") else '0' ;
mat_ind <= mat_index;
reg_ar_row <= mat_tim(1 downto 0) ;
diag_wm_tog <= '1' when csr= st_read_row else '0';

diag_address <= zero_bit& diag_cnt;


process(row_mode, col_cnt, diag_wm)
begin
	if(diag_wm="00") then
	     top_inv_addr_inp <= (others=>'0');
	else
		if(row_mode="10") then -- for normal mode
		  top_inv_addr_inp <= col_cnt;
		else
		  top_inv_addr_inp <= col_cnt(2)&"00";
		end if;
    end if;
end process;


-- user for addi and sub i process;
diag_cnt_dec:process (diag_cnt) 
begin

case  diag_cnt(1 downto 0) is
   when "00"=>
       diag_decod_out <="0001";
   when "01"=>
       diag_decod_out <="0010";
	  
   when "10"=>
       diag_decod_out <="0100";
   when "11"=>
       diag_decod_out <="1000";
   when others=>
   
end case;
end process;

process(csw, diag_cnt)
begin
 if(csw = st_diag_el_wt) then
   diag_cnt_incr <= diag_cnt +1;
 else
   diag_cnt_incr <= diag_cnt;
 end if;
end process;

---

ram_sel_gen: process(csr,csw,col_cnt,row_cnt,rnw,diag_wm, diag_decod_out)


begin
if(diag_wm="01") then 
 if(rnw='0') then
  if(csw=st_write4) then
	ram_sel <= "1111";
	address_incr_w<=zero_bit& std_logic_vector((col_cnt));
  else
   ram_sel <= "0000";
   address_incr_w <= (others=>'0');
  end if;
 else
  ram_sel <= "1111";
  address_incr_w <= zero_bit& std_logic_vector((col_cnt));
 end if;

 
 
elsif(diag_wm ="00") then
 if(rnw='0') then
	case csw is 
		when st_write1=>
			ram_sel<= "0001";
			address_incr_w<=zero_bit& std_logic_vector((col_cnt));
		when st_write2=>
			ram_sel<= "0010";
			address_incr_w<=zero_bit& std_logic_vector((col_cnt));
		when st_write3=>
			ram_sel<="0100";
			address_incr_w<=zero_bit& std_logic_vector((col_cnt));
		when st_write4=>
			ram_sel<="1000";
			address_incr_w<=zero_bit& std_logic_vector((col_cnt));
		

		when others=>
			ram_sel<="0000";
			address_incr_w<=(others=>'0');
	end case;
 else
	case csr is 

		
		
		when st_read_row =>
			ram_sel<="1111";
			address_incr_w<=zero_bit& std_logic_vector((row_cnt));
		when st_read_row_wt =>
			ram_sel<="1111";
			address_incr_w<=zero_bit& std_logic_vector((row_cnt));
		
		when st_read_mat =>
			ram_sel<="1111";
			address_incr_w<=zero_bit& std_logic_vector((row_cnt));
		when st_read_mat_wt =>
			ram_sel<="1111";
			address_incr_w<=zero_bit& std_logic_vector((row_cnt));
		
		when others=>
			ram_sel<="0000";
			address_incr_w<=(others=>'0');
	end case;
 end if;
elsif (diag_wm ="10")  then

  --  
        ram_sel<="0000";
		address_incr_w<=(others=>'0');

else   
--  diag_wm ="11" for adding and subtracting identity matrix.
         ram_sel <= diag_decod_out;
		 address_incr_w<=(others=>'0');
end if; 
end process;



process (rowset,csr,csw,rowset_m,colset,rnw,colset_ff,diag_wm,colset_ff_1) 
begin
-- for writing
if(rnw='0') then
 	case csw is 
		when st_write1 =>
		  if(colset=COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		when st_write2 =>
		 if(colset=COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		when st_write3 =>
		 if(colset=COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		when st_diag_el_wt=>
		 if(colset=COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		when st_write4 =>
		if(diag_wm ="01") then
		 if(colset_ff_1 = COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		else
		 if(colset_ff = COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		end if;
		 
		when others =>
		
		rowset_address <= (others=>'0');

	end case;
else	
-- for reading
    case csr is 
		
		when st_read_row=>
		if(diag_wm="01") then -- col_read and write
			if(colset_ff=COLSET_MAX) then
				rowset_address <= '0'& x"008";
		    else
			    rowset_address <= (others=>'0');
		    end if;
		 else
		   if(rowset=COLSET_MAX) then
				rowset_address <= '0'& x"008";
		    else
			    rowset_address <= (others=>'0');
		    end if;
		   
		end if;
		when st_read_row_wt=>
		 if(rowset=COLSET_MAX) then
		  rowset_address <= '0'& x"008";
		 else
		  rowset_address <= (others=>'0');
		 end if;
		 
		when st_read_mat=>
		  if(rowset_m="1") then
		   rowset_address <= '0'& x"008";
		  else
		   rowset_address <= (others=>'0');
		  end if;
		when st_read_mat_wt=>
		   if(rowset_m="1") then
		   rowset_address <= '0'& x"008";
		  else
		   rowset_address <= (others=>'0');
		  end if;
		when others =>
		
		rowset_address <= (others=>'0');

	end case;    
end if;
end process;


st_mac: process(clk,rst) 
begin
if(rst='1') then

	csr		<= st_idle;
	csw		<= st_write1;

	colset  <= (others=>'0');
	colset_ff  <= (others=>'0');
	colset_ff_1<= (others=>'0');
	rowset  <= (others=>'0');
	col_cnt <= (others=>'0');
	row_cnt <= (others=>'0');
	rowset_m<= (others=>'0');
	mat_tim <= (others=>'0');
	diag_cnt<= (others=>'0');
  --  ra_rd_i <= (others=>'0');
elsif(rising_edge(clk)) then
  
    diag_cnt <= diag_cnt_incr;
  
 if(diag_wm="01") then
   
   if(done_read='1' or rnw ='1') then
	 csr <= nsr;
	end if;
 else
	if(rnw='1') then
	 csr <= nsr;
	end if;
 end if;	
  	
	if(diag_wm="01") then
		if((start='1' and rnw ='0' )or done_read='1') then
				csw <= nsw;
	    end if;	
	elsif(diag_wm="11") then	
	       csw <= nsw;
	else
	   if(start='1' and rnw ='0') then
				csw <= nsw;
	   end if;
	
	end if;	

	colset_ff <= colset;
	colset_ff_1<= colset_ff;
	address_incr <= address_incr_w;

-- for writing.
if( diag_wm="01") then
    if(nsr = st_idle and csw = st_write4) then
		col_cnt <= col_cnt + 1;
	end if;	
	if(csw= st_write4 and col_cnt =ones_col_cnt-1 and start = '1' and rnw ='0') then
	    colset <= colset+1;
	end if;
elsif(diag_wm="11") then
     if(diag_cnt(1 downto 0)= "11") then
	   colset <= colset+1;
	 end if;
	 
	
else
	if((csw=st_write1 or csw=st_write2 or csw=st_write3 or csw=st_write4) and start = '1' and rnw ='0') then
		col_cnt<=col_cnt+1;
	end if;
	if(csw= st_write4 and col_cnt =ones_col_cnt-1 and start = '1' and rnw ='0') then
	    colset <= colset+1;
	end if;
end if;	
-- for reading row.

	if(csr= st_read_row_wt) then
		row_cnt<= row_cnt+1;
		if(row_cnt=ones_col_cnt) then
			rowset <= rowset+1;
		end if;
	end if;
	
	
-- for reading mat	
    if(csr= st_read_mat_wt) then
	 rowset_m <= rowset_m+1;
	  if( rowset_m="1") then
	   
	   row_cnt<= row_cnt+1;
	     if(row_cnt = ones_col_cnt) then
		  mat_tim <= mat_tim +1;
		 end if;
		-- if(mat_tim= ones_col_cnt) then
		  --ra_rd_i <= ra_rd_i +1;
		 --end if;
	  end if;
	end if;
end if;


end process;

st_mac_comb: process(csr,csw,start,rnw,col_cnt,colset,colset_ff,row_cnt,
						rowset_m,rowset,diag_wm,mat_tim,diag_cnt)
begin
if(diag_wm="01") then -- for diag col read and write.

 if(csw = st_done) then
   nsw <= st_write1;
   nsr <= st_idle;
 
 else
		if(rnw='0') then
		   nsr <= st_idle;
		   if(csw = st_write4) then
				if(col_cnt=ROW_SIZE) then
					 if(colset_ff="0") then
					  nsw <= st_done; 
					 else
					  nsw <= st_write4;
					 end if;
				else
				 nsw <= st_write4;
				end if;
		    else
				nsw <= st_write4;
		    end if;
	    else
		   nsw <= st_idle;
		    nsr <= st_read_row;
	    end if;	
  end if;
elsif(diag_wm="11") then -- for sub_i and add_i
    nsr <= st_idle;
  if(csw= st_write1) then
     nsw <= st_diag_el_wt;
  elsif(csw = st_done)then
     nsw <= st_write1;
  elsif(csw = st_done_wt) then
    nsw <= st_write1;  
  else
     if(diag_cnt= diag_cnt_max) then
	  nsw <= st_done;
	 elsif(csw /= st_done) then 
	  nsw <= csw;
	 else
	  nsw <= st_diag_el_wt;
	 end if;
  end if;
 
else
  case csw is
	when st_idle=>
	  if(start='1') then
			if(rnw='0') then
			 nsw <= st_write1;
			else
			 nsw <= st_idle;
			end if;
	   else
	   nsw<= st_idle;
	   end if;
-- writing	   
	when st_write1 =>
		if(col_cnt=ROW_SIZE) then
   	     nsw <= st_write2;
		else
         nsw <= st_write1;
		end if;		 
	when st_write2 =>
		if(col_cnt=ROW_SIZE) then
   	     nsw <= st_write3;
		else
         nsw <= st_write2;
		end if;	
	when st_write3=>
	    if(col_cnt=ROW_SIZE) then
   	     nsw <= st_write4;
		else
         nsw <= st_write3;
		end if;	
	when st_write4=>
	    if(col_cnt=ROW_SIZE) then
			if(colset="0") then
			 nsw <= st_done; 
			else
			 nsw <= st_write1;
			end if;
		else
         nsw <= st_write4;
		end if;
	when st_done =>
         nsw <= st_write1;	
    when others =>
	 	 nsw  <= st_idle;
end case;

-- reading
case csr is
	when st_idle=>
	  if(start='1') then
			if(rnw='0') then
			 nsr <= st_idle;
			else
			 nsr <= st_read_row;
			end if;
	   else
	   nsr<= st_idle;
	   end if;
	   

-- for reading row
	when st_read_row=>
	
	nsr <= st_read_row_wt;
	when st_read_row_wt=>
	if(row_cnt= ones_col_cnt) then
		nsr<= st_read_mat;
	else
		nsr <= st_read_row;
	end if;

-- for reading mat
    when st_read_mat =>
	    nsr <= st_read_mat_wt;
	when st_read_mat_wt=>
		if(row_cnt=ones_col_cnt and rowset_m =COLSET_MAX and mat_tim(1 downto 0)="11") then
			if(rowset="0") then
			 nsr <=st_done;
			else
			 nsr <=st_read_row;
			end if;
		else
			nsr <=st_read_mat;
		end if;	
	when st_done=>
	   nsr <= st_idle;
	when others =>
	   nsr  <= st_idle;
   end case;
 end if;  
end process;


----- base address generated to choose the mat of interest.


base_address_hc: process(mat_ind) begin

case mat_ind is
	when x"0"=>
	 base_address <= (others=>'0');
	when x"1"=>
	 base_address <=   '0' & x"010";
	when x"2"=>
	 base_address <=   '0' & x"020";
	when x"3"=>
	 base_address <=   '0' & x"030";
	when x"4"=>
	 base_address <=   '0' & x"040";
    when x"5"=>
	 base_address <=   '0' & x"050";
    when x"6"=>
	 base_address <=   '0' & x"060";
    when x"7"=>
	 base_address <=   '0' & x"070";	 
	when others =>
	 base_address <= (others=>'0');

end case;

end process;

--- sums up the address to get the address of the ram.

address_dec:process(base_address,rowset_address,address_incr_w,diag_address) 
begin
	
		address <= base_address+rowset_address+address_incr_w+ diag_address;
	
end process;


end beh;
	
	   