
TYPE
	GA_State : 
		(
		NotPowered,
		WaitEnable,
		WaitPower,
		Powered,
		CheckCommand,
		MoveVelocity,
		CheckVelocity,
		MoveAdditive,
		CheckAdditiveUpdate,
		AxisHalt,
		AxisStop,
		CheckCamUpdate,
		CheckCam,
		MoveCam,
		CheckVelocityUpdate,
		AxisEmergency
		);
	COMMANDS : 
		(
		NONE,
		MOVE_VELOCITY,
		MOVE_ADDITIVE,
		AXIS_HALT,
		AXIS_STOP,
		MOVE_CAM,
		AXIS_EMERGENCY
		);
END_TYPE
