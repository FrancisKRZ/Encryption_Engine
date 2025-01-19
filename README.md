Encryption Engine


1. Top Module (Encryption Engine Top)
This is the main control module that instantiates all components.
Connects the W5500 Ethernet module to the encryption engine and FIFO RAM.
Manages the data flow and overall communication between components.
Implements a finite state machine (FSM) for coordination.

2. W5500 Ethernet Module Driver
This module handles SPI communication with the W5500.
Implements the SPI protocol to read and write W5500 registers.
Manages data packet transmission and reception.
Handles network initialization, such as setting IP addresses and ports.
Exposes an easy-to-use interface for the Top Module to send and receive data.

Below showcases the Unit Under Test (UUT) signal's in the waveform:
![alt text](https://ibb.co/SVthWCS)


3. FIFO RAM
This module provides temporary storage for data packets.
Buffers data between the W5500 and the encryption engine.
Ensures smooth communication even if components operate at slightly different speeds.
Includes read/write logic with overflow/underflow protection.

4. Encryption Engine
Implements the cryptographic algorithm.
Works independently of the W5500 driver and FIFO RAM.
Supports the modular design for reusability in future projects.

5. SPI Controller (For W5500)
Handles low-level SPI communication (MOSI, MISO, SCLK, CS).
Serves as an interface for the W5500 module driver, abstracting raw SPI details.

6. Testbench Files
For each module, we’ve created a separate testbench to simulate and verify functionality in isolation.

