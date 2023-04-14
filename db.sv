`timescale 1ns/1ps
import SystemVerilogCSP::*;

module data_bucket (interface r);
  parameter NODE = 0;
  parameter WIDTH = 57;
  parameter BL = 0; //ideal environment    backward delay
  logic [WIDTH-1:0] ReceiveValue = 0;
  
  integer fp;

  //Variables added for performance measurements

  always
  begin
	//add a display here to see when this module starts its main loop
	fp = $fopen("mesh.out");
	//Communication action Receive is about to start
  r.Receive(ReceiveValue);
  $fdisplay(fp,"Node%d out data: %h",NODE,ReceiveValue);
	//Communication action Receive is finished
    
	#BL;

	
  end

endmodule