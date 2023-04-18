`timescale 1ns/1ns

import SystemVerilogCSP::*;

module filter_mem_node_tb;

    parameter WIDTH_addr = 12;
    parameter NODE = 11;
    parameter DEPTH_F =25;
    parameter FL = 2;
    parameter BL = 1;
    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;
    parameter WIDTH_data = 8;

    logic [WIDTH_data-1:0] data = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) load_start();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) filter_data();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(12)) filter_addr();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) load_done();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_in();

    filter_mem_node node11(
        load_start,
        filter_data,
        filter_addr,
        load_done,
        PE_in
    );

    data_bucket #(.NODE(1),.WIDTH(WIDTH_packet)) node1_bucket(PE_in);;

    initial begin
        load_start.Send(1'b1);
        for(integer i = 0; i < 5*5; i ++) begin
            filter_addr.Send(i);
            filter_data.Send(data);
            data = data+1'b1;  
        end

        load_done.Send(1'b1);
        $display("Send done. Start reading from PE_in");
    end

endmodule