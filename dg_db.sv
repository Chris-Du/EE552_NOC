`timescale 1ns/100ps

import SystemVerilogCSP::*;

//Sample data_generator module
module data_generator (interface r);
  parameter WIDTH = 3;
  parameter FL = 0; //ideal environment   forward delay
  logic [WIDTH-1:0] SendValue=0;
  always
  begin 
    
  //add a display here to see when this module starts its main loop
  $display("data_generator starts %m %d",$time);
  
    SendValue = $random() % (2**WIDTH); // the range of random number is from 0 to 2^WIDTH
    #FL;   // change FL and check the change of performance
     
    //Communication action Send is about to start
  $display("Start sending in module %m. Simulation time =%t", $time);
    
  r.Send(SendValue);
  
    //Communication action Send is finished
  $display("Finished sending in module %m. Simulation time =%t. Data =%d.", $time, SendValue);

  end
endmodule

//Sample data_bucket module
module data_bucket (interface r);
  parameter WIDTH = 57;
  parameter BL = 0; //ideal environment    backward delay
  logic [WIDTH-1:0] ReceiveValue = 0;
  
  //Variables added for performance measurements
  real cycleCounter=0, //# of cycles = Total number of times a value is received
       timeOfReceive=0, //Simulation time of the latest Receive 
       cycleTime=0; // time difference between the last two receives
  real averageThroughput=0, averageCycleTime=0, sumOfCycleTimes=0;
  always
  begin
	
	//add a display here to see when this module starts its main loop
	$display("data_bucket starts %m %d",$time);

    timeOfReceive = $time;
	
	//Communication action Receive is about to start
	$display("Start recieving in module %m. Simulation time =%t",$time);
    
	r.Receive(ReceiveValue);
	
	//Communication action Receive is finished
	$display("--------Finished recieving in module %m. Simulation time =%t. Final result =%d.",$time,ReceiveValue);

	#BL;
    cycleCounter += 1;		
    //Measuring throughput: calculate the number of Receives per unit of time  
    //CycleTime stores the time it takes from the begining to the end of the always block
    cycleTime = $time - timeOfReceive; // the difference of time between now and the last receive
    averageThroughput = cycleCounter/$time; 
    sumOfCycleTimes += cycleTime;
    averageCycleTime = sumOfCycleTimes / cycleCounter;
    $display("Execution cycle= %d, Cycle Time= %d, 
    Average CycleTime=%f, Average Throughput=%f", cycleCounter, cycleTime, 
    averageCycleTime, averageThroughput);
	
	
  end

endmodule