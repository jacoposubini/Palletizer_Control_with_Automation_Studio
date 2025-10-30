
{REDUND_ERROR} FUNCTION_BLOCK SignalManagement_FB (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		OperationType : INT;
		SignalType : INT; (* bit configuration for the signal*)
		Reset : BOOL;
		KeyReset : BOOL;
		SignalOutput : DWORD; (* Output of the Signal if active*)
		ActivationSignal : {REDUND_UNREPLICABLE} BOOL;
		SignalCode : INT; (* Is the signal number in the priority list*)
		InputString : STRING[80];
	END_VAR
	VAR_OUTPUT
		MainMessage : STRING[30];
		LogFile : STRING[3000];
		SignalOutputs : DWORD; (*Output Signal codification*)
	END_VAR
	VAR
		LogBuffer : ARRAY[1..100] OF STRING[30];
		NumberOfAlarms : INT; (*Counters*)
		NumberOfAnomalies : INT;
		NumberOfWarnings : INT;
		NumberOfInformation : INT; (*Counters for Active Signals*)
		NumberOfActiveAlarms : INT;
		NumberOfActiveAnomalies : INT;
		NumberOfActiveWarning : INT;
		NumberOfActiveInformation : INT; (*Reset Management*)
	END_VAR
	VAR_OUTPUT
		ResetEnable : BOOL;
	END_VAR
	VAR
		ResetActivation : BOOL;
		AuxResetActivation : BOOL;
		Signals : ARRAY[1..100] OF BOOL; (*Signals management*)
		ActiveSignalCodes : ARRAY[1..100] OF INT;
		ResetOld : BOOL; (*Auxiliary variable*)
		KeyResetOld : BOOL;
		Index : INT;
		BaseIndex : INT;
		Condition : BOOL;
		i : INT;
	END_VAR
END_FUNCTION_BLOCK
