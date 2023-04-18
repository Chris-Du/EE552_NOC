`timescale 1ns/1ns

import SystemVerilogCSP::*;

module if_mem_node_tb;

    parameter WIDTH_addr = 12;
    parameter NODE = 12;
    parameter DEPTH_I =25;
    parameter FL = 2;
    parameter BL = 1;
    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;

    logic data = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(18)) load_start();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(18)) ifmap_data();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(18)) ifmap_addr();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(18)) timestep();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(18)) load_done();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_in();

    if_mem_node node12(
        load_start,
        ifmap_data,
        ifmap_addr,
        timestep,
        load_done,
        PE_in
    );

    data_bucket #(.NODE(1),.WIDTH(WIDTH_packet)) node1_bucket(PE_in);;

    initial begin
        load_start.Send(1'b1);
        for(integer i = 0; i < 25*25; i ++) begin
            timestep.Send(1);
            ifmap_addr.Send(i);
            ifmap_data.Send(data);
            data = ~data;  
        end
        data = 1;
        for(integer i = 0; i < 25*25; i ++) begin
            timestep.Send(2);
            ifmap_addr.Send(i);
            ifmap_data.Send(data);
            data = ~data;  
        end

        load_done.Send(1'b1);
        $display("Send done. Start reading from PE_in");
    end

endmodule