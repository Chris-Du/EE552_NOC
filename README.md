# EE552_NOC
EE552 Final Project Proposal
Group members: Yifu Zhou, Peiliang Du
NOC:
Our group decided to implement the network on chip using a 3x4 mesh topology with packet switching, X-Y routing scheme and an enhancement of increased packet size. Everything else follows the baseline described in project specification.
The NOC has eight convolution PEs, one sum PE and three memory nodes for input feature, weight and output. Placement of each node has not been finalized. The heavy traffic paths should be from input feature nodes to the convolution PEs and from them to the sum node.
The expanded packet with a 40-bit data field indicates sending five data from source to the same destination at once. Note that this implies a wide memory architecture to allow reading 40-bit in one stroke. We expect such an improvement to ameliorate NOC traffic, especially from input feature memory to other PEs. Furthermore, given the internal latency of a PE component is only 2+2 ns compared to the 12+4 ns penalty of memory operation, the performance of SNN may be bottlenecked by the memory nodes. A larger packet size is expected to mitigate the memory bottleneck and improve the overall performance of NOC and SNN. As of routing, a packet is injected with a horizontal direction bit, a vertical direction bit, a horizontal hop value field and a vertical hop value field to help packet navigate through routers, in addition to the component fields in a baseline header. This enhancement does require a larger than baseline buffer size in each router. The packetize unit and depacketize unit should be modified to the standard of the new packet size.
SNN:
SNN follows baseline specification.
Workload Partition:
Peiliang is responsible for designing convolution and sum PE. Yifu, the router and NOC. Each of us should verify their own design. Code review and top level debug should be a joint effort. 
Gate Level:
The Sum module will be implemented at gate-level by using a 2-phase click controller and D flip flop model which was covered in the class, and we had implemented the 2-phase click controller in the previous homework. 
