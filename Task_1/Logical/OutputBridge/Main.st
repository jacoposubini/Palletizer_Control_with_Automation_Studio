
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	ComTCP_SimOutputs.Green_light_Key := GreenLight;
	ComTCP_SimOutputs.Stop_light_Key := RedLight;
	ComTCP_SimOutputs.Yellow_light_Key := EmergencyLight;
	ComTCP_SimOutputs.Shaft_0_ACT_POS := LREAL_TO_REAL(ConveyorPosition);
	ComTCP_SimOutputs.Shaft_1_ACT_POS := LREAL_TO_REAL(CutterPosition);
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

