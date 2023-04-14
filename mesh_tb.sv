`timescale 1ns/1ns

import SystemVerilogCSP::*;

module mesh_tb;

    parameter WIDTH_packet = 57;
    parameter FL = 0, BL = 0;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) in[14:0]();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) out[14:0]();

    logic [WIDTH_packet-1:0] in_data, 
    node1_in, node1_out,
    node2_in, node2_out,
    node3_in, node3_out,
    node4_in, node4_out,
    node5_in, node5_out,
    node6_in, node6_out,
    node7_in, node7_out,
    node8_in, node8_out,
    node9_in, node9_out,
    node10_in, node10_out,
    node11_in, node11_out,
    node12_in, node12_out,
    node13_in, node13_out,
    node14_in, node14_out,
    node15_in, node15_out;

    integer i, j,fp,count;

    mesh DUT(
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

    data_bucket #(.NODE(1)) node1_bucket(out[0]);
    data_bucket #(.NODE(2)) node2_bucket(out[1]);
    data_bucket #(.NODE(3))node3_bucket(out[2]);
    data_bucket #(.NODE(4))node4_bucket(out[3]);
    data_bucket #(.NODE(5))node5_bucket(out[4]);
    data_bucket #(.NODE(6))node6_bucket(out[5]);
    data_bucket #(.NODE(7))node7_bucket(out[6]);
    data_bucket #(.NODE(8))node8_bucket(out[7]);
    data_bucket #(.NODE(9))node9_bucket(out[8]);
    data_bucket #(.NODE(10))node10_bucket(out[9]);
    data_bucket #(.NODE(11))node11_bucket(out[10]);
    data_bucket #(.NODE(12))node12_bucket(out[11]);
    data_bucket #(.NODE(13))node13_bucket(out[12]);
    data_bucket #(.NODE(14))node14_bucket(out[13]);
    data_bucket #(.NODE(15))node15_bucket(out[14]);

    initial begin
        i = 0;
        j = 0;
        count = 0;
        fp = $fopen("mesh_send.out");
        in_data = 0;
        for(i = 0; i < 15; i = i + 1) begin
            // receive node
            for ( j = 0;j<15 ;j = j+1 ) begin
                //send node
                if( j == i) 
                    continue;
                in_data = 0;
                in_data[39:0] = count;
                count = count + 1;
                in_data[55:52] = j; //source
                in_data[51:48] = i; //dest
                if((i%5) > (j%5)) begin
                    in_data[47] = 1;// x dir 1 right 0 left
                    in_data[46:44] = (i%5) - (j%5);// x hop
                end
                else if ((i%5) < (j%5)) begin
                    in_data[47] = 0;
                    in_data[46:44] = (j%5) - (i%5);
                end

                if((j>=5)&&(j<=9)) begin
                    // bottom
                    in_data[43] = 1; // y dir 1 up 0 down
                    if( i < 5)
                        in_data[42:40] = 1; // y hop
                    if( i > 4)
                        in_data[42:40] = 2; // y hop
                end
                else if ((j>=10)&&(j<=14)) begin
                    // top
                    in_data[43] = 0;
                    if( i < 5)
                        in_data[42:40] = 1; // y hop
                    else if( i < 10)
                        in_data[42:40] = 2; // y hop
                end
                else if (i>= 10) begin
                    // mid to top
                    in_data[43] = 1;
                    in_data[42:40] = 1;
                end
                else if (i>=5&&i<= 9) begin
                    // mid to bot
                    in_data[43] = 0;
                    in_data[42:40] = 1;
                end
                
                
                //$display("node %d sent: %b",j+1,in_data);
                if ( j == 0)
                    in[0].Send(in_data);
                if ( j == 1)
                    in[1].Send(in_data);
                if ( j == 2)
                    in[2].Send(in_data);
                if ( j == 3)
                    in[3].Send(in_data);
                if ( j == 4)
                    in[4].Send(in_data);
                if ( j == 5)
                    in[5].Send(in_data);
                if ( j == 6)
                    in[6].Send(in_data);
                if ( j == 7)
                    in[7].Send(in_data);
                if ( j == 8)
                    in[8].Send(in_data);
                if ( j == 9)
                    in[9].Send(in_data);
                if ( j == 10)
                    in[10].Send(in_data);
                if ( j == 11)
                    in[11].Send(in_data);
                if ( j == 12)
                    in[12].Send(in_data);
                if ( j == 13)
                    in[13].Send(in_data);
                if ( j == 14)
                    in[14].Send(in_data);
                $fdisplay(fp,"from %d to %d, x dir %d, x hop%d, y dir %d, y hop %d.",j+1,i+1,
                in_data[47],in_data[46:44],in_data[43],in_data[42:40]);
                //$display("data = %h", in_data);
                
            end
        end
    end

    initial begin
        #150;
        $display("*** Stopped by watchdog timer ***");
        $stop;
    end



endmodule