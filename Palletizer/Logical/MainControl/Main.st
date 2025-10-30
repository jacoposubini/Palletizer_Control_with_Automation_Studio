// MAIN CONTROL MACHINE
// http://localhost:81/index.html?visuId=vis_0
// INTERFACE
// 	INPUT:
// 		MainEnable : BOOL : It enables the machine and executes the Homing if it is not already done.
//		MainStart : BOOL : It starts a machine cycle if The machine is Ready
//		MainStop : BOOL
//		MainEmergencyStop : BOOL
// 		
//	OUTPUT:
//		MainIsEnable : BOOL : True if the machine is ready to start a new cycle.
//		MainIsReady : BOOL : True if the machine is ready to start a new cycle.
//		MainIsStop : BOOL
//		MainIsStopEmergency : BOOL

PROGRAM _INIT
	(* Insert code here *)
	State := Idle;
	MainEnable := FALSE;
	MainStart := FALSE;
	CounterFloor := 0;
	CounterPallet := 0;
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)	
	CASE EmergencyStopMachine OF
		0: IF EmergencyStop AND State <> EmergencyState THEN
				State := EmergencyState;
				MainEnable := FALSE;
				MainStart := FALSE;
				EmergencyStopMachine := 1;
			END_IF
		1: IF NOT EmergencyStop THEN
				EmergencyStopMachine := 0;
				MainEnable := FALSE;
				MainStart := FALSE;
			END_IF
	END_CASE
	
	CASE ImmediateStopMachine OF
		0: IF ImmediateStop AND State <> ImmediateStopState THEN
				OldState := State;
				State := ImmediateStopState;
				MainEnable := FALSE;
				MainStart := FALSE;
				ImmediateStopMachine := 1;
			END_IF
		1: IF NOT ImmediateStop THEN
				ImmediateStopMachine := 0;
				MainEnable := FALSE;
				MainStart := FALSE;
				OperationType := ENABLED;
			END_IF
	END_CASE
	
	CASE OnPhaseStopMachine OF
		0: IF OnPhaseStop THEN
				OnPhaseStopPerforming := TRUE;
				OnPhaseStopMachine := 1;
			END_IF
		1: IF NOT OnPhaseStop THEN
				OnPhaseStopMachine := 0;
			END_IF
	END_CASE
	
	CASE State OF
		EmergencyState:
			IF NOT EmergencyStop THEN
				State := Idle;
				MainEnable := FALSE;
				MainStart := FALSE;
				OperationType := INIT;
			END_IF
			
		ImmediateStopState:
			IF MainStart AND NOT ImmediateStop THEN
				MainStart := FALSE;
				FeederStart := TRUE;
				CraneStart := TRUE;
				PalletHandlerStart := TRUE;
				State := CheckActivationsFromStop;
			END_IF
			
		CheckActivationsFromStop:
			IF FeederStart = FALSE AND CraneStart = FALSE AND PalletHandlerStart = FALSE THEN
				State := OldState;
				OperationType := RUN;
			END_IF
			
		Idle:
			CounterPallet := 0;
			OnPhaseStopPerforming := FALSE;
			IF MainEnable THEN
				CounterFloor := 0;
				OperationType := ENABLED;
				FeederEnable := TRUE;
				CraneEnable := TRUE;
				PalletHandlerEnable := TRUE;
				State := Homing;
			END_IF
			
		Homing:
			IF FeederEnable = FALSE AND CraneEnable = FALSE AND PalletHandlerEnable = FALSE THEN // AND PalletEnable ...
				MainEnable := FALSE;
				MainStart := FALSE;
				State := HomingDone;
			END_IF
			
		HomingDone:
			IF OnPhaseStopPerforming THEN
				OnPhaseStopPerforming := FALSE;
			END_IF
			
			IF MainStart THEN
				OperationType := RUN;
				MainStart := FALSE;
				FeederStart := TRUE;
				PalletHandlerStart := TRUE;
				State := FeedBoxes;
			END_IF	
			
		FeedBoxes:
			IF FeederStart = FALSE THEN
				State := WaitForBoxes; // Push of the Boxes
			END_IF
			
		WaitForBoxes:
			IF FeederIsReady = TRUE AND CraneIsReady = TRUE THEN
				FeederStart := TRUE;
				State := FeederPush;
				CounterFloor := CounterFloor + 1;
			END_IF
			
		FeederPush:
			IF FeederStart = FALSE THEN
				State := WaitForPush;
			END_IF
			
		WaitForPush:
			IF FeederIsReady = TRUE AND CraneIsReady = TRUE THEN // AND PalletHandler
				IF NOT (OnPhaseStop AND (CounterFloor MOD 2 <> 1) = TRUE) THEN
					FeederStart := TRUE; // Boxes accumulation
				END_IF
				
				CraneStart := TRUE;
				State := BoxOnPalletPositioning;
			END_IF
			
		BoxOnPalletPositioning:
			IF FeederStart = FALSE AND CraneStart = FALSE THEN
				State := WaitBoxesOnPallet;
			END_IF
			
		WaitBoxesOnPallet:
			IF CraneIsReady = TRUE AND PalletHandlerIsReady = TRUE THEN
				IF (CounterFloor MOD 2 <> 1) = TRUE AND NOT OnPhaseStop THEN
					PalletHandlerStart := TRUE;
					CounterPallet := CounterPallet +1;
					State := ChangePallet;
				ELSIF (CounterFloor MOD 2 <> 1) = TRUE AND OnPhaseStop THEN
					State := HomingDone;
					OnPhaseStopPerforming := FALSE;
					MainStart := FALSE;
					CounterPallet := CounterPallet +1;
					OperationType := ENABLED;
				ELSE
					State := WaitForBoxes;
				END_IF
				
			END_IF
			
		ChangePallet:
			IF PalletHandlerStart = FALSE AND CraneStart = FALSE  THEN
				State := WaitForNewPallet;
			END_IF
			
		WaitForNewPallet:
			IF PalletHandlerIsReady = TRUE THEN
				State := WaitForBoxes;
			END_IF
	END_CASE;
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

