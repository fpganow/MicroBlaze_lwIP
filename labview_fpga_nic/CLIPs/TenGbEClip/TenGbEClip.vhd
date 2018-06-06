-------------------------------------------------------------------------------
--
-- File: TenGbEClip.vhd
-- Author: National Instruments
-- Original Project: NI PXIe-6592R 10 Gigabit Ethernet Example
-- Date: 11/18/2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright National Instruments Corporation
-- All Rights Reserved
-- National Instruments Internal Information
-------------------------------------------------------------------------------
--
-- Purpose:
--
-- This is the top level VHDL file for the CLIP that provides diagrammatic
-- passthru of the single ended GPIOs and other signals and also hooks up the
-- PCS/PMA IP from Xilinx to the OpenCores.org XGE MAC
--
-- When configuring the LabVIEW FPGA Target, this CLIP requires the following
-- settings in the Clocking & Routing Property section of the IO Socket 
-- property page:
--
-- MGT_RefClk0: Enabled, 156.25 MHz
-- MGT_RefClk1: Disabled
-- MGT_RefClk2: Disabled 
-- PORT 0, PORT 1: Enabled, TX and RX
--
-- Changes to the Clocking & Routing property section that differ from this
-- default will require changes to the CLIP for successful compiles.
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;

--synthesis translate_off
library unisim;
  use unisim.vcomponents.all;
--synthesis translate_on

