
(* TODO: Add your comment here *)
FUNCTION_BLOCK CamFB
	
	CASE (AxisState) OF
		NotPowered: 
			IF AxisEnable THEN
				MpAxisBasic.Enable := TRUE;
				AxisState := WaitEnable;
			END_IF;
			
		WaitEnable:
			IF MpAxisBasic.Active THEN
				MpAxisBasic.Power := TRUE;
				AxisState := WaitPower; //ready state in the prof's slides
			END_IF;
			
		WaitPower:
			IF  MpAxisBasic.PowerOn THEN
				MpAxisBasic.Home := TRUE;
				AxisState := Powered;
			END_IF;
			
		Powered:
			IF MpAxisBasic.IsHomed THEN // condition for the homing	
				MpAxisBasic.Home := FALSE;
				AxisEnable := FALSE;
				CommandExecuted := TRUE;
				MpAxisCoupling.Enable := TRUE;
				AxisState := CheckCommand; //ready state in the prof's slides
			END_IF;
		
		CheckCommand:
			IF AxisCommand = MOVE_VELOCITY THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveAdditive := FALSE;
				MpAxisBasic.Update := TRUE;
				// MpAxisBasic.MoveVelocity := TRUE;  // <------ Come se ricevesse velocità nulla
				AxisState := CheckVelocityUpdate;
			END_IF;
	
			IF AxisCommand = MOVE_ADDITIVE THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveVelocity := FALSE;
				MpAxisBasic.MoveAdditive := TRUE;
				MpAxisBasic.Update := TRUE;
				AxisState := CheckAdditiveUpdate; //CheckAdditiveUpdate;
			END_IF;

			IF AxisCommand = AXIS_STOP THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveVelocity := FALSE;
				MpAxisBasic.MoveAdditive := FALSE;
				MpAxisBasic.Stop := TRUE;
				AxisState := AxisStop;
			END_IF;
			
			IF AxisCommand = AXIS_EMERGENCY THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveVelocity := FALSE;
				MpAxisBasic.MoveAdditive := FALSE;
				MpAxisBasic.Stop := TRUE;
				AxisState := AxisEmergency;
			END_IF;
					
			IF AxisCommand = MOVE_CAM AND CamActivated THEN
				CommandExecuted := FALSE;
				MpAxisCoupling.Cam := TRUE;
				AxisState := MoveCam;
			END_IF;
	
	(*IF AxisCommand = NONE THEN
		CommandExecuted := FALSE;
	END_IF*)
	
	
// command states 
		MoveVelocity:
			IF MpAxisBasic.InVelocity THEN  // <------- Siccome la velocità è nulls lo esegue subito
				CommandExecuted := TRUE;
				AxisState := CheckVelocity;
			END_IF;
			
			IF (AxisCommand <> MOVE_VELOCITY) THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveVelocity := FALSE;
				AxisState := CheckCommand;
			END_IF;
			
		CheckVelocity:
			IF (Param.Velocity <> OldVelocity) THEN
				OldVelocity := Param.Velocity;
				MpAxisBasic.Update := TRUE;
				AxisState := CheckVelocityUpdate;
			END_IF;
			IF (AxisCommand <> MOVE_VELOCITY) THEN
				CommandExecuted := FALSE;
				MpAxisBasic.MoveVelocity := FALSE;
				AxisState := CheckCommand;
			END_IF;
			
		CheckVelocityUpdate:
			IF MpAxisBasic.UpdateDone THEN
				MpAxisBasic.Update := FALSE;
				MpAxisBasic.MoveVelocity := TRUE;
				CommandExecuted := FALSE;
				AxisState := MoveVelocity;
			END_IF;
	
		MoveAdditive:
			IF MpAxisBasic.InPosition THEN
				MpAxisBasic.MoveAdditive := FALSE;
				AxisCommand := NONE;
				AxisState := CheckCommand;
				CommandExecuted := TRUE;
			ELSIF (AxisCommand <> MOVE_ADDITIVE) THEN
				MpAxisBasic.MoveAdditive := FALSE;
				CommandExecuted := FALSE;
				AxisState := CheckCommand;
			END_IF;
			
		CheckAdditiveUpdate:
			IF MpAxisBasic.UpdateDone THEN
				MpAxisBasic.Update := FALSE;
				MpAxisBasic.MoveAdditive := TRUE;
				CommandExecuted := FALSE;
					AxisState := MoveAdditive;
			END_IF;

		AxisStop:
			IF MpAxisBasic.Stopped THEN
				CommandExecuted := TRUE;
				MpAxisBasic.Stop := FALSE;
				MpAxisBasic.Power := FALSE; // The power is disabled for the same reason
				// MpAxisBasic.Enable := FALSE;
				// MpAxisCoupling.Enable := FALSE;
				MpAxisCoupling.Cam := FALSE;
				AxisCommand := NONE;
				AxisState := NotPowered; // It goes to the NotPowered state to perform a full reset of the system
			END_IF;
		
		AxisEmergency:
			IF MpAxisBasic.Stopped THEN
				CommandExecuted := TRUE;
				MpAxisBasic.Stop := FALSE;
				MpAxisBasic.Power := FALSE; // The power is disabled for the same reason
				// MpAxisBasic.Enable := FALSE;
				// MpAxisCoupling.Enable := FALSE;
				MpAxisCoupling.Cam := FALSE;
				AxisCommand := NONE;
				AxisState := NotPowered; // It goes to the NotPowered state to perform a full reset of the system
			END_IF;
			
			// memo, we don't check the mpaxiscoupling.active -> WARNING
			
		MoveCam:
			IF MpAxisCoupling.InSync THEN	
				CommandExecuted := TRUE;
				AxisState := CheckCam;
			END_IF
			IF (AxisCommand <> MOVE_CAM) THEN
				CommandExecuted := FALSE;
				MpAxisCoupling.Cam := FALSE;
				MpAxisCoupling.Enable := FALSE;
				AxisState := CheckCommand;
			END_IF;
		CheckCam:
			IF CamID <> OldCamID THEN
				OldCamID := CamID;
				CommandExecuted := FALSE;
				MpAxisCoupling.Update := TRUE;
				AxisState := CheckCamUpdate;
			END_IF
			IF (AxisCommand <> MOVE_CAM) THEN
				CommandExecuted := FALSE;
				MpAxisCoupling.Cam := FALSE;
				MpAxisCoupling.Enable := FALSE;
				AxisState := CheckCommand;
			END_IF;
			
		CheckCamUpdate:
			IF MpAxisCoupling.UpdateDone THEN
				MpAxisCoupling.Update := FALSE;
				AxisState := MoveCam;		
			END_IF;
			
	END_CASE
		
	
	MpAxisBasic.Axis := Axis;
	MpAxisBasic.MpLink := MpLink;
	
	MpAxisBasic.Parameters	:= ADR(Param);
	ActualPosition := MpAxisBasic.Position;
	
	MpAxisBasic();
	
			
	IF CamActivated THEN
		MpAxisCoupling.MpLinkMaster	:= MpLinkMaster;
		MpAxisCoupling.MpLink := MpLink;
		CouplingParam.Cam.CamTableID := CamID;
		CouplingParam.Cam.CamTable := CamTable;
		MpAxisCoupling.Parameters := ADR(CouplingParam);
		MpAxisCoupling();
	END_IF

	
	
END_FUNCTION_BLOCK
