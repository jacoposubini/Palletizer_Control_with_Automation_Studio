
// FEEDER MACHINE
// INTERFACE
// 	INPUT:
// 		FeederEnable : BOOL : It enables the machine and executes the Homing if it is not already done.
//		FeederStart : BOOL : It starts a machine cycle if The machine is Ready
//		FeederStop : BOOL
//		FeederEmergencyStop : BOOL
// 		
//	OUTPUT:
//		FeederIsEnable : BOOL : True if the machine is ready to start a new cycle.
//		FeederIsReady : BOOL : True if the machine is ready to start a new cycle.
//		FeederIsStop : BOOL
//		FeederIsStopEmergency : BOOL

PROGRAM _INIT
	(* Insert code here *)
	State := Idle;
	
	CounterBox := 0;	// Box Counter
	CounterLayer := 0;	// Layer Counter
	CounterFloor := 1;	// Starting the counter from Floor 1 due to the MOD operator
	BoxNumber := 8; 	// Start with 8 boxes (turnpuher disabled)
	LayerNumber := 3; 	// Number of layer in a Floor
			
	// Output requests initialization
	pusher_enable_request := FALSE;
	pusher_disable_request := FALSE;
	turnpusher_enable_request := FALSE;
	turnpusher_disable_request := FALSE;
	conveyor_if_enable_request := FALSE;
	conveyor_if_disable_request := FALSE;
	conveyor_turn1_enable_request := FALSE;
	conveyor_turn1_disable_request := FALSE; 
	conveyor_end_enable_request := FALSE;
	conveyor_end_disable_request := FALSE;
	carriage.Command := IDLE;
	//Fault
	LaserSensorIRFault := FALSE;
	LaserSensor2IRFault := FALSE;
			
	carriage_homed := FALSE;
END_PROGRAM
 
