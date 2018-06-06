# Most constraints are sourced by the XCI, these are constraints that it cannot supply (the actual clock pin), or constraints
# that are missed as because of the location or nuances of how these signals are plumbed.

create_clock -period 6.400 -name CoreClk156Out [get_pins %ClipInstancePath%/TenGbEBlock.pcs_pma_shared_clock_reset_i/clk156_bufg_i/O]
set CoreClk156Out_Out [get_clocks -of [get_pins %ClipInstancePath%/TenGbEBlock.pcs_pma_shared_clock_reset_i/clk156_bufg_i/O]]

# This should be covered by a constraint in the core, but it isn't being found during the compile.
# So here is a contextualized version of the same constraint.
set_false_path -from [get_pins {%ClipInstancePath%/TenGbEBlock.pcs_pma_shared_clock_reset_i/reset_pulse_reg[0]/C}] -to [get_pins {%ClipInstancePath%/TenGbEBlock.pcs_pma_shared_clock_reset_i/gttxreset_txusrclk2_sync_i/sync1_r_reg*/PRE}]

# likewise for these. Since the generated constraint can't locate the 156.25 BUFG, we need to replicate the constraint with the
# proper context.
set_false_path -from $CoreClk156Out_Out -to [get_cells -hierarchical -filter {NAME =~ *ratefifo*dp_ram_i*rd_data* && (PRIMITIVE_SUBGROUP =~ flop || PRIMITIVE_SUBGROUP =~ SDR)}]
set_max_delay -datapath_only -from $CoreClk156Out_Out -to [get_pins -of_objects [get_cells -hier -filter {NAME =~ *coreclk_rxusrclk2_timer_125us_resync/*synchc_inst*d1_reg}] -filter {NAME =~ *D}] 6.400
set_max_delay -datapath_only -from $CoreClk156Out_Out -to [get_pins -of_objects [get_cells -hier -filter {NAME =~ *coreclk_rxusrclk2_resyncs_i/*synchc_inst*d1_reg}] -filter {NAME =~ *D}] 6.400
set_max_delay -datapath_only -from $CoreClk156Out_Out -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *drp_ipif_i*synch_*q_reg*}] -filter {NAME =~ *D || NAME =~ *R || NAME =~ *S}] 3.100

# Actual constraints for the CLIP logic
# this crosses the block lock signal to a reliable clock so it can be monitored safely
# before the clock is running
set_false_path -to [get_pins {*/TenGbEStatus.BlockLock_ms_reg[*]/D}]
