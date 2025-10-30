// PALLET HANDLER MACHINE
// INTERFACE
// 	INPUT:
// 		PalletHandlerEnable : BOOL : It enables the machine and executes the Homing if it is not already done.
//		PalletHandlerStart : BOOL : It starts a machine cycle if The machine is Ready
//		PalletHandlerStop : BOOL
//		PalletHandlerEmergencyStop : BOOL
// 		
//	OUTPUT:
//		PalletHandlerIsEnable : BOOL : True if the machine is ready to start a new cycle.
//		PalletHandlerIsReady : BOOL : True if the machine is ready to start a new cycle.
//		PalletHandlerIsStop : BOOL
//		PalletHandlerIsStopEmergency : BOOL

PROGRAM _INIT
	(* Insert code here *)
	State := Idle;
	pallet_conveyor_2.Command := IDLE;
	pallet_lifter.Command := IDLE;
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	CASE EmergencyStopMachine OF
		0: IF EmergencyStop AND State <> EmergencyState THEN
				State := EmergencyState;
				pallet_lifter.Command := EMERGENCY_STOP_REQUEST;
				pallet_conveyor_2.Command := EMERGENCY_STOP_REQUEST;
				EmergencyStopMachine := 1;
			END_IF
		1: IF NOT EmergencyStop THEN
				EmergencyStopMachine := 0;
			END_IF
	END_CASE
	
	CASE ImmediateStopMachine OF
		0: IF ImmediateStop AND State <> ImmediateStopState THEN
				OldState := State;
				SuspendDevices := TRUE;
				OldPalletLifterCommand := pallet_lifter.Command;
				OldPalletConveyor2Command := pallet_conveyor_2.Command;
				OldPositionPalletLifterGoal := pallet_lifter_goal;
				OldPositionPalletConv2Vel := pallet_conveyor_2_velocity;
				pallet_lifter.Command := IMMEDIATE_STOP_REQUEST;
				pallet_conveyor_2.Command := IMMEDIATE_STOP_REQUEST;
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
				State := Idle;
				PalletHandlerIsReady := FALSE;
				PalletHandlerEnable := FALSE;
				pallet_lifter.Command := IDLE;
				pallet_conveyor_2.Command := IDLE;
			END_IF
		
		ImmediateStopState:
			IF NOT ImmediateStop AND PalletHandlerStart THEN
				PalletHandlerStart := FALSE;
				SuspendDevices := FALSE;
				State := OldState;
				pallet_lifter.Command := OldPalletLifterCommand;
				pallet_lifter_goal := OldPositionPalletLifterGoal;
				
				pallet_conveyor_2.Command := OldPalletConveyor2Command;
				pallet_conveyor_2_velocity := OldPositionPalletConv2Vel;
			END_IF
			
		Idle:
			IF PalletHandlerEnable THEN				// da impostare la variabile
				pallet_fork_disable_request := TRUE;
				pallet_conveyor_1_disable_reques := TRUE;
				IF pallet_lifter_TGT_POS <> PALLET_LIFTER_IDLE THEN
					pallet_lifter_goal := PALLET_LIFTER_IDLE;
					pallet_lifter.Command := CHANGE_POSITION;
				END_IF
				IF pallet_conveyor_2_ACT_VEL <> STANDSTILL THEN
					pallet_conveyor_2.Command := CHANGE_VELOCITY;
					pallet_conveyor_2_velocity := STANDSTILL;
				END_IF
				State := Homing;
			END_IF
		
		Homing:
			IF pallet_fork_disable_request = FALSE AND pallet_conveyor_1_disable_reques = FALSE AND PalletLifterPositionReached AND PalletConveyor2VelReached THEN
				State := HomingDone;
				PalletHandlerIsReady := TRUE;
				PalletHandlerEnable := FALSE;
			END_IF
			
		HomingDone:
			IF PalletHandlerStart THEN 
				PalletHandlerStart := FALSE;
				PalletHandlerIsReady := FALSE;
				IF pallet_lifter_TGT_POS <> PALLET_LIFTER_RELEASE THEN
					pallet_lifter_goal := PALLET_LIFTER_RELEASE;
					pallet_lifter.Command := CHANGE_POSITION;
				END_IF				
				IF pallet_conveyor_2_ACT_VEL <> FAST_VELOCITY THEN
					pallet_conveyor_2.Command := CHANGE_VELOCITY;
					pallet_conveyor_2_velocity := FAST_VELOCITY;
				END_IF
				State := MoveToPalletPositioning;
			END_IF
			
		MoveToPalletPositioning:
			IF PalletLifterPositionReached AND 	PalletConveyor2VelReached THEN
				pallet_fork_enable_request := TRUE;
				State := ReleasePallet;
			END_IF	
			
		ReleasePallet:
			IF pallet_fork_enable_request = FALSE THEN
				IF pallet_lifter_TGT_POS <> PALLET_LIFTER_GRASP THEN
					pallet_lifter_goal := PALLET_LIFTER_GRASP;
					pallet_lifter.Command := CHANGE_POSITION;
				END_IF
				State := MoveToNewPallet;
			END_IF
			
		MoveToNewPallet:
			IF PalletLifterPositionReached THEN
				pallet_fork_disable_request := TRUE;
				State := GraspPallet;
			END_IF
			
		GraspPallet:
			IF pallet_fork_disable_request = FALSE THEN
				IF pallet_lifter_TGT_POS <> PALLET_LIFTER_IDLE THEN
					pallet_lifter_goal := PALLET_LIFTER_IDLE;
					pallet_lifter.Command := CHANGE_POSITION;
				END_IF
				State := RaisePalletStack;
			END_IF
			
		RaisePalletStack:
			IF PalletLifterPositionReached THEN
				pallet_conveyor_1_enable_request := TRUE;
				State := MoveConveyor;
			END_IF
			
		MoveConveyor:
			IF pallet_conveyor_1_enable_request = FALSE THEN
				State := PalletApproach;
			END_IF
			
		PalletApproach:
			IF pallet_light_barrier2_enabled THEN
				pallet_conveyor_1_disable_reques := TRUE;
				IF pallet_conveyor_2_ACT_VEL <> LOW_VELOCITY THEN
					pallet_conveyor_2.Command := CHANGE_VELOCITY;
					pallet_conveyor_2_velocity := LOW_VELOCITY;
				END_IF
				State := PalletSlowdown;
			END_IF
			
		PalletSlowdown:
			IF pallet_conveyor_1_disable_reques = FALSE AND	PalletConveyor2VelReached THEN 
				State := PalletArrived;
			END_IF
			
		PalletArrived:
			IF pallet_light_barrier_enabled THEN
				IF pallet_conveyor_2_ACT_VEL <> STANDSTILL THEN
					pallet_conveyor_2.Command := CHANGE_VELOCITY;
					pallet_conveyor_2_velocity := STANDSTILL;
				END_IF
				State := PalletStop;
			END_IF
			
		PalletStop:
			IF PalletConveyor2VelReached THEN	
				PalletHandlerIsReady := TRUE;
				State := HomingDone;
			END_IF
			
	END_CASE
	

	// pallet_fork
	pallet_fork.DeviceOperation := OperationType;
	pallet_fork.DeviceClock := TRUE;
	pallet_fork.DeviceDiagnosticsEnabled := TRUE;
	pallet_fork.DeviceEnablePreset := FALSE;
	pallet_fork.DeviceEnableTime := pallet_fork_enable_time;
	pallet_fork.DeviceDisableTime := pallet_fork_disable_time;
	pallet_fork.DeviceEnabledSensor := pallet_fork_left_FB;
	pallet_fork.DeviceType := DEVICE_WITH_ENABLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pallet_fork(DeviceEnableRequest := pallet_fork_enable_request, DeviceDisableRequest := pallet_fork_disable_request);	
	pallet_fork_left_EN := pallet_fork.EnableDevice;
	
	// pallet_conveyor_1
	pallet_conveyor_1.DeviceOperation := OperationType;
	pallet_conveyor_1.DeviceClock := TRUE;
	pallet_conveyor_1.DeviceDiagnosticsEnabled := TRUE;
	pallet_conveyor_1.ImmediateStop := SuspendDevices OR EmergencyStop;
	pallet_conveyor_1.DeviceEnablePreset := FALSE;
	pallet_conveyor_1.DeviceEnableTime := pallet_conveyor_1_enable_time;
	pallet_conveyor_1.DeviceDisableTime := pallet_conveyor_1_disable_time;
	pallet_conveyor_1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION OR DEVICE_IMMEDIATE_STOP_AUTOMATIC;
	pallet_conveyor_1(DeviceEnableRequest := pallet_conveyor_1_enable_request, DeviceDisableRequest := pallet_conveyor_1_disable_reques);	
	pallet_conveyor_1_FWD := pallet_conveyor_1.EnableDevice;
				
	// pallet_lifter
	pallet_lifter.NewSetPoint := pallet_lifter_goal;
	pallet_lifter.DeviceTimer := pallet_lifter_timer; // if elapsed gives fault (See GenericAxis library)
	pallet_lifter.ActualPosition := pallet_lifter_AXIS;
	pallet_lifter.TGT_SENSOR := TRUE;
	pallet_lifter();
	pallet_lifter_TGT_POS := pallet_lifter.TargetPosition;
	PalletLifterPositionReached := pallet_lifter.InPosition;
	
	// pallet_conveyor_2
	pallet_conveyor_2.NewSetPoint := pallet_conveyor_2_velocity;
	pallet_conveyor_2.DeviceTimer := pallet_conveyor_2_timer; // if elapsed gives fault (See GenericAxis library)
	pallet_conveyor_2.ActualVelocity := pallet_conveyor_2_ACT_VEL;
	pallet_conveyor_2.TGT_SENSOR := TRUE;
	pallet_conveyor_2();
	pallet_conveyor_2_ACT_VEL := pallet_conveyor_2.TargetVelocity;
	PalletConveyor2VelReached := pallet_conveyor_2.InVelocity;
	
	// Signals
	
	(* Pallet Fork *)
	PalletForkActuatorFaultE := pallet_fork.DeviceActuatorFault;
	PalletForkDisableSensorFaultE := pallet_fork.DeviceDisabledSensorFault;
	PalletForkEnableSensorFaultE := pallet_fork.DeviceEnabledSensorFault;
	
	(* Pallet Lifter *)
	PalletLifterFaultSignalE := pallet_lifter.DeviceFault;
	
	(* Pallet Conveyor 1 *)
	PalletConv1ActuatorFaultE := pallet_conveyor_1.DeviceActuatorFault;
	PalletConv1DisableSensorFaultE := pallet_conveyor_1.DeviceDisabledSensorFault;
	PalletConv1SensorFaultE := pallet_conveyor_1.DeviceEnabledSensorFault;

	(* Pallet Conveyor 2 *)
	PalletConv2FaultSignalE := pallet_conveyor_2.DeviceFault;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM
