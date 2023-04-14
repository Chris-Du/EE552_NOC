`timescale 1ns/1ps

import SystemVerilogCSP::*;

module output_ctrl_tb;
    parameter WIDTH_packet = 57;
    parameter FL = 2, BL = 1;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) in[3:0]();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out();
    logic [WIDTH_packet-1:0] out_data;
    integer single,double,triple,quad,count;
    output_ctrl dut(
        in[0],
        in[1],
        in[2],
        in[3],
        out
    );
    
    integer i;

    always begin
        i = $random();
        #FL;
        fork
            in[0].Send(count);
            in[1].Send(count+1);
            in[2].Send(count+2);
            in[3].Send(count+3);
        join
        count = count + 4;
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