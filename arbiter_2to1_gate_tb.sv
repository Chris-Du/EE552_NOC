`timescale 1ns/1ps

module arbiter_2to1_gate_tb (
);
    parameter WIDTH_packet = 57;
    parameter FL = 2, BL = 1;
    logic in1_req,in1_ack;
    logic [WIDTH_packet-1:0] in1_data;
    logic in2_req;
    logic in2_ack;
    logic [WIDTH_packet-1:0] in2_data;
    logic out_req;
    logic out_ack;
    logic [WIDTH_packet-1:0] out_data;

    arbiter_2to1_gate DUT(
         in1_req,in1_ack,in1_data,in2_req,in2_ack,in2_data,out_req,out_ack,out_data
    );

    logic [WIDTH_packet-1:0] out_data_print;
    integer count;

    always begin
        #FL;
        /*
        if(i%1 == 0) begin
            in[0].Send(count);
            count = count + 1;
        end
        if(i%2 == 1) begin
            in[1].Send(count);
            count = count + 1;
        end
        */
        fork
            begin
                in1_data = count;
                in1_req = 1;
                wait(in1_ack == 1);
                in1_req = 0;
            end
            begin
                in2_data = count + 1;
                in2_req = 1;
                wait(in2_ack == 1);
                in2_req = 0;
            end
            /*
            in[0].Send(count);
            in[1].Send(count+1);
            */
        join
        
        count = count + 2;
    end

    always begin
        wait(out_req == 1);
        out_data_print = out_data;
        out_ack = 1;
        wait(out_req == 0);
        out_ack = 0;
        $display("out data: %d",out_data_print);
        #BL;
    end

    initial begin
        count = 0;
        in1_req = 0;
        in2_req = 0;
        out_ack = 0;
        

        #100;
        $stop();
    end

endmodule