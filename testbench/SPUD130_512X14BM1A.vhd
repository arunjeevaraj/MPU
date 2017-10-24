-- |-----------------------------------------------------------------------|
--
-- (C) Copyright 2002-2006 Faraday Technology Corp. All Rights Reserved.
-- This source code is an unpublished work belongs to Faraday Technology
-- Corp.  It is considered a trade secret and is not to be divulged or
-- used by parties who have not received written authorization from
-- Faraday Technology Corp.
--
-- Faraday's home page can be found at:
-- http:/www.faraday-tech.com
--   
-- |-----------------------------------------------------------------------|
--                VHDL Behavior Simulation Model
--
--                   Synchronous 1-Port ROM
--
--       Module Name      : SPUD130_512X14BM1A
--       Words            : 512
--       Bits             : 14
--       Output Loading   : 0.01  (pf)
--       Aspect Ratio     : 1
--       Data Slew        : 0.016   (ns)
--       CK Slew          : 0.016   (ns)
--       Power Ring Width : 10  (um)
--
-- |-----------------------------------------------------------------------|
--
-- Notice on usage: Fixed delay or timing data are given in this model.
--                  It supports SDF back-annotation, please generate SDF file
--                  by EDA tools to get the accurate timing.
--
-- |-----------------------------------------------------------------------|
--
-- Warning : 
--   If customer's design viloate the set-up time or hold time criteria of 
--   FTC's synchronous SRAM, it's possible to hit the meta-stable point of 
--   latch circuit in the decoder and cause the data loss in the memory 
--   bitcell. So please follow the FTC memory IP's spec to design your 
--   product.
--
-- |-----------------------------------------------------------------------|
--
--       Library          : FSC0U_D
--       Memaker          : 200701.1.1
--       Date             : 2009/10/23 10:39:17
--
-- |-----------------------------------------------------------------------|

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- entity declaration --
entity SPUD130_512X14BM1A is
   generic(
      ROMCODE:     string   := "./matlab/RomCoeff.txt";
      SYN_CS:      integer  := 1;
      NO_SER_TOH:  integer  := 0;
      AddressSize: integer  := 9;
      Bits:        integer  := 14;
      Words:       integer  := 512;
      AspectRatio: integer  := 1;
      TOH:         time     := 1.31322 ns;

      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;

      tpd_CK_DO0_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO1_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO2_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO3_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO4_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO5_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO6_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO7_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO8_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO9_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO10_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO11_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO12_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);
      tpd_CK_DO13_posedge : VitalDelayType01 :=  (2.82395 ns,2.82395 ns);

      tpd_OE_DO0    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO1    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO2    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO3    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO4    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO5    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO6    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO7    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO8    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO9    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO10    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO11    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO12    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tpd_OE_DO13    : VitalDelayType01Z := (0.73368 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns, 0.608705 ns, 0.73368 ns);
      tsetup_A0_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A0_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A1_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A1_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A2_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A2_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A3_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A3_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A4_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A4_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A5_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A5_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A6_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A6_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A7_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A7_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A8_CK_posedge_posedge    :  VitalDelayType := 0.31872 ns;
      tsetup_A8_CK_negedge_posedge    :  VitalDelayType := 0.31872 ns;
      thold_A0_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A0_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A1_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A1_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A2_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A2_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A3_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A3_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A4_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A4_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A5_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A5_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A6_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A6_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A7_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A7_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A8_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_A8_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      tsetup_CS_CK_posedge_posedge    :  VitalDelayType := 0.439035 ns;
      tsetup_CS_CK_negedge_posedge    :  VitalDelayType := 0.439035 ns;
      thold_CS_CK_posedge_posedge     :  VitalDelayType := 0.1 ns;
      thold_CS_CK_negedge_posedge     :  VitalDelayType := 0.1 ns;
      tperiod_CK                      :  VitalDelayType := 2.62644 ns;
      tpw_CK_posedge                  :  VitalDelayType := 0.87548 ns;
      tpw_CK_negedge                  :  VitalDelayType := 0.87548 ns;
      tipd_A0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CS                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CK                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OE                     :  VitalDelayType01 := (0.000 ns, 0.000 ns)
      );

   port(
      A0                         :   IN   std_logic;
      A1                         :   IN   std_logic;
      A2                         :   IN   std_logic;
      A3                         :   IN   std_logic;
      A4                         :   IN   std_logic;
      A5                         :   IN   std_logic;
      A6                         :   IN   std_logic;
      A7                         :   IN   std_logic;
      A8                         :   IN   std_logic;
      DO0                        :   OUT   std_logic;
      DO1                        :   OUT   std_logic;
      DO2                        :   OUT   std_logic;
      DO3                        :   OUT   std_logic;
      DO4                        :   OUT   std_logic;
      DO5                        :   OUT   std_logic;
      DO6                        :   OUT   std_logic;
      DO7                        :   OUT   std_logic;
      DO8                        :   OUT   std_logic;
      DO9                        :   OUT   std_logic;
      DO10                        :   OUT   std_logic;
      DO11                        :   OUT   std_logic;
      DO12                        :   OUT   std_logic;
      DO13                        :   OUT   std_logic;
      CK                            :   IN   std_logic;
      CS                            :   IN   std_logic;
      OE                            :   IN   std_logic
      );

