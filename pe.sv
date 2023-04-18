/*
TO DO:
1. test protection mechanism  


*/
`timescale 1ns/100ps

import SystemVerilogCSP::*;

module pe_depacketizer(interface packet_in, ifmap_in, ifmap_addr, filter_in, filter_addr, psum_in, start, 
    iff_typeIntf, sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, if_forwardIntf, f_forwardIntf, data_forwardIntf);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    
    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter x_hop_width = 3;
    parameter y_hop_width = 3;


    parameter FL = 1;
    parameter BL = 1;

    logic [packet_width-1:0] packet_data;
    logic [data_width-1:0] if_data, f_data, data;
    logic [data_width-1:0] forward_data = 0;
    logic [x_hop_width-1:0] x_hop;
    logic [y_hop_width-1:0] y_hop;

    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest, f_source, f_dest, if_source, if_dest;
    logic iff_type;

    logic [WIDTH-1:0] filter_data, ifmap_data;

    logic [ADDR_F-1:0] addr_filter = 0;
    logic [ADDR_I-1:0] addr_ifmap = 0;

    logic filter_ready = 0;
    logic ifmap_ready = 0;
    logic f_forward = 0;
    logic if_forward = 0;

    always begin
        packet_in.Receive(packet_data);

        #FL;

        f_forward = 0;
        
        iff_type = packet_data[56];
        source = packet_data[55:52];
        dest = packet_data[51:48];
        x_dir = packet_data[47];
        y_dir = packet_data[43];
        x_hop = packet_data[46:44];
        y_hop = packet_data[42:40];
        
        //ifmap
        if(iff_type) begin
            if_data = packet_data[24:0];
            data = packet_data[24:0];            
        end
        //filter
        else begin  
            f_data = packet_data[39:0];
            data = packet_data[39:0];
        end

        $display("Receive packet in PE depack:\niff_type = %b\nsource = %d\ndest = %d\nx_dir = %b\nx_hop = %d\ny_dir = %b\ny_hop = %d\ndata = %d\n", 
            iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data);

        //filter packet arrive, then PE1-5 forward filter data to PE6-10
        if((iff_type == 0) && (dest == 1 || dest == 2 || dest == 3 || dest == 4 || dest == 5)) begin
            f_forward = 1;
            f_forwardIntf.Send(f_forward);

            case(dest)
                1: begin
                    f_source = 1;
                end

                2: begin
                    f_source = 2;              
                end

                3: begin
                    f_source = 3;               
                end

                4: begin
                    f_source = 4;                
                end

                5: begin
                    f_source = 5;              
                end

            endcase

            f_dest = f_source + 5;

            fork
                iff_typeIntf.Send(0);
                sourceIntf.Send(f_source);
                destIntf.Send(f_dest);
                x_dirIntf.Send(0);
                y_dirIntf.Send(0);
                x_hopIntf.Send(3'b000);
                y_hopIntf.Send(2'b01);
                data_forwardIntf.Send(f_data);                    
            join

            #BL;

        end
        /*
        else if((iff_type == 1) && (dest == 2 || dest == 3 || dest == 4 || dest == 5 || dest == 7 || dest == 8 || dest == 9 || dest == 10)) begin
            f_forward = 1;
            f_forwardIntf.Send(f_forward);

            case(dest)
                2: begin
                    if_source = 2;
                end

                3: begin
                    if_source = 3;               
                end

                4: begin
                    if_source = 4;               
                end

                5: begin
                    if_source = 5;                
                end

                7: begin
                    if_source = 7;                
                end
                8: begin
                    if_source = 8;                
                end
                9: begin
                    if_source = 9;                 
                end
                10: begin
                    if_source = 10;                
                end

            endcase

            if_dest = if_source - 1;

            fork
                iff_typeIntf.Send(0);
                sourceIntf.Send(if_source);
                destIntf.Send(if_dest);
                x_dirIntf.Send(0);
                y_dirIntf.Send(0);
                x_hopIntf.Send(3'b001);
                y_hopIntf.Send(2'b00);
                data_forwardIntf.Send(forward_data);                    
            join

            #BL;            
        end
        */

        //ifmap
        if(iff_type) begin
            for(int i = 0; i < DEPTH_I; i++) begin
                ifmap_data = (data >> i) & 1'b1;
                ifmap_in.Send(ifmap_data);                
                ifmap_addr.Send(addr_ifmap);

                $display("ifmap_data = %d\nifmap_addr = %d\n", ifmap_data, addr_ifmap);
                addr_ifmap++;
                #BL;
            end
            addr_ifmap = 0;
            ifmap_ready = 1;
        end
        //filter
        else begin 
            for(int i = 0; i < DEPTH_F; i++) begin
                filter_data = (data >> (i*8)) & 8'hFF;
                filter_in.Send(filter_data);
                filter_addr.Send(addr_filter);

                $display("filter_data = %d\nfilter_addr = %d\n", filter_data, addr_filter);
                addr_filter++;
                #BL;
            end
            addr_filter = 0;
            filter_ready = 1;
        end

        $display("ifmap ready= %b, filter ready= %b", ifmap_ready, filter_ready);

        //if ifmap and filter ready, start computing in PE
        if(filter_ready && ifmap_ready) begin

            f_forward = 0;
            f_forwardIntf.Send(f_forward);  
            #BL;

            //inject x y dir hop to each PE1-10
            case(dest)
                    1: begin
                        source = 1;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b010;
                        y_hop = 3'b001;
                end
                    2: begin
                        source = 2;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b001;
                        y_hop = 3'b001;
                end
                    3: begin
                        source = 3;
                        x_dir = 0;
                        y_dir = 1;
                        x_hop = 3'b000;
                        y_hop = 3'b001;
                end
                    4: begin
                        source = 4;
                        x_dir = 0;
                        y_dir = 1;
                        x_hop = 3'b001;
                        y_hop = 3'b001;
                end
                    5: begin
                        source = 5;
                        x_dir = 0;
                        y_dir = 1;
                        x_hop = 3'b010;
                        y_hop = 3'b001;
                end
                    6: begin
                        source = 6;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b011;
                        y_hop = 3'b010;
                end
                    7: begin
                        source = 7;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b010;
                        y_hop = 3'b010;
                end
                    8: begin
                        source = 8;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b001;
                        y_hop = 3'b010;
                end
                    9: begin
                        source = 9;
                        x_dir = 1;
                        y_dir = 1;
                        x_hop = 3'b000;
                        y_hop = 3'b010;
                end
                    10: begin
                        source = 10;
                        x_dir = 0;
                        y_dir = 1;
                        x_hop = 3'b001;
                        y_hop = 3'b010;
                end

            endcase

            //PE1-5
            if(source == 1 || source == 2 || source == 3 || source == 4 || source == 5) begin
                dest = 13;
            end
            //PE6-10
            else begin
                dest = 14;
            end

            //send headers to pack for psum

            fork
                start.Send(0);
                sourceIntf.Send(source);
                destIntf.Send(dest);
                x_dirIntf.Send(x_dir);
                y_dirIntf.Send(y_dir);
                x_hopIntf.Send(x_hop);
                y_hopIntf.Send(y_hop); 
            join

            ifmap_ready = 0;

            #BL;

            
            //after psum packet is send, PE2-5 forward ifmap to PE1-4; PE7-10 forward ifmap to PE6-9
            if(source == 2 || source == 3 || source == 4 || source == 5 || source == 7 || source == 8 || source == 9 || source == 10) begin
                
                if_forwardIntf.Receive(if_forward);

                #FL;

                if(if_forward) begin 
                    

                    //source, dest are changed previously, now source is PE id
                    dest = source - 1;
                    x_dir = 0;
                    y_dir = 0;
                    x_hop = 3'b001;
                    y_hop = 3'b000;

                    fork
                        /*
                        //borrow f_forward channel to acknowledge packetizer
                        f_forwardIntf.Send(1);
                        */
                        
                        iff_typeIntf.Send(1); //send ifmap 
                        sourceIntf.Send(source);
                        destIntf.Send(dest);
                        x_dirIntf.Send(x_dir);
                        y_dirIntf.Send(y_dir);
                        x_hopIntf.Send(x_hop);
                        y_hopIntf.Send(y_hop);
                        data_forwardIntf.Send(if_data);                     
                    join

                    #BL;
                end

            end

            //receive a signal from pack to receive next new packet
            if_forwardIntf.Receive(if_forward);

            #FL;
        end
    end  

    always begin
        psum_in.Send(0);
        
        #BL;
    end

endmodule


module pe_packetizer(interface f_forwardIntf, if_forwardIntf, data_forwardIntf, done, psum_out, 
    iff_typeIntf, sourceIntf, destIntf, x_dirIntf, y_dirIntf, x_hopIntf, y_hopIntf, packet_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;
    parameter DEPTH_C = 441;

    parameter FL = 1;
    parameter BL = 1;

    parameter packet_width = 57;
    parameter addr_width = 4;
    parameter data_width = 40;
    parameter psum_width = 13;
    parameter hop_width = 3;
    parameter psum_addr_width = 27;

    logic [packet_width-1:0] packet_data = 0;
    logic [data_width-1:0] data = 0; 
    logic [psum_width-1:0] psum = 0;
    logic [psum_addr_width-1:0] psum_addr = 0;

    logic [hop_width-1:0] x_hop, y_hop; 
    logic x_dir, y_dir;
    logic [addr_width-1:0] source, dest;
    logic iff_type = 0;

    logic f_forward;
    logic if_forward;
    logic don_e;

    int no_iterations = DEPTH_I - DEPTH_F + 1;

    always begin

        //check if depack has anything to forward
        f_forwardIntf.Receive(f_forward);

        //filter_forward = 1, need to forward filter to PE
        if(f_forward == 1) begin
            fork
                iff_typeIntf.Receive(iff_type);
                sourceIntf.Receive(source);
                destIntf.Receive(dest);
                x_dirIntf.Receive(x_dir);
                y_dirIntf.Receive(y_dir);
                x_hopIntf.Receive(x_hop);
                y_hopIntf.Receive(y_hop); 
                data_forwardIntf.Receive(data);                  
            join

            #FL;

            $display("Sending forwarding data\niff type = %b\ndata = %b\nsource = %d\ndest = %d\nx_dir = %b\ny_dir = %b\nx_hop = %d\ny_hop = %d\n",
            iff_type, data, source, dest, x_dir, y_dir, x_hop, y_hop);

            packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};

            packet_out.Send(packet_data);
            $display("packet = %b\n", packet_data);
            #BL;
        end
        //filter_forward = 0, need to send psum to PSUM module
        else begin
            fork
                sourceIntf.Receive(source);
                destIntf.Receive(dest);
                x_dirIntf.Receive(x_dir);
                y_dirIntf.Receive(y_dir);
                x_hopIntf.Receive(x_hop);
                y_hopIntf.Receive(y_hop);
            join

            for(int i = 0; i < no_iterations; i++) begin 

                psum_out.Receive(psum);  

                #FL;            
                
                $display("Sending psum\niff type = %b\npsum_out = %d\npsum_addr = %d\nsource = %d\ndest = %d\nx_dir = %b\ny_dir = %b\nx_hop = %d\ny_hop = %d\n",
                
                iff_type, psum, psum_addr, source, dest, x_dir, y_dir, x_hop, y_hop);

                packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, psum_addr, psum};

                packet_out.Send(packet_data);
                $display("packet = %b\n", packet_data);

                if(psum_addr < DEPTH_C-1) psum_addr++;
                //counter >= 440
                else psum_addr = 0;
                
                #BL;

            end

            done.Receive(don_e);

            #FL;
            
            //after psum is sent, req depack to forward ifmap
            if(don_e && (source == 2 || source == 3 || source == 4 || source == 5 || source == 7 || source == 8 || source == 9 || source == 10)) begin
                if_forward = 1;
                if_forwardIntf.Send(if_forward);
                #BL;

                //forward ifmap
                fork
                    iff_typeIntf.Receive(iff_type);
                    sourceIntf.Receive(source);
                    destIntf.Receive(dest);
                    x_dirIntf.Receive(x_dir);
                    y_dirIntf.Receive(y_dir);
                    x_hopIntf.Receive(x_hop);
                    y_hopIntf.Receive(y_hop); 
                    data_forwardIntf.Receive(data);
                join

                #FL;

                $display("Sending forwarding data\niff type = %b\ndata = %b\nsource = %d\ndest = %d\nx_dir = %b\ny_dir = %b\nx_hop = %d\ny_hop = %d\n",
                iff_type, data, source, dest, x_dir, y_dir, x_hop, y_hop);

                packet_data = {iff_type, source, dest, x_dir, x_hop, y_dir, y_hop, data};

                packet_out.Send(packet_data);
                $display("packet = %b\n", packet_data);
                #BL;

            end

            //send a signal to depack to allow to receive next new packet
            if_forward = 0;  
            if_forwardIntf.Send(if_forward);

            #BL;
            
        end
    end
    

endmodule


module ifmap_mem(interface ifmap_in, ifmap_addr, ifmap_out_addr, ifmap_out);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
    parameter BL = 2;

    logic [WIDTH-1:0] data; 
    logic sel;

    always begin
        fork
            split_sel.Receive(sel);
            adder_out.Receive(data);
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    parameter DEPTH_I = 25;
    parameter ADDR_I = 5; 
    parameter DEPTH_F = 5;
    parameter ADDR_F = 3;

    parameter FL = 2;
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
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) iff_typeIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) sourceIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) destIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_dirIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) x_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) y_hopIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) f_forwardIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) if_forwardIntf ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) data_forwardIntf ();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(packet_width)) intf [3:0]();

    pe_depacketizer #(.WIDTH(WIDTH))
    pedep (.packet_in(packet_in), .ifmap_in(ifmap_in), .ifmap_addr(ifmap_addr), .filter_in(filter_in), .filter_addr(filter_addr), 
    .psum_in(psum_in), .start(start), .iff_typeIntf(iff_typeIntf), .sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), 
    .if_forwardIntf(if_forwardIntf), .f_forwardIntf(f_forwardIntf), .data_forwardIntf(data_forwardIntf));    
    
    pe_packetizer #(.WIDTH(WIDTH))
    pep (.f_forwardIntf(f_forwardIntf), .if_forwardIntf(if_forwardIntf), .data_forwardIntf(data_forwardIntf), .done(done), .psum_out(psum_out), 
    .iff_typeIntf(iff_typeIntf), .sourceIntf(sourceIntf), .destIntf(destIntf), .x_dirIntf(x_dirIntf), .y_dirIntf(y_dirIntf), .x_hopIntf(x_hopIntf), .y_hopIntf(y_hopIntf), .packet_out(packet_out));
    
    control #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    ctrl (.start(start), .ifmap_out_addr(ifmap_out_addr), .filter_out_addr(filter_out_addr), .acc_clear(acc_clear), .add_sel(add_sel), .split_sel(split_sel), .done(done));

    ifmap_mem  #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
    i_mem (.ifmap_in(ifmap_in), .ifmap_addr(ifmap_addr), .ifmap_out_addr(ifmap_out_addr), .ifmap_out(ifmap_out));

    filter_mem #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
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
