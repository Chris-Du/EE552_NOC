`timescale 1ns/100ps

import SystemVerilogCSP::*;

module ifmap_mem_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 3;
    parameter ADDR_F = 2;

    logic [WIDTH-1:0] data;

    Channel #(.hsProtocol(P4PhaseBD)) intf [3:0] ();
    ifmap_mem im (intf[0], intf[1], intf[2], intf[3]);

    initial begin
    	for(int i = 0; i < DEPTH_I; i++) begin
    		#2;
    		intf[0].Send(i);
    		intf[1].Send(i);
    	end

    	for(int i = 0; i < DEPTH_I; i++) begin
    		#2;
    		intf[2].Send(i);
    		intf[3].Receive(data);

    		$display("ifmap mem data = %d store @ %d", data, i);
    	end

    	$stop;
    end


endmodule

module filter_mem_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 3;
    parameter ADDR_F = 2;

    logic [WIDTH-1:0] data;

    Channel #(.hsProtocol(P4PhaseBD)) intf [3:0] ();
    filter_mem fm (intf[0], intf[1], intf[2], intf[3]);

    initial begin
    	for(int i = 0; i < DEPTH_F; i++) begin
    		#2;
    		intf[0].Send(i);
    		intf[1].Send(i);
    	end

    	for(int i = 0; i < DEPTH_F; i++) begin
    		#2;
    		intf[2].Send(i);
    		intf[3].Receive(data);

    		$display("filter mem data = %d store @ %d", data, i);
    	end

    	$stop;
    end


endmodule

module multiplier_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 3;
    parameter ADDR_F = 2;

    logic [WIDTH-1:0] data;

    Channel #(.hsProtocol(P4PhaseBD)) intf [2:0] ();
    multiplier mul (intf[0], intf[1], intf[2]);

    initial begin
        for(int i = 0; i < DEPTH_I; i++) begin
            #2;
            intf[0].Send(i);
            intf[1].Send(i);
            #2;
            intf[2].Receive(data);
            $display("data = %d", data);
        end

        $stop;
    end

endmodule

/*
module pe_packetizer_tb;
    parameter packet_width = 55;

    logic [packet_width-1:0] packet;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [12:0] ();

    pe_depacketizer pedep(.packet_in(intf[0]), .ifmap_in(intf[1]), .ifmap_addr(intf[2]), .filter_in(intf[3]), .filter_addr(intf[4]), 
    .psum_in(intf[5]), .start(intf[6]), .sourceInft(intf[7]), .destInft(intf[8]), .x_dirInft(intf[9]), .y_dirInft(intf[10]), 
    .x_hopInft(intf[11]), .y_hopInft(intf[12]));

    initial begin
        #10;
        inft[0].Send();
        #10;
        intf[1].Receive(packet);
        #10;
        inft[0].Send();
        #10;
        intf[1].Receive(packet);
        #10;
        $stop;
    end

endmodule
*/

/*
module pe_depacketizer_tb;
    parameter packet_width = 57;

    logic [packet_width-1:0] packet;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [13:0] ();

    pe_depacketizer pedep(.packet_in(intf[0]), .ifmap_in(intf[1]), .ifmap_addr(intf[2]), .filter_in(intf[3]), .filter_addr(intf[4]), 
    .psum_in(intf[5]), .start(intf[6]), .sourceInft(intf[7]), .destInft(intf[8]), .x_dirInft(intf[9]), .y_dirInft(intf[10]), 
    .x_hopInft(intf[11]), .y_hopInft(intf[12]));

    initial begin
        intf[0].Send('h00F3512345);
        #10;
        intf[13].Receive(packet);
        #10;
        intf[0].Send('h10F3534567);
        #10;
        intf[13].Receive(packet);
        #10;
        $stop;
    end

endmodule
*/

module complete_pe_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 2;

    logic [packet_width-1:0] packet;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [1:0] ();
    pe pe_i(.packet_in(intf[0]), .packet_out(intf[1]));
    data_bucket db (intf[1]);

    initial begin
        #20;
        intf[0].Send('h00F350102030405);
        #20;
        intf[0].Send('h10F350304050607);
        #200;
        $stop;
    end
endmodule
