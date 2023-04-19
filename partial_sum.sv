/*
TO DO:

*/
`timescale 1ns/100ps

import SystemVerilogCSP::*;

module partial_sum_depacketizer(interface from_pe1, from_pe2, from_pe3, from_pe4, from_pe5, 
    sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, psum_addrForwardIntf, conv_outForwardIntf);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter DEPTH_P = 21;
    parameter ROWS_P = 5;
    
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 3;
    parameter psum_width = 13;
    parameter psum_addr_width = 27;

    integer fp;

    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet_data;
    logic [psum_addr_width-1:0] addr_psum;
    logic [psum_width-1:0] data_psum;
    logic [addr_width-1:0] source, dest;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;

    logic [psum_width-1:0] conv_out = 0;

    logic conv_done;


    always begin

        for(int i = 1; i < 6; i++) begin
            if(i == 1) from_pe1.Receive(packet_data);
            else if(i == 2) from_pe2.Receive(packet_data);
            else if(i == 3) from_pe3.Receive(packet_data);
            else if(i == 4) from_pe4.Receive(packet_data);
            else from_pe5.Receive(packet_data);

            source = packet_data[55:52];
            dest = packet_data[51:48];
            addr_psum = packet_data[39:13];
            data_psum = packet_data[12:0]; 

            /*
            $display("Receive packet in partial sum depack:\nsource = %d\ndest = %d\npsum addr = %d\npsum = %d\n", 
            source, dest, addr_psum, data_psum);
            */

            #FL;

            conv_out += data_psum;
            
            //add a display here to see when this module starts its main loop
            fp = $fopen("partial_sum.out");
            $fdisplay(fp,"PE%d out data: %h from %d addr = %d with data = %d",dest,packet_data,source,addr_psum,data_psum);
            //Communication action Receive is finished 

            #BL;

        end

        if(dest == 13) begin
            source = 13;
            dest = source + 2;
            x_dir = 1;
            y_dir = 1;
            x_hop = 3'b010;
            y_hop = 3'b000;          
        end
        //dest == 14
        else begin
            source = 14;
            dest = source + 1;  
            x_dir = 1;
            y_dir = 1;
            x_hop = 3'b001;
            y_hop = 3'b000;          
        end

        fork
            sourceIntf.Send(source);
            destIntf.Send(dest);
            x_dirIntf.Send(x_dir);
            y_dirIntf.Send(y_dir);
            x_hopIntf.Send(x_hop);
            y_hopIntf.Send(y_hop);  
            psum_addrForwardIntf.Send(addr_psum);
            conv_outForwardIntf.Send(conv_out);
        join

        //$display("end depacketizer");

        conv_out = 0;

        #BL;

    end

endmodule

module partial_sum_packetizer(interface sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, 
    psum_addrForwardIntf, conv_outForwardIntf, packet_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter DEPTH_P = 21;
    parameter ROWS_P = 5;

    parameter conv_width = 13;
    parameter psum_addr_width = 27;
    parameter hop_width = 3;
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter iff_type_width = 2;

    parameter FL = 1;
    parameter BL = 1;

    logic [conv_width-1:0] conv_output;
    logic [packet_width-1:0] packet_data = 0;
    logic [psum_addr_width-1:0] psum_addr = 0;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir, don_e;
    logic [addr_width-1:0] source, dest;
    logic [iff_type_width-1:0] iff_type = 0;

    always begin

        fork
            sourceIntf.Receive(source);
            destIntf.Receive(dest);
            x_dirIntf.Receive(x_dir);
            y_dirIntf.Receive(y_dir);
            x_hopIntf.Receive(x_hop);
            y_hopIntf.Receive(y_hop);
            psum_addrForwardIntf.Receive(psum_addr);
            conv_outForwardIntf.Receive(conv_output);
        join

        #FL;

        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        /*
        $display("Send conv out\niff type = %b\nsource = %d\ndest = %d\nx_dir = %b\nx_hop = %d\ny_dir = %b\ny_hop = %d\npsum_addr = %d\nconv_out = %d\n",
        iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output);
        */

        packet_out.Send(packet_data);
        
        //$display("packet = %b\n", packet_data);

        #BL;

    end

endmodule

module partial_sum(interface from_pe1, from_pe2, from_pe3, from_pe4, from_pe5, packet_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter packet_width = 57;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) sourceIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) destIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_addr_forward ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) conv_out_forward ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) conv_output ();


    partial_sum_depacketizer #(.WIDTH(WIDTH))
    psum_dep (.from_pe1(from_pe1), .from_pe2(from_pe2), .from_pe3(from_pe3), .from_pe4(from_pe4), .from_pe5(from_pe5), 
    .sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), 
    .psum_addrForwardIntf(psum_addr_forward), .conv_outForwardIntf(conv_out_forward));

    partial_sum_packetizer #(.WIDTH(WIDTH))
    psum_p (.sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), 
    .psum_addrForwardIntf(psum_addr_forward), .conv_outForwardIntf(conv_out_forward), .packet_out(packet_out));

endmodule