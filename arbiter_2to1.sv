`timescale 1ns/1ps

import SystemVerilogCSP::*;

parameter WIDTH_packet = 57;

module arbiter_2to1 (
    input logic in1_req,
    output logic  in1_ack,
    input logic [WIDTH_packet-1:0] in1_data,
    input logic in2_req,
    output logic in2_ack,
    input logic [WIDTH_packet-1:0] in2_data,
    interface out
);
    
    parameter FL = 2, BL = 1;
    logic [WIDTH_packet-1:0] in_packet;
    logic prio;
    initial begin
        prio = 0;
    end

    always begin
        if(in1_req && in2_req) begin
            // contention
            if(prio) begin
                // in2 gets it
                //in2.Receive(in_packet);
                in_packet = in2_data;
                in2_ack = 1;
                wait(in2_req == 0);
                in2_ack = 0;
                #FL;
                out.Send(in_packet);
                #BL;
                prio = ~prio;
            end
            else begin
                // in1
                //in1.Receive(in_packet);
                in_packet = in1_data;
                in1_ack = 1;
                wait(in1_req == 0);
                in1_ack = 0;
                #FL;
                out.Send(in_packet);
                #BL;
                prio = ~prio;
            end
        end
        else if(in1_req) begin
            //in1.Receive(in_packet);
            in_packet = in1_data;
            in1_ack = 1;
            wait(in1_req == 0);
            in1_ack = 0;
            #FL;
            out.Send(in_packet);
            #BL;
        end
        else if(in2_req) begin
            //in2.Receive(in_packet);
            in_packet = in2_data;
            in2_ack = 1;
            wait(in2_req == 0);
            in2_ack = 0;
            #FL;
            out.Send(in_packet);
            #BL;
        end
    end

endmodule