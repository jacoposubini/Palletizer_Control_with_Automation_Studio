
FUNCTION_BLOCK GenericDevice_FB
	VAR_INPUT
		DeviceOperation : INT;
		DeviceType : INT;
		DeviceEnabledSensor : BOOL;
		DeviceDisabledSensor : BOOL;
		DeviceClock : BOOL;
		DeviceEnableTime : INT;
		DeviceDisableTime : INT;
		DeviceDiagnosticsEnabled : BOOL;
		DeviceEnablePreset : BOOL;
		ImmediateStop : BOOL;
	END_VAR
	VAR_OUTPUT
		EnableDevice : BOOL;
		DisableDevice : BOOL;
		DeviceEnabledSensorFault : BOOL;
		DeviceDisabledSensorFault : BOOL;
		DeviceActuatorFault : BOOL;
		DeviceFault : BOOL;
		DeviceNotInitialized : BOOL;
	END_VAR
	VAR_IN_OUT
		DeviceEnableRequest : BOOL;
		DeviceDisableRequest : BOOL;
	END_VAR
	VAR
		DeviceState : GenericDeviceStateType;
		DeviceTimer : INT;
		DeviceTimeout : BOOL;
		DeviceEnabled : BOOL;
		DeviceDisabled : BOOL;
		OldEnableDevice : BOOL;
		Condition : BOOL;
	END_VAR
END_FUNCTION_BLOCK
