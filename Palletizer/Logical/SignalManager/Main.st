
PROGRAM _INIT
	(* Insert code here *)
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
	IF OperationType = INIT THEN
		SignalManagement(OperationType := START_CONFIGURATION);
		SignalManagement.OperationType := CONFIGURATION;
	ELSE
		SignalManagement(OperationType := START_GENERATION);
		SignalManagement.OperationType := GENERATION;
		SignalManagement.Reset := ResetButton;
	END_IF
	
	(* IMMEDIATE STOP *)
	
	(* IMMEDIATE STOP *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mImmediateStopButton,
	SignalOutput := IMMEDIATE_STOP,
	InputString := 'IMMEDIATE STOP ACTIVATED',
	ActivationSignal := ImmediateStopButton);

	(* EMERGENCY STOP *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mEmergencyStopButton,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'EMERGENCY STOP ACTIVATED',
	ActivationSignal := EmergencyStopButton);

	(* ON PHASE STOP *)
	SignalManagement(SignalType := INFORMATION OR DISPLAY_LOG,
	SignalCode := mOnPhaseStopButton,
	SignalOutput := ON_PHASE_STOP,
	InputString := 'ON PHASE STOP PERFORMING ...',
	ActivationSignal := OnPhaseStopPerforming OR OnPhaseStopButton);

	(* CRANE MACHINE *)

	(* Pusher X *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherXActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_X Actuator Fault',
	ActivationSignal := PusherXActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherXDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_X Disable Sensor Fault',
	ActivationSignal := PusherXDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherXEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_X Enable Sensor Fault',
	ActivationSignal := PusherXEnableSensorFaultE);

	(* Pusher Z *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherZActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_Z Actuator Fault',
	ActivationSignal := PusherZActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherZDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_Z Disable Sensor Fault',
	ActivationSignal := PusherZDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherZEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher_Z Enable Sensor Fault',
	ActivationSignal := PusherZEnableSensorFaultE);

	(* Slide Rail Right *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mSlideRailRightActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Slide Rail Right Actuator Fault',
	ActivationSignal := SlideRailRightActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mSlideRailRightDisableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Slide Rail Right Disable Sensor Fault',
	ActivationSignal := SlideRailRightDisableFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mSlideRailRightEnableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Slide Rail Right Enable Sensor Fault',
	ActivationSignal := SlideRailRightEnableFaultE);

	(* Vacuum Box Crane *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mVacuumBoxCraneActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Vacuum Box Crane Actuator Fault',
	ActivationSignal := VacuumBoxCraneActuatorFaultE OR SimVacuumBoxCraneActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mVacuumBoxCraneDisableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Vacuum Box Crane Disable Sensor Fault',
	ActivationSignal := VacuumBoxCraneDisableFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mVacuumBoxCraneEnableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Vacuum Box Crane Enable Sensor Fault',
	ActivationSignal := VacuumBoxCraneEnableFaultE);

	(* Cardboard *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mCardboardActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Cardboard Actuator Fault',
	ActivationSignal := CardboardActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mCardboardDisableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Cardboard Disable Sensor Fault',
	ActivationSignal := CardboardDisableFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mCardboardEnableFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Cardboard Enable Sensor Fault',
	ActivationSignal := CardboardEnableFaultE);

	(* Box Crane *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mBoxCraneFaultSignal,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Box Crane Fault',
	ActivationSignal := BoxCraneFaultSignalE OR SimBoxCraneFaultSignalE);

	(* Gantry Crane *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mGantryCraneFaultSignal,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Gantry Crane Fault',
	ActivationSignal := GantryCraneFaultSignalE);

	(* FEEDER *)

	(* Turnpusher *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mTurnpusherActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Turnpusher Actuator Fault',
	ActivationSignal := TurnpusherActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mTurnpusherDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Turnpusher Disable Sensor Fault',
	ActivationSignal := TurnpusherDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mTurnpusherEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Turnpusher Enable Sensor Fault',
	ActivationSignal := TurnpusherEnableSensorFaultE);

	(* Pusher *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher Actuator Fault',
	ActivationSignal := PusherActuatorFaultE OR SimPusherActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher Disable Sensor Fault',
	ActivationSignal := PusherDisableSensorFaultE OR SimPusherDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPusherEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pusher Enable Sensor Fault',
	ActivationSignal := PusherEnableSensorFaultE);

	(* Conveyor If *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorIfActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor If Actuator Fault',
	ActivationSignal := ConveyorIfActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorIfDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor If Disable Sensor Fault',
	ActivationSignal := ConveyorIfDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorIfEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor If Enable Sensor Fault',
	ActivationSignal := ConveyorIfEnableSensorFaultE);

	(* Conveyor Turn1 *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorTurn1ActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor Turn1 Actuator Fault',
	ActivationSignal := ConveyorTurn1ActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorTurn1DisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor Turn1 Disable Sensor Fault',
	ActivationSignal := ConveyorTurn1DisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorTurn1EnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor Turn1 Enable Sensor Fault',
	ActivationSignal := ConveyorTurn1EnableSensorFaultE);

	(* Conveyor End *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorEndActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor End Actuator Fault',
	ActivationSignal := ConveyorEndActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorEndDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor End Disable Sensor Fault',
	ActivationSignal := ConveyorEndDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mConveyorEndEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Conveyor End Enable Sensor Fault',
	ActivationSignal := ConveyorEndEnableSensorFaultE);

	(* Carriage *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mCarriagePositionFaultSignal,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Carriage Position Fault',
	ActivationSignal := CarriagePositionFaultSignalE);

	(* PALLET HANDLER *)

	(* Pallet Fork *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletForkActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Fork Actuator Fault',
	ActivationSignal := PalletForkActuatorFaultE OR SimPalletForkActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletForkDisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Fork Disable Sensor Fault',
	ActivationSignal := PalletForkDisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletForkEnableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Fork Enable Sensor Fault',
	ActivationSignal := PalletForkEnableSensorFaultE OR SimPalletForkEnableSensorFaultE);

	(* Pallet Lifter *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletLifterFaultSignal,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Lifter Fault',
	ActivationSignal := PalletLifterFaultSignalE);

	(* Pallet Conveyor 1 *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletConv1ActuatorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Conveyor 1 Actuator Fault',
	ActivationSignal := PalletConv1ActuatorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletConv1DisableSensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Conveyor 1 Disable Sensor Fault',
	ActivationSignal := PalletConv1DisableSensorFaultE);

	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletConv1SensorFault,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Conveyor 1 Sensor Fault',
	ActivationSignal := PalletConv1SensorFaultE);

	(* Pallet Conveyor 2 *)
	SignalManagement(SignalType := ALARM OR DISPLAY_LOG,
	SignalCode := mPalletConv2FaultSignal,
	SignalOutput := EMERGENCY_STOP,
	InputString := 'Pallet Conveyor 2 Fault',
	ActivationSignal := PalletConv2FaultSignalE);

	IF OperationType <> INIT THEN
		SignalManagement(OperationType := MESSAGES_GENERATION);
		LogFile := SignalManagement.LogFile;
		MainMessage := SignalManagement.MainMessage;
		SignalOutputs := SignalManagement.SignalOutputs;
		EmergencyStop := (SignalOutputs AND EMERGENCY_STOP) = EMERGENCY_STOP;
		ImmediateStop := (SignalOutputs AND IMMEDIATE_STOP) = IMMEDIATE_STOP;
		OnPhaseStop := (SignalOutputs AND ON_PHASE_STOP) = ON_PHASE_STOP;
	END_IF
	
	ResetEnable := SignalManagement.ResetEnable;
	ResetButton := FALSE;
	ImmediateStopButton := FALSE;
	EmergencyStopButton := FALSE;
	OnPhaseStopButton := FALSE;	
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

