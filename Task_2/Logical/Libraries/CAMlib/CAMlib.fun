
{REDUND_ERROR} FUNCTION_BLOCK CamFB (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		AxisOperation : INT;
		AxisCommand : COMMANDS;
		Axis : UDINT;
		MpLinkMaster : UDINT;
		MpLink : UDINT;
		Slave : UDINT;
		CamTable : ARRAY[0..4] OF STRING[12];
		Position : REAL;
		Velocity : REAL;
		Acceleration : REAL;
		Deceleration : REAL;
		Jerk : REAL;
		Direction : USINT;
		ArraySize : INT;
		Scale : REAL;
		Offset : REAL;
		RatioNumerator : INT;
		CamID : USINT;
		CamActivated : BOOL;
		RatioDenominator : INT;
		CouplingParam : MpAxisCouplingParType;
		Param : MpAxisBasicParType;
	END_VAR
	VAR_OUTPUT
		CommandExecuted : BOOL;
		CommandAborted : BOOL;
		Error : BOOL;
		ErrorID : UINT;
		AxisErrorID : UINT;
		AxisErrorCount : UINT;
		AxisNotInitialized : BOOL;
		Status : WORD;
		ActualVelocity : REAL;
		ActualPosition : LREAL;
	END_VAR
	VAR_IN_OUT
		AxisEnable : BOOL;
	END_VAR
	VAR
		MpAxisCoupling : MpAxisCoupling;
		MpAxisBasic : MpAxisBasic;
		OldVelocity : REAL;
		AxisState : GA_State;
		OldCamID : USINT;
	END_VAR
END_FUNCTION_BLOCK
