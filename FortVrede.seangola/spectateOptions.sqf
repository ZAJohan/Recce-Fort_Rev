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

private ["_unit"];

_unit = _this select 0;

waitUntil {!(isNull _unit)};

// Make sure addactions only appear to the player themselves.
if !(local _unit) exitWith {};
waitUntil {!(isNull player)};
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

_unit addAction ["Spectate", {["Initialize", [player, [], true]] call BIS_fnc_EGSpectator;}];
_unit addAction ["Teleport", _teleport_map_click];
