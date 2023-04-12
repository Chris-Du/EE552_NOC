/*
TO DO:

*/
`timescale 1ns/100ps

import SystemVerilogCSP::*;

module partial_sum_depacketizer(interface packet_in, psum_addr, psum_in, adder_in,
    sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, psum_addrForwardIntf, start);
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


    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet_data;
    logic [psum_addr_width-1:0] addr_psum;
    logic [psum_width-1:0] data_psum;
    logic [addr_width-1:0] source, dest;
    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;

    always begin

        for(int i = 0; i < ROWS_P; i++) begin
            packet_in.Receive(packet_data);

            source = packet_data[55:52];
            dest = packet_data[51:48];
            addr_psum = packet_data[39:13];
            data_psum = packet_data[12:0]; 

            #FL;

            fork
                psum_addr.Send(i);  
                psum_in.Send(data_psum);   
                //$display("store data = %d @ addr = %d",data_psum, i);           
            join

            #BL;

        end
    	

        if(dest == 13) begin
            source = 13;
            dest = source + 2;
            x_dir = 1;
            y_dir = 1;
            x_hop = 3'b010;
            y_hop = 2'b000;          
        end
        //dest == 14
        else begin
            source = 14;
            dest = source + 1;  
            x_dir = 1;
            y_dir = 1;
            x_hop = 3'b001;
            y_hop = 2'b000;          
        end

        fork
            start.Send(0);
            sourceIntf.Send(source);
            destIntf.Send(dest);
            x_dirIntf.Send(x_dir);
            y_dirIntf.Send(y_dir);
            x_hopIntf.Send(x_hop);
            y_hopIntf.Send(y_hop);  
            psum_addrForwardIntf.Send(addr_psum);          
        join

        //$display("end depacketizer");

        #BL;

    end

    always begin
        adder_in.Send(0);
        
        #BL;
    end

endmodule

module partial_sum_packetizer(interface sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, 
    psum_addrForwardIntf, conv_out, done, packet_out);
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

    logic [conv_width-1:0] conv_output = 0;
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
        join

        conv_out.Receive(conv_output);

        //$display("==============conv_out received in pack");

        done.Receive(don_e);

        #FL;

        packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output};
        $display("Send conv out\niff type = %b\nsource = %d\ndest = %d\nx_dir = %b\nx_hop = %d\ny_dir = %b\ny_hop = %d\npsum_addr = %d\nconv_out = %d\n",
        iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, conv_output);

        packet_out.Send(packet_data);
        $display("packet = %b\n", packet_data);

        #BL;

    end

endmodule

module partial_sum_adder(interface psum_mem_out, accum_out, adder_in, add_sel, adder_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter psum_width = 13;
    
    logic [psum_width-1:0] data0, data1, result;
    logic sel;

    always begin
        add_sel.Receive(sel);

        if(sel == 0) begin
            fork
                psum_mem_out.Receive(data0);
                accum_out.Receive(data1);
            join
        end
        //sel == 1
        else begin
            fork
                adder_in.Receive(data0);
                accum_out.Receive(data1);
            join
        end
        //$display("adder receive data0 = %d, data1 = %d @time = %d", data0, data1, $time);
        #FL;

        result = data0 + data1;
        adder_out.Send(result);
        //$display("adder send result = %d @time = %d", result, $time);
        #BL;
    end

endmodule

module partial_sum_control(interface start, psum_out_addr, acc_clear, split_sel, add_sel, done);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter ROWS_P = 5;
    parameter ADDR_P = 5;

    logic st; 
    int no_iterations = ROWS_P;

    always begin
        //$display("starts psum_control\n");

        start.Receive(st);

        #FL;

        //$display("++++++++++++++++++RECEIVE START\n");

        if(st == 0) begin
            acc_clear.Send(1); //restarting the accumulator


            //$display("----------CLEAR ACC IN CTRL\n");
            for(int i = 0; i < no_iterations; i++) begin
                #FL;

                fork
                    split_sel.Send(0);// steers to accumulator
                    add_sel.Send(0); // selects inputs for sum =.a0 + .b
                    psum_out_addr.Send(i);//send psum_out_addr to mem
                    acc_clear.Send(0);//accumulator enabled
                join   

                #BL;

            end

            fork
                split_sel.Send(1); // steers to psum_out
                add_sel.Send(1); // selects inputs for sum = .a1 + .b  
                done.Send(1);        
            join

            #BL;

        end
    end

endmodule

module partial_sum_split(interface adder_out, split_sel, to_accum, conv_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter psum_width = 13;

    logic [psum_width-1:0] data; 
    logic sel;

    always begin
        //$display("starts psum_split\n");

        fork
            adder_out.Receive(data);
            split_sel.Receive(sel);
        join

        #FL;

        if(sel == 0) begin
            to_accum.Send(data);
            //$display("send data to accum = %d\n", data);
        end
        else begin
            conv_out.Send(data);
            //$display("send conv_out = %d\n", data);
        end

        //$display("end psum_split\n");

        #BL;

    end    

endmodule


module partial_sum_accumulator(interface from_split, acc_clear, to_adder);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter psum_width = 13;

    logic [psum_width-1:0] data;
    logic clear;

    always begin
        //$display("starts psum_accum\n");

        acc_clear.Receive(clear);

        if(clear) begin
            data = 0;
            //$display("accum receive clear = 1 @time = %d", $time);
        end

        else begin
            from_split.Receive(data);
            //$display("accum receive data = %d @time = %d", data, $time);
        end

        #FL;

        to_adder.Send(data);
        //$display("accum send data = %d @time = %d", data, $time);
        //$display("end psum_accum\n");

        #BL;

    end

endmodule

module partial_sum_mem(interface psum_in, psum_addr, psum_out_addr, psum_mem_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter DEPTH_P = 21;
    parameter ROWS_P = 5;
    parameter ADDR_P = 5;

    parameter FL = 2;
    parameter BL = 2;

    parameter psum_addr_width = 27;
    parameter psum_width = 13; 

    logic [ADDR_P-1:0] in_addr, out_addr;
    logic [psum_width-1:0] psum_data;



    //each array to store an entire row of psum
    logic [psum_width-1:0] psum_array [ROWS_P-1:0];

    //write
    always begin
        //$display("starts psum_mem\n");

        fork
            psum_in.Receive(psum_data);
            psum_addr.Receive(in_addr);
        join
        
        #FL;

        psum_array[in_addr] = psum_data;

        #BL;
    end

    //read
    always begin
        psum_out_addr.Receive(out_addr);

        #FL;

        psum_mem_out.Send(psum_array[out_addr]);

        //$display("psum_mem read, data = %d @ addr = %d\n", psum_array[out_addr], out_addr);

        #BL;
    end


endmodule

module partial_sum(interface packet_in, packet_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    parameter packet_width = 57;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) start ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) done ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) split_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) acc_clear ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) sourceIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) destIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_addr_forward ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_in ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_out_addr ();  
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_mem_out ();  
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) accum_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) to_accum ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) adder_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) conv_output ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) adder_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) adder_in ();

    partial_sum_depacketizer #(.WIDTH(WIDTH))
    psum_dep (.packet_in(packet_in), .psum_addr(psum_addr), .psum_in(psum_in), .adder_in(adder_in),
    .sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), 
    .psum_addrForwardIntf(psum_addr_forward), .start(start));

    partial_sum_packetizer #(.WIDTH(WIDTH))
    psum_p (.sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), 
    .psum_addrForwardIntf(psum_addr_forward), .conv_out(conv_output), .done(done), .packet_out(packet_out));

    partial_sum_control #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    psum_ctrl (.start(start), .psum_out_addr(psum_out_addr), .acc_clear(acc_clear), .split_sel(split_sel), .add_sel(adder_sel), .done(done));

    partial_sum_mem #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    psum_mem (.psum_in(psum_in), .psum_addr(psum_addr), .psum_out_addr(psum_out_addr), .psum_mem_out(psum_mem_out));

    partial_sum_adder #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    psum_add(.psum_mem_out(psum_mem_out), .accum_out(accum_out), .adder_in(adder_in), .add_sel(adder_sel), .adder_out(adder_out));

    partial_sum_split #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    psum_sp(.adder_out(adder_out), .split_sel(split_sel), .to_accum(to_accum), .conv_out(conv_output));

    partial_sum_accumulator #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    psum_acc(.from_split(to_accum), .acc_clear(acc_clear), .to_adder(accum_out));

endmodule