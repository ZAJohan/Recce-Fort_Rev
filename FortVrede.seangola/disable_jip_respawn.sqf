/*
* To prevent people from circumventing the effective no respawn by using the jip 
* system (exiting and rejoining after dying)
*/

if (isServer) then {
	killed_player_ids = [];
	publicVariable "killed_player_ids";
}

if (hasInterface) then {
	player addEventHandler [
		"killed", {
			killed_player_ids set [count killed_player_ids, getPlayerUID player];
			publicVariable "killed_player_ids";
		}
	];
};
