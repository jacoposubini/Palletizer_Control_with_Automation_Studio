// CRANE MACHINE
// INTERFACE
// 	INPUT:
// 		CraneEnable : BOOL : It enables the machine and executes the Homing if it is not already done.
//		CraneStart : BOOL : It starts a machine cycle if The machine is Ready
//		CraneStop : BOOL
//		CraneEmergencyStop : BOOL
// 		
//	OUTPUT:
//		CraneIsEnable : BOOL : True if the machine is ready to start a new cycle.
//		CraneIsReady : BOOL : True if the machine is ready to start a new cycle.
//		CraneIsStop : BOOL
//		CraneIsStopEmergency : BOOL

PROGRAM _INIT
	(* Insert code here *)
	State := Idle;
	
	pusher_x_enable_request := FALSE;
	pusher_x_disable_request := FALSE;
	pusher_z_enable_request := FALSE;
	pusher_z_disable_request := FALSE;
	slide_rail_right_enable_request := FALSE;
	slide_rail_right_disable_request := FALSE;
	vacuum_box_crane_enable_request := FALSE;
	vacuum_box_crane_disable_request := FALSE;
	cardboard_enable_request := FALSE;
	cardboard_disable_request := FALSE;
	
	CounterFloor := 0;
	box_crane.Command := IDLE;
	gantry_crane.Command := IDLE;
	CraneIsReady := FALSE;
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	CASE EmergencyStopMachine OF
		0: IF EmergencyStop AND State <> EmergencyState THEN
				State := EmergencyState;
				gantry_crane.Command := EMERGENCY_STOP_REQUEST;
				box_crane.Command := EMERGENCY_STOP_REQUEST;
				EmergencyStopMachine := 1;
			END_IF
		1: IF NOT EmergencyStop THEN
				EmergencyStopMachine := 0;
			END_IF
	END_CASE
	
	CASE ImmediateStopMachine OF
		0: IF ImmediateStop AND State <> ImmediateStopState THEN
				OldState := State;
				OldBoxCraneCommand := box_crane.Command;
				OldGantryCraneCommand := gantry_crane.Command;
				OldPositionBoxCraneGoal := box_crane_goal;
				OldPositionGantryCraneGoal := gantry_crane_goal;
				box_crane.Command := IMMEDIATE_STOP_REQUEST;
				gantry_crane.Command := IMMEDIATE_STOP_REQUEST;
				State := ImmediateStopState;
				ImmediateStopMachine := 1;
			END_IF
		1: IF NOT ImmediateStop THEN
				ImmediateStopMachine := 0;
			END_IF
	END_CASE
	
	CASE State OF
		
		EmergencyState:
			IF NOT EmergencyStop THEN
				gantry_crane.Command := IDLE;
				box_crane.Command := IDLE;
				CraneIsReady := FALSE;
				CraneEnable := FALSE;
				State := Idle;
			END_IF
		
		ImmediateStopState:
			IF NOT ImmediateStop AND CraneStart THEN
				CraneStart := FALSE;
				State := OldState;
				box_crane.Command := OldBoxCraneCommand;
				box_crane_goal := OldPositionBoxCraneGoal;
				
				gantry_crane.Command := OldGantryCraneCommand;
				gantry_crane_goal := OldPositionGantryCraneGoal;
			END_IF
			
		
		Idle:
			IF CraneEnable THEN
				// Abbassare il Box_Crane
				slide_rail_right_disable_request := TRUE;
				pusher_x_disable_request := TRUE;
				pusher_z_disable_request := TRUE;
				vacuum_box_crane_disable_request := TRUE;
				cardboard_disable_request := TRUE;
				CounterFloor := 0;
			
				IF box_crane_AXIS <> BOX_CRANE_HOMING_POSITION THEN
					box_crane_goal := BOX_CRANE_HOMING_POSITION;
					box_crane.Command := CHANGE_POSITION;
				END_IF
				IF gantry_crane_AXIS <> GANTRY_CRANE_HOMING_POSITION THEN
					gantry_crane_goal := GANTRY_CRANE_HOMING_POSITION;
					gantry_crane.Command := CHANGE_POSITION;
				END_IF
				State := CardBoardPickHoming;
			END_IF
			
		CardBoardPickHoming:
			IF 	(slide_rail_right_disable_request = FALSE AND pusher_x_disable_request = FALSE AND pusher_z_disable_request = FALSE 
				AND BoxCranePositionReached AND GantryCranePositionReached) THEN
				IF box_crane_AXIS <> CARDBOARD_PICK_POSITION THEN
					box_crane_goal := CARDBOARD_PICK_POSITION;
					box_crane.Command := CHANGE_POSITION;
				END_IF
				State := CardBoardVacuum;
			END_IF
			
		CardBoardVacuum:
			IF BoxCranePositionReached  THEN
				cardboard_enable_request := TRUE;
				vacuum_box_crane_enable_request := TRUE;
				State := CardBoardVacuumHoming;
			END_IF
			
		CardBoardVacuumHoming:
			IF (vacuum_box_crane_enable_request = FALSE  AND cardboard_enable_request = FALSE) THEN
				cardboard_disable_request := TRUE;
				IF box_crane_AXIS <> BOX_CRANE_HOMING_POSITION THEN
					box_crane_goal := BOX_CRANE_HOMING_POSITION;
					box_crane.Command := CHANGE_POSITION;
					State := Homing;
				END_IF
			END_IF
			
		Homing:
			IF  BoxCranePositionReached AND cardboard_disable_request = FALSE THEN
				CraneIsReady := TRUE;
				CraneEnable := FALSE;
				State := HomingDone;
			END_IF
			
		HomingDone:
			// crane ready, wait for start
			IF CraneStart THEN
				CraneStart := FALSE;
				CraneIsReady := FALSE;
				CounterFloor := CounterFloor + 1;
				slide_rail_right_enable_request := TRUE;
				pusher_z_enable_request := TRUE;
				State := MoveToCardBoardPositioning;
			END_IF
			
		MoveToCardBoardPositioning:
			IF slide_rail_right_enable_request = FALSE  AND pusher_z_enable_request = FALSE THEN // the closure of the slide_rail_right should be defined in correspondance of the MAIN-FEEDER-CRANE interface
				IF (CounterFloor MOD 2 = 1) = TRUE THEN
					IF box_crane_AXIS <> BOX_CRANE_FLOOR1_POSITION THEN
						box_crane_goal := BOX_CRANE_FLOOR1_POSITION;
						box_crane.Command := CHANGE_POSITION;
					END_IF
				ELSE
					IF box_crane_AXIS <> BOX_CRANE_FLOOR2_POSITION THEN
						box_crane_goal := BOX_CRANE_FLOOR2_POSITION;
						box_crane.Command := CHANGE_POSITION;
					END_IF
				END_IF
				IF gantry_crane_AXIS <> GANTRY_CRANE_CARDBOARD_POSITION THEN
					gantry_crane_goal := GANTRY_CRANE_CARDBOARD_POSITION;
					gantry_crane.Command := CHANGE_POSITION;
				END_IF
				
				IF NOT (BoxCranePositionReached AND GantryCranePositionReached) THEN
					State := CardBoardPositioning;
				END_IF
			END_IF
			
		CardBoardPositioning:
			IF  (BoxCranePositionReached AND GantryCranePositionReached) THEN
				vacuum_box_crane_disable_request := TRUE;
				State := MoveToPallet;
			END_IF
			
		MoveToPallet:
			IF (vacuum_box_crane_disable_request = FALSE) THEN
				IF gantry_crane_AXIS <> GANTRY_CRANE_PALLET_POSITION THEN
					gantry_crane_goal := GANTRY_CRANE_PALLET_POSITION;
					gantry_crane.Command := CHANGE_POSITION;
				END_IF
				State := FreeBoxes;
			END_IF
			
		FreeBoxes:
			IF GantryCranePositionReached THEN
				slide_rail_right_disable_request := TRUE;
				IF (CounterFloor MOD 2 = 1) = TRUE THEN
					State := MoveToCardBoardBuffer1;
				ELSE
					State := MoveToCardBoardBuffer2_1;
				END_IF
			END_IF
			
		MoveToCardBoardBuffer1:
			IF slide_rail_right_disable_request = FALSE THEN
				pusher_x_enable_request := TRUE; // POTREBBE ESSERE NECESSARIO FARE PRIMA LA RICHIESTA E POI MUOVERE IL CRANE
				IF box_crane_AXIS <> CARDBOARD_PICK_POSITION THEN
					box_crane_goal := CARDBOARD_PICK_POSITION;
					box_crane.Command := CHANGE_POSITION;
				END_IF
				IF gantry_crane_AXIS <> GANTRY_CRANE_HOMING_POSITION THEN
					gantry_crane_goal := GANTRY_CRANE_HOMING_POSITION;
					gantry_crane.Command := CHANGE_POSITION;
				END_IF
				State := CardBoardPick;
			END_IF
			
		MoveToCardBoardBuffer2_1:
			IF slide_rail_right_disable_request = FALSE THEN
				pusher_x_enable_request := TRUE; // POTREBBE ESSERE NECESSARIO FARE PRIMA LA RICHIESTA E POI MUOVERE IL CRANE
				IF gantry_crane_AXIS <> GANTRY_CRANE_HOMING_POSITION THEN
					gantry_crane_goal := GANTRY_CRANE_HOMING_POSITION;
					gantry_crane.Command := CHANGE_POSITION;
				END_IF
				State := MoveToCardBoardBuffer2_2;
			END_IF
		MoveToCardBoardBuffer2_2:
			IF pusher_x_enable_request = FALSE AND GantryCranePositionReached THEN
				IF box_crane_AXIS <> CARDBOARD_PICK_POSITION THEN
					box_crane_goal := CARDBOARD_PICK_POSITION;
					box_crane.Command := CHANGE_POSITION;
				END_IF
				State := CardBoardPick;
			END_IF
			
		CardBoardPick:
			IF pusher_x_enable_request = FALSE AND BoxCranePositionReached AND GantryCranePositionReached THEN
				cardboard_enable_request := TRUE;
				vacuum_box_crane_enable_request := TRUE;
				State := MoveToHomingPosition;
			END_IF
			
		MoveToHomingPosition:
			IF vacuum_box_crane_enable_request = FALSE AND cardboard_enable_request = FALSE THEN
				IF box_crane_AXIS <> BOX_CRANE_HOMING_POSITION THEN
					box_crane_goal := BOX_CRANE_HOMING_POSITION;
					box_crane.Command := CHANGE_POSITION;
				END_IF
				cardboard_disable_request := TRUE;
				pusher_x_disable_request := TRUE;
				pusher_z_disable_request := TRUE;
				State := CheckForHomingDone;
			END_IF
			
		CheckForHomingDone:
			IF pusher_x_disable_request = FALSE AND pusher_z_disable_request = FALSE AND cardboard_disable_request = FALSE AND BoxCranePositionReached AND GantryCranePositionReached THEN
				State := HomingDone;
				CraneIsReady := TRUE;
			END_IF
		
	END_CASE
		
	// Device Calls
	// Generic Axis
	box_crane.NewSetPoint := box_crane_goal;
	box_crane.DeviceTimer := box_crane_timer; // if elapsed gives fault (See GenericAxis library)
	box_crane.ActualPosition := box_crane_AXIS;
	box_crane.TGT_SENSOR := TRUE;
	box_crane();
	box_crane_TGT_POS := box_crane.TargetPosition;
	BoxCranePositionReached := box_crane.InPosition;
	
	
	gantry_crane.NewSetPoint := gantry_crane_goal;
	gantry_crane.DeviceTimer := gantry_crane_timer; // if elapsed gives fault (See GenericAxis library)
	gantry_crane.ActualPosition := gantry_crane_AXIS;
	gantry_crane.TGT_SENSOR := TRUE;
	gantry_crane();
	gantry_crane_TGT_POS := gantry_crane.TargetPosition;
	GantryCranePositionReached := gantry_crane.InPosition;
	
	
	// Generic Device
	pusher_x.DeviceOperation := OperationType;
	pusher_x.DeviceClock := TRUE;
	pusher_x.DeviceDiagnosticsEnabled := TRUE;
	pusher_x.DeviceEnablePreset := FALSE;
	pusher_x.DeviceEnableTime := pusher_x_enable_time;
	pusher_x.DeviceDisableTime := pusher_x_disable_time;
	pusher_x.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher_x(DeviceEnableRequest := pusher_x_enable_request, DeviceDisableRequest := pusher_x_disable_request);
	pusher_x_EN := pusher_x.EnableDevice;
	
	pusher_z.DeviceOperation := OperationType;
	pusher_z.DeviceClock := TRUE;
	pusher_z.DeviceDiagnosticsEnabled := TRUE;
	pusher_z.DeviceEnablePreset := FALSE;
	pusher_z.DeviceEnableTime := pusher_z_enable_time;
	pusher_z.DeviceDisableTime := pusher_z_disable_time;
	pusher_z.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher_z(DeviceEnableRequest := pusher_z_enable_request, DeviceDisableRequest := pusher_z_disable_request);
	pusher_z_EN := pusher_z.EnableDevice;
	
	slide_rail_right.DeviceOperation := OperationType;
	slide_rail_right.DeviceClock := TRUE;
	slide_rail_right.DeviceDiagnosticsEnabled := TRUE;
	slide_rail_right.DeviceEnablePreset := FALSE;
	slide_rail_right.DeviceEnableTime := slide_rail_right_enable_time;
	slide_rail_right.DeviceDisableTime := slide_rail_right_disable_time;
	slide_rail_right.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	slide_rail_right(DeviceEnableRequest := slide_rail_right_enable_request, DeviceDisableRequest := slide_rail_right_disable_request);
	slide_rail_right_EN := slide_rail_right.EnableDevice;
	
	vacuum_box_crane.DeviceOperation := OperationType;
	vacuum_box_crane.DeviceClock := TRUE;
	vacuum_box_crane.DeviceDiagnosticsEnabled := TRUE;
	vacuum_box_crane.DeviceEnablePreset := FALSE;
	vacuum_box_crane.DeviceEnableTime := vacuum_box_crane_enable_time;
	vacuum_box_crane.DeviceDisableTime := vacuum_box_crane_disable_time;
	vacuum_box_crane.DeviceEnabledSensor := vacuum_box_crane_VACUUM;
	vacuum_box_crane.DeviceType := DEVICE_WITH_ENABLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	vacuum_box_crane(DeviceEnableRequest := vacuum_box_crane_enable_request, DeviceDisableRequest := vacuum_box_crane_disable_request);
	vacuum_box_crane_GRIP := vacuum_box_crane.EnableDevice;
	
	cardboard.DeviceOperation := OperationType;
	cardboard.DeviceClock := TRUE;
	cardboard.DeviceDiagnosticsEnabled := TRUE;
	cardboard.DeviceEnablePreset := FALSE;
	cardboard.DeviceEnableTime := cardboard_enable_time;
	cardboard.DeviceDisableTime := cardboard_disable_time;
	cardboard.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	cardboard(DeviceEnableRequest := cardboard_enable_request, DeviceDisableRequest := cardboard_disable_request);
	cardboard_TRIG := cardboard.EnableDevice;

	// Signals
	
	(* Pusher X *)
	PusherXActuatorFaultE := pusher_x.DeviceActuatorFault;
	PusherXDisableSensorFaultE := pusher_x.DeviceDisabledSensorFault;
	PusherXEnableSensorFaultE := pusher_x.DeviceEnabledSensorFault;

	(* Pusher Z *)
	PusherZActuatorFaultE := pusher_z.DeviceActuatorFault;
	PusherZDisableSensorFaultE := pusher_z.DeviceDisabledSensorFault;
	PusherZEnableSensorFaultE := pusher_z.DeviceEnabledSensorFault;

	(* Slide Rail Right *)
	SlideRailRightActuatorFaultE := slide_rail_right.DeviceActuatorFault;
	SlideRailRightDisableFaultE := slide_rail_right.DeviceDisabledSensorFault;
	SlideRailRightEnableFaultE := slide_rail_right.DeviceEnabledSensorFault;

	(* Vacuum Box Crane *)
	VacuumBoxCraneActuatorFaultE := vacuum_box_crane.DeviceActuatorFault;
	VacuumBoxCraneDisableFaultE := vacuum_box_crane.DeviceDisabledSensorFault;
	VacuumBoxCraneEnableFaultE := vacuum_box_crane.DeviceEnabledSensorFault;

	(* Cardboard *)
	CardboardActuatorFaultE := cardboard.DeviceActuatorFault;
	CardboardDisableFaultE := cardboard.DeviceDisabledSensorFault;
	CardboardEnableFaultE := cardboard.DeviceEnabledSensorFault;
	
	(* Box Crane *)
	BoxCraneFaultSignalE :=  box_crane.DeviceFault;
	
	(* Gantry Crane *)
	GantryCraneFaultSignalE := gantry_crane.DeviceFault;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

