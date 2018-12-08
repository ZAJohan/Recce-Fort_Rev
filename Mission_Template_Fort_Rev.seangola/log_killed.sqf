if !(isServer) exitWith {};
waitUntil {time > 5};


EAST_TOTAL_KILLED = 0;
WEST_TOTAL_KILLED = 0;
INDEPENDENT_TOTAL_KILLED = 0;
CIVILIAN_TOTAL_KILLED = 0;

log_death = {
	params ["_unit", "_killer"];
	if !(isServer) exitWith {};
	private _side = _unit getVariable "original_side_str";
	_side call {
		if (_this == "EAST") exitWith {EAST_TOTAL_KILLED = EAST_TOTAL_KILLED + 1};
		if (_this == "WEST") exitWith {WEST_TOTAL_KILLED = WEST_TOTAL_KILLED + 1};
		if (_this == "GUER") exitWith {INDEPENDENT_TOTAL_KILLED = INDEPENDENT_TOTAL_KILLED + 1};
		if (_this == "CIV") exitWith {CIVILIAN_TOTAL_KILLED = CIVILIAN_TOTAL_KILLED + 1};
	};
	diag_log "**** Killed event detected ****";
	diag_log format ["%1 (side %2) was killed. Total deaths so far: East: %3, West: %4, Independent: %5, Civilian: %6",
			         name _unit, _side, EAST_TOTAL_KILLED, WEST_TOTAL_KILLED, INDEPENDENT_TOTAL_KILLED, 
					 CIVILIAN_TOTAL_KILLED];
};

nul = [] spawn {
	while {true} do {
		{
			if !(_x getVariable ["killed_logging_added", false]) then {
				_x addMPEventHandler ["mpkilled", {nul = _this call log_death}];
				_x setVariable ["killed_logging_added", true, false];
				_x setVariable ["original_side_str", str(side _x), false];
			};
			sleep 0.1;
		} forEach allUnits;
		sleep 30;
	};
};
