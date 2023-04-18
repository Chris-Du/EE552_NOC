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

module complete_pe_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 2;
    parameter BL = 2;

    parameter packet_width = 57;
    parameter data_width = 40;
    parameter hop_width = 3;
    parameter addr_width = 4;
    parameter iff_type_width = 2;

    logic [packet_width-1:0] packet_data;
    logic [data_width-1:0] data;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic [iff_type_width-1:0] iff_type = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [1:0] ();
    pe pe_i(.packet_in(intf[0]), .packet_out(intf[1]));
    data_bucket db (intf[1]);

    initial begin

        /*
        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd2;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #1500;
        */

        /*
        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd1;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #1500;
        */

        
        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);



        #10;
        iff_type = 2'h0;
        source = 4'd11;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h0504030201;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #10;
        iff_type = 2'h1;
        source = 4'd12;
        dest = 4'd6;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        data = 40'h1F;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};
        intf[0].Send(packet_data);
        
        #1500;

        $stop;
    end
endmodule


module partial_sum_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 2;
    parameter BL = 2;

    parameter conv_width = 13;
    parameter psum_addr_width = 27;
    parameter hop_width = 3;
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter iff_type_width = 2;

    logic [conv_width-1:0] conv_output = 0;
    logic [packet_width-1:0] packet_data = 0;
    logic [psum_addr_width-1:0] psum_addr = 0;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic [iff_type_width-1:0] iff_type = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [1:0] ();
    partial_sum psum(.packet_in(intf[0]), .packet_out(intf[1]));
    data_bucket db (intf[1]);

    initial begin
        //send 5 psum packets to partial sum adder
        
        //PE1
        #2;
        iff_type = 2'h0;
        source = 4'h1;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h5;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);
        
        //PE2
        #2;
        iff_type = 2'h0;
        source = 4'h2;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'hA;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);
        
        //PE3
        #2;
        iff_type = 2'h0;
        source = 4'h3;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'hF;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //PE4
        #2;
        iff_type = 2'h0;
        source = 4'h4;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h14;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //PE5
        #2;
        iff_type = 2'h0;
        source = 4'h5;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h19;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);
        
        #50;

        //send 5 psum packets to partial sum adder
        
        //PE1
        #2;
        iff_type = 2'h0;
        source = 4'h1;
        dest = 4'hE;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'hF;
        conv_output = 13'h8;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);
        
        //PE2
        #2;
        iff_type = 2'h0;
        source = 4'h2;
        dest = 4'hE;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'hF;
        conv_output = 13'h12;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);
        
        //PE3
        #2;
        iff_type = 2'h0;
        source = 4'h3;
        dest = 4'hE;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'hF;
        conv_output = 13'h1C;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //PE4
        #2;
        iff_type = 2'h0;
        source = 4'h4;
        dest = 4'hE;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'hF;
        conv_output = 13'h26;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //PE5
        #2;
        iff_type = 2'h0;
        source = 4'h5;
        dest = 4'hE;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'hF;
        conv_output = 13'h30;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #50;
        $stop;
    end

endmodule

module output_mem_depacketizer_tb;
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 2;
    parameter BL = 2;

    parameter conv_width = 13;
    parameter psum_addr_width = 27;
    parameter hop_width = 3;
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter iff_type_width = 2;

    logic [conv_width-1:0] conv_output = 0;
    logic [packet_width-1:0] packet_data = 0;
    logic [psum_addr_width-1:0] psum_addr = 0;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic [iff_type_width-1:0] iff_type = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [2:0] ();
    output_mem_depacketizer omd(.packet_in(intf[0]), .conv_mem_in(intf[1]), .conv_mem_addr(intf[2]));
    data_bucket db1 (intf[1]);
    data_bucket db2 (intf[2]);

    initial begin
        #2;
        iff_type = 2'h0;
        source = 4'hD;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h5;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #2;
        iff_type = 2'h0;
        source = 4'hD;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h6;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #2;
        iff_type = 2'h0;
        source = 4'hD;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h7;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #2;
        iff_type = 2'h0;
        source = 4'hD;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h8;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #2;
        iff_type = 2'h0;
        source = 4'hD;
        dest = 4'hD;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'h9;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        #50;
        $stop;
    end
endmodule

module output_mem_array_tb;
    parameter packet_width = 57;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [5:0] ();
    output_mem_array oma(.conv_mem_in(intf[0]), .conv_mem_ts(intf[1]), .conv_mem_addr(intf[2]), .conv_mem_out_ts(intf[3]), 
        .conv_mem_out_addr(intf[4]), .conv_mem_out(intf[5]));
    data_bucket db (intf[5]);

    initial begin
        #5;
        intf[0].Send(5);
        intf[1].Send(0);
        intf[2].Send(5);

        #5;
        intf[3].Send(0);
        intf[4].Send(5);

        #5;
        intf[0].Send(10);
        intf[1].Send(1);
        intf[2].Send(10);

        #5;
        intf[3].Send(1);
        intf[4].Send(10);

        #50;
        $stop;
    end

endmodule

module output_mem_tb;
    parameter DEPTH_C = 4;
    parameter FL = 2;
    parameter BL = 2;

    parameter conv_width = 13;
    parameter psum_addr_width = 27;
    parameter hop_width = 3;
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter iff_type_width = 2;

    logic [conv_width-1:0] conv_output = 0;
    logic [packet_width-1:0] packet_data = 0;
    logic [psum_addr_width-1:0] psum_addr = 0;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic [iff_type_width-1:0] iff_type = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [6:0] ();
    
    output_mem #(.DEPTH_C(DEPTH_C), .FL(FL), .BL(BL))
    om(.packet_in(intf[0]), .start_r(intf[1]), .out_spike_addr(intf[2]), .out_spike_data(intf[3]), .ts_r(intf[4]), .layer_r(intf[5]), .done_r(intf[6]));
    
    data_bucket db1 (intf[1]);
    data_bucket db2 (intf[2]);
    data_bucket db3 (intf[3]);
    data_bucket db4 (intf[4]);
    data_bucket db5 (intf[5]);
    data_bucket db6 (intf[6]);

    initial begin
        //ts1[0] = 74
        #2;
        iff_type = 2'h0;
        source = 4'd13;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'd74;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts2[0] = 20
        #2;
        iff_type = 2'h0;
        source = 4'd14;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h0;
        conv_output = 13'd20;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts1[1] = 33
        #2;
        iff_type = 2'h0;
        source = 4'd13;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h1;
        conv_output = 13'd33;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts2[1] = 31
        #2;
        iff_type = 2'h0;
        source = 4'd14;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h1;
        conv_output = 13'd31;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts1[2] = 105
        #2;
        iff_type = 2'h0;
        source = 4'd13;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h2;
        conv_output = 13'd105;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts2[2] = 20
        #2;
        iff_type = 2'h0;
        source = 4'd14;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h2;
        conv_output = 13'd20;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts1[3] = 68
        #2;
        iff_type = 2'h0;
        source = 4'd13;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h3;
        conv_output = 13'd68;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);

        //ts2[3] = 60
        #2;
        iff_type = 2'h0;
        source = 4'd14;
        dest = 4'd15;
        x_dir = 1'b1;
        x_hop = 3'b111;
        y_dir = 1'b1;
        y_hop = 3'b111;    
        psum_addr = 27'h3;
        conv_output = 13'd60;
        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        intf[0].Send(packet_data);


        #50;
        $stop;
    end

endmodule