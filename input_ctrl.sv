`timescale 1ns/1ps

import SystemVerilogCSP::*;
module input_ctrl (
    interface in, north_out, south_out, east_out, west_out, PE_out
);
    parameter WIDTH_packet = 57;
    parameter FL = 2, BL = 1;
    logic [WIDTH_packet-1:0] in_packet, out_packet;

    always begin
        in.Receive(in_packet);
        #FL;
        // check x hop
        if(in_packet[44:42] > 0) begin
            out_packet = {in_packet[56:47],in_packet[46:44]-1,in_packet[43:0]};
            if(in_packet[47]) begin
                // going east
                east_out.Send(out_packet);
            end
            else begin
                // west
                west_out.Send(out_packet);
            end
        end
        //going horizontal
        else if(in_packet[42:40]>0) begin
            out_packet = {in_packet[56:43],in_packet[42:40]-1,in_packet[39:0]};
            if(in_packet[43]) begin
                //north
                north_out.Send(out_packet);
            end
            else begin
                //south
                south_out.Send(out_packet);         
            end
        end
        // arrived destination
        else begin
            out_packet = in_packet;
            PE_out.Send(out_packet);
        end
        #BL;
    end
endmodule