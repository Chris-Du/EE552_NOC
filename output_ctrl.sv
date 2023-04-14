`timescale 1ns/1ps

import SystemVerilogCSP::*;
module output_ctrl (
    interface in1, in2, in3, in4, out
);
    parameter WIDTH_packet = 57;
    parameter FL = 2, BL = 1;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out1();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out2();
    
    arbiter_2to1 arb1(in1,in2,out1);
    arbiter_2to1 arb2(in3,in4,out2);
    arbiter_2to1 final_out(out1,out2,out);


endmodule