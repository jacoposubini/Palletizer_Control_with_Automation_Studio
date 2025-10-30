
PROGRAM _INIT
	// executed only once at the start
	
	Cutter.CamActivated := TRUE;
	
	Cutter.CamTable[0]	:= 'standstill';		// since we have only 1 cam we fill the first array,
	Cutter.CamTable[1]	:= 'Cam';
	Cutter.CamID := 0;					// the default value is 0
	CouplingParameters.RatioDenominator := 1;
	
	// CouplingParameters.Cam.CamTable[1]	:= 'Cam1';		// it's the name of the cam folder and the number of the cam
	
	
	// in the mpaxiscoupling_cutter --> info section --> we can see if master and slave can be synchronized
	// either master and slave start to false, in order to have the MasterReady = TRUE the conveyor must be homed
	// so the IsHomed flag goes to TRUE then the MasterReady = TRUE
	// the MasterReady = TRUE when Conveyor is Homed, but since I want to move it I need to set Power = TRUE (NOTE: In order to have MasterReady = TRUE, Power = TRUE is not necessary)
	// The SlaveReady = TRUE when the Cutter is Homed and Powered (Power = TRUE).
	// setting the CAM = TRUE in the cutter PLCOpen = Sync
	// in coupling parameters it's possible to choose the numerator for the slave and the denominator for the slave, at the moment with a RatioNumerator = 360 
	// the slave does a complete rotation represents the cut task
	// RatioNumerator and RatioDenominator are the stretching factor of the normalized cam    (180 means 180° of range)
	
	(* Insert code here *)
	MachineState := Init;
	ConveyorState := Init;
	CutterState := Init;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// STOP indicates an emergency stop, it is not a stop in normal conditions
	CASE EmergencyStateMachine OF
		0 : 
			IF EMERGENCY_STOP THEN
				MachineState := StopState;
				ConveyorState := StopState;
				CutterState := StopState;
				Conveyor.AxisCommand := AXIS_EMERGENCY;
				Cutter.AxisCommand := AXIS_EMERGENCY;
				EmergencyStateMachine := 1;
			END_IF
		1 : 
			IF NOT EMERGENCY_STOP AND CutterStopped AND ConveyorStopped THEN
				EmergencyStateMachine := 0;
			END_IF
	END_CASE
	
	(*IF EMERGENCY_STOP AND THEN
		MachineState := StopState;
		ConveyorState := StopState;
		CutterState := StopState;
		Conveyor.AxisCommand := AXIS_HALT;
		Cutter.AxisCommand := AXIS_HALT;
	END_IF*)
	
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
			IF NOT ConveyorEnable AND TRIGGER_INPUT THEN
				CutterEnable := TRUE;
				MachineState := CutterForward;
			END_IF
			// STOP
			IF FutureStop AND CutterPosition = 0.0 THEN
				MachineState := HaltState;
			END_IF
		CutterForward: // Cut
			IF NOT CutterEnable THEN
				CutterDisable := TRUE;
				MachineState := CutterBackward;
			END_IF
		CutterBackward: // Go back
			IF NOT CutterDisable THEN
				// ConveyorEnable := TRUE;
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
			IF ConveyorEnable AND (NOT FutureStop OR CutterPosition <> 0.0) THEN
				Conveyor.AxisCommand := MOVE_VELOCITY;
				ConveyorState := ConveyorStarting;
			ELSIF FutureStop AND CutterPosition = 0.0 THEN
				Conveyor.AxisCommand := AXIS_STOP;
				ConveyorState := HaltState;
			END_IF
		ConveyorStarting:
			IF Conveyor.CommandExecuted THEN
				ConveyorEnable := FALSE;
				ConveyorState := ConveyorMoving;
			END_IF
		ConveyorMoving:
			IF FutureStop AND NOT CutterWorking THEN
				Conveyor.AxisCommand := AXIS_STOP;
				ConveyorState := HaltState;
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
				ConveyorAxisEnable := FALSE;
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
				Cutter.AxisCommand := MOVE_CAM;
				CutterState := CamEnabled;
			END_IF
		CamEnabled:
			IF Conveyor.CommandExecuted THEN
				InitializeCutter := FALSE;
				CutterState := AxisEnabled;
			END_IF
		AxisEnabled:
			IF CutterEnable AND NOT FutureStop THEN
				CutterWorking := TRUE;
				Cutter.CamID := 1;
				CutterState := CheckCamUpdate1;
			ELSIF FutureStop THEN
				Cutter.AxisCommand := AXIS_STOP;
				CutterState := HaltState;
			END_IF
			
		CheckCamUpdate1:
			IF Cutter.CommandExecuted THEN
				// cambio camma
				CutterEnable := FALSE;
				CutterState := CutterMoveForward;
			END_IF
		CutterMoveForward:
			IF CutterPosition <> 0.0 THEN
				// cambio camma
				Cutter.CamID := 0;
				CutterState := CheckCamUpdate2;
			END_IF
		CheckCamUpdate2:
			IF Cutter.CommandExecuted THEN
				// cambio camma
				CutterState := CutterCompleted;
			END_IF
		CutterCompleted:
			IF CutterPosition = 0.0 THEN
				CutterDisable := FALSE;
				CutterState := AxisEnabled;
				CutterWorking := FALSE;
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
				CutterAxisEnable := FALSE;
				CutterState := Init;
			END_IF
	END_CASE
	
	// Implementing the Homing as in video (as in the first video)
	// Implementing the button (start button, the stop button and the emergency stop)
	
		
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
	
			
	//Conveyor(AxisEnable := ConveyorAxisEnable);
	//ConveyorPosition := Conveyor.ActualPosition;

	//Cutter(AxisEnable := CutterAxisEnable);
	//CutterPosition := Cutter.ActualPosition;
	
	Conveyor.Axis	:= ADR(gAxis01);
	Conveyor.MpLink	:= ADR(gAxisConveyor);
	RealConveyorSpeed := CONVEYOR_SPEED/10;
	
	Conveyor.Param.Velocity := INT_TO_REAL(RealConveyorSpeed);
	Conveyor.Param.Acceleration := 100;
	Conveyor.Param.Deceleration := 100;
	
	Cutter.Axis	:= ADR(gAxis02);
	Cutter.MpLink	:= ADR(gAxisCutter);
	Cutter.MpLinkMaster	:= ADR(gAxisConveyor);
		
	Cutter.Param.Velocity := CUTTER_SPEED;
	
	Cutter.Param.Acceleration := 100;
	Cutter.Param.Deceleration := 100;
	
	CouplingParameters.Cam.LeadIn.CamEnable:= TRUE;
	//CouplingParameters.Cam.MasterStartPosition := 180;

	Cutter.CouplingParam := CouplingParameters;
		
	Conveyor(AxisEnable := ConveyorAxisEnable);
	ConveyorPosition := Conveyor.ActualPosition;

	Cutter(AxisEnable := CutterAxisEnable);
	CutterPosition := Cutter.ActualPosition;
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

