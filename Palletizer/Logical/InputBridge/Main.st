
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	// Feeder input variable simulation establishment 
	laser_sensor_IR := ComTCP_SimInputs.laser_sensor_IR;
	laser_sensor_2_IR := ComTCP_SimInputs.laser_sensor2_IR;
	carriage_2_AXIS := ComTCP_SimInputs.carriage_2_AXIS;
	carriage_2_RCHD := ComTCP_SimInputs.carriage_2_RCHD;
	pusher_LBK := ComTCP_SimInputs.pusher_LBK;
	pusher_LFR := ComTCP_SimInputs.pusher_LFR;
	turnpusher_LBK := NOT(ComTCP_SimInputs.turnpusher_LBK);
	turnpusher_LFR := NOT(ComTCP_SimInputs.turnpusher_LFR);
	
	// Crane input variable simulation establishment 
	vacuum_box_crane_VACUUM := ComTCP_SimInputs.vaccum_box_crane_VACUUM;
	box_crane_AXIS := ComTCP_SimInputs.box_crane_AXIS;
	gantry_crane_AXIS := ComTCP_SimInputs.gantry_crane_AXIS;
	
	// Pallet Handler input variable simulation establishment 
	pallet_lifter_AXIS := ComTCP_SimInputs.pallet_lifter_AXIS;
	pallet_fork_left_FB := ComTCP_SimInputs.pallet_fork_left_FB;
	pallet_light_barrier_1_IR := ComTCP_SimInputs.pallet_light_barrier_1_IR;
	pallet_light_barrier_2_IR := ComTCP_SimInputs.pallet_light_barrier_2_IR;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

