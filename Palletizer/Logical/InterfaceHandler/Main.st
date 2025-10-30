
PROGRAM _INIT
	(* Insert code here *)
	Counter := 10;
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
	IF Counter = 0 THEN
		Counter := 10;
	ELSE
		Counter := Counter -1;
	END_IF
	
	CASE OperationType OF
		INIT:
			OperationTypeString := 'INIT';
			IF Counter = 0 THEN
				BlueLight := NOT BlueLight;
			END_IF
			GreenLight := FALSE;
			
		ENABLED:
			OperationTypeString := 'ENABLED';
			BlueLight := TRUE;
			IF Counter = 0 THEN
				GreenLight := NOT GreenLight;
			END_IF
			
		RUN:
			OperationTypeString := 'RUN';
			GreenLight := TRUE;
			BlueLight := FALSE;			
			
		STOP:
			OperationTypeString := 'STOP';
			GreenLight := FALSE;
			BlueLight := FALSE;
			
	END_CASE
	
	
	IF OnPhaseStop THEN
		OrangeLight := TRUE;
	ELSE
		OrangeLight := FALSE;
	END_IF
	
	IF ImmediateStop THEN
		YellowLight := TRUE;
	ELSE
		YellowLight := FALSE;
	END_IF
	
	IF EmergencyStop THEN
		RedLight := TRUE;
	ELSE
		RedLight := FALSE;
	END_IF
	
	IF ResetEnable AND Counter = 0 THEN
		WhiteLight := NOT WhiteLight;
	ELSIF NOT ResetEnable THEN
		WhiteLight := FALSE;
	END_IF
	
	
	IF HomeButton THEN
		InfoCarousel := 'content_0';
	END_IF
	
	IF ErrorButton THEN
		InfoCarousel := 'content_1';
	END_IF
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

