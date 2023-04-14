`timescale 1ns/1ps

import SystemVerilogCSP::*;
module output_ctrl_gate (
    interface in1, in2, in3, in4, out
);
    parameter WIDTH_packet = 57;
    parameter FL = 0, BL = 0;
    logic [WIDTH_packet-1:0] in_packet;
    logic out1_req,out2_req,out3_req;
    logic out1_ack,out2_ack,out3_ack;
    logic [WIDTH_packet-1:0] out1_data, out2_data,out3_data, interface_out_data;
    
    arbiter_2to1 arb1(in1.req, in1.ack,in1.data,in2.req,in2.ack,in2.data,out1_req,out1_ack,out1_data);
    arbiter_2to1 arb2(in3.req, in3.ack,in3.data,in4.req,in4.ack,in4.data,out2_req,out2_ack,out2_data);
    arbiter_2to1 final_out(out1_req,out1_ack,out1_data,out2_req,out2_ack,out2_data, out3_req,out3_ack,out3_data);

    always begin
        out3_ack = 0;
        wait(out3_req);
        interface_out_data = out3_data;
        #FL;
        out3_ack = 1;
        out.Send(interface_out_data);
        wait(!out3_req)
        #BL;
    end


endmodule