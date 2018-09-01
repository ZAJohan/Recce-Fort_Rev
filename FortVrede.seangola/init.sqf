[] spawn {
	if !(hasinterface) exitWith {};
	waitUntil {!(isNull player)};
	[player, 1] call BIS_fnc_respawnTickets;  // https://community.bistudio.com/wiki/BIS_fnc_respawnTickets
};

[] execVM "VCOMAI\init.sqf";
[] execVM "vcom_settings.sqf";

[] execVM "disable_jip_respawn.sqf";

