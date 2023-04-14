`timescale 1ns/1ps

import SystemVerilogCSP::*;
parameter WIDTH_packet = 57;
module arbiter_2to1 (
    interface in1, in2,out
);
    
    parameter FL = 0, BL = 0;
    logic [WIDTH_packet-1:0] in_packet;
    logic prio;
    initial begin
        prio = 0;
    end

    always begin
        wait(in1.req || in2.req);
        if(in1.req && in2.req) begin
            // contention
            if(prio) begin
                // in2 gets it
                in2.Receive(in_packet);
                #FL;
                out.Send(in_packet);
                #BL;
                prio = ~prio;
            end
            else begin
                // in1
                in1.Receive(in_packet);
                #FL;
                out.Send(in_packet);
                #BL;
                prio = ~prio;
            end
        end
        else if(in1.req) begin
            in1.Receive(in_packet);
            #FL;
            out.Send(in_packet);
            #BL;
        end
        else if(in2.req) begin
            in2.Receive(in_packet);
            #FL;
            out.Send(in_packet);
            #BL;
        end
    end

endmodule