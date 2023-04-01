`timescale 1ns/100ps

import SystemVerilogCSP::*;

module pe_depacketizer(interface packet_in, ifmap_in, ifmap_addr, filter_in, filter_addr, psum_in, start, 
    sourceInft, destInft, x_dirInft, y_dirInft, x_hopInft, y_hopInft);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    
    parameter packet_width = 55;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 2;

    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet;
    logic [data_width-1:0] data;
    logic [hop_width-1:0] x_hop, y_hop;
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic iff_type;

    logic [WIDTH-1:0] filter_data, ifmap_data;

    logic [ADDR_F-1:0] addr_filter = 0;
    logic [ADDR_I-1:0] addr_ifmap = 0;


    always begin
        packet_in.Receive(packet);

        iff_type = packet[54];
        source = packet[53:50];
        dest = packet[49:46];
        x_dir = packet[45];
        y_dir = packet[44];
        x_hop = packet[43:42];
        y_hop = packet[41:40];
        data = packet[39:0];

        //ifmap
        if(iff_type) begin
            for(int i = 0; i < DEPTH_I; i++) begin
                #FL;
                ifmap_data = (data >> i*8) & 8'hFF;
                ifmap_addr.Send(addr_ifmap);
                ifmap_in.Send(data);
                addr_ifmap++;
                #BL;
            end
        end
        //filter
        else begin 
            for(int i = 0; i < DEPTH_F; i++) begin
                #FL;
                filter_data = (data >> i*8) & 8'hFF;
                filter_addr.Send(addr_filter);
                filter_in.Send(data);
                addr_filter++;
                #BL;
            end
        end

        //send the header data to packetizer
        fork
            sourceInft.Send(source);
            destInft.Send(dest);
            x_dirInft.Send(x_dir);
            y_dirInft.Send(y_dir);
            x_hopInft.Send(x_hop);
            y_hopInft.Send(y_hop);
            start.Send(0);
            psum_in.Send(0);
        join

        #BL;

    end

endmodule


module pe_packetizer(interface done, psum_out, sourceInft, destInft, x_dirInft, y_dirInft, x_hopInft, y_hopInft, packet_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 1;
    parameter BL = 1;

    parameter packet_width = 55;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 2;

    logic [packet_width-1:0] packet;
    logic [data_width-1:0] data;
    logic [hop_width-1:0] x_hop, y_hop;
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic packet_type;

    logic don_e;


    always begin
        done.Receive(don_e);

        fork
            psum_out.Receive(data);
            sourceInft.Receive(source);
            destInft.Receive(dest);
            x_dirInft.Receive(x_dir);
            y_dirInft.Receive(y_dir);
            x_hopInft.Receive(x_hop);
            y_hopInft.Receive(y_hop);
        join

        #FL;

        packet = (source << (packet_width-addr_width-1)) | (dest << (packet_width-2*addr_width-1)) | (x_dir << (packet_width-2*addr_width-2)) 
        | (y_dir << (packet_width-2*addr_width-3)) | (x_hop << (data_width + hop_width)) | (y_hop << data_width) | data;

        packet_out.Send(packet);
        #BL;

    end

endmodule


module ifmap_mem(interface ifmap_in, ifmap_addr, ifmap_out_addr, ifmap_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [ADDR_I-1:0] in_addr, out_addr;
    logic [WIDTH-1:0] in_data;

    logic [WIDTH-1:0] ifmap_array [DEPTH_I-1:0];

    //write
    always begin
        //$display("ifmap mem starts @ time = %d", $time);

        for(int count = 0; count < DEPTH_I; count++) begin
            fork
                ifmap_in.Receive(in_data);

                ifmap_addr.Receive(in_addr);
            join

            //$display("ifmap mem receive data = %d @ time = %d", in_data, $time);
            #FL;

            ifmap_array[in_addr] = in_data;
            #BL;
        end
        
    end

    //read
    always begin
        ifmap_out_addr.Receive(out_addr);
        #FL;

        ifmap_out.Send(ifmap_array[out_addr]);
        #BL;
    end

endmodule

module filter_mem(interface filter_in, filter_addr, filter_out_addr, filter_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [ADDR_F-1:0] in_addr, out_addr;
    logic [WIDTH-1:0] in_data;

    logic [WIDTH-1:0] filter_array [DEPTH_F-1:0];

    //write
    always begin
        //$display("filter mem starts @ time = %d", $time);

        for(int count = 0; count < DEPTH_F; count++) begin
            fork
                filter_in.Receive(in_data);

                filter_addr.Receive(in_addr);
            join
            
            //$display("filter mem receive data = %d @ time = %d", in_data, $time);
            #FL;

            filter_array[in_addr] = in_data;
            #BL;
        end
        
    end

    //read
    always begin
        filter_out_addr.Receive(out_addr);
        #FL;

        filter_out.Send(filter_array[out_addr]);
        #BL;
    end

endmodule


module multiplier(interface ifmap_out, filter_out, mult_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [WIDTH-1:0] data0, data1, result;

    always begin
        //$display("mult starts @ time = %d", $time);
        fork
            ifmap_out.Receive(data0);
            filter_out.Receive(data1);
        join

        result = data0 * data1;
        //$display("mult receive data0 = %d, data1 = %d, result = %d @time = %d", data0, data1, result, $time);
        #FL;

        mult_out.Send(result);
        //$display("mult send mult result = %d @time = %d", result, $time);
        #BL;

    end

endmodule


module adder(interface mult_out, psum_in, accum_out, add_sel, adder_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [WIDTH-1:0] data0, data1, result;
    logic sel;

    always begin
        add_sel.Receive(sel);

        if(sel == 0) begin
            fork
                mult_out.Receive(data0);
                accum_out.Receive(data1);
            join
        end
        //sel == 1
        else begin
            fork
                psum_in.Receive(data0);
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


module split(interface adder_out, split_sel, to_accum, psum_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [WIDTH-1:0] data; 
    logic sel;

    always begin
        fork
            adder_out.Receive(data);
            split_sel.Receive(sel);
        join
        //$display("adder receive data = %d, sel = %d @time = %d", data, sel, $time);

        #FL;

        if(sel == 0) begin
            to_accum.Send(data);
            //$display("adder send data = %d to_accum @time = %d", data, $time);

        end
        //sel == 1
        else begin
            psum_out.Send(data);
            //$display("adder send data = %d to psum_out @time = %d", data, $time);
        
        end

        #BL;
    end

endmodule


module accumulator(interface from_split, acc_clear, to_adder);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic [WIDTH-1:0] data;
    logic clear;

    always begin
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

        #BL;

    end

endmodule


module control(interface start, ifmap_out_addr, filter_out_addr, acc_clear, add_sel, split_sel, done);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    logic st;
    int no_iterations = DEPTH_I - DEPTH_F + 1;

    always begin
        start.Receive(st); //waits for start token transfer

        if(st == 0) begin
            for(int i = 0; i < no_iterations; i++) begin
                
                #FL;
                acc_clear.Send(1); // restarting the accumulator
                #BL;

                for(int j = 0; j < DEPTH_F; j++) begin
                    #FL;

                    fork
                        split_sel.Send(0); // steers to accumulator
                        add_sel.Send(0); // selects inputs for sum =.a0 + .b
                        filter_out_addr.Send(j); // next filter address
                        ifmap_out_addr.Send(i+j); // next ifmap address
                        acc_clear.Send(0); // accumulator enabled
                        
                    join

                    #BL;
                end

                #FL;

                fork
                    split_sel.Send(1); // steers to psum_out
                    add_sel.Send(1); // selects inputs for sum = .a1 + .b

                join
                
                #BL;

            end

            #FL;

            done.Send(1); // finished operation

            #BL;
        end
    end // always end


endmodule


module pe(interface filter_in, filter_addr, ifmap_in, ifmap_addr, psum_in, start, done, psum_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter FL = 4;
    parameter BL = 2;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) filter_out_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) filter_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) ifmap_out_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) ifmap_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) add_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) split_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) acc_clear ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf [3:0]();
    
    control #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
    ctrl (.start(start), .ifmap_out_addr(ifmap_out_addr), .filter_out_addr(filter_out_addr), .acc_clear(acc_clear), .add_sel(add_sel), .split_sel(split_sel), .done(done));

    ifmap_mem  #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
    i_mem (.ifmap_in(ifmap_in), .ifmap_addr(ifmap_addr), .ifmap_out_addr(ifmap_out_addr), .ifmap_out(ifmap_out));

    filter_mem #(.WIDTH(WIDTH), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
    f_mem (.filter_in(filter_in), .filter_addr(filter_addr), .filter_out_addr(filter_out_addr), .filter_out(filter_out));

    multiplier #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    mult (.ifmap_out(ifmap_out), .filter_out(filter_out), .mult_out(intf[0]));

    adder #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    add (.mult_out(intf[0]), .psum_in(psum_in), .accum_out(intf[3]), .add_sel(add_sel), .adder_out(intf[1]));

    split#(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    sp (.adder_out(intf[1]), .split_sel(split_sel), .to_accum(intf[2]), .psum_out(psum_out));

    accumulator #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    acc (.from_split(intf[2]), .acc_clear(acc_clear), .to_adder(intf[3]));

endmodule
