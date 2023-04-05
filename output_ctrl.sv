`timescale 1ns/1ps

import SystemVerilogCSP::*;
module output_ctrl (
    interface in1, in2, in3, in4, out
);
    parameter WIDTH_packet = 57;
    parameter FL = 0, BL = 0;
    logic [WIDTH_packet-1:0] in_packet;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) arb_out1();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) arb_out2();
    
    arbiter_2to1 arb1(in1.req, in1.ack,in1.data,in2.req,in2.ack,in2.data,arb_out1);
    arbiter_2to1 arb2(in3.req, in3.ack,in3.data,in4.req,in4.ack,in4.data,arb_out2);
    arbiter_2to1 final_out(arb_out1.req, arb_out1.ack,arb_out1.data,arb_out2.req,arb_out2.ack,arb_out2.data,out);


endmodule