entity TenGbEClip is
  port(
    -------------------------------------------------------------------------------------
    -- Front-panel facing signals and Required signals
    -------------------------------------------------------------------------------------
    
    -- IO Socket I/O (Single-ended GPIO connector interface signals)
    PFI0_GPIO_In                   : in    std_logic;
    PFI0_GPIO_Out                  : out   std_logic;
    PFI0_GPIO_OutEnable_n          : out   std_logic;
    PFI1_GPIO_In                   : in    std_logic;
    PFI1_GPIO_Out                  : out   std_logic;
    PFI1_GPIO_OutEnable_n          : out   std_logic;
    PFI2_GPIO_In                   : in    std_logic;
    PFI2_GPIO_Out                  : out   std_logic;
    PFI2_GPIO_OutEnable_n          : out   std_logic;
    PFI3_GPIO_In                   : in    std_logic;
    PFI3_GPIO_Out                  : out   std_logic;
    PFI3_GPIO_OutEnable_n          : out   std_logic;

    -------------------------------------------------------------------------------------
    -- Socketed CLIP Signals
    -------------------------------------------------------------------------------------
    Port0_RX_n                     : in    std_logic;
    Port0_RX_p                     : in    std_logic;
    Port0_TX_n                     : out   std_logic;
    Port0_TX_p                     : out   std_logic;
    Port0_Mod_Abs                  : in    std_logic; --aka MODDEF0, represents GND, grounded by the module to indicate module present
    Port0_RS0                      : out   std_logic; --RX Rate Select, default 1 for rates greater than 4.25 Gbps
    Port0_RS1                      : out   std_logic; --TX Rate Select, default 1 for rates greater than 4.25 Gbps
    Port0_Rx_LOS                   : in    std_logic; --Loss of signal, when high indicates received optical power below worst-case
    Port0_Tx_Disable               : out   std_logic; --Optical output disabled when high
    Port0_Tx_Fault                 : in    std_logic; --TX fault indicator, unconnected in 10GbE IP core
    Port0_SCL                      : inout std_logic; --aka MODDEF1, clock line of serial interface
    Port0_SDA                      : inout std_logic; --aka MODDEF2, data line of serial interface
    
    Port1_RX_n                     : in    std_logic;
    Port1_RX_p                     : in    std_logic;
    Port1_TX_n                     : out   std_logic;
    Port1_TX_p                     : out   std_logic;
    Port1_Mod_Abs                  : in    std_logic;
    Port1_RS0                      : out   std_logic;
    Port1_RS1                      : out   std_logic;
    Port1_Rx_LOS                   : in    std_logic;
    Port1_Tx_Disable               : out   std_logic;
    Port1_Tx_Fault                 : in    std_logic;
    Port1_SCL                      : inout std_logic;
    Port1_SDA                      : inout std_logic;   
    
    Port2_RX_n                     : in    std_logic;
    Port2_RX_p                     : in    std_logic;
    Port2_TX_n                     : out   std_logic;
    Port2_TX_p                     : out   std_logic;
    Port2_Mod_Abs                  : in    std_logic;
    Port2_RS0                      : out   std_logic;
    Port2_RS1                      : out   std_logic;
    Port2_Rx_LOS                   : in    std_logic;
    Port2_Tx_Disable               : out   std_logic;
    Port2_Tx_Fault                 : in    std_logic;
    Port2_SCL                      : inout std_logic;
    Port2_SDA                      : inout std_logic;
    
    Port3_RX_n                     : in    std_logic;
    Port3_RX_p                     : in    std_logic;
    Port3_TX_n                     : out   std_logic;
    Port3_TX_p                     : out   std_logic;   
    Port3_Mod_Abs                  : in    std_logic;
    Port3_RS0                      : out   std_logic;
    Port3_RS1                      : out   std_logic;
    Port3_Rx_LOS                   : in    std_logic;
    Port3_Tx_Disable               : out   std_logic;
    Port3_Tx_Fault                 : in    std_logic;
    Port3_SCL                      : inout std_logic;
    Port3_SDA                      : inout std_logic;       
    
    -- These signals enable/disable the cable power supply for the front
    -- panel connectors and report the status of this supply
    sPort0_EnablePower             : out   std_logic; --3.3V power applied
    sPort0_PowerGood               : in    std_logic; --Recevier, transmitter power supply is on (VR ON, VT ON)
    sPort1_EnablePower             : out   std_logic;
    sPort1_PowerGood               : in    std_logic;
    sPort2_EnablePower             : out   std_logic;
    sPort2_PowerGood               : in    std_logic;
    sPort3_EnablePower             : out   std_logic;
    sPort3_PowerGood               : in    std_logic;   
    
    -- IO Socket I/O (MGT reference clock differential pair pads)
    MGT_RefClk0_p                  : in    std_logic;
    MGT_RefClk0_n                  : in    std_logic;
    MGT_RefClk1_p                  : in    std_logic;
    MGT_RefClk1_n                  : in    std_logic;
    MGT_RefClk2_p                  : in    std_logic;
    MGT_RefClk2_n                  : in    std_logic;

    -- These two signals indicate the health of the clocks that are generated for use
    -- at the MgtRefClkX clocks above.  There is one PLL that recovers a clock that feeds
    -- both of these clocks.  The Valid signal includes additional logic from
    -- configuration of the FPGA Target and Si5368 outputs. @ToDo more docs.
    MGT_RefClks_ExtPllLocked       : in    std_logic;
    MGT_RefClks_Valid              : in    std_logic;   
    
    -- The CLIP may recover a clock and export it to the onboard clock routing circuitry.
    ExportedUserReferenceClk       : out   std_logic;

    -- These are outputs that the CLIP may assert to drive the Active and Access LEDs
    -- on the front panel.  The fixed logic may pre-empt the CLIP's access to these LEDs
    -- to show general purpose error conditions, temperature faults, etc...
    -- (clk156 domain)
    LED_ActiveRed                  : out   std_logic;
    LED_ActiveGreen                : out   std_logic;

    -- 40 MHz clock for the socket
    SocketClk40                    : in    std_logic;
    
    -- These clocks can be provided by the CLIP that the Fixed Logic may monitor them
    -- via frequency counters, etc... and provide status to the host methods
    DebugClks                      : out   std_logic_vector(3 downto 0);

    -- The fixed logic has a POSC (power on self configuration) state machine that
    -- configures various subsystems on the board.  This line will assert high
    -- when the fixed logic is done configuring the various chips, etc...
    sFrontEndConfigurationDone     : in    std_logic;
    
    -- These signals provide a handshaking mechanism for triggering a
    -- reconfiguration of the board while powered on.
    -- Prepare tells the CLIP to shut down, and when it is fully shut down it sends Ready.
    -- This is unused but required in the design.
    sFrontEndConfigurationPrepare  : in    std_logic;
    sFrontEndConfigurationReady    : out   std_logic;
    ---------------------------------------------------------------------------
    -- Required Clock
    -- This signal is present to facilitate requiring a clock to be a specific
    -- clock from the LabVIEW environment. SocketClk40 is the same signal as
    -- 40 MHz Onboard Clock, but we need to have this metadata available in the
    -- CLIP XML to force this signal to be in this particular clock domain.
    OnboardClk40ToClip          : in  std_logic;
    -------------------------------------------------------------------------------------
    -- Diagram facing signals
    -- This is the collection of signals that appears in LabVIEW FPGA.
    -- LabVIEW FPGA signals must use one of the following signal directions:  {in, out}
    -- LabVIEW FPGA signals must use one of the following data types:
    --          std_logic
    --          std_logic_vector(7 downto 0)
    --          std_logic_vector(15 downto 0)
    --          std_logic_vector(31 downto 0)
    --

    -- Asynchronous reset signal from the LabVIEW FPGA environment.
    -- This signal *must* be present in the port interface for all IO Socket CLIPs.
    -- You should reset your CLIP logic whenever this signal is logic high.
    aReset                  : in  std_logic;

    -- Combined transceiver reset-done indication (in core_clk156_out domain)
    -- Used for debug, what causes block lock to fail.
    -- Pg 127 when multi-cores used, synchronized ResetDone signals from each core should be
    -- included in the combined signal.
    cResetDone              : out std_logic;

    -- Indication that 500 ns have passed after configuration or 'master' reset
    -- (in refclk domain)
    cResetCounterDoneOut   : out std_logic;
    
    -- Core Clk156 from the design out to the diagram for AXI4-Stream use
    CoreClk156Out           : out std_logic;
    
    -- AXI Streaming TX Interface (in tx_clk0 domain)
    cTxTDataPort0           : in  std_logic_vector(63 downto 0);    
    cTxTValidPort0          : in  std_logic;
    cTxTLastPort0           : in  std_logic;
    cTxTUserPort0           : in  std_logic_vector(0 downto 0);
    cTxTKeepPort0           : in  std_logic_vector(7 downto 0);
    cTxTReadyPort0          : out std_logic;

    cTxTDataPort1           : in  std_logic_vector(63 downto 0);
    cTxTValidPort1          : in  std_logic;
    cTxTLastPort1           : in  std_logic;
    cTxTUserPort1           : in  std_logic_vector(0 downto 0);
    cTxTKeepPort1           : in  std_logic_vector(7 downto 0);
    cTxTReadyPort1          : out std_logic;

    -- AXI Streaming RX Interface (in rx_clk0 domain)
    cRxTDataPort0           : out std_logic_vector(63 downto 0);
    cRxTKeepPort0           : out std_logic_vector(7 downto 0);
    cRxTValidPort0          : out std_logic;
    cRxTLastPort0           : out std_logic;
    cRxTUserPort0           : out std_logic;

    cRxTDataPort1           : out std_logic_vector(63 downto 0);    
    cRxTKeepPort1           : out std_logic_vector(7 downto 0);
    cRxTValidPort1          : out std_logic;
    cRxTLastPort1           : out std_logic;
    cRxTUserPort1           : out std_logic;

    -- Management Interface Port (AXI4-Lite) (in s_axi_aclk domain)
    s_axi_aclk              : in  std_logic; -- 10-300 MHz, leaving it as an input to the CLIP for the user to select their own clock
    sManageAWAddrPort0      : in  std_logic_vector(31 downto 0);
    sManageAWValidPort0     : in  std_logic;
    sManageAWReadyPort0     : out std_logic;
    sManageWDataPort0       : in  std_logic_vector(31 downto 0);
    sManageWValidPort0      : in  std_logic;
    sManageWStrbPort0       : in  std_logic_vector(3 downto 0); -- Required for AXI4-Lite LVFPGA interface
    sManageWReadyPort0      : out std_logic;
    sManageBRespPort0       : out std_logic_vector(1 downto 0);
    sManageBValidPort0      : out std_logic;
    sManageBReadyPort0      : in  std_logic;
    sManageARAddrPort0      : in  std_logic_vector(31 downto 0);
    sManageARValidPort0     : in  std_logic;
    sManageARReadyPort0     : out std_logic;
    sManageRDataPort0       : out std_logic_vector(31 downto 0);
    sManageRRespPort0       : out std_logic_vector(1 downto 0);
    sManageRValidPort0      : out std_logic;
    sManageRReadyPort0      : in  std_logic;
    
    sManageAWAddrPort1      : in  std_logic_vector(31 downto 0);
    sManageAWValidPort1     : in  std_logic;
    sManageAWReadyPort1     : out std_logic;
    sManageWDataPort1       : in  std_logic_vector(31 downto 0);
    sManageWValidPort1      : in  std_logic;
    sManageWReadyPort1      : out std_logic;
    sManageWStrbPort1       : in  std_logic_vector(3 downto 0); -- Required for AXI4-Lite LVFPGA interface
    sManageBRespPort1       : out std_logic_vector(1 downto 0);
    sManageBValidPort1      : out std_logic;
    sManageBReadyPort1      : in  std_logic;
    sManageARAddrPort1      : in  std_logic_vector(31 downto 0);
    sManageARValidPort1     : in  std_logic;
    sManageARReadyPort1     : out std_logic;
    sManageRDataPort1       : out std_logic_vector(31 downto 0);
    sManageRRespPort1       : out std_logic_vector(1 downto 0);
    sManageRValidPort1      : out std_logic;
    sManageRReadyPort1      : in  std_logic;
    
    -- Core Status to indicate Block Lock on bit 0 (not listed in a clock domain)
    aBlockLockPort0          : out std_logic;
    aBlockLockPort1          : out std_logic;
    
    -- Dynamic GPIO Lines
    PFI0_In                 : out std_logic;
    PFI0_Out                : in  std_logic;
    PFI0_OutEnable          : in  std_logic;
    PFI1_In                 : out std_logic;
    PFI1_Out                : in  std_logic;
    PFI1_OutEnable          : in  std_logic;
    PFI2_In                 : out std_logic;
    PFI2_Out                : in  std_logic;
    PFI2_OutEnable          : in  std_logic;
    PFI3_In                 : out std_logic;
    PFI3_Out                : in  std_logic;
    PFI3_OutEnable          : in  std_logic;

    -- Mgt RefClk status signals
    MgtRefClks_Locked       : out std_logic;
    MgtRefClks_Valid        : out std_logic;

    -- FPGA POSC status signal
    POSC_Complete           : out std_logic;
    
    -- Power Good status signals
    sPort0_Power_Good       : out std_logic;
    sPort1_Power_Good       : out std_logic;
    
    -- Signal Detect status signals
    signal_detect_Port0     : out std_logic;
    signal_detect_Port1     : out std_logic;
    
    -- QPLL lock signal to let management interface know when to begin
    PllLocked               : out std_logic
    );
    
