
(*Generic Device function block implementation (See Slide Generic Device)*)
FUNCTION_BLOCK GenericDevice_FB

    // Device clock handler
	IF (DeviceClock AND (DeviceTimer > 0)) THEN
		DeviceTimer := DeviceTimer - 1;
	END_IF;
	
	
	// Device sensors handler
	CASE (DeviceType AND DEVICE_FEEDBACK_MASK) OF
		DEVICE_WITH_DISABLE_FEEDBACK:
			
			DeviceDisabled := DeviceDisabledSensor;
			
			DeviceEnabled := NOT DeviceDisabled AND 
				((DeviceState = DeviceEnabledState) OR 
				((DeviceState = DeviceEnablePhaseState) AND DeviceTimeout));

		DEVICE_WITH_ENABLE_FEEDBACK:
			
			DeviceEnabled := DeviceEnabledSensor;
			
			DeviceDisabled := NOT DeviceEnabled AND
				((DeviceState = DeviceDisabledState) OR 
				((DeviceState = DeviceDisablePhaseState) AND DeviceTimeout));

		DEVICE_WITH_DOUBLE_FEEDBACK:
			
			DeviceEnabled := DeviceEnabledSensor;
			
			DeviceDisabled := DeviceDisabledSensor;

		DEVICE_WITHOUT_FEEDBACK:

			DeviceEnabled := (DeviceState = DeviceEnabledState) OR ((DeviceState = DeviceEnablePhaseState) AND DeviceTimeout);

			DeviceDisabled := (DeviceState = DeviceDisabledState) OR ((DeviceState = DeviceDisablePhaseState) AND DeviceTimeout);
		
	END_CASE;

	// Initialization handler
	IF DeviceOperation = INIT THEN
		CASE (DeviceType AND DEVICE_FEEDBACK_MASK) OF
			DEVICE_WITH_ENABLE_FEEDBACK:
				DeviceDisabled := NOT DeviceEnabled;
			
			DEVICE_WITH_DISABLE_FEEDBACK:
				DeviceEnabled := NOT DeviceDisabled;
			
			DEVICE_WITHOUT_FEEDBACK:
				DeviceEnabled := DeviceEnablePreset;
				DeviceDisabled := NOT DeviceEnabled;
		END_CASE;
		
		DeviceEnableRequest := FALSE;
		DeviceDisableRequest := FALSE;

		IF DeviceEnablePreset THEN
			EnableDevice := TRUE;
			DeviceTimer := DeviceEnableTime;
			IF NOT (DeviceDisabled AND DeviceEnabled) THEN
				DeviceState := DeviceEnablePhaseState;
			ELSE
				DeviceState := DeviceEnabledState;
			END_IF;
			DeviceNotInitialized := NOT DeviceEnabled OR DeviceDisabled;
		ELSE
			EnableDevice := FALSE;
			DeviceTimer := DeviceDisableTime;
			IF NOT (DeviceDisabled AND DeviceEnabled) THEN
				DeviceState := DeviceDisablePhaseState;
			ELSE
				DeviceState := DeviceDisabledState;
			END_IF;
			DeviceNotInitialized := DeviceEnabled OR NOT DeviceDisabled;
		END_IF;
	END_IF;

	// Device control handler (slide 8-9)
	CASE DeviceState OF
		DeviceDisabledState:
			DeviceDisableRequest := FALSE;
			IF (DeviceEnableRequest) THEN
				EnableDevice := TRUE;
				DeviceTimer := DeviceEnableTime;
				DeviceState := DeviceEnablePhaseState;
			END_IF;

		DeviceEnablePhaseState:
			IF (DeviceDisableRequest) THEN
				DeviceEnableRequest := FALSE;
				EnableDevice := FALSE;
				DeviceTimer := DeviceDisableTime;
				DeviceState := DeviceDisablePhaseState;
			END_IF;
			IF (DeviceEnabled) THEN
				DeviceEnableRequest := FALSE;
				//DeviceTimer := 0;
				DeviceState := DeviceEnabledState;
			END_IF;
			
		DeviceEnabledState:
			DeviceEnableRequest := FALSE;
			IF (DeviceDisableRequest) THEN
				EnableDevice := FALSE;
				DeviceTimer := DeviceDisableTime;
				DeviceState := DeviceDisablePhaseState;
			END_IF;

		DeviceDisablePhaseState:
			IF (DeviceEnableRequest) THEN
				DeviceDisableRequest := FALSE;
				EnableDevice := TRUE;
				DeviceTimer := DeviceEnableTime;
				DeviceState := DeviceEnablePhaseState;
			END_IF;
			IF (DeviceDisabled) THEN
				DeviceDisableRequest := FALSE;
				//DeviceTimer := 0;
				DeviceState := DeviceDisabledState;
			END_IF;
	END_CASE;
	
		
	// Device diagnostics handler (slide 26)
	DeviceTimeout := (DeviceTimer = 0);
	IF DeviceDiagnosticsEnabled AND NOT ImmediateStop AND (DeviceType AND DEVICE_FEEDBACK_MASK) <> DEVICE_WITHOUT_FEEDBACK THEN
		CASE (DeviceType AND DEVICE_FEEDBACK_MASK) OF
			DEVICE_WITH_DISABLE_FEEDBACK:
				
				DeviceDisabledSensorFault := 
				(NOT EnableDevice AND NOT DeviceDisabled AND NOT DeviceEnabled) AND DeviceTimeout;
				
				DeviceActuatorFault :=
				(EnableDevice AND DeviceDisabled AND NOT DeviceEnabled) AND DeviceTimeout;

			DEVICE_WITH_ENABLE_FEEDBACK:
			
				DeviceEnabledSensorFault :=
				(EnableDevice AND NOT DeviceDisabled AND NOT DeviceEnabled) AND DeviceTimeout;
				
				DeviceActuatorFault :=
				(NOT EnableDevice AND NOT DeviceDisabled AND DeviceEnabled) AND DeviceTimeout;

			DEVICE_WITH_DOUBLE_FEEDBACK:
			
				DeviceDisabledSensorFault := 
				((NOT EnableDevice AND NOT DeviceDisabled AND NOT DeviceEnabled) OR
				(EnableDevice AND DeviceDisabled AND DeviceEnabled)) AND DeviceTimeout;
			
				DeviceEnabledSensorFault :=
				((NOT EnableDevice AND DeviceDisabled AND DeviceEnabled) OR
				(EnableDevice AND NOT DeviceDisabled AND NOT DeviceEnabled)) AND DeviceTimeout;
						
				DeviceActuatorFault :=
				((NOT EnableDevice AND NOT DeviceDisabled AND DeviceEnabled) OR
				(EnableDevice AND DeviceDisabled AND NOT DeviceEnabled)) AND DeviceTimeout;
		
		END_CASE;
		
		DeviceFault := DeviceDisabledSensorFault OR DeviceEnabledSensorFault OR DeviceActuatorFault;
	END_IF
	
	IF (DeviceType AND DEVICE_STOP_MASK) = DEVICE_IMMEDIATE_STOP_AUTOMATIC AND ImmediateStop AND NOT Condition THEN
		OldEnableDevice := EnableDevice;
		EnableDevice := FALSE;
		Condition := TRUE;
	ELSIF Condition AND NOT ImmediateStop THEN
		EnableDevice := OldEnableDevice;
		Condition := FALSE;
	END_IF
	
	// Device actuators handler (correct from slides)
	CASE (DeviceType AND DEVICE_ACTUATION_MASK) OF
		DEVICE_WITH_DOUBLE_ACTUATION:
			DisableDevice := NOT EnableDevice;
		
		DEVICE_WITH_DA_NO_RETAIN:
			EnableDevice := EnableDevice AND (DeviceState = DeviceEnablePhaseState);
			DisableDevice := NOT EnableDevice AND(DeviceState = DeviceDisablePhaseState);
	END_CASE;
	

END_FUNCTION_BLOCK

