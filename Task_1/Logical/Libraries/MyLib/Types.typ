
TYPE
	GA_State : 
		(
		NotPowered,
		WaitPower,
		Powered,
		CheckCommand,
		MoveVelocity,
		CheckVelocity,
		MoveAdditive,
		AxisHalt,
		AxisStop
		);
	COMMANDS : 
		(
		NONE,
		MOVE_VELOCITY,
		MOVE_ADDITIVE,
		AXIS_HALT,
		AXIS_STOP
		);
END_TYPE