end TenGbEClip;

architecture rtl of TenGbEClip is

  component ten_gig_eth_pcs_pma_0
    port (
      rxrecclk_out        : out std_logic;
      coreclk             : in  std_logic;
      dclk                : in  std_logic;
      txusrclk            : in  std_logic;
      txusrclk2           : in  std_logic;
      txoutclk            : out std_logic;
      areset              : in  std_logic;
      areset_coreclk      : in  std_logic;
      gttxreset           : in  std_logic;
      gtrxreset           : in  std_logic;
      txuserrdy           : in  std_logic;
      qplllock            : in  std_logic;
      qplloutclk          : in  std_logic;
      qplloutrefclk       : in  std_logic;
      reset_counter_done  : in  std_logic;
      xgmii_txd           : in  std_logic_vector(63 downto 0);
      xgmii_txc           : in  std_logic_vector(7 downto 0);
      xgmii_rxd           : out std_logic_vector(63 downto 0);
      xgmii_rxc           : out std_logic_vector(7 downto 0);
      txp                 : out std_logic;
      txn                 : out std_logic;
      rxp                 : in  std_logic;
      rxn                 : in  std_logic;
      sim_speedup_control : in  std_logic;
      mdc                 : in  std_logic;
      mdio_in             : in  std_logic;
      mdio_out            : out std_logic;
      mdio_tri            : out std_logic;
      prtad               : in  std_logic_vector(4 downto 0);
      core_status         : out std_logic_vector(7 downto 0);
      tx_resetdone        : out std_logic;
      rx_resetdone        : out std_logic;
      signal_detect       : in  std_logic;
      tx_fault            : in  std_logic;
      drp_req             : out std_logic;
      drp_gnt             : in  std_logic;
      drp_den_o           : out std_logic;
      drp_dwe_o           : out std_logic;
      drp_daddr_o         : out std_logic_vector(15 downto 0);
      drp_di_o            : out std_logic_vector(15 downto 0);
      drp_drdy_i          : in  std_logic;
      drp_drpdo_i         : in  std_logic_vector(15 downto 0);
      drp_den_i           : in  std_logic;
      drp_dwe_i           : in  std_logic;
      drp_daddr_i         : in  std_logic_vector(15 downto 0);
      drp_di_i            : in  std_logic_vector(15 downto 0);
      drp_drdy_o          : out std_logic;
      drp_drpdo_o         : out std_logic_vector(15 downto 0);
      pma_pmd_type        : in  std_logic_vector(2 downto 0);
      tx_disable          : out std_logic;
      gt0_eyescanreset    : in  std_logic;
      gt0_eyescandataerror: out std_logic;
      gt0_txbufstatus     : out std_logic_vector(1 downto 0);
      gt0_rxbufstatus     : out std_logic_vector(2 downto 0);
      gt0_eyescantrigger  : in  std_logic;
      gt0_rxcdrhold       : in  std_logic;
      gt0_txprbsforceerr  : in  std_logic;
      gt0_txpolarity      : in  std_logic;
      gt0_rxpolarity      : in  std_logic;
      gt0_rxprbserr       : out std_logic;
      gt0_txpmareset      : in  std_logic;
      gt0_rxpmareset      : in  std_logic;
      gt0_txresetdone     : out std_logic;
      gt0_rxresetdone     : out std_logic;
      gt0_rxdfelpmreset   : in  std_logic;
      gt0_rxlpmen         : in  std_logic;
      gt0_dmonitorout     : out std_logic_vector(7 downto 0);
      gt0_rxrate          : in  std_logic_vector(2 downto 0);
      gt0_txprecursor     : in  std_logic_vector(4 downto 0);
      gt0_txpostcursor    : in  std_logic_vector(4 downto 0);
      gt0_txdiffctrl      : in  std_logic_vector(3 downto 0)
      );
  end component;

  component xge_mac_wrapper
    port(
      -- XGMII
      xgmii_txd      : out std_logic_vector(63 downto 0);
      xgmii_txc      : out std_logic_vector(7 downto 0);
      xgmii_rxd      : in  std_logic_vector(63 downto 0);
      xgmii_rxc      : in  std_logic_vector(7 downto 0);
      -- MDIO
      mdc            : out std_logic;
      mdio_in        : out std_logic;
      mdio_out       : in  std_logic;
      -- Client FIFO Interfaces
      sys_clk        : in  std_logic;
      reset          : in  std_logic;
      rx_axis_tdata  : out std_logic_vector(63 downto 0);
      rx_axis_tuser  : out std_logic_vector(3 downto 0);
      rx_axis_tlast  : out std_logic;
      rx_axis_tvalid : out std_logic;
      rx_axis_tready : in  std_logic;
      tx_axis_tdata  : in  std_logic_vector(63 downto 0);
      tx_axis_tuser  : in  std_logic_vector(3 downto 0);
      tx_axis_tlast  : in  std_logic;
      tx_axis_tvalid : in  std_logic;
      tx_axis_tready : out std_logic);
  end component;

  component axis_tuser_to_tkeep
    port (
      tuser : in  std_logic_vector(2 downto 0);
      tkeep : out std_logic_vector(7 downto 0));
  end component;

  component axis_tkeep_to_tuser
    port (
      tuser : out std_logic_vector(2 downto 0);
      tkeep : in  std_logic_vector(7 downto 0));
  end component;

  -- relay signal for putting together tuser bits
  signal tx_axis_tuser_port0,
         tx_axis_tuser_port1  : std_logic_vector(3 downto 0);
  -- translation signal for converting TKeep byte enables to
  -- xge_mac TUser byte counts
  signal cTxTKeepToTUserPort0,
         cTxTKeepToTUserPort1 : std_logic_vector(2 downto 0);
  -- translation signal for converting TUser byte counts to
  -- TKeep byte enables
  signal cRxTUserToTKeepPort0,
         cRxTUserToTKeepPort1 : std_logic_vector(3 downto 0);
