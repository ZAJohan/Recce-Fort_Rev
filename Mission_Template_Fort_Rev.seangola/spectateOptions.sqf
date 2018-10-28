/*
	Author: Phoenix of Zulu-Alpha

	Description:
		Gives the target player local only action menu options to spectate.
		Must be spawned

	Params:
		0 : OBJECT - The player to give options to.

	Returns:
		(NUL)
*/

params ["_unit"];

// Make sure addactions only appear to the player themselves.
waitUntil {!(isNull player) and !(isNull _unit)};
if !(local _unit) exitWith {};
sleep 5;

// Allow exiting of spectator script if inventory key is pressed
[] spawn {
	while {true} do {
		waitUntil {inputAction "Gear" > 0};
		if (playerRespawnTime < 0) then {
			["Terminate"] call BIS_fnc_EGSpectator;
		};
	};
};

_teleport_map_click = {
	onMapSingleClick "player setPos _pos; onMapSingleClick ''; hint ''";
	hintSilent "Open your map and left click on where you want to teleport to.";
};

_unit addAction ["Spectate", {["Initialize", [player, [west], false, false, true, true, true, true, true, true]] call BIS_fnc_EGSpectator;}];
// _this select 0 : The target player object
// _this select 1 : Whitelisted sides, empty means all
// _this select 2 : Whether AI can be viewed by the spectator
// _this select 3 : Whether Free camera mode is available
// _this select 4 : Whether 3th Person Perspective camera mode is available
// _this select 5 : Whether to show Focus Info stats widget
// _this select 6 : Whether or not to show camera buttons widget
// _this select 7 : Whether to show controls helper widget
// _this select 8 : Whether to show header widget
// _this select 9 : Whether to show entities / locations lists
_unit addAction ["Teleport", _teleport_map_click];

// Track all units
//[] execVM "spectateTrack.sqf";
