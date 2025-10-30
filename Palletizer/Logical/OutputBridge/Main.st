
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	// Feeder output variable simulation establishment 
	ComTCP_SimOutputs.conveyor_if_FWD := conveyor_if_FWD;
	ComTCP_SimOutputs.conveyer_turn1_FWD :=  conveyor_turn1_FWD;
	ComTCP_SimOutputs.conveyer_end_FWD := conveyor_end_FWD;
	ComTCP_SimOutputs.pusher_FW := pusher_FW;
	ComTCP_SimOutputs.turnpusher_BWD := NOT(turnpusher_BWD);
	ComTCP_SimOutputs.turnpusher_FWD := NOT(turnpusher_FWD);
	ComTCP_SimOutputs.carriage_2_TGT_POS := carrige_2_TGT_POS;
	
	// Crane output variable simulation establishment 
	ComTCP_SimOutputs.vaccum_box_crane_GRIP := vacuum_box_crane_GRIP;
	ComTCP_SimOutputs.gantry_crane_TGT_POS := gantry_crane_TGT_POS;
	ComTCP_SimOutputs.box_crane_TGT_POS := box_crane_TGT_POS;
	ComTCP_SimOutputs.cartboard_TRIG := cardboard_TRIG;
	ComTCP_SimOutputs.slide_rail_right_EN := slide_rail_right_EN;
	ComTCP_SimOutputs.pusher_z_EN := pusher_z_EN;
	ComTCP_SimOutputs.pusher_x_EN := pusher_x_EN;
	
	// Pallet Handler output variable simulation establishment 
	ComTCP_SimOutputs.pallet_lifter_TGT_POS := pallet_lifter_TGT_POS;
	ComTCP_SimOutputs.pallet_fork_left_EN := pallet_fork_left_EN;
	ComTCP_SimOutputs.pallet_conveyor_1_FWD := pallet_conveyor_1_FWD;
	ComTCP_SimOutputs.pallet_conveyor_2_ACT_VEL := pallet_conveyor_2_ACT_VEL;

END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

