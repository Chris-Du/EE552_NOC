`timescale 1ns/100ps

import SystemVerilogCSP::*;

module pe_depacketizer(interface packet_in, ifmap_in, ifmap_addr, filter_in, filter_addr, psum_in, start, 
    sourceInft, destInft, x_dirInft, y_dirInft, x_hopInft, y_hopInft);
    parameter WIDTH = 8;
    parameter DEPTH_I = 5;
    parameter ADDR_I = 3; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 2;

    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet_data;
    logic [data_width-1:0] data;
    logic [hop_width-1:0] x_hop, y_hop;
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic iff_type;

    logic [WIDTH-1:0] filter_data, ifmap_data;

    logic [ADDR_F-1:0] addr_filter = 0;
    logic [ADDR_I-1:0] addr_ifmap = 0;

    logic filter_ready = 0;
    logic ifmap_ready = 0;


    always begin
        packet_in.Receive(packet_data);

        
        iff_type = packet_data[56];
        source = packet_data[55:52];
        dest = packet_data[51:48];
        x_dir = packet_data[45];
        y_dir = packet_data[44];
        x_hop = packet_data[43:42];
        y_hop = packet_data[41:40];
        data = packet_data[39:0];
        

        /*
        iff_type = (packet_data >> (packet_width-1)) & 1'b1;
        source = (packet_data >> (packet_width-addr_width-1)) & 4'hF;
        dest = (packet_data >> (packet_width-2*addr_width-1)) & 4'hF;
        x_dir = (packet_data >> (packet_width-2*addr_width-4)) & 1'b1;
        y_dir = (packet_data >> (packet_width-2*addr_width-5)) & 1'b1;
        x_hop = (packet_data >> (data_width + hop_width)) & 4'hF;
        y_hop = (packet_data >> data_width) & 4'hF;
        data = packet_data & 40'hFFFFFFFFFF;
        */
        
        /*
        $display("pe_depacketizer\n
            packet = %p\n
            iff_type = %p\n
            psum_in = %p\n
            start = %p\n
            sourceInft = %p\n
            destInft = %p\n
            x_dirInft = %p\n
            y_dirInft = %p\n
            x_hopInft = %p\n
            y_hopInft = %p\n"
                ,packet_data, iff_type, psum_in, start, 
                sourceInft, destInft, x_dirInft, y_dirInft, x_hopInft, y_hopInft);
        */


        //ifmap
        if(iff_type) begin
            for(int i = 0; i < DEPTH_I; i++) begin
                #FL;
                ifmap_data = (data >> i*8) & 8'hFF;
                ifmap_addr.Send(addr_ifmap);
                ifmap_in.Send(ifmap_data);
                addr_ifmap++;
                #BL;
            end
            ifmap_ready = 1;
        end
        //filter
        else begin 
            for(int i = 0; i < DEPTH_F; i++) begin
                #FL;
                filter_data = (data >> i*8) & 8'hFF;
                filter_addr.Send(addr_filter);
                filter_in.Send(filter_data);
                addr_filter++;
                #BL;
            end
            filter_ready = 1;
        end

        $display("ifmap ready= %b, filter ready= %b", ifmap_ready, filter_ready);

        if(filter_ready && ifmap_ready) begin
            
            #FL;
            //send the header data to packetizer
            fork
                start.Send(0);
                sourceInft.Send(source);
                destInft.Send(dest);
                x_dirInft.Send(x_dir);
                y_dirInft.Send(y_dir);
                x_hopInft.Send(x_hop);
                y_hopInft.Send(y_hop);
                psum_in.Send(0);
            join

            filter_ready = 0;
            ifmap_ready = 0;

            #BL;

        end
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

    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter hop_width = 2;

    logic [packet_width-1:0] packet_data;
    logic [data_width-1:0] data;
    logic [hop_width-1:0] x_hop, y_hop;
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic packet_type;
    logic [1:0] reserve = 2'b00;

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

        $display("psum_out = %d\nsource = %b\ndest = %b\nx_dir = %b\ny_dir = %b\nx_hop = %b\ny_hop = %b\n",
            data, source, dest, x_dir, y_dir, x_hop, y_hop);

        #FL;

        packet_data = {source, dest, reserve, x_dir, y_dir, x_hop, y_hop, data};

        /*
        packet_data = source << (packet_width-1-addr_width) | dest << (packet_width-1-2*addr_width) 
        | reserve << (data_width+2*hop_width+2) | x_dir << (data_width+2*hop_width+1) | y_dir << (data_width+2*hop_width) 
        | (x_hop << (data_width+hop_width)) | (y_hop << data_width) | data;
        */

        packet_out.Send(packet_data);
        $display("packet = %b\n", packet_data);
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


module pe(interface packet_in, packet_out);
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

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) filter_out_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) filter_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) ifmap_out_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) ifmap_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) add_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) split_sel ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) acc_clear ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) ifmap_in ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) ifmap_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) filter_in ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) filter_addr ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_in ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) psum_out ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) start ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) done ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) sourceInft ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) destInft ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_dirInft ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_dirInft ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_hopInft ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_hopInft ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf [3:0]();

    pe_depacketizer #(.WIDTH(packet_width), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
    pedep (.packet_in(packet_in), .ifmap_in(ifmap_in), .ifmap_addr(ifmap_addr), .filter_in(filter_in), .filter_addr(filter_addr), 
    .psum_in(psum_in), .start(start), .sourceInft(sourceInft), .destInft(destInft), .x_dirInft(x_dirInft), .y_dirInft(y_dirInft), .x_hopInft(x_hopInft), .y_hopInft(y_hopInft));
    
    pe_packetizer #(.WIDTH(packet_width), .DEPTH_I(DEPTH_I), .ADDR_I(ADDR_I), .DEPTH_F(DEPTH_F), .ADDR_F(ADDR_F))
    pep (.done(done), .psum_out(psum_out), .sourceInft(sourceInft), .destInft(destInft), .x_dirInft(x_dirInft), .y_dirInft(y_dirInft), .x_hopInft(x_hopInft), .y_hopInft(y_hopInft), .packet_out(packet_out));

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
