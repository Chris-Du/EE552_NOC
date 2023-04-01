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