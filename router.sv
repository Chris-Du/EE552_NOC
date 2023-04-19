`timescale 1ns/1ps

import SystemVerilogCSP::*;

module router(
    interface north_in, north_out,
    south_in, south_out, 
    east_in, east_out, 
    west_in, west_out,
    PE_in, PE_out
    );

    parameter FL = 2, BL = 1;
    
    parameter WIDTH_data = 8;
    parameter WIDTH_addr = 12;
    parameter WIDTH_out_data = 13;
    parameter DEPTH_F= 5;
    parameter DEPTH_I =25;
    parameter DEPTH_R =21;

    parameter WIDTH_packet = 57;
    parameter WIDTH_payload = 40;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) north_to_south();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) north_to_east();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) north_to_west();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) north_to_PE();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) south_to_north();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) south_to_east();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) south_to_west();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) south_to_PE();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) east_to_north();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) east_to_south();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) east_to_west();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) east_to_PE();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) west_to_north();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) west_to_south();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) west_to_east();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) west_to_PE();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_to_north();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_to_south();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_to_east();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) PE_to_west();

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) empty[4:0]();
    
    logic [WIDTH_packet-1:0] 
        north_in_packet, north_out_packet,
        south_in_packet, south_out_packet, 
        east_in_packet, east_out_packet, 
        west_in_packet, west_out_packet,
        PE_in_packet, PE_out_packet;
    // grant priority for output port

    // x dir 0 west, 1 east. y dir 0 south, 1 north
    //40:41 y hop, 42:44 x hop, 45 y dir, 46 x dir

    input_ctrl north_input(
        .in(north_in),
        .north_out(empty[0]),
        .south_out(north_to_south),
        .east_out(north_to_east),
        .west_out(north_to_west),
        .PE_out(north_to_PE)
    );
    input_ctrl south_input(
        .in(south_in),
        .north_out(south_to_north),
        .south_out(empty[1]),
        .east_out(south_to_east),
        .west_out(south_to_west),
        .PE_out(south_to_PE)
    );
    input_ctrl east_input(
        .in(east_in),
        .north_out(east_to_north),
        .south_out(east_to_south),
        .east_out(empty[2]),
        .west_out(east_to_west),
        .PE_out(east_to_PE)
    );
    input_ctrl west_input(
        .in(west_in),
        .north_out(west_to_north),
        .south_out(west_to_south),
        .east_out(west_to_east),
        .west_out(empty[3]),
        .PE_out(west_to_PE)
    );
    input_ctrl pe_input(
        .in(PE_in),
        .north_out(PE_to_north),
        .south_out(PE_to_south),
        .east_out(PE_to_east),
        .west_out(PE_to_west),
        .PE_out(empty[4])
    );

    output_ctrl north_output(
        .in1(south_to_north),
        .in2(east_to_north),
        .in3(west_to_north),
        .in4(PE_to_north),
        .out(north_out)
    );
    output_ctrl south_output(
        .in1(north_to_south),
        .in2(east_to_south),
        .in3(west_to_south),
        .in4(PE_to_south),
        .out(south_out)
    );
    output_ctrl east_output(
        .in1(north_to_east),
        .in2(south_to_east),
        .in3(PE_to_east),
        .in4(west_to_east),
        .out(east_out)
    );
    output_ctrl west_output(
        .in1(north_to_west),
        .in2(south_to_west),
        .in3(east_to_west),
        .in4(PE_to_west),
        .out(west_out)
    );
    output_ctrl PE_output(
        .in1(north_to_PE),
        .in2(south_to_PE),
        .in3(east_to_PE),
        .in4(west_to_PE),
        .out(PE_out)
    );

endmodule