PROGRAM _CYCLIC
	
	CASE EmergencyStopMachine OF
		0: 
			IF EmergencyStop AND State <> EmergencyState THEN
				State := EmergencyState;
				conveyor_if_disable_request := TRUE;
				conveyor_turn1_disable_request := TRUE;
				conveyor_end_disable_request := TRUE;
				carriage.Command := EMERGENCY_STOP_REQUEST;
				EmergencyStopMachine := 1;
			END_IF

		1: 
			IF NOT EmergencyStop THEN
				EmergencyStopMachine := 0;
			END_IF
	END_CASE


	CASE ImmediateStopMachine OF
		0: 
			IF ImmediateStop AND State <> ImmediateStopState THEN
				OldState := State;
				SuspendDevices := TRUE;
				OldCarriageCommand := carriage.Command;
				OldPositionCarriageGoal := carriage_goal;
				carriage.Command := IMMEDIATE_STOP_REQUEST;
				State := ImmediateStopState;
				ImmediateStopMachine := 1;
			END_IF

		1: 
			IF NOT ImmediateStop THEN
				ImmediateStopMachine := 0;
			END_IF
	END_CASE


	
	CASE State OF
		EmergencyState:
			IF NOT EmergencyStop THEN
				FeederIsReady := FALSE;
				FeederEnable := FALSE;
				carriage.Command := IDLE;
				State := Idle;
			END_IF
		
		ImmediateStopState:
			IF NOT ImmediateStop AND FeederStart THEN
				FeederStart := FALSE;
				SuspendDevices := FALSE;
				State := OldState;
				carriage.Command := OldCarriageCommand;
				carriage_goal := OldPositionCarriageGoal;
			END_IF

		Idle:
			IF FeederEnable THEN
				State := Homing;
				pusher_disable_request := TRUE;
				turnpusher_disable_request := TRUE;
				CounterBox := 0;
				CounterLayer := 0;
				CounterFloor := 1;	
				BoxNumber := 8; 
				LayerNumber := 3;	
				// comando di homing carriage solo se serve --- DA VEDERE
				IF carriage.ActualPosition <> HOME_POSITION THEN
					carriage.Command := CHANGE_POSITION;
					carriage_goal := HOME_POSITION;
				END_IF
			END_IF

		Homing:
			IF pusher_disable_request = FALSE AND turnpusher_disable_request = FALSE AND carriagePositionReached THEN
				OldPositionCarriageGoal := carriage_goal;
				OldCarriageCommand := carriage.Command;
				conveyor_if_enable_request := FALSE;
				conveyor_if_disable_request := FALSE;
				carriage.Command := IDLE;
				FeederIsReady := TRUE;
				FeederEnable := FALSE;
				State := HomingDone;
			END_IF
	
		HomingDone:			
			// feeder ready, ora aspetta start
			IF FeederStart THEN
				FeederStart := FALSE;
				FeederIsReady := FALSE;
				CounterLayer := 0;
				State := WaitForStart;
			END_IF

		WaitForStart:
			// counter reset at each cycle
			IF carriagePositionReached THEN
				CounterBox := 0;
				State := WaitForBoxes;
				conveyor_if_enable_request := TRUE;
				conveyor_turn1_enable_request := TRUE;
				conveyor_end_enable_request := TRUE;
			END_IF
			

		WaitForBoxes:
			IF conveyor_if_enable_request = FALSE
				AND conveyor_turn1_enable_request = FALSE 
				AND conveyor_end_enable_request = FALSE THEN
			
				IF laser_sensor_IR_enabled THEN
					FeederHomed := FALSE;
					State := PushBox;
					conveyor_if_disable_request := TRUE;
					pusher_enable_request := TRUE;
				END_IF
				
			END_IF

		PushBox:
			IF pusher_enable_request = FALSE AND conveyor_if_disable_request = FALSE THEN
				State := CheckSecondLaser;
			END_IF

		CheckSecondLaser:
			IF laser_sensor_2_IR_enabled THEN
				CounterBox := CounterBox + 1;
				State := CheckPusherBackwardPosition;
				pusher_disable_request := TRUE;
			END_IF

		CheckPusherBackwardPosition:
			IF pusher_disable_request = FALSE THEN
				IF CounterBox < BoxNumber THEN
					conveyor_if_enable_request := TRUE;
					State := WaitForBoxes;
				ELSE
					CounterLayer := CounterLayer + 1;
					conveyor_turn1_disable_request := TRUE;
					conveyor_end_disable_request := TRUE;
					State := WaitBeforeCarriage;
				END_IF
			END_IF

		WaitBeforeCarriage:
			IF conveyor_turn1_disable_request = FALSE AND conveyor_end_disable_request = FALSE THEN
				IF CounterLayer < LayerNumber THEN
					carriage.Command := CHANGE_POSITION;
					carriage_goal := CARRIAGE_MID_PUSH;
					State := CarriageMidPush;
				ELSE
					FeederIsReady := TRUE;
					State := CarriageWaitForStart;
				END_IF
			END_IF

		CarriageWaitForStart:
			IF FeederStart THEN
				FeederStart := FALSE;
				FeederIsReady := FALSE;
				carriage.Command := CHANGE_POSITION;
				carriage_goal := CARRIAGE_TOTAL_PUSH;
				State := CarriageTotalPush;
			END_IF

		CarriageMidPush:
			IF carriagePositionReached THEN
				IF (CounterFloor MOD 2 = 1) = TRUE THEN
					IF CounterLayer > 0 THEN
						turnpusher_enable_request := TRUE;
						turnpusher_disable_request := FALSE;
						BoxNumber := 3;
					ELSE
						turnpusher_enable_request := FALSE;
						turnpusher_disable_request := TRUE;
						BoxNumber := 8;
					END_IF
				ELSE
					IF CounterLayer > 1 THEN
						turnpusher_enable_request := FALSE;
						turnpusher_disable_request := TRUE;
						BoxNumber := 8;
					ELSE
						turnpusher_enable_request := TRUE;
						turnpusher_disable_request := FALSE;
						BoxNumber := 3;
					END_IF
				END_IF

				State := CarriagePushBack;
			END_IF


		CarriageTotalPush:
			IF carriagePositionReached AND turnpusher_enable_request = FALSE AND turnpusher_disable_request = FALSE THEN
				CounterFloor := CounterFloor + 1;
				State := CarriagePushBack;
			END_IF

		CarriagePushBack:
			IF carriagePositionReached THEN
				carriage.Command := CHANGE_POSITION;
				carriage_goal := HOME_POSITION;
				IF CounterLayer = 3 THEN
					State := HomingDone;
					FeederIsReady := TRUE;
				ELSE
					State := WaitForStart;
				END_IF
			END_IF
		

	END_CASE;

	// DEVICE CALLS
	
	// pusher
	pusher.DeviceOperation := OperationType;
	pusher.DeviceClock := TRUE;
	pusher.DeviceDiagnosticsEnabled := TRUE;
	pusher.DeviceEnablePreset := FALSE;
	pusher.DeviceEnableTime := pusher_enable_time;
	pusher.DeviceDisableTime := pusher_disable_time;
	pusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher.DeviceEnabledSensor := pusher_LFR;
	pusher.DeviceDisabledSensor := pusher_LBK;
	pusher(DeviceEnableRequest := pusher_enable_request, DeviceDisableRequest := pusher_disable_request);
	pusher_FW := pusher.EnableDevice;


	// turnpusher
	turnpusher.DeviceOperation := OperationType;
	turnpusher.DeviceClock := TRUE;
	turnpusher.DeviceDiagnosticsEnabled := TRUE;
	turnpusher.DeviceEnablePreset := FALSE;
	turnpusher.DeviceEnableTime := turnpusher_enable_time;
	turnpusher.DeviceDisableTime := turnpusher_disable_time;
	turnpusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_DOUBLE_ACTUATION;
	turnpusher.DeviceEnabledSensor := turnpusher_LFR;
	turnpusher.DeviceDisabledSensor := turnpusher_LBK;
	turnpusher(DeviceEnableRequest := turnpusher_enable_request, DeviceDisableRequest := turnpusher_disable_request);
	turnpusher_FWD := turnpusher.EnableDevice;
	turnpusher_BWD := turnpusher.DisableDevice;


	// conveyor_if
	conveyor_if.DeviceOperation := OperationType;
	conveyor_if.DeviceClock := TRUE;
	conveyor_if.DeviceDiagnosticsEnabled := TRUE;
	conveyor_if.ImmediateStop := SuspendDevices OR EmergencyStop;
	conveyor_if.DeviceEnablePreset := FALSE;
	conveyor_if.DeviceEnableTime := conveyor_if_enable_time;
	conveyor_if.DeviceDisableTime := conveyor_if_disable_time;
	conveyor_if.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION OR DEVICE_IMMEDIATE_STOP_AUTOMATIC;
	conveyor_if(DeviceEnableRequest := conveyor_if_enable_request, DeviceDisableRequest := conveyor_if_disable_request);
	conveyor_if_FWD := conveyor_if.EnableDevice;


	// conveyor_turn1
	conveyor_turn1.DeviceOperation := OperationType;
	conveyor_turn1.DeviceClock := TRUE;
	conveyor_turn1.DeviceDiagnosticsEnabled := TRUE;
	conveyor_turn1.ImmediateStop := SuspendDevices OR EmergencyStop;
	conveyor_turn1.DeviceEnablePreset := FALSE;
	conveyor_turn1.DeviceEnableTime := conveyor_turn1_enable_time;
	conveyor_turn1.DeviceDisableTime := conveyor_turn1_disable_time;
	conveyor_turn1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION OR DEVICE_IMMEDIATE_STOP_AUTOMATIC;
	conveyor_turn1(DeviceEnableRequest := conveyor_turn1_enable_request, DeviceDisableRequest := conveyor_turn1_disable_request);
	conveyor_turn1_FWD := conveyor_turn1.EnableDevice;


	// conveyor_end
	conveyor_end.DeviceOperation := OperationType;
	conveyor_end.DeviceClock := TRUE;
	conveyor_end.DeviceDiagnosticsEnabled := TRUE;
	conveyor_end.ImmediateStop := SuspendDevices OR EmergencyStop;
	conveyor_end.DeviceEnablePreset := FALSE;
	conveyor_end.DeviceEnableTime := conveyor_end_enable_time;
	conveyor_end.DeviceDisableTime := conveyor_end_disable_time;
	conveyor_end.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION OR DEVICE_IMMEDIATE_STOP_AUTOMATIC;
	conveyor_end(DeviceEnableRequest := conveyor_end_enable_request, DeviceDisableRequest := conveyor_end_disable_request);
	conveyor_end_FWD := conveyor_end.EnableDevice;

	// carriage
	carriage.NewSetPoint := carriage_goal;
	carriage.DeviceTimer := carriage_timer; // if elapsed gives fault (See GenericAxis library)
	carriage.ActualPosition := carriage_2_AXIS;
	carriage.TGT_SENSOR := carriage_2_RCHD;
	carrige_2_TGT_POS := carriage.TargetPosition;
	carriagePositionReached := carriage.InPosition;
	carriage();
	
	// Signals
	
	// turnpusher fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	TurnpusherActuatorFaultE := turnpusher.DeviceActuatorFault;
	TurnpusherDisableSensorFaultE := turnpusher.DeviceDisabledSensorFault;
	TurnpusherEnableSensorFaultE := turnpusher.DeviceEnabledSensorFault;
	
	// pusher fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	PusherActuatorFaultE := pusher.DeviceActuatorFault;
	PusherDisableSensorFaultE := pusher.DeviceDisabledSensorFault;
	PusherEnableSensorFaultE := pusher.DeviceEnabledSensorFault;
	
	// conveyor_if fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	ConveyorIfActuatorFaultE := conveyor_if.DeviceActuatorFault;
	ConveyorIfDisableSensorFaultE := conveyor_if.DeviceDisabledSensorFault;
	ConveyorIfEnableSensorFaultE := conveyor_if.DeviceEnabledSensorFault;
	
	// conveyor_turn1 fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	ConveyorTurn1ActuatorFaultE := conveyor_turn1.DeviceActuatorFault;
	ConveyorTurn1DisableSensorFaultE := conveyor_turn1.DeviceDisabledSensorFault;
	ConveyorTurn1EnableSensorFaultE := conveyor_turn1.DeviceEnabledSensorFault;
	
	// conveyor_end fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	ConveyorEndActuatorFaultE := conveyor_end.DeviceActuatorFault;
	ConveyorEndDisableSensorFaultE := conveyor_end.DeviceDisabledSensorFault;
	ConveyorEndEnableSensorFaultE := conveyor_end.DeviceEnabledSensorFault;
	
	// carriage fault signals (TO BE DEFINED AS GLOBAL VARIABLES)
	CarriagePositionFaultSignalE := carriage.DeviceFault;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
END_PROGRAM
