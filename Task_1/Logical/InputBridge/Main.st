
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	START_BUTTON := ComTCP_SimInputs.Start_Button_ButtonPress;
	TRIGGER_INPUT := ComTCP_SimInputs.White_Button_ButtonPress;
	EMERGENCY_STOP := ComTCP_SimInputs.Emergency_Button_ButtonToggle;
	STOP := ComTCP_SimInputs.Stop_Button_ButtonPress;
	ERROR_RESET := ComTCP_SimInputs.Yellow_Button_ButtonPress;
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

