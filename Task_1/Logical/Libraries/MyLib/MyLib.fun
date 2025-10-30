
FUNCTION_BLOCK GenericAxis_FB (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		AxisOperation : INT;
		AxisCommand : COMMANDS;
		Master : UDINT;
		Slave : UDINT;
		CamTable : STRING[12];
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
		RatioDenominator : INT;
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
		OldVelocity : REAL;
		MC_Power_GA : MC_Power;
		MC_Home_GA : MC_Home;
		MC_MoveVelocity_GA : MC_MoveVelocity;
		MC_MoveAdditive_GA : MC_MoveAdditive;
		MC_MoveAbsolute_GA : MC_MoveAbsolute;
		MC_ReadActualPosition_GA : MC_ReadActualPosition;
		MC_ReadActualVelocity_GA : MC_ReadActualVelocity;
		MC_ReadAxisError_GA : MC_ReadAxisError;
		MC_ReadStatus_GA : MC_ReadStatus;
		AxisState : GA_State;
		MC_Halt_GA : MC_Halt;
		MC_Stop_GA : MC_Stop;
	END_VAR
END_FUNCTION_BLOCK
