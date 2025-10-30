(* GenericAxis function block *)
FUNCTION_BLOCK GenericAxis

	CASE AxisState OF

		CheckCommand:
			IF Command = CHANGE_POSITION THEN
				IF TargetPosition <> NewSetPoint THEN
					TargetPosition := NewSetPoint;
					InPosition := FALSE;
					Timer := DeviceTimer;
					AxisState := WaitTargetPosition;
				END_IF

			ELSIF Command = CHANGE_VELOCITY THEN
				IF TargetVelocity <> NewSetPoint THEN
					TargetVelocity := NewSetPoint;
					InVelocity := FALSE;
					Timer := DeviceTimer;
					AxisState := WaitTargetVelocity;
				END_IF

			ELSIF Command = IMMEDIATE_STOP_REQUEST OR Command = EMERGENCY_STOP_REQUEST THEN
				TargetPosition := ActualPosition;
				TargetVelocity := 0;
				AxisState := StopEmergencyState;

			ELSIF Command = IDLE THEN
				IF (ActualPosition = TargetPosition AND TGT_SENSOR) THEN
					InPosition := TRUE;
				ELSE 
					InPosition := FALSE;
				END_IF
				IF (ActualVelocity = TargetVelocity) THEN
					InVelocity := TRUE;
				ELSE 
					InVelocity := FALSE;
				END_IF
				Timer := DeviceTimer;
				DeviceFault := FALSE;
			END_IF

		WaitTargetPosition:
			IF  Command = IMMEDIATE_STOP_REQUEST OR Command = EMERGENCY_STOP_REQUEST THEN
				TargetPosition := ActualPosition;
				TargetVelocity := 0;
				AxisState := StopEmergencyState;	
			ELSIF (ActualPosition = TargetPosition AND TGT_SENSOR) THEN
				InPosition := TRUE;
				AxisState := CheckCommand;
			END_IF
			
			Timer := Timer - 1;
			IF Timer = 0 THEN
				DeviceFault := TRUE;
				AxisState := FaultState;
			END_IF

		WaitTargetVelocity:		
			IF  Command = IMMEDIATE_STOP_REQUEST OR Command = EMERGENCY_STOP_REQUEST THEN
				TargetVelocity := 0;
				AxisState := StopEmergencyState;

			ELSIF ActualVelocity = TargetVelocity THEN
				InVelocity := TRUE;
				AxisState := CheckCommand;
			END_IF
			
			Timer := Timer - 1;
			IF Timer = 0 THEN
				DeviceFault := TRUE;
				AxisState := FaultState;
			END_IF
				
		StopEmergencyState:
			IF Command <> IMMEDIATE_STOP_REQUEST AND Command <> EMERGENCY_STOP_REQUEST THEN
				InPosition := FALSE;
				InVelocity := FALSE;
				AxisState := CheckCommand;
			END_IF
			
		FaultState:
			IF Reset THEN
				DeviceFault := FALSE;
				AxisState := CheckCommand;
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

 
