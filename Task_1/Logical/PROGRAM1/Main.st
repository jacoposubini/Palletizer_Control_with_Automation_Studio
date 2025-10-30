
PROGRAM _INIT
	(* Insert code here *)
	MachineState := Init;
	ConveyorState := Init;
	CutterState := Init;
	OldCutterPose := 0;
END_PROGRAM

PROGRAM _CYCLIC
	
	// STOP indicates an emergency stop, it is not a stop in normal conditions
	CASE EmergencyStateMachine OF
		0 : 
			IF EMERGENCY_STOP THEN
				MachineState := StopState;
				ConveyorState := StopState;
				CutterState := StopState;
				Conveyor.AxisCommand := AXIS_HALT;
				Cutter.AxisCommand := AXIS_HALT;
				EmergencyStateMachine := 1;
			END_IF
		1 : 
			IF NOT EMERGENCY_STOP AND CutterStopped AND ConveyorStopped THEN
				EmergencyStateMachine := 0;
			END_IF
	END_CASE

	IF STOP THEN
		FutureStop := TRUE;
	END_IF
	

	// GLOBAL STATE MACHINE
	CASE MachineState OF	
		Init: // Initial configuration state
			IF START_BUTTON THEN		
				InitializeConveyor := TRUE;
				InitializeCutter := TRUE;
				MachineState := Initialize;
			END_IF
		Initialize: // initialization - Power and Homing (This operations are implemented inside the function block)
			IF NOT InitializeConveyor AND NOT InitializeCutter THEN
				ConveyorEnable := TRUE;
				MachineState := WaitProduct;
			END_IF
		WaitProduct: // It waits for a trigger
			IF NOT ConveyorEnable AND TRIGGER_INPUT AND NOT REG_TRIGGER THEN
				ConveyorDisable := TRUE;
				MachineState := ConveyorHolding;
			END_IF
			// STOP
			IF FutureStop THEN
				MachineState := HaltState;
			END_IF
				
		ConveyorHolding: // Stop the Conveyor
			IF NOT ConveyorDisable THEN
				CutterEnable := TRUE;
				MachineState := CutterForward;
			END_IF
		CutterForward: // Cut
			IF NOT CutterEnable THEN
				CutterDisable := TRUE;
				MachineState := CutterBackward;
			END_IF
		CutterBackward: // Go back
			IF NOT CutterDisable THEN
				ConveyorEnable := TRUE;
				MachineState := WaitProduct;
			END_IF
		
		// Emergency stop
		StopState:
			IF NOT EMERGENCY_STOP AND ConveyorStopped AND CutterStopped THEN
				MachineState := CheckReset;
			END_IF
		CheckReset:
			IF ERROR_RESET THEN
				MachineState := Init;
				ConveyorStopped := FALSE;
				CutterStopped := FALSE;
				FutureStop := FALSE;
			END_IF
		// CAN BE ERASED
		HaltState:
			IF ConveyorStopped AND CutterStopped THEN
				MachineState := Init;
				ConveyorStopped := FALSE;
				CutterStopped := FALSE;
				FutureStop := FALSE;
			END_IF
				
	END_CASE
	
	// CONVEYOR STATE MACHINE
	CASE ConveyorState OF	
		Init:
			IF InitializeConveyor THEN		
				ConveyorAxisEnable := TRUE;
				ConveyorState := InitializeAxis;
			END_IF
		InitializeAxis:
			IF NOT ConveyorAxisEnable THEN
				InitializeConveyor := FALSE;
				ConveyorState := AxisEnabled;
			END_IF
		AxisEnabled:
			IF ConveyorEnable AND NOT FutureStop THEN
				Conveyor.AxisCommand := MOVE_VELOCITY;
				ConveyorState := ConveyorStarting;
			ELSIF FutureStop THEN
				Conveyor.AxisCommand := AXIS_HALT;
				ConveyorState := HaltState;
			END_IF
		ConveyorStarting:
			IF Conveyor.CommandExecuted THEN
				ConveyorEnable := FALSE;
				ConveyorState := ConveyorMoving;
			END_IF
		ConveyorMoving:
			IF ConveyorDisable AND NOT FutureStop THEN
				Conveyor.AxisCommand := MOVE_ADDITIVE;
				ConveyorState := ConveyorStopping;
			ELSIF FutureStop THEN
				Conveyor.AxisCommand := AXIS_HALT;
				ConveyorState := HaltState;
			END_IF
		ConveyorStopping:
			IF Conveyor.CommandExecuted THEN
				ConveyorDisable := FALSE;
				ConveyorState := AxisEnabled;
			END_IF
			
		// EMERGENCY STOP
		StopState:
			IF NOT EMERGENCY_STOP AND Conveyor.CommandExecuted THEN
				ConveyorEnable := FALSE;
				ConveyorDisable := FALSE;
				ConveyorStopped := TRUE;
				ConveyorState := Init;
			END_IF
			
		HaltState:
			IF Conveyor.CommandExecuted THEN
				ConveyorDisable := FALSE;
				ConveyorEnable := FALSE;
				ConveyorStopped := TRUE;
				ConveyorState := Init;
			END_IF
	END_CASE

	// CUTTER STATE MACHINE
	CASE CutterState OF
		Init:
			IF InitializeCutter THEN		
				CutterAxisEnable := TRUE;
				CutterState := InitializeAxis;
			END_IF
		InitializeAxis:
			IF NOT CutterAxisEnable THEN
				InitializeCutter := FALSE;
				CutterState := AxisEnabled;
			END_IF
		AxisEnabled:
			IF REG_TRIGGER THEN // 2
				IF CUTTER_POSITION <> OldCutterPose THEN
					Cutter.Position := INT_TO_REAL((CUTTER_POSITION - OldCutterPose) / 100);
					OldCutterPose := CUTTER_POSITION;
					Cutter.AxisCommand := MOVE_ADDITIVE;
					CutterState := RegulatePosition;
				END_IF
			ELSIF ConveyorDisable AND NOT FutureStop THEN
				CutterState := WaitForConveyor;
			ELSIF FutureStop THEN
				Cutter.AxisCommand := AXIS_HALT;
				CutterState := HaltState;
			END_IF
			
		RegulatePosition: // 2
			IF Cutter.CommandExecuted THEN
				CutterState := AxisEnabled;
			END_IF
					
		WaitForConveyor:
			IF CutterEnable THEN
				Cutter.Position := BELT_DISTANCE; // Added by me
				Cutter.AxisCommand := MOVE_ADDITIVE;
				CutterState := CutterMoveForward;
			END_IF
		CutterMoveForward:
			IF Cutter.CommandExecuted THEN
				CutterEnable := FALSE;
				CutterState := CutterCompleted;
			END_IF
		CutterCompleted:
			IF CutterDisable THEN
				Cutter.Position := -BELT_DISTANCE; // Added by me
				Cutter.AxisCommand := MOVE_ADDITIVE;
				CutterState := CutterMoveBackward;
			END_IF
		CutterMoveBackward:
			IF Cutter.CommandExecuted THEN
				CutterDisable := FALSE;
				CutterState := AxisEnabled;
			END_IF
		
		// EMERGENCY STOP
		StopState:
			IF NOT EMERGENCY_STOP AND Cutter.CommandExecuted THEN
				CutterEnable := FALSE;
				CutterDisable := FALSE;
				CutterStopped := TRUE;
				CutterState := Init;
			END_IF

		HaltState:
			IF Cutter.CommandExecuted THEN
				CutterDisable := FALSE;
				CutterEnable := FALSE;
				CutterStopped := TRUE;
				CutterState := Init;
			END_IF
	END_CASE
	
	// Counter for blink
	Count := Count + 1;
	IF Count = 10 THEN
		ToggleLights := TRUE;
		Count := 0;
	ELSE 
		ToggleLights := FALSE;
	END_IF
	
	
	// LIGHTS
	IF MachineState = Init THEN
		IF ToggleLights THEN 
			GreenLight := NOT GreenLight;
		END_IF
		RedLight := FALSE;
		EmergencyLight := FALSE;
		
	ELSIF MachineState <> HaltState AND MachineState <> StopState AND MachineState <> CheckReset THEN
		GreenLight := TRUE;
		RedLight := TRUE;
		EmergencyLight := FALSE;
	ELSIF MachineState = StopState OR MachineState = CheckReset THEN
		GreenLight := FALSE;
		RedLight := FALSE;
		IF ToggleLights THEN 
			EmergencyLight := NOT EmergencyLight;
		END_IF
	END_IF
	
	Conveyor.Slave := ADR(gAxis01);
	Conveyor.Position := 2*BELT_DISTANCE;
	RealConveyorSpeed := CONVEYOR_SPEED/10;
	
	Conveyor.Velocity :=  INT_TO_REAL(RealConveyorSpeed);
	Conveyor.Acceleration := 200;
	Conveyor.Deceleration := 200;
	
	Conveyor(AxisEnable := ConveyorAxisEnable);
	ConveyorPosition := Conveyor.ActualPosition;
	
	
	Cutter.Slave := ADR(gAxis02);
	Cutter.Velocity := CUTTER_SPEED;
	Cutter.Acceleration := 200;
	Cutter.Deceleration := 200;
	
	Cutter(AxisEnable := CutterAxisEnable);
	CutterPosition := Cutter.ActualPosition;
	

END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