----------------------------------------------------------------------------------------

  -- various signals used in CLIP
  signal cLED_ActiveGreen : std_logic;
  signal cLED_ActiveRed : std_logic;
  signal areset_coreclk_i: std_logic;
  signal aReset_n: std_logic;
  signal coreclk_i: std_logic;
  signal CoreStatusPort0_i: std_logic_vector(7 downto 0);
  signal CoreStatusPort1_i: std_logic_vector(7 downto 0);
  signal dclk_i: std_logic;
  signal ddrp_core_daddr_i_Port0: std_logic_vector(15 downto 0);
  signal ddrp_core_daddr_i_Port1: std_logic_vector(15 downto 0);
  signal ddrp_core_den_i_Port0: std_logic;
  signal ddrp_core_den_i_Port1: std_logic;
  signal ddrp_core_di_i_Port0: std_logic_vector(15 downto 0);
  signal ddrp_core_di_i_Port1: std_logic_vector(15 downto 0);
  signal ddrp_core_drdy_o_Port0: std_logic;
  signal ddrp_core_drdy_o_Port1: std_logic;
  signal ddrp_core_drpdo_o_Port0: std_logic_vector(15 downto 0);
  signal ddrp_core_drpdo_o_Port1: std_logic_vector(15 downto 0);
  signal ddrp_core_dwe_i_Port0: std_logic;
  signal ddrp_core_dwe_i_Port1: std_logic;
  signal ddrp_core_gnt_Port0: std_logic;
  signal ddrp_core_gnt_Port1: std_logic;
  signal ddrp_core_req_Port0: std_logic;
  signal ddrp_core_req_Port1: std_logic;
  signal ddrp_daddr_i_Port0: std_logic_vector(15 downto 0);
  signal ddrp_daddr_i_Port1: std_logic_vector(15 downto 0);
  signal ddrp_den_i_Port0: std_logic;
  signal ddrp_den_i_Port1: std_logic;
  signal ddrp_di_i_Port0: std_logic_vector(15 downto 0);
  signal ddrp_di_i_Port1: std_logic_vector(15 downto 0);
  signal ddrp_drdy_o_Port0: std_logic;
  signal ddrp_drdy_o_Port1: std_logic;
  signal ddrp_drpdo_o_Port0: std_logic_vector(15 downto 0);
  signal ddrp_drpdo_o_Port1: std_logic_vector(15 downto 0);
  signal ddrp_dwe_i_Port0: std_logic;
  signal ddrp_dwe_i_Port1: std_logic;
  signal gtrxreset_i: std_logic;
  signal gttxreset_i: std_logic;
  signal MDCPort0: std_logic;
  signal MDCPort1: std_logic;
  signal mMDIOInMACOutPHYPort0: std_logic;
  signal mMDIOInMACOutPHYPort1: std_logic;
  signal mMDIOInPHYOutMACPort0: std_logic;
  signal mMDIOInPHYOutMACPort1: std_logic;
  signal qplllock_i: std_logic;
  signal qplloutclk_i: std_logic;
  signal qplloutrefclk_i: std_logic;
  signal qpllreset_i: std_logic;
  signal refclk_i: std_logic;
  signal reset_counter_done_i: std_logic;
  signal cRxTValidPort0_i: std_logic;
  signal cRxTValidPort1_i: std_logic;
  signal cRxTLastPort0_i: std_logic;
  signal cRxTLastPort1_i: std_logic;
  signal cRxResetDonePort0_i: std_logic;
  signal cRxResetDonePort1_i: std_logic;
  signal signal_detect_Port0_i: std_logic;
  signal signal_detect_Port1_i: std_logic;
  signal cTxTReadyPort0_i: std_logic;
  signal cTxTReadyPort1_i: std_logic;
  signal cTxResetDonePort0_i: std_logic;
  signal cTxResetDonePort1_i: std_logic;
  signal txoutclk_i: std_logic;
  signal txuserrdy_i: std_logic;
  signal txusrclk2_i: std_logic;
  signal txusrclk_i: std_logic;
  signal xgmii_txd_phy_mac_Port0: std_logic_vector(63 downto 0);
  signal xgmii_txc_phy_mac_Port0: std_logic_vector(7 downto 0);
  signal xgmii_rxd_mac_phy_Port0: std_logic_vector(63 downto 0);
  signal xgmii_rxc_mac_phy_Port0: std_logic_vector(7 downto 0);
  signal xgmii_txd_phy_mac_Port1: std_logic_vector(63 downto 0);
  signal xgmii_txc_phy_mac_Port1: std_logic_vector(7 downto 0);
  signal xgmii_rxd_mac_phy_Port1: std_logic_vector(63 downto 0);
  signal xgmii_rxc_mac_phy_Port1: std_logic_vector(7 downto 0);

  signal gt0_eyescanreset     : std_logic := '0';
  signal gt0_eyescantrigger   : std_logic := '0';
  signal gt0_rxcdrhold        : std_logic := '0';
  signal gt0_txprbsforceerr   : std_logic := '0';
  signal gt0_txpolarity       : std_logic := '0';
  signal gt0_rxpolarity       : std_logic := '0';
  signal gt0_rxrate           : std_logic_vector(2 downto 0) := "000";
  signal gt0_txprecursor      : std_logic_vector(4 downto 0) := "00000";
  signal gt0_txpostcursor     : std_logic_vector(4 downto 0) := "00000";
  signal gt0_txdiffctrl       : std_logic_vector(3 downto 0) := "1110";
  signal gt0_eyescandataerror : std_logic;
  signal gt0_txbufstatus      : std_logic_vector(1 downto 0);
  signal gt0_rxbufstatus      : std_logic_vector(2 downto 0);
  signal gt0_txpmareset       : std_logic := '0';
  signal gt0_rxpmareset       : std_logic := '0';
  signal gt0_rxpmaresetdone   : std_logic;
  signal gt0_rxdfelpmreset    : std_logic := '0';
  signal gt0_rxlpmen          : std_logic := '0';
  signal gt0_rxprbserr        : std_logic;
  signal gt0_dmonitorout      : std_logic_vector(7 downto 0);
  
begin
  aReset_n <= not aReset;

  -- cResetDone is a combination for all cores
  ResetDone : process (coreclk_i, aReset)
  begin
    if aReset = '1' then
        cResetDone <= '0';
    elsif rising_edge(coreclk_i) then
        cResetDone <= cTxResetDonePort0_i and cRxResetDonePort0_i and cTxResetDonePort1_i and cRxResetDonePort1_i;
    end if;
  end process; --ResetDone
        
  -- From example, routed out of the CLIP for diagram use
  -- re = refclk domain, 156.25 MHz from Si5368
  cResetCounterDoneOut <= reset_counter_done_i;

  -- Drive clock derived from Si5368 to the diagram
  CoreClk156Out <= coreclk_i;
  
  -- Internal signals driven out to top level
  cRxTLastPort0  <= cRxTLastPort0_i;
  cRxTLastPort1  <= cRxTLastPort1_i;
  cRxTValidPort0 <= cRxTValidPort0_i;
  cRxTValidPort1 <= cRxTValidPort1_i;
  cTxTReadyPort0 <= cTxTReadyPort0_i;
  cTxTReadyPort1 <= cTxTReadyPort1_i;



  -- Port 0 and Port 1 DRP tied input to output, accessing PHY registers through MDIO on MAC IP Core
  ddrp_core_gnt_Port0     <= ddrp_core_req_Port0;
  ddrp_den_i_Port0        <= ddrp_core_den_i_Port0;
  ddrp_dwe_i_Port0        <= ddrp_core_dwe_i_Port0;
  ddrp_daddr_i_Port0      <= ddrp_core_daddr_i_Port0;
  ddrp_di_i_Port0         <= ddrp_core_di_i_Port0;
  ddrp_core_drdy_o_Port0  <= ddrp_drdy_o_Port0;
  ddrp_core_drpdo_o_Port0 <= ddrp_drpdo_o_Port0;
  
  ddrp_core_gnt_Port1     <= ddrp_core_req_Port1;
  ddrp_den_i_Port1        <= ddrp_core_den_i_Port1;
  ddrp_dwe_i_Port1        <= ddrp_core_dwe_i_Port1;
  ddrp_daddr_i_Port1      <= ddrp_core_daddr_i_Port1;
  ddrp_di_i_Port1         <= ddrp_core_di_i_Port1;
  ddrp_core_drdy_o_Port1  <= ddrp_drdy_o_Port1;
  ddrp_core_drpdo_o_Port1 <= ddrp_drpdo_o_Port1;

  -- Begin TenGbEBlock which contains instantiated cores.
  TenGbEBlock: block
  begin --block TenGbEBlock
