/*
TO DO:
1. test the module
*/
`timescale 1ns/100ps

import SystemVerilogCSP::*;

module output_mem_depacketizer(interface packet_in, output_done, conv_mem_in_ts1, conv_mem_addr_ts1, conv_mem_in_ts2, conv_mem_addr_ts2, start);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 3;
    parameter psum_width = 13;
    parameter psum_addr_width = 27;

    parameter THRESHOLD = 64;
    parameter ADDR_C = 9;//2^9 = 512
    parameter DEPTH_C = 441;
    parameter DEPTH_TS = 2;
    parameter ADDR_TS = 2;

    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet_data;
    logic [psum_addr_width-1:0] addr_psum;
    logic [psum_width-1:0] conv_out;
    logic [addr_width-1:0] source, dest;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;

    logic out_spike = 0;
    logic [psum_width-1:0] out_residue = 0;
    logic [ADDR_C-1:0] conv_out_ts1_addr = 0;
    logic [ADDR_C-1:0] conv_out_ts2_addr = 0;
    logic [ADDR_TS-1:0] conv_out_ts = 0;

    logic ts1_ready = 0;
    logic ts2_ready = 0;
    logic out_done = 0;

    always begin
    	packet_in.Receive(packet_data);

        source = packet_data[55:52];
        dest = packet_data[51:48];
        addr_psum = packet_data[39:13];
        conv_out = packet_data[12:0];

        $display("Receive packet in output mem depack:\nsource = %d\ndest = %d\npsum addr = %d\npsum = %d\n", 
        source, dest, addr_psum, conv_out);

        #FL;

        //conv out from PE1-5 for ts1
       	if(source == 13) begin
            fork
                conv_mem_in_ts1.Send(conv_out);
                conv_mem_addr_ts1.Send(addr_psum);
            join

            //$display("send conv out in depack\nconv_data = %d @ mem_addr = %d\n", conv_out, conv_out_ts1_addr);
            
            //if addr reaches 440, flag ts1_ready 
            if(conv_out_ts1_addr >= DEPTH_C-1) ts1_ready = 1;
            //counter < 440
            else conv_out_ts1_addr++; 
                
       	end
       	//conv out from PE6-10
       	else begin
            fork
                conv_mem_in_ts2.Send(conv_out);
                conv_mem_addr_ts2.Send(addr_psum);
            join

            //if addr reaches 440, flag ts2_ready 
            if(conv_out_ts2_addr >= DEPTH_C-1) ts2_ready = 1;
            //counter < 440
            else conv_out_ts2_addr++;
       		
       	end

        #BL;

        $display("ts1_ready = %b\nts2_ready = %b\n", ts1_ready, ts2_ready);

        if(ts1_ready && ts2_ready) begin
            start.Send(0);

            #BL;

            ts1_ready = 0;
            ts2_ready = 0;
            conv_out_ts1_addr = 0;
            conv_out_ts2_addr = 0;

            output_done.Receive(out_done);

            #FL;
        end
        
    end

endmodule


module output_mem_array(interface conv_mem_in1, conv_mem_addr1, conv_mem_in2, conv_mem_addr2, conv_mem_out_addr, conv_mem_out);
    parameter ADDR_C = 9;//2^9 = 512
    parameter DEPTH_C = 441;
    parameter DEPTH_TS = 2;
    
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;

    parameter FL = 12;
    parameter BL = 4;

    parameter conv_width = 13; 

    logic [ADDR_C-1:0] in_addr, out_addr;
    logic [DEPTH_TS-1:0] in_ts, out_ts;
    logic [conv_width-1:0] conv_data;

    logic [conv_width-1:0] conv_mem_array [DEPTH_C-1:0];

    //write port 1
    always begin
        fork
            conv_mem_in1.Receive(conv_data);
            conv_mem_addr1.Receive(in_addr);
        join

        #FL;

        conv_mem_array[in_addr] = conv_data;

        $display("write data = %d @ addr = %d\n", conv_data, in_addr);

        #BL;
    end

    //write port 2
    always begin
        fork
            conv_mem_in2.Receive(conv_data);
            conv_mem_addr2.Receive(in_addr);
        join

        #FL;

        conv_mem_array[in_addr] = conv_data;

        $display("write data = %d @ addr = %d\n", conv_data, in_addr);

        #BL;
    end

    //read
    always begin    
        conv_mem_out_addr.Receive(out_addr);

        #FL;

        conv_mem_out.Send(conv_mem_array[out_addr]);

        $display("read data = %d @ addr = %d\n", conv_mem_array[out_addr], out_addr);

        #BL;
    end

endmodule

module output_mem_control(interface start, conv_mem_out_addr_ts1, conv_mem_out_addr_ts2, done);
    parameter ADDR_C = 9;//2^9 = 512
    parameter DEPTH_C = 441;

    parameter FL = 2;
    parameter BL = 2;

    logic st;

    always begin
        start.Receive(st);

        if(st == 0) begin
            for(int i = 0; i < DEPTH_C; i++) begin
                #FL;
                conv_mem_out_addr_ts1.Send(i);
                #BL;
            end

            for(int j = 0; j < DEPTH_C; j++) begin
                #FL;
                //read ts1 residue from mem
                conv_mem_out_addr_ts1.Send(j);
                conv_mem_out_addr_ts2.Send(j);
                #BL;    
            end

            done.Send(1);

            #BL;
        end
    end

endmodule

module output_mem_out(interface conv_mem_out_ts1, conv_mem_out_ts2, done, conv_mem_in_ts1, conv_mem_addr_ts1, conv_mem_in_ts2, conv_mem_addr_ts2,
    start_r, out_spike_addr, out_spike_data, ts_r, layer_r, done_r, output_done);
    parameter THRESHOLD = 64;
    parameter ADDR_C = 9;//2^9 = 512
    parameter DEPTH_C = 441;

    parameter conv_width = 13; 
    logic out_spike_ts1 = 0, out_spike_ts2 = 0;
    logic [conv_width-1:0] conv_data1, conv_data2;
    logic [conv_width-1:0] out_residue1, out_residue2;
    logic don_e;

    parameter FL = 2;
    parameter BL = 2;

    always begin
        start_r.Send(1);

        ts_r.Send(1);
        layer_r.Send(1);

        #BL;

        for(int i = 0; i < DEPTH_C; i++) begin
            conv_mem_out_ts1.Receive(conv_data1);

            #FL;

            //conv out >= 64
            if(conv_data1 >= THRESHOLD) begin
                out_spike_ts1 = 1;
                out_residue1 = conv_data1 - THRESHOLD;
            end
            //conv out < 64
            else begin
                out_spike_ts1 = 0;
                out_residue1 = conv_data1;
            end

            fork
                //write residue back to mem
                conv_mem_in_ts1.Send(out_residue1);
                conv_mem_addr_ts1.Send(i);

                $display("write residue = %d @ addr = %d for ts1\n", out_residue1, i);

                //send output spike ts1
                out_spike_data.Send(out_spike_ts1);
                out_spike_addr.Send(i);

                $display("output spike = %d @ addr = %d for ts1\n", out_spike_ts1, i);
            join

            #BL;
        end

        ts_r.Send(2);
        layer_r.Send(1);
        $display("+++++++++++++++++++++++++++++++SEND 2 TO TS_R, SEND 1 TO LAYER_R");

        #BL;

        for(int j = 0; j < DEPTH_C; j++) begin
            fork
                conv_mem_out_ts1.Receive(conv_data1);
                conv_mem_out_ts2.Receive(conv_data2);
            join

            $display("=======================================Receive ts1 residue and ts2 conv out");

            #FL;

            conv_data2 = conv_data1 + conv_data2;

            //conv out >= 64
            if(conv_data2 >= THRESHOLD) begin
                out_spike_ts2 = 1;
                out_residue2 = conv_data2 - THRESHOLD;
            end
            //conv out < 64
            else begin
                out_spike_ts2 = 0;
                out_residue2 = conv_data2;
            end

            fork
                //write residue back to mem
                conv_mem_in_ts2.Send(out_residue2);
                conv_mem_addr_ts2.Send(j);

                $display("write residue = %d @ addr = %d for ts2\n", out_residue2, j);

                //send output spike ts2
                out_spike_data.Send(out_spike_ts2);
                out_spike_addr.Send(j);

                $display("output spike = %d @ addr = %d for ts2\n", out_spike_ts2, j);
            join

            #BL;
        end

        done.Receive(don_e);

        #FL;

        fork
            done_r.Send(1);
            output_done.Send(1);
        join

        #BL;

    end

endmodule


module output_mem(interface packet_in, start_r, out_spike_addr, out_spike_data, ts_r, layer_r, done_r);
    parameter DEPTH_C = 441;
    parameter FL = 2;
    parameter BL = 2;

    parameter packet_width = 57;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_in1_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_addr1_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_in1_ts2 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_addr1_ts2 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) start ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) out_addr_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) out_addr_ts2 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) done ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_in2_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_addr2_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_in2_ts2 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_addr2_ts2 ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_out_ts1 ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) mem_out_ts2 ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) out_done ();

    output_mem_depacketizer #(.DEPTH_C(DEPTH_C))
    om_dep(.packet_in(packet_in), .output_done(out_done), .conv_mem_in_ts1(mem_in1_ts1), .conv_mem_addr_ts1(mem_addr1_ts1), 
        .conv_mem_in_ts2(mem_in1_ts2), .conv_mem_addr_ts2(mem_addr1_ts2), .start(start));

    output_mem_control #(.DEPTH_C(DEPTH_C), .FL(FL), .BL(BL))
    om_control(.start(start), .conv_mem_out_addr_ts1(out_addr_ts1), .conv_mem_out_addr_ts2(out_addr_ts2), .done(done));

    output_mem_array #(.DEPTH_C(DEPTH_C), .FL(FL), .BL(BL))
    oma_ts1(.conv_mem_in1(mem_in1_ts1), .conv_mem_addr1(mem_addr1_ts1), .conv_mem_in2(mem_in2_ts1), .conv_mem_addr2(mem_addr2_ts1), 
        .conv_mem_out_addr(out_addr_ts1), .conv_mem_out(mem_out_ts1));

    output_mem_array #(.DEPTH_C(DEPTH_C), .FL(FL), .BL(BL))
    oma_ts2(.conv_mem_in1(mem_in1_ts2), .conv_mem_addr1(mem_addr1_ts2), .conv_mem_in2(mem_in2_ts2), .conv_mem_addr2(mem_addr2_ts2), 
        .conv_mem_out_addr(out_addr_ts2), .conv_mem_out(mem_out_ts2));

    output_mem_out #(.DEPTH_C(DEPTH_C), .FL(FL), .BL(BL))
    om_out(.conv_mem_out_ts1(mem_out_ts1), .conv_mem_out_ts2(mem_out_ts2), .done(done), 
        .conv_mem_in_ts1(mem_in2_ts1), .conv_mem_addr_ts1(mem_addr2_ts1), .conv_mem_in_ts2(mem_in2_ts2), .conv_mem_addr_ts2(mem_addr2_ts2),
        .start_r(start_r), .out_spike_addr(out_spike_addr), .out_spike_data(out_spike_data), .ts_r(ts_r), .layer_r(layer_r), .done_r(done_r), .output_done(out_done));

endmodule

