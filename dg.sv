import SystemVerilogCSP::*;

module data_generator (interface r);
  parameter WIDTH = 57;
  parameter FL = 0; //ideal environment   forward delay
  logic [WIDTH-1:0] SendValue=0;
  always
  begin 
    
	//add a display here to see when this module starts its main loop
    SendValue = $random() % (2**WIDTH); // the range of random number is from 0 to 2^WIDTH
    #FL;   // change FL and check the change of performance
     
    //Communication action Send is about to start
    r.Send(SendValue);
    //Communication action Send is finished
	

  end
endmodule