---------------------------------------------------------------------------
-- Instantiate the clock and reset modules for PCS/PMA Core
---------------------------------------------------------------------------

--Note: refclk_i goes to GT_COMMON
pcs_pma_shared_clock_reset_i: entity work.ten_gig_eth_pcs_pma_0_shared_clock_and_reset (wrapper)
  port map (
    areset             => aReset,                -- in  std_logic
    refclk_p           => MGT_RefClk0_p,         -- in  std_logic
    refclk_n           => MGT_RefClk0_n,         -- in  std_logic
    refclk             => refclk_i,              -- out std_logic
    txclk322           => txoutclk_i,            -- in  std_logic
    clk156             => coreclk_i,             -- out std_logic
    dclk               => dclk_i,                -- out std_logic
    qplllock           => qplllock_i,            -- in  std_logic
    areset_clk156      => areset_coreclk_i,       -- out std_logic
    gttxreset          => gttxreset_i,           -- out std_logic
    gtrxreset          => gtrxreset_i,           -- out std_logic
    txuserrdy          => txuserrdy_i,           -- out std_logic
    txusrclk           => txusrclk_i,            -- out std_logic
    txusrclk2          => txusrclk2_i,           -- out std_logic
    qpllreset          => qpllreset_i,           -- out std_logic
    reset_counter_done => reset_counter_done_i); -- out std_logic

