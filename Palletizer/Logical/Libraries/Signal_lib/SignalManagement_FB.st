
(* TODO: Add your comment here *)
FUNCTION_BLOCK SignalManagement_FB
	
	CASE OperationType OF
		START_CONFIGURATION:  (* Reset signals counts *)
			NumberOfAlarms := 0;
			NumberOfAnomalies := 0;
			NumberOfWarnings := 0;
			NumberOfInformation := 0;
			ResetEnable := FALSE;
		CONFIGURATION:
			(* counting signals *)
			CASE SignalType AND SIGNAL_TYPE_MASK OF
				ALARM:
					NumberOfAlarms := NumberOfAlarms + 1;
				ANOMALY:
					NumberOfAnomalies := NumberOfAnomalies + 1;
				WARNING:
					NumberOfWarnings := NumberOfWarnings + 1;
				INFORMATION:
					NumberOfInformation := NumberOfInformation + 1;
			END_CASE
		START_GENERATION:              
			(* Prepare for generation *)
			ResetEnable := FALSE;
			SignalOutputs := NONE;
			ResetActivation := Reset AND NOT ResetOld;
			ResetOld := Reset;
			AuxResetActivation := KeyReset AND NOT KeyResetOld;
			KeyResetOld:= KeyReset;
			LogFile := '';
			MainMessage := '';
			
		GENERATION:
			CASE SignalType AND SIGNAL_TYPE_MASK OF
				ALARM:
					Index := NumberOfActiveAlarms;
					BaseIndex := 0;
					Condition := TRUE;
				ANOMALY:
					Index := NumberOfActiveAnomalies;
					BaseIndex := NumberOfAlarms;
					Condition := TRUE;
				WARNING:
					Index := NumberOfActiveWarning;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies;
					Condition := FALSE;
				INFORMATION:
					Index := NumberOfActiveInformation;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings;
					Condition := FALSE;
			END_CASE 
			IF ActivationSignal AND NOT Signals[SignalCode] THEN
				Signals[SignalCode] := TRUE;
				Index := Index + 1;
				ActiveSignalCodes[BaseIndex + Index] := SignalCode;
				
				IF (SignalType AND SIGNAL_LOG_MASK) = DISPLAY_LOG THEN
					LogBuffer[SignalCode] := InputString;
				END_IF
				
			END_IF
			IF Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) THEN
				ResetEnable := TRUE;
			END_IF
			
			IF (ResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) THEN
				Signals[SignalCode] := FALSE;
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index :=  Index - 1;
				ResetActivation := FALSE; (* COMMENT THIS LINE TO GO BACK TO CUMULATIVE RESET *)
				
				IF (SignalType AND SIGNAL_LOG_MASK) = DISPLAY_LOG THEN
					LogBuffer[SignalCode] := ' ';
				END_IF
				
			END_IF
			CASE SignalType AND SIGNAL_TYPE_MASK OF
				ALARM:
					NumberOfActiveAlarms := Index;
				ANOMALY:
					NumberOfActiveAnomalies := Index;
				WARNING:
					NumberOfActiveWarning := Index;
				INFORMATION:
					NumberOfActiveInformation := Index;
			END_CASE 			
			IF Signals[SignalCode] THEN
				SignalOutputs := SignalOutputs OR SignalOutput;
			END_IF
		
		MESSAGES_GENERATION:
			
			LogFile := ' ';
			// ALARMS messages creation
			BaseIndex := 0;
			FOR i := 1 TO NumberOfActiveAlarms DO
				IF LogBuffer[ActiveSignalCodes[BaseIndex + i]] <> '' THEN
					LogFile := CONCAT(CONCAT(LogFile, CONCAT('ALARM : ',LogBuffer[ActiveSignalCodes[BaseIndex + i]])), ' \n ');
				END_IF
			END_FOR;
			
			// ANOMALIES messages creation
			BaseIndex := NumberOfAlarms;
			FOR i := 1 TO NumberOfActiveAnomalies DO
				IF LogBuffer[ActiveSignalCodes[BaseIndex + i]] <> '' THEN
					LogFile := CONCAT(CONCAT(LogFile,CONCAT('ANOMALY : ',LogBuffer[ActiveSignalCodes[BaseIndex + i]])), ' \n ');
				END_IF
				
			END_FOR;
			
			// WARNING messages creation
			BaseIndex := NumberOfAlarms + NumberOfAnomalies;
			FOR i := 1 TO NumberOfActiveWarning DO
				IF LogBuffer[ActiveSignalCodes[BaseIndex + i]] <> '' THEN		
					LogFile := CONCAT(CONCAT(LogFile , CONCAT('WARNING : ',LogBuffer[ActiveSignalCodes[BaseIndex + i]])), ' \n ');
				END_IF
			END_FOR;
			
			// WARNING messages creation
			BaseIndex := NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings;
			FOR i := 1 TO NumberOfActiveInformation DO
				IF LogBuffer[ActiveSignalCodes[BaseIndex + i]] <> '' THEN		
					LogFile := CONCAT(CONCAT(LogFile , CONCAT('INFORMATION : ',LogBuffer[ActiveSignalCodes[BaseIndex + i]])), ' \n ');		
				END_IF
			END_FOR;
			
			MainMessage := '';
			IF NumberOfActiveAlarms <> 0 THEN
				MainMessage := LogBuffer[ActiveSignalCodes[1]];
			ELSIF NumberOfActiveAnomalies <> 0 THEN
				MainMessage := LogBuffer[ActiveSignalCodes[NumberOfAlarms + 1]];
			ELSIF NumberOfActiveWarning <> 0 THEN
				MainMessage := LogBuffer[ActiveSignalCodes[NumberOfAlarms + NumberOfAnomalies + 1]];
			ELSIF NumberOfActiveInformation <> 0 THEN
				MainMessage := LogBuffer[ActiveSignalCodes[NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings + 1]];
			END_IF

		
	END_CASE
	
END_FUNCTION_BLOCK
