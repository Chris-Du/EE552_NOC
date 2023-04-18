`timescale 1ns/1ns

import SystemVerilogCSP::*;
module if_mem_node (
    interface load_start, ifmap_data, ifmap_addr, timestep, load_done, PE_in
);
    
    parameter WIDTH_addr = 12;
    parameter NODE = 12;
    parameter DEPTH_I =25;
    parameter FL = 12;
    parameter BL = 4;
    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;

    
    // mem bank width = 25 
    logic [DEPTH_I-1:0]mem_ifmap_1[DEPTH_I-1:0];
    logic [DEPTH_I-1:0]mem_ifmap_2[DEPTH_I-1:0];

    // from signal from tb
    logic i1_data, i2_data, load_dn, l_st;
    logic [1:0] ts;
    logic [WIDTH_addr-1:0] i1_addr, i2_addr;

    // internal signal
    logic [3:0] dest,source;

    // to to router
    logic [WIDTH_packet-1:0] packet;  

    integer fp1, fp2;

    initial begin
        fp1=$fopen("if_1.dump");fp2=$fopen("if_2.dump");
        load_start.Receive(l_st);
        if(l_st) begin
            // input feature receiving
            for(integer i = 0; i < (DEPTH_I**2); i++) begin
                timestep.Receive(ts);
 		        if (ts == 1) begin
                    ifmap_addr.Receive(i1_addr);
                    ifmap_data.Receive(i1_data);
                    mem_ifmap_1[i1_addr/25][i1_addr%25] =i1_data;
                    //$display("Timestep %d: receive %d at %d", ts, i1_data, i1_addr);
                end
            end

            for(integer i=0; i<DEPTH_I*DEPTH_I; i++) begin
                timestep.Receive(ts);
                if (ts == 2) begin
                    ifmap_addr.Receive(i2_addr);
                    ifmap_data.Receive(i2_data);
                    mem_ifmap_2[i2_addr/25][i2_addr%25] = i2_data;
                    //$display("Timestep %d: receive %d at %d", ts, i2_data, i2_addr);
                end
            end
            /*
            load_done.Receive(load_dn);
            if (load_dn==1) begin
                $display("Successfully load all ifmaps and filter!");
            end
            */
        end

        load_done.Receive(load_dn);
        if(load_dn==1) begin
            $display("Successfully load all ifmaps and filter!");
        end
        $display("Start send op to each nodes.");
        source = NODE-1;
        for(integer i = 0; i < DEPTH_I; i = i + 1) begin
            for(integer loop_ts = 0; loop_ts < 2; loop_ts= loop_ts + 1) begin
                packet = 0;
                if(i < 5) begin
                    dest = i;
                end
                else begin
                    dest = 4;
                end

                if(loop_ts == 1) begin
                    dest = dest + 5;
                    packet[24:0] = mem_ifmap_2[i];
                    $fdisplay(fp2,"%h",packet[24:0]);
                end
                else begin
                    packet[24:0] = mem_ifmap_1[i];
                    $fdisplay(fp1,"%h",packet[24:0]);
                end
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

    end  


endmodule