`timescale 1ns/1ps

import SystemVerilogCSP::*;

module router_tb;
    
    parameter FL = 2, BL = 1;
    parameter WIDTH_packet = 57;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) in[4:0]();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out[4:0]();


    router DUT(
        in[0], out[0], //up
        in[1], out[1], //down
        in[2], out[2], //right
        in[3], out[3], //left
        in[4], out[4]  //PE
    );

    data_bucket #(.NODE(0)) north_bucket(out[0]);
    data_bucket #(.NODE(1)) south_bucket(out[1]);
    data_bucket #(.NODE(2)) east_bucket(out[2]);
    data_bucket #(.NODE(3)) west_bucket(out[3]);
    data_bucket #(.NODE(4)) PE_bucket(out[4]);
    logic [WIDTH_packet-1:0] in_data;
    integer i = 0;

    initial begin
        
        //west to east
        in_data = 0;
        in_data[47] = 1;
        in_data[46:44] = 1; // xhop
        in_data[39:0] = 1;
        #FL;
        in[3].Send(in_data);
        $display("send: %b",in_data);
        #BL;
        //west to north
        in_data[46:44] = 0;
        in_data[43] = 1;
        in_data[42:40] = 1;
        in_data[39:0] = 2;
        #FL;
        in[3].Send(in_data);
        $display("send: %b",in_data);
        #BL;
        //west to south
        in_data[46:44] = 0;
        in_data[43] = 0;
        in_data[42:40] = 1;
        in_data[39:0] = 3;
        #FL;
        in[3].Send(in_data);
        $display("send: %b",in_data);
        #BL;
        // west to pe
        in_data = 0;
        in_data[39:0] = 4;
        #FL;
        in[3].Send(in_data);
        $display("send: %b",in_data);
        #BL;

        // pe to west, also check pe out
        in_data = 0;
        in_data[47] = 1'b0;
        in_data[46:44] = 3'd 2;
        in_data[39:0] = 5;
        #FL;
        in[4].Send(in_data);
        $display("send: %b",in_data);
        #BL;

    end

    initial begin
        #100;
        $display("*** Stopped by watchdog timer ***");
        $stop;
    end
endmodule