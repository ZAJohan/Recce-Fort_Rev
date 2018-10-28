params ["_player", "_didJIP"];

[_player, 1] call BIS_fnc_respawnTickets;

waitUntil {!(isNil "killed_player_ids")};

if (getPlayerUID _player in killed_player_ids) then {
	waitUntil {([player, nil] call BIS_fnc_respawnTickets) > -1};
	sleep 3;
	_player setDamage 1;
	hint "You are deemed to have died before on this server, therefore you are dead now.";
};