ten_gig_eth_pcs_pma_gt_common_P0_1: entity work.ten_gig_eth_pcs_pma_0_gt_common (wrapper)
  generic map (
    WRAPPER_SIM_GTRESET_SPEEDUP => "TRUE")  -- in  string := "false"
  port map (
    refclk        => refclk_i,         -- in  std_logic
    qpllreset     => qpllreset_i,      -- in  std_logic
    qplllock      => qplllock_i,       -- out std_logic
    qplloutclk    => qplloutclk_i,     -- out std_logic
    qplloutrefclk => qplloutrefclk_i); -- out std_logic
    
  ---------------------------------------------------------------------------
  -- Module Instantiations
  ---------------------------------------------------------------------------
    -- ptrad tied to 0's since MDIO is only connected to one PHY, no other port addresses needed
 ten_gig_eth_pcs_pma_Port0_i: ten_gig_eth_pcs_pma_0
   port map (
     gt0_eyescanreset     => gt0_eyescanreset,
     gt0_eyescandataerror => open,
     gt0_txbufstatus      => open,
     gt0_rxbufstatus      => open,
     gt0_eyescantrigger   => gt0_eyescantrigger,
     gt0_rxcdrhold        => gt0_rxcdrhold,
     gt0_txprbsforceerr   => gt0_txprbsforceerr,
     gt0_txpolarity       => gt0_txpolarity,
     gt0_rxpolarity       => gt0_rxpolarity,
     gt0_rxprbserr        => open,
     gt0_txpmareset       => gt0_txpmareset,
     gt0_rxpmareset       => gt0_rxpmareset,
     gt0_txresetdone      => open,
     gt0_rxresetdone      => open,
     gt0_rxdfelpmreset    => gt0_rxdfelpmreset,
     gt0_rxlpmen          => gt0_rxlpmen,
     gt0_dmonitorout      => open,
     gt0_rxrate           => gt0_rxrate,
     gt0_txprecursor      => gt0_txprecursor,
     gt0_txpostcursor     => gt0_txpostcursor,
     gt0_txdiffctrl       => gt0_txdiffctrl,
     sim_speedup_control=> '1',
     rxrecclk_out       => open,
     coreclk            => coreclk_i,                 -- in  std_logic
     dclk               => dclk_i,                   -- in  std_logic
     txusrclk           => txusrclk_i,               -- in  std_logic
     txusrclk2          => txusrclk2_i,              -- in  std_logic
     txoutclk           => txoutclk_i,               -- out std_logic
     areset             => aReset,                   -- in  std_logic
     areset_coreclk     => areset_coreclk_i,          -- in  std_logic
     gttxreset          => gttxreset_i,              -- in  std_logic
     gtrxreset          => gtrxreset_i,              -- in  std_logic
     txuserrdy          => txuserrdy_i,              -- in  std_logic
     qplllock           => qplllock_i,               -- in  std_logic
     qplloutclk         => qplloutclk_i,             -- in  std_logic
     qplloutrefclk      => qplloutrefclk_i,          -- in  std_logic
     reset_counter_done => reset_counter_done_i,     -- in  std_logic
     xgmii_txd          => xgmii_txd_phy_mac_Port0,      -- in  std_logic_vector(63 downto 0)
     xgmii_txc          => xgmii_txc_phy_mac_Port0,      -- in  std_logic_vector(7 downto 0)
     xgmii_rxd          => xgmii_rxd_mac_phy_Port0,      -- out std_logic_vector(63 downto 0)
     xgmii_rxc          => xgmii_rxc_mac_phy_Port0,      -- out std_logic_vector(7 downto 0)
     txp                => Port0_TX_p,               -- out std_logic
     txn                => Port0_TX_n,               -- out std_logic
     rxp                => Port0_RX_p,               -- in  std_logic
     rxn                => Port0_RX_n,               -- in  std_logic
     mdc                => MDCPort0,                 -- in  std_logic
     mdio_in            => mMDIOInPHYOutMACPort0,    -- in  std_logic
     mdio_out           => mMDIOInMACOutPHYPort0,    -- out std_logic
     mdio_tri           => open,                     -- out std_logic
     prtad              => "00000",                  -- in  std_logic_vector(4 downto 0)
     core_status        => CoreStatusPort0_i,        -- out std_logic_vector(7 downto 0)
     tx_resetdone       => cTxResetDonePort0_i,      -- out std_logic
     rx_resetdone       => cRxResetDonePort0_i,      -- out std_logic
     signal_detect      => signal_detect_Port0_i,    -- in  std_logic
     tx_fault           => Port0_Tx_Fault,           -- in  std_logic
     drp_req            => ddrp_core_req_Port0,      -- out std_logic
     drp_gnt            => ddrp_core_gnt_Port0,      -- in  std_logic
     drp_den_o          => ddrp_core_den_i_Port0,    -- out std_logic
     drp_dwe_o          => ddrp_core_dwe_i_Port0,    -- out std_logic
     drp_daddr_o        => ddrp_core_daddr_i_Port0,  -- out std_logic_vector(15 downto 0)
     drp_di_o           => ddrp_core_di_i_Port0,     -- out std_logic_vector(15 downto 0)
     drp_drdy_i         => ddrp_core_drdy_o_Port0,   -- in  std_logic
     drp_drpdo_i        => ddrp_core_drpdo_o_Port0,  -- in  std_logic_vector(15 downto 0)
     drp_den_i          => ddrp_den_i_Port0,         -- in  std_logic
     drp_dwe_i          => ddrp_dwe_i_Port0,         -- in  std_logic
     drp_daddr_i        => ddrp_daddr_i_Port0,       -- in  std_logic_vector(15 downto 0)
     drp_di_i           => ddrp_di_i_Port0,          -- in  std_logic_vector(15 downto 0)
     drp_drdy_o         => ddrp_drdy_o_Port0,        -- out std_logic
     drp_drpdo_o        => ddrp_drpdo_o_Port0,       -- out std_logic_vector(15 downto 0)
     pma_pmd_type       => "101",                    -- in  std_logic_vector(2 downto 0)
     tx_disable         => Port0_Tx_Disable);        -- out std_logic

    --Note: txoutclk open since only one needs to be used. txoutclk on core 0 is the main clock used.
 ten_gig_eth_pcs_pma_Port1_i: ten_gig_eth_pcs_pma_0
   port map (
     gt0_eyescanreset     => gt0_eyescanreset,
     gt0_eyescandataerror => open,
     gt0_txbufstatus      => open,
     gt0_rxbufstatus      => open,
     gt0_eyescantrigger   => gt0_eyescantrigger,
     gt0_rxcdrhold        => gt0_rxcdrhold,
     gt0_txprbsforceerr   => gt0_txprbsforceerr,
     gt0_txpolarity       => gt0_txpolarity,
     gt0_rxpolarity       => gt0_rxpolarity,
     gt0_rxprbserr        => open,
     gt0_txpmareset       => gt0_txpmareset,
     gt0_rxpmareset       => gt0_rxpmareset,
     gt0_txresetdone      => open,
     gt0_rxresetdone      => open,
     gt0_rxdfelpmreset    => gt0_rxdfelpmreset,
     gt0_rxlpmen          => gt0_rxlpmen,
     gt0_dmonitorout      => open,
     gt0_rxrate           => gt0_rxrate,
     gt0_txprecursor      => gt0_txprecursor,
     gt0_txpostcursor     => gt0_txpostcursor,
     gt0_txdiffctrl       => gt0_txdiffctrl,
     sim_speedup_control=> '1',
     rxrecclk_out       => open,
     coreclk            => coreclk_i,                 -- in  std_logic
     dclk               => dclk_i,                   -- in  std_logic
     txusrclk           => txusrclk_i,               -- in  std_logic
     txusrclk2          => txusrclk2_i,              -- in  std_logic
     txoutclk           => open,                     -- out std_logic
     areset             => aReset,                   -- in  std_logic
     areset_coreclk     => areset_coreclk_i,          -- in  std_logic
     gttxreset          => gttxreset_i,              -- in  std_logic
     gtrxreset          => gtrxreset_i,              -- in  std_logic
     txuserrdy          => txuserrdy_i,              -- in  std_logic
     qplllock           => qplllock_i,               -- in  std_logic
     qplloutclk         => qplloutclk_i,             -- in  std_logic
     qplloutrefclk      => qplloutrefclk_i,          -- in  std_logic
     reset_counter_done => reset_counter_done_i,     -- in  std_logic
     xgmii_txd          => xgmii_txd_phy_mac_Port1,      -- in  std_logic_vector(63 downto 0)
     xgmii_txc          => xgmii_txc_phy_mac_Port1,      -- in  std_logic_vector(7 downto 0)
     xgmii_rxd          => xgmii_rxd_mac_phy_Port1,      -- out std_logic_vector(63 downto 0)
     xgmii_rxc          => xgmii_rxc_mac_phy_Port1,      -- out std_logic_vector(7 downto 0)
     txp                => Port1_TX_p,               -- out std_logic
     txn                => Port1_TX_n,               -- out std_logic
     rxp                => Port1_RX_p,               -- in  std_logic
     rxn                => Port1_RX_n,               -- in  std_logic
     mdc                => MDCPort1,                 -- in  std_logic
     mdio_in            => mMDIOInPHYOutMACPort1,    -- in  std_logic
     mdio_out           => mMDIOInMACOutPHYPort1,    -- out std_logic
     mdio_tri           => open,                     -- out std_logic
     prtad              => "00000",                  -- in  std_logic_vector(4 downto 0)
     core_status        => CoreStatusPort1_i,        -- out std_logic_vector(7 downto 0)
     tx_resetdone       => cTxResetDonePort1_i,      -- out std_logic
     rx_resetdone       => cRxResetDonePort1_i,      -- out std_logic
     signal_detect      => signal_detect_Port1_i,    -- in  std_logic
     tx_fault           => Port1_Tx_Fault,           -- in  std_logic
     drp_req            => ddrp_core_req_Port1,      -- out std_logic
     drp_gnt            => ddrp_core_gnt_Port1,      -- in  std_logic
     drp_den_o          => ddrp_core_den_i_Port1,    -- out std_logic
     drp_dwe_o          => ddrp_core_dwe_i_Port1,    -- out std_logic
     drp_daddr_o        => ddrp_core_daddr_i_Port1,  -- out std_logic_vector(15 downto 0)
     drp_di_o           => ddrp_core_di_i_Port1,     -- out std_logic_vector(15 downto 0)
     drp_drdy_i         => ddrp_core_drdy_o_Port1,   -- in  std_logic
     drp_drpdo_i        => ddrp_core_drpdo_o_Port1,  -- in  std_logic_vector(15 downto 0)
     drp_den_i          => ddrp_den_i_Port1,         -- in  std_logic
     drp_dwe_i          => ddrp_dwe_i_Port1,         -- in  std_logic
     drp_daddr_i        => ddrp_daddr_i_Port1,       -- in  std_logic_vector(15 downto 0)
     drp_di_i           => ddrp_di_i_Port1,          -- in  std_logic_vector(15 downto 0)
     drp_drdy_o         => ddrp_drdy_o_Port1,        -- out std_logic
     drp_drpdo_o        => ddrp_drpdo_o_Port1,       -- out std_logic_vector(15 downto 0)
     pma_pmd_type       => "101",                    -- in  std_logic_vector(2 downto 0)
     tx_disable         => Port1_Tx_Disable);        -- out std_logic


  axis_tuser_to_tkeep_inst0 : axis_tuser_to_tkeep
    port map(
      tuser => cRxTUserToTKeepPort0(2 downto 0),
      tkeep => cRxTKeepPort0
      );
  
  -- To be compatible with the Xilinx MAC interface, the CLIP asserts TUser(0)
  -- when a packet ends in a valid packet.  If we get a TLast with no TUser,
  -- that indicates a bad packet.  But a TUser without a TLast is undefined.
  -- This is inverted w.r.t. the XGE MAC.
  cRxTUserPort0       <= (not cRxTUserToTKeepPort0(3)) and cRxTLastPort0_i;

  -- Likewise, the XGE MAC core uses byte counts, so convert byte enables to
  -- byte counts
  axis_tkeep_to_tuser_inst0 : axis_tkeep_to_tuser
    port map(
      tuser => cTxTKeepToTUserPort0,
      tkeep => cTxTKeepPort0
      );


  --Bitfield explained:
  --cTxTUserPort        indicates explicit underrun
  --cTxTKeepToTUserPort indicates bytes enabled
  tx_axis_tuser_port0 <= cTxTUserPort0 & cTxTKeepToTUserPort0(2 downto 0);
  
  xge_mac_wrapper_port_0 : xge_mac_wrapper
    port map(
      -- XGMII
      xgmii_txd      => xgmii_txd_phy_mac_Port0,  -- out std_logic_vector(63 downto 0);
      xgmii_txc      => xgmii_txc_phy_mac_Port0,  -- out std_logic_vector(7 downto 0);
      xgmii_rxd      => xgmii_rxd_mac_phy_Port0,  -- in std_logic_vector(63 downto 0);
      xgmii_rxc      => xgmii_rxc_mac_phy_Port0,  -- in std_logic_vector(7 downto 0);
      -- MDIO
      mdc            => MDCPort0,                 -- out std_logic;
      mdio_in        => mMDIOInPHYOutMACPort0,    -- out std_logic;
      mdio_out       => mMDIOInMACOutPHYPort0,    -- in std_logic;
      -- Client FIFO Interfaces
      sys_clk        => coreclk_i,                 -- in std_logic;
      reset          => aReset,                   -- in std_logic;
      rx_axis_tdata  => cRxTDataPort0,            -- out std_logic_vector(63 downto 0);
      rx_axis_tuser  => cRxTUserToTKeepPort0,     -- out std_logic_vector(3 downto 0);
      rx_axis_tlast  => cRxTLastPort0_i,          -- out std_logic;
      rx_axis_tvalid => cRxTValidPort0_i,         -- out std_logic;
      rx_axis_tready => '1',                      -- in std_logic;
      tx_axis_tdata  => cTxTDataPort0,            -- in std_logic_vector(63 downto 0);
      tx_axis_tuser  => tx_axis_tuser_port0,      -- in std_logic_vector(3 downto 0);
      tx_axis_tlast  => cTxTLastPort0,            -- in std_logic;
      tx_axis_tvalid => cTxTValidPort0,           -- in std_logic;
      tx_axis_tready => cTxTReadyPort0_i          -- out std_logic;
      );

  axis_tuser_to_tkeep_inst1 : axis_tuser_to_tkeep
    port map(
      tuser => cRxTUserToTKeepPort1(2 downto 0),
      tkeep => cRxTKeepPort1
      );
  
  -- To be compatible with the Xilinx MAC interface, the CLIP asserts TUser(0)
  -- when a packet ends in a valid packet.  If we get a TLast with no TUser,
  -- that indicates a bad packet.  But a TUser without a TLast is undefined.
  -- This is inverted w.r.t. the XGE MAC.
  cRxTUserPort1       <= (not cRxTUserToTKeepPort1(3)) and cRxTLastPort1_i;

  -- Likewise, the XGE MAC core uses byte counts, so convert byte enables to
  -- byte counts
  axis_tkeep_to_tuser_inst1 : axis_tkeep_to_tuser
    port map(
      tuser => cTxTKeepToTUserPort1,
      tkeep => cTxTKeepPort1
      );


  --Bitfield explained:
  --cTxTUserPort        indicates explicit underrun
  --cTxTKeepToTUserPort indicates bytes enabled
  tx_axis_tuser_port1 <= cTxTUserPort1 & cTxTKeepToTUserPort1(2 downto 0);
  
  xge_mac_wrapper_port_1 : xge_mac_wrapper
    port map(
      -- XGMII
      xgmii_txd      => xgmii_txd_phy_mac_Port1,  -- out std_logic_vector(63 downto 0);
      xgmii_txc      => xgmii_txc_phy_mac_Port1,  -- out std_logic_vector(7 downto 0);
      xgmii_rxd      => xgmii_rxd_mac_phy_Port1,  -- in std_logic_vector(63 downto 0);
      xgmii_rxc      => xgmii_rxc_mac_phy_Port1,  -- in std_logic_vector(7 downto 0);
      -- MDIO
      mdc            => MDCPort1,                 -- out std_logic;
      mdio_in        => mMDIOInPHYOutMACPort1,    -- out std_logic;
      mdio_out       => mMDIOInMACOutPHYPort1,    -- in std_logic;
      -- Client FIFO Interfaces
      sys_clk        => coreclk_i,                 -- in std_logic;
      reset          => aReset,                   -- in std_logic;
      rx_axis_tdata  => cRxTDataPort1,            -- out std_logic_vector(63 downto 0);
      rx_axis_tuser  => cRxTUserToTKeepPort1,     -- out std_logic_vector(3 downto 0);
      rx_axis_tlast  => cRxTLastPort1_i,          -- out std_logic;
      rx_axis_tvalid => cRxTValidPort1_i,         -- out std_logic;
      rx_axis_tready => '1',                      -- in std_logic;
      tx_axis_tdata  => cTxTDataPort1,            -- in std_logic_vector(63 downto 0);
      tx_axis_tuser  => tx_axis_tuser_port1,      -- in std_logic_vector(3 downto 0);
      tx_axis_tlast  => cTxTLastPort1,            -- in std_logic;
      tx_axis_tvalid => cTxTValidPort1,           -- in std_logic;
      tx_axis_tready => cTxTReadyPort1_i          -- out std_logic;
      );
