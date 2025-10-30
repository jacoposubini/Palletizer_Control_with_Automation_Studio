
PROGRAM _INIT

		MachineState := Idle;
END_PROGRAM

PROGRAM _CYCLIC

	CASE MachineState OF

		Idle:
			FeederEnable := FALSE;
			FeederHomed := FALSE;
			FeederStart := FALSE;

			IF StartMachine THEN
				FeederEnable := TRUE; (* sblocca alimentazione feeder *)
				MachineState := Init;
			END_IF

		Init:
			OperationType := INIT;
			StartMachine := FALSE;
			//FeederHomed := TRUE; (* manda homing feeder *)
			IF FeederHomed THEN // Need to add also the carriage
				FeederInitDone := TRUE;
			END_IF
			
			// Perform the same procedure for all the other 3 machines
			IF FeederInitDone THEN
				FeederReady := TRUE;  // States that all 3 machines are ready (now we consider only the feeder)
			END_IF
			
			IF FeederReady THEN
				MachineState := Ready;
			END_IF
		Ready:
			(* Attesa che anche crane e pallet handler siano ready, ora non li abbiamo *)
			OperationType := READY;
			IF StartMachine THEN
				FeederStart := TRUE;
				MachineState := Run;
			END_IF
		Run:
			OperationType := RUN;	
			FeederHomed := FALSE;
			FeederEnable := TRUE;
			FeederStart := TRUE;

	END_CASE
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

