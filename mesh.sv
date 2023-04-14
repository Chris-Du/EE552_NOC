`timescale 1ns/1ps

import SystemVerilogCSP::*;
module mesh (
    interface node1_PE_in, node1_PE_out,
    node2_PE_in, node2_PE_out,
    node3_PE_in, node3_PE_out,
    node4_PE_in, node4_PE_out,
    node5_PE_in, node5_PE_out,
    node6_PE_in, node6_PE_out,
    node7_PE_in, node7_PE_out,
    node8_PE_in, node8_PE_out,
    node9_PE_in, node9_PE_out,
    node10_PE_in, node10_PE_out,
    node11_PE_in, node11_PE_out,
    node12_PE_in, node12_PE_out,
    node13_PE_in, node13_PE_out,
    node14_PE_in, node14_PE_out,
    node15_PE_in, node15_PE_out
);
    parameter WIDTH_packet = 57;
    parameter FL = 0, BL = 0;

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node1_2();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node2_1();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node1_11();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node11_1();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node1_6();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node6_1();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node12_2();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node2_12();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node7_2();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node2_7();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node3_2();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node2_3();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node13_3();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node3_13();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node8_3();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node3_8();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node4_3();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node3_4();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node14_4();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node4_14();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node9_4();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node4_9();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node5_4();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node4_5();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node15_5();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node5_15();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node10_5();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node5_10();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node7_6();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node6_7();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node15_14();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node14_15();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node13_12();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node12_13();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node13_14();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node14_13();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node12_11();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node11_12();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node10_9();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node9_10();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node9_8();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node8_9();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node7_8();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH_packet)) node8_7();

    router node1(
        node11_1, node1_11,
        node6_1, node1_6, 
        node2_1, node1_2, 
        , , //west unconnected
        node1_PE_in, node1_PE_out
    );

    router node2(
        node12_2, node2_12,
        node7_2, node2_7, 
        node3_2, node2_3, 
        node1_2, node2_1,
        node2_PE_in, node2_PE_out
    );

    router node3(
        node13_3, node3_13,
        node8_3, node3_8, 
        node4_3, node3_4, 
        node2_3, node3_2,
        node3_PE_in, node3_PE_out
    );

    router node4(
        node14_4, node4_14,
        node9_4, node4_9, 
        node5_4, node4_5, 
        node3_4, node4_3,
        node4_PE_in, node4_PE_out
    );

    router node5(
        node15_5, node5_15,
        node10_5, node5_10, 
        ,, 
        node4_5, node5_4,
        node5_PE_in, node5_PE_out
    );

    router node6(
        node1_6, node6_1,
        ,, 
        node7_6, node6_7, 
        ,,
        node6_PE_in, node6_PE_out
    );

    router node7(
        node2_7, node7_2,
        , , 
        node8_7, node7_8, 
        node6_7, node7_6,
        node7_PE_in, node7_PE_out
    );

    

    router node8(
        node3_8, node8_3,
        , , 
        node9_8, node8_9, 
        node7_8, node8_7,
        node8_PE_in, node8_PE_out
    );
    
    

    router node9(
        node4_9, node9_4,
        ,, 
        node10_9, node9_10, 
        node8_9, node9_8,
        node9_PE_in, node9_PE_out
    );

    router node10(
        node5_10, node10_5,
        , , 
        , , 
        node9_10, node10_9,
        node10_PE_in, node10_PE_out
    );

    router node11(
        , ,
        node1_11, node11_1, 
        node12_11, node11_12, 
        , ,
        node11_PE_in, node11_PE_out
    );

    

    router node12(
        , ,
        node2_12, node12_2, 
        node13_12, node12_13, 
        node11_12, node12_11,
        node12_PE_in, node12_PE_out
    );

    

    router node13(
        , ,
        node3_13, node13_3, 
        node13_14, node14_13, 
        node12_13, node13_12,
        node13_PE_in, node13_PE_out
    );



    router node14(
         ,  ,
        node4_14, node14_4, 
        node15_14, node14_15, 
        node13_14, node14_13,
        node14_PE_in, node14_PE_out
    );


    router node15(
        , ,
        node5_15, node15_5, 
        , , 
        node14_15, node15_14,
        node15_PE_in, node15_PE_out
    );

endmodule