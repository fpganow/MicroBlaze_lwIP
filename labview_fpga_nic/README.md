# 10 Gigabit LabVIEW FPGA-based Network Card


## Description
This project demonstrates and exercises the first 10 Gigabit port of the National Instruments PXIe-6592R board, containing a Kintex 7 410t FPGA card.
There are 2 sub-projects
One sub-project (**MAC-Tester.vi**) is for exercising the Network interface portion of the project, and the other sub-project (**MicroBlaze-Tester.vi**) is for exercising the MicroBlaze portion of the project.

## Definitions
* **FPGA** - refers to all code that runs inside/on the FPGA
* **Host** - refers to all code that runs on the CPU of the host system.  This is the regular "Windows Application" portion of the project.
* **CLIP** - Component Level IP - Refers to the 4-port 10 Gigabit Ethernet Interface provided on the board.

### 10 Gigabit MAC Tester
This vi communicates with the FPGA by using 2 FIFOs, one for sending raw Ethernet Frames that will be put on the wire via the CLIP, and one for receiving raw Ethernet Frames received from the wire by the CLIP.  Think of this as an FPGA accelerated Network card that has this top level vi as the endpoint.
* Top Level Vi - [MAC-Tester.vi](https://github.com/JohnStratoudakis/LabVIEW_Fpga/blob/master/07_10_Gigabit_CLIP/Tests/MAC/MAC-Tester.vi)
* Before running, make sure the **Fpga-Mac-Top** build specification has been built.
* Usage:
  * Plug a 10 Gigabit cable in to the top port (Port 0) and connect it to another 10 Gigabit endpoint on your local network.
  * Run the Vi
  * Fill out the parameters in the following controls for a UDP Packet Parameters:
  * Click Transmit and check the other endpoint for the packet data!

### MicroBlaze Tester
This vi exercises the following components that have been added to the MicroBlaze soft-core processor:
* GPIO #1
  * Dual-Channel
  * Channel 1: All Inputs, 32-bits
  * Channel 2: All Outputs, 32-bits
* GPIO #2
  * Dual-Channel
  * Channel 1: All Inputs, 32-bits
  * Channel 2: All Outputs, 32-bits
* FIFO #1
  * 32-bit width
  * Transmit Control Disable
* FIFO #2
  * 32-bit width
  * Transmit Control Disable
* 2 Interrupt Channels

# To Do
- [ ] Clean up MicroBlaze Tester
  - [ ] Convert FIFOs to use 64-bits instead of 32-bits
  - [ ] Make a blog post with screenshots
