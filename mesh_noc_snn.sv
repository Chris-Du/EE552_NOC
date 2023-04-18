`timescale 1ns/1ns

import SystemVerilogCSP::*;
module noc_snn (
    interface load_start, 
    ifmap_data, ifmap_addr, timestep, 
    filter_data, filter_addr, 
    load_done, 
    start_r, ts_r, layer_r, done_r, //to be assigned
    out_spike_addr, out_spike_data //to be assigned
);
    parameter WIDTH_data = 8;
    parameter WIDTH_addr = 12;
    parameter WIDTH_out_data = 13;
    parameter DEPTH_F= 5;
    parameter DEPTH_I =25;
    parameter DEPTH_R =21;
    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;

    logic ls, ld;

    // router in out channel
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) in[14:0]();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out[14:0]();

    // node12 ifmem node channel
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) ifmem_load_start();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) ifmem_load_done(); 

    // node 11 filter mem channel
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) filter_load_start(); 
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) filter_load_done(); 

    // in == PE_in, input from PE to router
    // out == PE_out, output from router to PE
    //out[11] and out[12] are unconnected since ifmem and filter mem doesnt take input from PEs
    mesh noc_mesh(
        in[0],out[0],
        in[1],out[1],
        in[2],out[2],
        in[3],out[3],
        in[4],out[4],
        in[5],out[5],
        in[6],out[6],
        in[7],out[7],
        in[8],out[8],
        in[9],out[9],
        in[10],out[10],
        in[11],out[11],
        in[12],out[12],
        in[13],out[13],
        in[14],out[14]
    );

    
    if_mem_node node12(
        ifmem_load_start,
        ifmap_data,
        ifmap_addr,
        timestep,
        ifmem_load_done,
        in[11] // PE_in of node12 goes to in[11]
    );

    filter_mem_node node11(
        filter_load_start,
        filter_data,
        filter_addr,
        filter_load_done,
        in[10] // PE_in of node12 goes to in[10]
    );

    // copy load_start and load_done to two input mem nodes
    always begin
        load_start.Receive(ls);
        fork
            ifmem_load_start.Send(ls);
            filter_load_start.Send(ls);
        join
    end
    always begin
        load_done.Receive(ld);
        fork
            ifmem_load_done.Send(ld);
            filter_load_done.Send(ld);
        join
    end
endmodule