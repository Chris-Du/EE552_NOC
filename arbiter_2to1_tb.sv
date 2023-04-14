`timescale 1ns/1ps

import SystemVerilogCSP::*;
module arbiter_2to1_tb (
);
    parameter WIDTH_packet = 57;
    parameter FL = 2, BL = 1;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) in [1:0] ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out ();
    
    arbiter_2to1 DUT(
        in[0],
        in[1],
        out
    );

    logic [WIDTH_packet-1:0] out_data;

    integer i,count;

    always begin
        i = $random();
        #FL;
        /*
        if(i%1 == 0) begin
            in[0].Send(count);
            count = count + 1;
        end
        if(i%2 == 1) begin
            in[1].Send(count);
            count = count + 1;
        end
        */
        fork
            in[0].Send(count);
            in[1].Send(count+1);
        join
        
        count = count + 2;
    end

    always begin
        out.Receive(out_data);
        $display("out data: %d",out_data);
        #BL;
    end

    initial begin
        count = 0;
        #100;
        $stop();
    end

endmodule