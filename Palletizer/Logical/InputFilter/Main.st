
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
	Laser1Filter.Clock := TRUE;
	Laser1Filter.ActivationDelay := 0;
	Laser1Filter.DeactivationDelay := 10;
	Laser1Filter.Signal := laser_sensor_IR;
	Laser1Filter(OperationType := OperationType);
	laser_sensor_IR_enabled := Laser1Filter.DelayedSignal;
	
	Laser2Filter.Clock := TRUE;
	Laser2Filter.ActivationDelay := 0;
	Laser2Filter.DeactivationDelay := 3;
	Laser2Filter.Signal := laser_sensor_2_IR;
	Laser2Filter(OperationType := OperationType);
	laser_sensor_2_IR_enabled := Laser2Filter.DelayedSignal;
	
	palletLightBarrier1Filter.Clock := TRUE;
	palletLightBarrier1Filter.ActivationDelay := 0;
	palletLightBarrier1Filter.DeactivationDelay := 10;
	palletLightBarrier1Filter.Signal := pallet_light_barrier_1_IR;
	palletLightBarrier1Filter(OperationType := OperationType);
	pallet_light_barrier_enabled := palletLightBarrier1Filter.DelayedSignal;
	
	palletLightBarrier2Filter.Clock := TRUE;
	palletLightBarrier2Filter.ActivationDelay := 0;
	palletLightBarrier2Filter.DeactivationDelay := 5;
	palletLightBarrier2Filter.Signal := pallet_light_barrier_2_IR;
	palletLightBarrier2Filter(OperationType := OperationType);
	pallet_light_barrier2_enabled := palletLightBarrier2Filter.DelayedSignal;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

