-------------------------------------------------------------------------
-- RAM wrapper for 130nm 
-- Switch of timing for behavioural model
-- A quick and hardcoded (bad) wrapper for checking 
-- 
-------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity ram_wrapper is
  port (
    addr     : in  unsigned(6 downto 0);
    data_out : out std_logic_vector(31 downto 0);
    data_in  : in  std_logic_vector(31 downto 0);
    CK       : in  std_logic;
    CS       : in  std_logic;
    WEB      : in  std_logic;
    OE       : in  std_logic
    );
end entity ram_wrapper;

architecture behave of ram_wrapper is

  component SHUD130_128X32X1BM1 is
    generic (TimingChecksOn : boolean := true);
    port (
      A0   : in  std_logic;
      A1   : in  std_logic;
      A2   : in  std_logic;
      A3   : in  std_logic;
      A4   : in  std_logic;
      A5   : in  std_logic;
      A6   : in  std_logic;
      DO0  : out std_logic;
      DO1  : out std_logic;
      DO2  : out std_logic;
      DO3  : out std_logic;
      DO4  : out std_logic;
      DO5  : out std_logic;
      DO6  : out std_logic;
      DO7  : out std_logic;
      DO8  : out std_logic;
      DO9  : out std_logic;
      DO10 : out std_logic;
      DO11 : out std_logic;
      DO12 : out std_logic;
      DO13 : out std_logic;
      DO14 : out std_logic;
      DO15 : out std_logic;
      DO16 : out std_logic;
      DO17 : out std_logic;
      DO18 : out std_logic;
      DO19 : out std_logic;
      DO20 : out std_logic;
      DO21 : out std_logic;
      DO22 : out std_logic;
      DO23 : out std_logic;
      DO24 : out std_logic;
      DO25 : out std_logic;
      DO26 : out std_logic;
      DO27 : out std_logic;
      DO28 : out std_logic;
      DO29 : out std_logic;
      DO30 : out std_logic;
      DO31 : out std_logic;
      DI0  : in  std_logic;
      DI1  : in  std_logic;
      DI2  : in  std_logic;
      DI3  : in  std_logic;
      DI4  : in  std_logic;
      DI5  : in  std_logic;
      DI6  : in  std_logic;
      DI7  : in  std_logic;
      DI8  : in  std_logic;
      DI9  : in  std_logic;
      DI10 : in  std_logic;
      DI11 : in  std_logic;
      DI12 : in  std_logic;
      DI13 : in  std_logic;
      DI14 : in  std_logic;
      DI15 : in  std_logic;
      DI16 : in  std_logic;
      DI17 : in  std_logic;
      DI18 : in  std_logic;
      DI19 : in  std_logic;
      DI20 : in  std_logic;
      DI21 : in  std_logic;
      DI22 : in  std_logic;
      DI23 : in  std_logic;
      DI24 : in  std_logic;
      DI25 : in  std_logic;
      DI26 : in  std_logic;
      DI27 : in  std_logic;
      DI28 : in  std_logic;
      DI29 : in  std_logic;
      DI30 : in  std_logic;
      DI31 : in  std_logic;
      WEB : in std_logic;
      CK   : in  std_logic;
      CS   : in  std_logic;
      OE   : in  std_logic
      );
  end component;



begin

  ram_inst : SHUD130_128X32X1BM1
    generic map (TimingChecksOn => false)
    port map (
      A0   => addr(0),
      A1   => addr(1),
      A2   => addr(2),
      A3   => addr(3),
      A4   => addr(4),
      A5   => addr(5),
      A6   => addr(6),
      DO0  => data_out(0),
      DO1  => data_out(1),
      DO2  => data_out(2),
      DO3  => data_out(3),
      DO4  => data_out(4),
      DO5  => data_out(5),
      DO6  => data_out(6),
      DO7  => data_out(7),
      DO8  => data_out(8),
      DO9  => data_out(9),
      DO10 => data_out(10),
      DO11 => data_out(11),
      DO12 => data_out(12),
      DO13 => data_out(13),
      DO14 => data_out(14),
      DO15 => data_out(15),
      DO16 => data_out(16),
      DO17 => data_out(17),
      DO18 => data_out(18),
      DO19 => data_out(19),
      DO20 => data_out(20),
      DO21 => data_out(21),
      DO22 => data_out(22),
      DO23 => data_out(23),
      DO24 => data_out(24),
      DO25 => data_out(25),
      DO26 => data_out(26),
      DO27 => data_out(27),
      DO28 => data_out(28),
      DO29 => data_out(29),
      DO30 => data_out(30),
      DO31 => data_out(31),
      DI0  => data_in(0),
      DI1  => data_in(1),
      DI2  => data_in(2),
      DI3  => data_in(3),
      DI4  => data_in(4),
      DI5  => data_in(5),
      DI6  => data_in(6),
      DI7  => data_in(7),
      DI8  => data_in(8),
      DI9  => data_in(9),
      DI10 => data_in(10),
      DI11 => data_in(11),
      DI12 => data_in(12),
      DI13 => data_in(13),
      DI14 => data_in(14),
      DI15 => data_in(15),
      DI16 => data_in(16),
      DI17 => data_in(17),
      DI18 => data_in(18),
      DI19 => data_in(19),
      DI20 => data_in(20),
      DI21 => data_in(21),
      DI22 => data_in(22),
      DI23 => data_in(23),
      DI24 => data_in(24),
      DI25 => data_in(25),
      DI26 => data_in(26),
      DI27 => data_in(27),
      DI28 => data_in(28),
      DI29 => data_in(29),
      DI30 => data_in(30),
      DI31 => data_in(31),
      WEB => WEB,
      CK => CK,
      CS => CS,
      OE => OE
      );



end architecture;
