-------------------------------------------------------------------------------
-- Title      : Shared clocking and resets                                             
-- Project    : 10GBASE-R                                                      
-------------------------------------------------------------------------------
-- File       : ten_gig_eth_pcs_pma_0_shared_clock_and_reset.vhd                                          
-------------------------------------------------------------------------------
-- Description: This file contains the 
-- 10GBASE-R clocking and reset logic which can be shared between multiple cores                
-------------------------------------------------------------------------------
-- (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and 
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity  ten_gig_eth_pcs_pma_0_shared_clock_and_reset is
port
(
  areset              : in  std_logic;
  refclk_p            : in  std_logic;
  refclk_n            : in  std_logic;
  refclk              : out std_logic;
  txclk322            : in  std_logic;
  clk156              : out std_logic;
  dclk                : out std_logic;    
  qplllock            : in  std_logic;
  areset_clk156       : out std_logic;
  gttxreset           : out std_logic;
  gtrxreset           : out std_logic;
  txuserrdy           : out std_logic;
  txusrclk            : out std_logic;
  txusrclk2           : out std_logic;
        
  qpllreset           : out std_logic;
  reset_counter_done  : out std_logic
);
end entity ten_gig_eth_pcs_pma_0_shared_clock_and_reset;

architecture wrapper of ten_gig_eth_pcs_pma_0_shared_clock_and_reset is

    attribute DowngradeIPIdentifiedWarnings: string;

    attribute DowngradeIPIdentifiedWarnings of wrapper : architecture is "yes";

  component ten_gig_eth_pcs_pma_0_ff_synchronizer_rst2  
  generic
  (
    C_NUM_SYNC_REGS : integer := 3;
    C_RVAL : std_logic := '0'
  );
  port 
  (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic;
    data_out : out std_logic
  );
  end component;
  
  signal clk156_buf : std_logic;
  signal clk156_int : std_logic;
  signal refclk_i : std_logic;
  signal txusrclk_i : std_logic;
  signal txusrclk2_i : std_logic;
  signal gttxreset_i : std_logic;
  signal reset_i : std_logic;

  signal areset_clk156_i : std_logic;

  signal qplllock_txusrclk2_rst : std_logic;
  signal qplllock_txusrclk2_i : std_logic;

  signal gttxreset_txusrclk2_i : std_logic;
  
  signal reset_counter  : std_logic_vector(7 downto 0) := X"00";
  signal reset_pulse : std_logic_vector(3 downto 0) := "1110";
  
  
begin
  
  reset_counter_done <= reset_counter(7);

  ibufds_inst : IBUFDS_GTE2   
  port map
  (
     O     => refclk_i,
     ODIV2 => open,
     CEB   => '0',
     I     => refclk_p,
     IB    => refclk_n
  );
  
  refclk <= refclk_i;

  
  tx322clk_bufg_i : BUFG 
  port map
  (
     I => txclk322,
     O => txusrclk_i
  );

  clk156_bufg_i : BUFG
    port map
    (
      I  =>      refclk_i,
      O  =>      clk156_int 
    );

  dclk <= clk156_int;
      
      

    
  clk156              <= clk156_int;
  txusrclk2           <= txusrclk_i;
  txusrclk2_i         <= txusrclk_i;  
  txusrclk            <= txusrclk_i;  
  reset_i             <= not qplllock ;  
  areset_clk156       <= areset_clk156_i;  
  
        
  -- Asynch reset synchronizers...
      
  areset_clk156_sync_i : ten_gig_eth_pcs_pma_0_ff_synchronizer_rst2 
    generic map(
      C_NUM_SYNC_REGS => 4,
      C_RVAL => '1') 
    port map(
      clk      => clk156_int,
      rst      => areset,
      data_in  => '0',
      data_out => areset_clk156_i
    );

  qplllock_txusrclk2_rst <= not(qplllock);
  
  qplllock_txusrclk2_sync_i : ten_gig_eth_pcs_pma_0_ff_synchronizer_rst2 
    generic map(
      C_NUM_SYNC_REGS => 4,
      C_RVAL => '0') 
    port map(
      clk      => txusrclk2_i,
      rst      => qplllock_txusrclk2_rst,
      data_in  => '1',
      data_out => qplllock_txusrclk2_i
    );

  gttxreset_txusrclk2_sync_i : ten_gig_eth_pcs_pma_0_ff_synchronizer_rst2 
    generic map(
      C_NUM_SYNC_REGS => 4,
      C_RVAL => '1') 
    port map(
      clk      => txusrclk2_i,
      rst      => gttxreset_i,
      data_in  => '0',
      data_out => gttxreset_txusrclk2_i
    );
    
  
  -- Hold off release the GT resets until 500ns after configuration.
  -- 128 ticks at 6.4ns period will be >> 500 ns.

  reset_proc1: process (clk156_int)
  begin
    if(clk156_int'event and clk156_int = '1') then
       if(reset_counter(7) = '0')  then
          reset_counter    <= reset_counter + 1;
       else
          reset_counter    <= reset_counter;
       end if;
    end if;
  end process;

      
  reset_proc2: process (clk156_int)
  begin
     if(clk156_int'event and clk156_int = '1') then
       if(areset_clk156_i = '1') then
          reset_pulse      <=  "1110"; 
       elsif(reset_counter(7) = '1') then
          reset_pulse(3)            <=  '0';
          reset_pulse(2 downto 0)   <=  reset_pulse(3 downto 1);
       end if;
     end if;
  end process;

  gttxreset_i <=     reset_pulse(0);
  gttxreset   <=     gttxreset_i;
  gtrxreset   <=     reset_pulse(0);
  qpllreset   <=     reset_pulse(0);
   
  reset_proc5 : process (txusrclk2_i, gttxreset_txusrclk2_i)
  begin
     if(gttxreset_txusrclk2_i = '1') then
       txuserrdy    <= '0';
     elsif(txusrclk2_i'event and txusrclk2_i = '1') then
       txuserrdy    <=  qplllock_txusrclk2_i;
     end if;
  end process;

end wrapper;



