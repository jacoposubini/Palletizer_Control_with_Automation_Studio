
{REDUND_ERROR} FUNCTION_BLOCK GenericAxis (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Command : {REDUND_UNREPLICABLE} WORD := 6;
		ActualPosition : REAL;
		ActualVelocity : REAL;
		NewSetPoint : REAL;
		DeviceTimer : UDINT;
		TGT_SENSOR : BOOL;
		Reset : BOOL;
	END_VAR
	VAR_OUTPUT
		TargetVelocity : REAL;
		TargetPosition : REAL;
		InPosition : BOOL;
		InVelocity : BOOL;
		DeviceFault : BOOL;
	END_VAR
	VAR
		AxisState : GenericAxisStateType;
		Timer : UDINT;
	END_VAR
END_FUNCTION_BLOCK