----------------------------------------------------------------------------------------
end block TenGbEBlock;

  DebugClks(0) <= coreclk_i;
  DebugClks(1) <= MDCPort0;
  DebugClks(2) <= MDCPort1;  
  DebugClks(3) <= '0';

  ---------------------------------------------------------------------------------------
  -- Status Signals
  ---------------------------------------------------------------------------------------
  TenGbEStatus : block
    signal signal_detect_ms : std_logic_vector(1 downto 0);
    signal PowerGood_ms     : std_logic_vector(1 downto 0);
    signal BlockLock_ms     : std_logic_vector(1 downto 0);
    -- 659x unique signals
    signal MGT_RefClks_Valid_ms        : std_logic;
    signal MGT_RefClks_ExtPllLocked_ms : std_logic;
  begin  --block TenGbEStatus
    -- purpose: resynchronize status signals sent to LV to avoid potential
    --          metastabiltiies or timing violations
    -- type   : sequential
    -- inputs : OnboardClk40ToClip, aReset
    -- outputs:
    StatusSynchronizer : process (OnboardClk40ToClip, aReset) is
    begin  -- process StatusSynchronizer
      if aReset = '1' then              -- asynchronous reset (active high)        
        signal_detect_ms <= (others => '0');
        PowerGood_ms     <= (others => '0');
        BlockLock_ms     <= (others => '0');
      elsif rising_edge(OnboardClk40ToClip) then  -- rising clock edge
        ------------------------------------------------------------
        -- synchronize signal_detect_PortX internal signals to Clk40
        signal_detect_ms(0) <= signal_detect_Port0_i;
        signal_detect_ms(1) <= signal_detect_Port1_i;
        -- Send signal detect for both ports to diagram facing signals
        signal_detect_Port0 <= signal_detect_ms(0);
        signal_detect_Port1 <= signal_detect_ms(1);
        ------------------------------------------------------------
        -- synchronize PowerGood_ms internal signals to Clk40
        PowerGood_ms(0)     <= sPort0_PowerGood;
        PowerGood_ms(1)     <= sPort1_PowerGood;
        -- Read if the power is good on all the ports.
        sPort0_Power_Good   <= PowerGood_ms(0);
        sPort1_Power_Good   <= PowerGood_ms(1);
        ------------------------------------------------------------
        -- synchronize CoreStatus for block lock detect
        BlockLock_ms(0)     <= CoreStatusPort0_i(0);
        BlockLock_ms(1)     <= CoreStatusPort1_i(0);
        -- PCS Block Lock achieved and link is up when both cores indicate block lock.
        aBlockLockPort0     <= BlockLock_ms(0);
        aBlockLockPort1     <= BlockLock_ms(1);
      end if;
    end process StatusSynchronizer;
    
    -- purpose: resynchronize status signals sent to LV to avoid potential metastabiltiies or timing violations
    -- type   : sequential
    -- inputs : OnboardClk40ToClip, aReset
    -- outputs: 
    ni659xStatusSynchronizer: process (OnboardClk40ToClip, aReset) is
    begin  -- process ni659xStatusSynchronizer
      if aReset = '1' then              -- asynchronous reset (active high)
        MGT_RefClks_ExtPllLocked_ms <= '0';
        MGT_RefClks_Valid_ms        <= '0';
        MgtRefClks_Valid            <= '0';
        MgtRefClks_Locked           <= '0';
        PllLocked                   <= '0';
      elsif rising_edge(OnboardClk40ToClip) then  -- rising clock edge
        ------------------------------------------------------------
        -- synchronize MGT_RefClks_* internal signals to Clk40
        MGT_RefClks_Valid_ms        <= MGT_RefClks_Valid;
        MGT_RefClks_ExtPllLocked_ms <= MGT_RefClks_ExtPllLocked;
        -- Clock Status Signals
        MgtRefClks_Locked <= MGT_RefClks_ExtPllLocked_ms;
        MgtRefClks_Valid  <= MGT_RefClks_Valid_ms;
        -- The si5368 must indicated that it is locked and the fixed logic must
        -- indicate that the reference clock is established
        PllLocked <= MGT_RefClks_ExtPllLocked_ms and MGT_RefClks_Valid_ms;  
      end if;
    end process ni659xStatusSynchronizer;

    -- The following status signals do not require a synchronizer as they are
    -- static or on a required clock domain that is the same as their origin.

    -- Enable power on all ports, SFP+ standard does not require the power line to be disabled when no module is present.
    sPort0_EnablePower <= '1';
    sPort1_EnablePower <= '1';

    -- Rate Select and Enable set
    -- RS0 and RS1 are always set to 1 for operation above 4.25 Gbps. We are operating at 10.3125 Gbps.
    Port0_RS0 <= '1';
    Port0_RS1 <= '1';
    Port1_RS0 <= '1';
    Port1_RS1 <= '1';
    
    -- Logic per Xilinx doc pg 16 PCS/PMA User Guide
    -- pg 127 signal_detect is tied to logic 1 if not connected to an optical module
    signal_detect_Port0_i <= Port0_Mod_ABS nor Port0_Rx_LOS;
    signal_detect_Port1_i <= Port1_Mod_ABS nor Port1_Rx_LOS;

    -- Front End Configuration Signals
    -- sFrontEndConfigurationDone is asserted on SocketClk40, and the CLIP XML
    -- enforces that POSC_Complete is received on that clock, so this
    -- assignment is safe.
    POSC_Complete <= sFrontEndConfigurationDone;
    -- CLIP documentation states that this is safe
    sFrontEndConfigurationReady <= sFrontEndConfigurationPrepare;

    -------------------------------------------------------------------------------------
    -- Unused ports
    -------------------------------------------------------------------------------------
    Port2_RS0          <= '1';
    Port2_RS1          <= '1';
    Port3_RS0          <= '1';
    Port3_RS1          <= '1';
    Port2_Tx_Disable   <= '0';
    Port3_Tx_Disable   <= '0';
    sPort2_EnablePower <= '0';  --Powered down since unused in this example
    sPort3_EnablePower <= '0';
    Port2_TX_n         <= '0';          --TX tied to 0 on unused ports
    Port2_TX_p         <= '0';          --TX tied to 0 on unused ports
    Port3_TX_n         <= '0';          --TX tied to 0 on unused ports
    Port3_TX_p         <= '0';          --TX tied to 0 on unused ports
    
  end block TenGbEStatus; 
  ---------------------------------------------------------------------------------------
  -- LED Control
  --
  -- Process to read valid statistics from the MAC core for LED status change.
  -- coreclk_i is tx_clk0 and rx_clk0, which is what both vectors are synced to.
  -- The results from this process are used in LED_Reg process for LED control.

  -- This is only necessary to hook into the fixed logic with the correct signal name while
  -- specifying the clocking domain that controls the signals.
  LED_ActiveGreen <= cLED_ActiveGreen;
  LED_ActiveRed   <= cLED_ActiveRed;

  -- If both links for Tx/Rx are up, link is up and Green should activate. Otherwise link is not up.
  -- If there are errors, or if packets are transmitting, assert Red. Indicates orange when packets
  -- are sending due to link up asserting green. Indicates red only on error.
  LED_Reg : process(aReset, coreclk_i)
  begin
    if aReset = '1' then                -- Set register to turn off all LED's
      cLED_ActiveGreen <= '0';
      cLED_ActiveRed   <= '0';
    elsif rising_edge(coreclk_i) then
      -- LED goes green when PCS/PMA core status on bit 0 indicates block lock achieved and data communication
      -- follows after. Block lock indicates the link is up.
      if CoreStatusPort0_i(0) = '1' or CoreStatusPort1_i(0) = '1' then
        cLED_ActiveGreen <= '1';
      else
        cLED_ActiveGreen <= '0';
      end if;

      -- If there are bad frames, then indicate error. Also, if link is up and 1) RxTValid is asserted or 2) TxTReady
      -- is asserted, then packets are being transferred, so indicate "orange" which is green=1 AND red=1.
      if cRxTValidPort0_i = '1' or cRxTValidPort1_i = '1'
        or (cTxTReadyPort0_i = '1' and cTxTValidPort0 = '1')
        or (cTxTReadyPort1_i = '1' and cTxTValidPort1 = '1') then
        cLED_ActiveRed   <= '1';
        cLED_ActiveGreen <= '1';
      else
        cLED_ActiveRed <= '0';
      end if;
    end if;
  end process;  --LED_Reg 
 
  ---------------------------------------------------------------------------------------
  -- General Purpose I/O
  --
  -- For the GPIO, there are a lot of signal assignments that need to happen that
  -- are pass-through.  We use look-up tables and generate statements to do this mapping
  -- of the I/O to the correct pins.  The look-up table includes the aUserGpio pin number
  -- and a selection of whether it is the positive or negative terminal.

  GeneralPurposeIO: block
  begin  -- block GeneralPurposeIO

    PFI0_GPIO_Out <= PFI0_Out;
    PFI0_GPIO_OutEnable_n <= NOT PFI0_OutEnable;

    PFI1_GPIO_Out <= PFI1_Out;
    PFI1_GPIO_OutEnable_n <= NOT PFI1_OutEnable;

    PFI2_GPIO_Out <= PFI2_Out;
    PFI2_GPIO_OutEnable_n <= NOT PFI2_OutEnable;

    PFI3_GPIO_Out <= PFI3_Out;
    PFI3_GPIO_OutEnable_n <= NOT PFI3_OutEnable;

    PFI0_In <= PFI0_GPIO_In;
    PFI1_In <= PFI1_GPIO_In;
    PFI2_In <= PFI2_GPIO_In;
    PFI3_In <= PFI3_GPIO_In;
  end block GeneralPurposeIO;

end rtl;
