params ["_player", "_didJIP"];

waitUntil {!(isNil "killed_player_ids")};

if (getPlayerUID _player in killed_player_ids) then {
	_player setDamage 1;
	hint "You are deemed to have died before on this server, therefore you are dead now.";
};