attribute VITAL_LEVEL0 of SPUD130_512X14BM1A : entity is TRUE;

end SPUD130_512X14BM1A;

-- architecture body --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

architecture behavior of SPUD130_512X14BM1A is
   -- attribute VITALMEMORY_LEVEL1 of behavior : architecture is TRUE;

   FILE infile: text is in ROMCODE;

   CONSTANT True_flg:       integer := 0;
   CONSTANT False_flg:      integer := 1;

   FUNCTION Minimum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t1); ELSE RETURN (t2); END IF;
   END Minimum;

   FUNCTION Maximum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t2); ELSE RETURN (t1); END IF;
   END Maximum;

   FUNCTION BVtoI(bin: std_logic_vector) RETURN integer IS
      variable result: integer;
   BEGIN
      result := 0;
      for i in bin'range loop
         if bin(i) = '1' then
            result := result + 2**i;
         end if;
      end loop;
      return result;
   END; -- BVtoI

   PROCEDURE ScheduleOutputDelay (
       SIGNAL   OutSignal        : OUT std_logic;
       VARIABLE Data             : IN  std_logic;
       CONSTANT Delay            : IN  VitalDelayType01 := VitalDefDelay01;
       VARIABLE Previous_A       : IN  std_logic_vector(AddressSize-1 downto 0);
       VARIABLE Current_A        : IN  std_logic_vector(AddressSize-1 downto 0);
       CONSTANT NO_SER_TOH       : IN  integer
   ) IS
   BEGIN

      if (NO_SER_TOH /= 1) then
         OutSignal <= TRANSPORT 'X' AFTER TOH;
         OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
      else
         if (Current_A /= Previous_A) then
            OutSignal <= TRANSPORT 'X' AFTER TOH;
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         else
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         end if;
      end if;
   END ScheduleOutputDelay;

   FUNCTION TO_INTEGER (
     a: std_logic_vector
   ) RETURN INTEGER IS
     VARIABLE y: INTEGER := 0;
   BEGIN
        y := 0;
        FOR i IN a'RANGE LOOP
            y := y * 2;
            IF a(i) /= '1' AND a(i) /= '0' THEN
                y := 0;
                EXIT;
            ELSIF a(i) = '1' THEN
                y := y + 1;
            END IF;
        END LOOP;
        RETURN y;
   END TO_INTEGER;

   function AddressRangeCheck(AddressItem: std_logic_vector; flag_Address: integer) return integer is
     variable Uresult : std_logic;
     variable status  : integer := 0;

   begin
      if (Bits /= 1) then
         Uresult := AddressItem(0) xor AddressItem(1);
         for i in 2 to AddressItem'length-1 loop
            Uresult := Uresult xor AddressItem(i);
         end loop;
      else
         Uresult := AddressItem(0);
      end if;

      if (Uresult = 'U') then
         status := False_flg;
      elsif (Uresult = 'X') then
         status := False_flg;
      elsif (Uresult = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_Address = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in Address." severity WARNING; 
        end if;
      end if;

      if (status=True_flg) then
         if ((BVtoI(AddressItem)) >= Words) then
             assert FALSE report "** MEM_Error: Out of range occurred in Address." severity WARNING;
             status := False_flg;
         else
             status := True_flg;
         end if;
      end if;

      return status;
   end AddressRangeCheck;

   function CS_monitor(CSItem: std_logic; flag_CS: integer) return integer is
     variable status  : integer := 0;

   begin
      if (CSItem = 'U') then
         status := False_flg;
      elsif (CSItem = 'X') then
         status := False_flg;
      elsif (CSItem = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_CS = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in ChipSelect." severity WARNING;
        end if;
      end if;

      return status;
   end CS_monitor;

   Type memoryArray Is array (Words-1 downto 0) Of std_logic_vector (Bits-1 downto 0);

   SIGNAL CS_ipd         : std_logic := 'X';
   SIGNAL OE_ipd         : std_logic := 'X';
   SIGNAL CK_ipd         : std_logic := 'X';
   SIGNAL A_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL DO_int         : std_logic_vector(Bits-1 downto 0) := (others => 'X');

   SIGNAL FileRead       : bit := '0';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (CS_ipd, CS, tipd_CS);
   VitalWireDelay (OE_ipd, OE, tipd_OE);
   VitalWireDelay (CK_ipd, CK, tipd_CK);
   VitalWireDelay (A_ipd(0), A0, tipd_A0);
   VitalWireDelay (A_ipd(1), A1, tipd_A1);
   VitalWireDelay (A_ipd(2), A2, tipd_A2);
   VitalWireDelay (A_ipd(3), A3, tipd_A3);
   VitalWireDelay (A_ipd(4), A4, tipd_A4);
   VitalWireDelay (A_ipd(5), A5, tipd_A5);
   VitalWireDelay (A_ipd(6), A6, tipd_A6);
   VitalWireDelay (A_ipd(7), A7, tipd_A7);
   VitalWireDelay (A_ipd(8), A8, tipd_A8);

   end block;

   VitalBUFIF1 (q      => DO0,
                data   => DO_int(0),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO0);
   VitalBUFIF1 (q      => DO1,
                data   => DO_int(1),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO1);
   VitalBUFIF1 (q      => DO2,
                data   => DO_int(2),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO2);
   VitalBUFIF1 (q      => DO3,
                data   => DO_int(3),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO3);
   VitalBUFIF1 (q      => DO4,
                data   => DO_int(4),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO4);
   VitalBUFIF1 (q      => DO5,
                data   => DO_int(5),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO5);
   VitalBUFIF1 (q      => DO6,
                data   => DO_int(6),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO6);
   VitalBUFIF1 (q      => DO7,
                data   => DO_int(7),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO7);
   VitalBUFIF1 (q      => DO8,
                data   => DO_int(8),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO8);
   VitalBUFIF1 (q      => DO9,
                data   => DO_int(9),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO9);
   VitalBUFIF1 (q      => DO10,
                data   => DO_int(10),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO10);
   VitalBUFIF1 (q      => DO11,
                data   => DO_int(11),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO11);
   VitalBUFIF1 (q      => DO12,
                data   => DO_int(12),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO12);
   VitalBUFIF1 (q      => DO13,
                data   => DO_int(13),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO13);

   --------------------
   --  BEHAVIOR SECTION
   --------------------
   PROCESS
     begin
       FileRead <= not FileRead;
       wait;
   end PROCESS;

   VITALBehavior : PROCESS (FileRead, CS_ipd, OE_ipd, A_ipd, CK_ipd)

   -- timing check results
   VARIABLE Tviol_A_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_CS_CK_posedge  : STD_ULOGIC := '0';

   VARIABLE Pviol_CK    : STD_ULOGIC := '0';
   VARIABLE Pdata_CK    : VitalPeriodDataType := VitalPeriodDataInit;

   VARIABLE Tmkr_A_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CS_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;

   VARIABLE DO_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore  : memoryArray;

   VARIABLE ck_change   : std_logic_vector(1 downto 0);
   VARIABLE web_cs      : std_logic_vector(1 downto 0);

   -- previous latch data
   VARIABLE Latch_A        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_CS       : std_logic := 'X';
   -- internal latch data
   VARIABLE A_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE CS_i           : std_logic := 'X';

   VARIABLE last_A         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');

   VARIABLE LastClkEdge    : std_logic := 'X';

   VARIABLE flag_A: integer   := True_flg;
   VARIABLE flag_CS: integer   := True_flg;

   VARIABLE i                 : integer := 0;
   VARIABLE buf               : LINE;

   begin

   ------------------------
   --  Timing Check Section
   ------------------------
   if (TimingChecksOn) then

         VitalSetupHoldCheck (
          Violation               => Tviol_A_CK_posedge,
          TimingData              => Tmkr_A_CK_posedge,
          TestSignal              => A_ipd,
          TestSignalName          => "A",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_A0_CK_posedge_posedge,
          SetupLow                => tsetup_A0_CK_negedge_posedge,
          HoldHigh                => thold_A0_CK_negedge_posedge,
          HoldLow                 => thold_A0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SPUD130_512X14BM1A",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CS_CK_posedge,
          TimingData              => Tmkr_CS_CK_posedge,
          TestSignal              => CS_ipd,
          TestSignalName          => "CS",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CS_CK_posedge_posedge,
          SetupLow                => tsetup_CS_CK_negedge_posedge,
          HoldHigh                => thold_CS_CK_negedge_posedge,
          HoldLow                 => thold_CS_CK_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SPUD130_512X14BM1A",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CK,
          PeriodData              => Pdata_CK,
          TestSignal              => CK_ipd,
          TestSignalName          => "CK",
          TestDelay               => 0 ns,
          Period                  => tperiod_CK,
          PulseWidthHigh          => tpw_CK_posedge,
          PulseWidthLow           => tpw_CK_negedge,
          CheckEnabled            => NOW /= 0 ns AND CS_ipd = '1',
          HeaderMsg               => InstancePath & "/SPUD130_512X14BM1A",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

   end if;

   -------------------------
   --  Functionality Section
   -------------------------

       if (FileRead'event) then
           while not(endfile(infile)) loop
               READLINE (infile, buf);
               -- synopsys translate_off
               READ(buf, memoryCore(i));
               -- synopsys translate_on
               i := i+1;
           end loop;
       end if;

       if (CS_ipd = '0' and CS_ipd'event) then
          if (SYN_CS = 0) then
             DO_zd := (OTHERS => 'X');
             DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
          end if;
       end if;

       if (CK_ipd'event) then
         ck_change := LastClkEdge&CK_ipd;
         case ck_change is
            when "01"   =>
                if (CS_monitor(CS_ipd,flag_CS) = True_flg) then
                   -- Reduce error message --
                   flag_CS := True_flg;
                else
                   flag_CS := False_flg;
                end if;

                Latch_A   := A_ipd;
                Latch_CS  := CS_ipd;

                -- memory_function
                A_i   := Latch_A;
                CS_i  := Latch_CS;

                case CS_i is
                   when '1' =>
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO_zd := memoryCore(to_integer(A_i));
                           ScheduleOutputDelay(DO_int(0), DO_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(1), DO_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(2), DO_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(3), DO_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(4), DO_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(5), DO_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(6), DO_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(7), DO_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(8), DO_zd(8),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(9), DO_zd(9),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(10), DO_zd(10),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(11), DO_zd(11),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(12), DO_zd(12),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(13), DO_zd(13),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO_zd := (OTHERS => 'X');
                           DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when '0'    => -- do nothing

                   when others => DO_zd := (OTHERS => 'X');
                                DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                end case;
                -- end memory_function
                last_A := A_ipd;

            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns) then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                           end if;
                           DO_zd := (OTHERS => 'X');
                           DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
         end case;
         LastClkEdge := CK_ipd;
       end if;

       if (Tviol_A_CK_posedge    = 'X' or
           Tviol_CS_CK_posedge   = 'X' or
           Pviol_CK              = 'X'
          ) then
         if (Pviol_CK = 'X') then
            if (CS_ipd /= '0') then
               DO_zd := (OTHERS => 'X');
               DO_int <= TRANSPORT (OTHERS => 'X');
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_A_CK_posedge = 'X') then
                 Latch_A(i) := 'X';
              else
                 Latch_A(i) := Latch_A(i);
              end if;
            END LOOP;
            if (Tviol_CS_CK_posedge = 'X') then
               Latch_CS := 'X';
            else
               Latch_CS := Latch_CS;
            end if;

                -- memory_function
                A_i   := Latch_A;
                CS_i  := Latch_CS;

                case CS_i is
                   when '1' =>
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO_zd := memoryCore(to_integer(A_i));
                           ScheduleOutputDelay(DO_int(0), DO_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(1), DO_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(2), DO_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(3), DO_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(4), DO_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(5), DO_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(6), DO_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(7), DO_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(8), DO_zd(8),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(9), DO_zd(9),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(10), DO_zd(10),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(11), DO_zd(11),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(12), DO_zd(12),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO_int(13), DO_zd(13),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO_zd := (OTHERS => 'X');
                           DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when '0'    => -- do nothing

                   when others => DO_zd := (OTHERS => 'X');
                                DO_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                end case;
                -- end memory_function
         end if;
       end if;

   end PROCESS;

end behavior;
