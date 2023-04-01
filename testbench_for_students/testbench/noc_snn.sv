/* testbench.sv
   
   SP23 EE-552 Final project 
   
   INSTRUCTIONS:
   1. You can add/modify code to this file, if needed.

*/


module noc_snn(interface load_start, ifmap_data, ifmap_addr, timestep, filter_data, filter_addr, load_done, start_r, ts_r, layer_r, done_r, out_spike_addr, out_spike_data);

// parameters
parameter WIDTH_data = 8;
parameter WIDTH_addr = 12;
parameter WIDTH_out_data = 13;
parameter DEPTH_F= 5;
parameter DEPTH_I =25;
parameter DEPTH_R =21;

logic i1_data, i2_data, load_dn, l_st;
logic [1:0] ts;
logic [WIDTH_data-1:0] f_data;
logic [WIDTH_addr-1:0] i1_addr, i2_addr, f_addr, out_addr=0;
logic [WIDTH_out_data-1:0] out_data;

logic mem_ifmap_1[DEPTH_I*DEPTH_I-1:0];
logic mem_ifmap_2[DEPTH_I*DEPTH_I-1:0];
logic [WIDTH_data-1:0] mem_filter[DEPTH_F*DEPTH_F-1:0];

logic [WIDTH_data-1:0] mem_out_1[DEPTH_R*DEPTH_R-1:0];
logic [WIDTH_data-1:0] mem_out_2[DEPTH_R*DEPTH_R-1:0];

integer fpi_out1, fpi_out2, status;


// main execution
initial begin
// sending values to M module


  fpi_out1 = $fopen("out_spike1_sim.txt","r");
  fpi_out2 = $fopen("out_spike2_sim.txt","r");


//sending to the memory filter and feature map

 load_start.Receive(l_st);
if (l_st==1) begin
 for(integer i=0; i<DEPTH_F*DEPTH_F; i++) begin
	filter_addr.Receive(f_addr);
	filter_data.Receive(f_data);
	mem_filter[f_addr] = f_data;
	$display("Filter receives %d at %d", f_data, f_addr);
  end

  //timestep.Receive(ts);

	for(integer i=0; i<DEPTH_I*DEPTH_I; i++) begin
  		timestep.Receive(ts);
 		 if (ts == 1) begin
		ifmap_addr.Receive(i1_addr);
		ifmap_data.Receive(i1_data);
		mem_ifmap_1[i1_addr] = i1_data;
		$display("Timestep %d: receive %d at %d", ts, i1_data, i1_addr);

	  end
  end

	for(integer i=0; i<DEPTH_I*DEPTH_I; i++) begin

 	 timestep.Receive(ts);
  	  if (ts == 2) begin
		ifmap_addr.Receive(i2_addr);
		ifmap_data.Receive(i2_data);
		mem_ifmap_2[i2_addr] = i2_data;
		$display("Timestep %d: receive %d at %d", ts, i2_data, i2_addr);
	  end
  end
  end


  load_done.Receive(load_dn);
  if (load_dn==1) begin
	$display("Successfully load all ifmaps and filter!");
  end



//loading fake output spikes
   	   for(integer i=0; i<(DEPTH_R*DEPTH_R); i++) begin
	    if(!$feof(fpi_out1)) begin
	     status = $fscanf(fpi_out1,"%d\n", out_data);
	     mem_out_1[i] = out_data;
	   end end

   	   for(integer i=0; i<(DEPTH_R*DEPTH_R); i++) begin
	    if(!$feof(fpi_out2)) begin
	     status = $fscanf(fpi_out2,"%d\n", out_data);
	     mem_out_2[i] = out_data;
	   end end

  
 // sending out_spike_1
  start_r.Send(1);
  ts_r.Send(1);
  layer_r.Send(1);
  
  for(integer i=0; i<DEPTH_R*DEPTH_R; i++) begin
    out_spike_addr.Send(out_addr);
    out_spike_data.Send(mem_out_1[out_addr]);
    out_addr++;
    $display("Send out spike 1: addr: %d, data: 1", out_addr);
  end

 // sending out_spike_2
  ts_r.Send(2);
  layer_r.Send(1);
  
  out_addr=0;
  for(integer i=0; i<DEPTH_R*DEPTH_R; i++) begin
    out_spike_addr.Send(out_addr);
    out_spike_data.Send(mem_out_2[out_addr]);
    out_addr++;
    $display("Send out spike 1: addr: %d, data: 0", out_addr);
  end
  done_r.Send(1);

end
endmodule




 

