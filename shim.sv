`timescale 1ns/1ns
import SystemVerilogCSP::*;


//--------------------------shim tb-------------------------------
module shim_tb ();

Channel #(.hsProtocol(P4PhaseBD)) sv_intf (); 

logic gate_level_ack, gate_level_req;
logic reset;
logic [11:0]  gate_level_data;

buffer b ( .bAck(gate_level_ack),
               .bReq(gate_level_req),
               .rcvd_val(gate_level_data),
               .out_chan(sv_intf)
              );

data_generator dg (.aReq(gate_level_req),
                           .aAck(gate_level_ack), 
                           .a(gate_level_data), 
                           .reset(reset)
                         ); // gate level

data_bucket db (.r(sv_intf)); // normal one

initial begin
    #50;
end
endmodule

//-------------------------gate level data gen-------------------------------
// i modified this slightly so that it is only sending to one place, not two
module data_generator (aReq, aAck, a,  reset);
  input  logic          aAck;
  output logic [11:0]    a;
  output logic          reset, aReq;
  logic        [11:0]    A [0:6] = {12'd14, 12'd5, 12'd118, 12'd51, 12'd27, 12'd8, 12'd77};
   initial begin
    reset = 1;
    #2 reset = 0;
    #1 reset = 1;
    aReq = 1;

    for (int i = 0; i<7; i = i+1) begin
        aReq = 1;
        a = A[i];
        //b = B[i];
        wait (aAck) begin
            #1;
            aReq = 0;
        end
        wait (!aAck) #2;
    end
  end
endmodule

//-------------------data bucket (normal) ----------------------
module data_bucket #(parameter WIDTH = 12) (interface r);
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
 
  always
  begin
    r.Receive(ReceiveValue);
    #BL;
  end

endmodule

//-------------------------shim code-------------------------------
// built from ruiheng's data_bucket module
module buffer (output logic bAck, input logic bReq, input   logic [11:0] rcvd_val, interface out_chan);
  
  logic [11:0]  output_value;
 
 
  always begin
    bAck = 0;
    wait (bReq)
    begin: first_phase
        output_value = rcvd_val;
        #2;
        bAck = 1;
		out_chan.Send(output_value);

    end: first_phase
   
    wait (!bReq) #1;

  end
endmodule