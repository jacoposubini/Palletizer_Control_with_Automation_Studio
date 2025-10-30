FUNCTION_BLOCK GenericAxis_FB
	CASE (AxisState) OF
		NotPowered: 
			IF AxisEnable THEN
				MC_Power_GA.Enable := TRUE;
				AxisState := WaitPower;
			END_IF;
		WaitPower:
			IF MC_Power_GA.Status THEN
				MC_Home_GA.Execute := TRUE;
				AxisState := Powered;
			END_IF;
		Powered:
			IF MC_Home_GA.Done THEN
				MC_Home_GA.Execute := FALSE;
				AxisEnable := FALSE;
				CommandExecuted := TRUE;
				AxisState := CheckCommand; //ready state in the prof's slides
			END_IF
		// In this state you can implement several commands
		CheckCommand:	
			IF AxisCommand = MOVE_VELOCITY THEN
				CommandExecuted := FALSE;
				MC_MoveVelocity_GA.Execute := TRUE;
				AxisState := MoveVelocity;
			END_IF
			
			IF AxisCommand = MOVE_ADDITIVE THEN
				CommandExecuted := FALSE;
				MC_MoveAdditive_GA.Execute := TRUE;
				AxisState := MoveAdditive;
			END_IF
			
			IF AxisCommand = AXIS_HALT THEN
				CommandExecuted := FALSE;
				MC_Halt_GA.Execute := TRUE;
				AxisState := AxisHalt;
			END_IF

			IF AxisCommand = AXIS_STOP THEN
				CommandExecuted := FALSE;
				MC_Stop_GA.Execute := TRUE;
				AxisState := AxisStop;
			END_IF
			
			(*IF AxisCommand = NONE THEN
				CommandExecuted := FALSE;
			END_IF*)
			
			
		// command states 
		MoveVelocity:
			IF MC_MoveVelocity_GA.InVelocity THEN
				CommandExecuted := TRUE;
				MC_MoveVelocity_GA.Execute := FALSE;
				AxisState := CheckVelocity;
			END_IF
			IF (AxisCommand <> MOVE_VELOCITY) THEN
				CommandExecuted := FALSE;
				AxisState := CheckCommand;
			END_IF
		CheckVelocity:
			IF (Velocity <> OldVelocity) THEN
				OldVelocity := Velocity;
				MC_MoveVelocity_GA.Execute := TRUE;
				AxisState := MoveVelocity;
			END_IF
			IF (AxisCommand <> MOVE_VELOCITY) THEN
				CommandExecuted := FALSE;			
				AxisState := CheckCommand;
				
			END_IF
			
		MoveAdditive:
			IF MC_MoveAdditive_GA.Done THEN
				MC_MoveAdditive_GA.Execute := FALSE;
				AxisCommand := NONE;
				AxisState := CheckCommand;
				CommandExecuted := TRUE;
			ELSIF (AxisCommand <> MOVE_ADDITIVE) THEN
				MC_MoveAdditive_GA.Execute := FALSE;
				CommandExecuted := FALSE;
				AxisState := CheckCommand;
				
			END_IF
			
			// In my implementation I used Halt to stop in Emergency conditions. IT IS NOT CORRECT
			// TO DO: Implement Halt in normal conditions and use STOP for critical conditions
		AxisHalt:
			IF MC_Halt_GA.Done THEN
				CommandExecuted := TRUE;
				MC_Halt_GA.Execute := FALSE;
				AxisState := NotPowered; // It goes to the NotPowered state to perform a full reset of the system
				MC_Power_GA.Enable := FALSE; // The power is disabled for the same reason
				AxisCommand := NONE;
			END_IF
		
		// TO DO: IT IS NOT IMPLEMENTED  (To stop the execution in critical conditions)
		AxisStop:
			IF MC_Stop_GA.Done THEN
				CommandExecuted := TRUE;
				MC_Stop_GA.Execute := FALSE;
				AxisState := NotPowered; // It goes to the NotPowered state to perform a full reset of the system
				MC_Power_GA.Enable := FALSE; // The power is disabled for the same reason
				AxisCommand := NONE;
			END_IF
	END_CASE;
	
	MC_Power_GA.Axis := Slave;
	MC_Power_GA();
	MC_Home_GA.Axis := Slave;
	MC_Home_GA.Position := 0;
	MC_Home_GA();
	MC_MoveVelocity_GA.Axis := Slave;
	MC_MoveVelocity_GA.Velocity := Velocity;
	MC_MoveVelocity_GA.Acceleration := Acceleration;
	MC_MoveVelocity_GA.Deceleration := Deceleration;
	MC_MoveVelocity_GA();
	
	MC_MoveAdditive_GA.Axis := Slave;
	MC_MoveAdditive_GA.Distance := Position;
	MC_MoveAdditive_GA.Velocity := Velocity;
	MC_MoveAdditive_GA.Acceleration := Acceleration;
	MC_MoveAdditive_GA.Deceleration := Deceleration;
	MC_MoveAdditive_GA();
	
	// Stop in normal conditions
	MC_Halt_GA.Axis := Slave;
	MC_Halt_GA.Deceleration := Deceleration;
	MC_Halt_GA();
	
	// Stop in critical conditions
	MC_Stop_GA.Axis := Slave;
	MC_Stop_GA.Deceleration := Deceleration;
	MC_Stop_GA();	
	
	// FEEDBACKS
	MC_ReadActualPosition_GA.Axis := Slave;
	MC_ReadActualPosition_GA.Enable := TRUE;
	MC_ReadActualPosition_GA();
	ActualPosition := MC_ReadActualPosition_GA.Position;
	MC_ReadActualVelocity_GA.Axis := Slave;
	MC_ReadActualVelocity_GA.Enable := TRUE;
	MC_ReadActualVelocity_GA();
	ActualVelocity := MC_ReadActualVelocity_GA.Velocity;
	MC_ReadAxisError_GA.Enable := TRUE;
	MC_ReadAxisError_GA.Axis := Slave;
	MC_ReadAxisError_GA();
	Error := MC_ReadAxisError_GA.Error;
	ErrorID := MC_ReadAxisError_GA.ErrorID;
	AxisErrorID := MC_ReadAxisError_GA.AxisErrorID;
	AxisErrorCount := MC_ReadAxisError_GA.AxisErrorCount;
	MC_ReadStatus_GA.Enable := TRUE;
	MC_ReadStatus_GA.Axis := Slave;
	MC_ReadStatus_GA();
	
	IF MC_ReadStatus_GA.ContinuousMotion THEN
		Status := CONTINUOUS_MOTION;
	END_IF
	IF MC_ReadStatus_GA.DiscreteMotion THEN
		Status := DISCRETE_MOTION;
	END_IF
	IF MC_ReadStatus_GA.StandStill THEN
		Status := STANDSTILL;
	END_IF
END_FUNCTION_BLOCK
