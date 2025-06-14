 /////////////////////////Spiking Neural Network Accelerator (Verilog Implementation)/////////////////////////////////
 Project Status: Completed 
A fully implemented Spiking Neural Network (SNN) Accelerator in Verilog, modeled with asynchronous design principles and verified on a mesh-based Network-on-Chip (NoC).

 //////////Summary/////////////////

Inspired by IBM TrueNorth and Intel Loihi, this project implements a hardware accelerator for Spiking Neural Networks (SNNs) using a 3x3 Mesh NoC architecture. The system is written entirely in Verilog HDL, simulating asynchronous communication between routers and spiking neurons. Unlike TrueNorth/Loihi, this design also supports mapped Convolutional Neural Network (CNN) workloads translated into SNN formats.

 ////////////////Core Features/////

 Network-on-Chip (NoC)
3x3 Mesh Topology

9 Routers, each with 5 ports:

North, South, East, West, Local

XY Routing Algorithm

4-bit Address Format: XXYY (2 bits X, 2 bits Y)

///////////////// Processing Element (PE)///////////////
Models a spiking neuron

Integrate-and-fire behavior

Generates spikes when threshold is reached

Connected via Local Port of the router

///////////////// Asynchronous Communication//////////////
Routers and PEs operate asynchronously

No global clock

Handshake protocols (ready-valid style)

Simple control FSMs for routing and neuron firing

///////////// Tech Stack///////////////
Component	Description
HDL	Verilog
Simulation Tool	Xlinix Vivado / Icarus Verilog
Verification	Waveform Analysis (GTKWave)
Routing Protocol	XY Routing
Communication	Asynchronous (Handshaking)
Target Domain	SNN/CNN Acceleration

////////////////////// Project Structure///////////////////////

├── README.md              # Project documentation
├── router.v               # Asynchronous 5-port router
├── pe.v                   # Spiking Neuron Processing Element
├── noc_top.v              # 3x3 Mesh NoC top-level
├── xy_routing.v           # XY Routing logic
├── packet_format.v        # Packet structure and encoding
├── testbench/             # TBs for router, PE, and full mesh
├── waveforms/             # GTKWave files
└── docs/                  # Mapping theory: CNN → SNN


 //////////////////CNN → SNN Mapping/////////////////

We discuss how CNNs can be converted into SNNs for hardware deployment:

Rate coding for representing pixel intensities as spike frequency

Convolution filters as synaptic weight matrices

Pooling layers approximated via local inhibition or spike thresholding

Neuron dynamics simulated through discrete time steps in Verilog

 //////////////////////////Simulation Output/////////////////////

Simulations include:

Spike propagation across routers

Packet routing to destination PE

Neuron threshold-based spiking

Waveform analysis done via GTKWave

 ////////////References//////////////

1.IBM TrueNorth Neuromorphic Chip
2.Paul A. Merolla et al.,
"A million spiking-neuron integrated circuit with a scalable communication network and interface",
3.Intel Loihi Neuromorphic Architectur
4.Mike Davies et al.,
"Loihi: A Neuromorphic Manycore Processor with On-Chip Learning",
W. Maass,
5."Networks of spiking neurons: the third generation of neural network models",
S. Sengupta et al.,
6."Going Deeper in Spiking Neural Networks: VGG and Residual Architectures",
Asynchronous NoC for Neuromorphic Systems

 /////////////////Future Work/////////////////
Expand to larger mesh (e.g., 4x4 or 8x8)

Add learning rules (STDP, Hebbian)

Deploy to FPGA platform (e.g., Basys 3, Nexys A7)

Connect to external image input (e.g., MNIST spike encoder)



