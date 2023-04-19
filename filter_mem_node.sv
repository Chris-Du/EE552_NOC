`timescale 1ns/1ns

import SystemVerilogCSP::*;
module filter_mem_node (
    interface load_start, filter_data, filter_addr, load_done, PE_in
);
    
    parameter WIDTH_addr = 12;
    parameter NODE = 11;
    parameter DEPTH_F= 5;
    parameter FL = 12;
    parameter BL = 4;
    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;
    parameter WIDTH_data = 8;

    
    // mem bank width = 5
    logic [WIDTH_payload-1:0]mem_filter[DEPTH_F-1:0];

    // from signal from tb
    logic load_dn, l_st;
    logic [WIDTH_data-1:0] f_data;
    logic [WIDTH_addr-1:0] f_addr;

    // internal signal
    logic [3:0] dest,source;

    // to to router
    logic [WIDTH_packet-1:0] packet;  

    integer fp1; 
    logic [WIDTH_data-1:0] test_data;

    initial begin
        fp1=$fopen("filter_mem.dump");
        load_start.Receive(l_st);
        if(l_st) begin
            // filter receiving
            for(integer i = 0; i < (DEPTH_F**2); i++) begin
                filter_addr.Receive(f_addr);
                filter_data.Receive(f_data);
                for(integer j = 0; j < WIDTH_data; j++) begin
                    mem_filter [i/DEPTH_F] [f_addr%DEPTH_F*8+j] = f_data[j];
                    test_data[j] = f_data[j];
                    //$display("%d",test_data);
                end
                //$display("Filter receives %d at %d", f_data, f_addr);

            end
        end

        load_done.Receive(load_dn);
        if(load_dn==1) begin
            //$display("Successfully load all filter!");
        end
        source = NODE-1;
        for(integer i = 0; i < DEPTH_F; i = i + 1) begin
            
            packet = 0;
            dest = i;
            packet[39:0] = mem_filter[i];
            $fdisplay(fp1,"%h",packet[39:0]);
            packet[55:52] = source+1; //source field. +1 since node labeling in this loop starts for 0
            packet[51:48] = dest+1; //dest field
            // configure x
            if((dest%5) > (source%5)) begin
                // x dir 1 right 0 left
                packet[47] = 1;
                packet[46:44] = (dest%5) - (source%5);// x hop
            end
            else if ((dest%5) < (source%5)) begin
                packet[47] = 0;
                packet[46:44] = (source%5) - (dest%5);
            end
            // configure y, direction default to 0 (down)
            if( dest < 5)
                packet[42:40] = 1; // y hop
            else if( dest < 10)
                packet[42:40] = 2; // y hop
            #FL;
            PE_in.Send(packet);
            #BL;
            
        end

    end  


endmodule