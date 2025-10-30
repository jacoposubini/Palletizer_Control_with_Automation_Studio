
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	Enable := TRUE;
	
	IF STOP THEN
		CutterEnable := FALSE;
		ConveyorEnable := FALSE;
		
		Cutter.AxisCommand := AXIS_STOP;
		Conveyor.AxisCommand := MOVE_ADDITIVE;
		Conveyor.AxisCommand := AXIS_STOP;
		
		Stop_Light := TRUE;
		Green_Light := FALSE;
		White_Light := FALSE;
		Yellow_Light := FALSE;
		
		State := IDLE;
	END_IF
	
	CASE State OF
		IDLE:
			IF START_BUTTON THEN		
				CutterEnable := TRUE;
				ConveyorEnable := TRUE;
				
				Cutter.AxisCommand := AXIS_STOP;
				Conveyor.AxisCommand := AXIS_STOP;
				
				Stop_Light := FALSE;
				Green_Light := TRUE;
				White_Light := FALSE;
				Yellow_Light := FALSE;
				
				State := ENABLE_AXES;
			END_IF
		
		ENABLE_AXES: 
			IF Cutter.Status = STANDSTILL AND Conveyor.Status = STANDSTILL THEN
				Conveyor.AxisCommand := MOVE_VELOCITY;
				
				Stop_Light := FALSE;
				Green_Light := TRUE;
				White_Light := TRUE;
				Yellow_Light := FALSE;
				
				State := BELT_MOVING;
			END_IF
		
		BELT_MOVING: 
			IF TRIGGER_INPUT THEN
				Conveyor.AxisCommand := MOVE_ADDITIVE;
				
				State := BELT_STOPPING;
			END_IF
			
		BELT_STOPPING:
			IF Conveyor.CommandExecuted THEN
				Conveyor.AxisCommand := AXIS_STOP;
				Cutter.AxisCommand := MOVE_ADDITIVE;
				Cutter.Position := CUTTER_END_POSE;
				
				Stop_Light := FALSE;
				Green_Light := TRUE;
				White_Light := FALSE;
				Yellow_Light := TRUE;
				
				State := BELT_HOLDING;
			END_IF
		
		BELT_HOLDING:
			IF Cutter.CommandExecuted THEN
				Cutter.AxisCommand := AXIS_STOP;
				
				State := CUTTER_BACK;
			END_IF
		
		CUTTER_BACK:
			IF NOT Cutter.CommandExecuted THEN
				Cutter.AxisCommand := MOVE_ADDITIVE;
				Cutter.Position := -CUTTER_END_POSE;
				
				State := CUTTER_END;
			END_IF
			
		CUTTER_END:
			IF Cutter.CommandExecuted THEN
				Cutter.AxisCommand := AXIS_STOP;
				
				State := ENABLE_AXES;
			END_IF
	END_CASE
	
	Conveyor.Slave := ADR(gAxis01);
	Conveyor.Position := 2*BELT_DISTANCE;
	Conveyor.Velocity := velocity;
	Conveyor.Acceleration := 100;
	Conveyor.Deceleration := 100;
	
	Conveyor(AxisEnable := ConveyorEnable);
	ConveyorPosition := Conveyor.ActualPosition;
	
	Cutter.Slave := ADR(gAxis02);
	Cutter.Velocity := CUTTER_SPEED;
	Cutter.Acceleration := 100;
	Cutter.Deceleration := 100;
	
	Cutter(AxisEnable := CutterEnable);
	CutterPosition := Cutter.ActualPosition;

END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

