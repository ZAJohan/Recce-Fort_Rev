[] execVM "VCOMAI\init.sqf";
[] execVM "vcom_settings.sqf";

[player, 1] call BIS_fnc_respawnTickets; // https://community.bistudio.com/wiki/BIS_fnc_respawnTickets

[] execVM "disable_jip_respawn.sqf";
