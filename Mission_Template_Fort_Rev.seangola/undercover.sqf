/*
	Author(s):
		Phoenix of Zulu-Alpha

	License:
		APL-SA: http://www.bistudio.com/english/community/licenses/arma-public-license-share-alike

	Purpose:
		Makes the target unit (should be a player) be undercover (set as captive) unless these conditions are met:

			The subject has a non civilian uniform, nor a civilian uniform that has been compromised earlier, a vest, any
			headgear with armor, any primary or secondary weapon on person (pistols can be carried but must be holstered or hidden),
			holding any equipment in their hands (even binocs), must not be using NVGs or thermals, must not be in a non civilian
			vehicle and must not be closer than 5 meters to an enemy who would be able to see you (you can be behind them or behind a wall for eg).

		If any one of these conditions are violated and there is an enemy who is close enough (within 200m), who has you within their FOV
		(from 60 deg at 0m to 10 deg at 200m) and has LOS of you and fully knows about you, then your uniform will be compromised and remembered by
		all enemies and you	would have to change into a different civilian uniform in order to remain under cover. Note that you cannot compromise
		a uniform for someone else, as the enemy only remembers the particular combination of person and uniform.

	Usage:
		Place the following line in the playable unit to make undercover:
			nul = [this] execVm "undercover.sqf";

	Params:
		0: OBJECT - Person to make undercover

	Return:
		Null

	Version: 1.1

	Changelog:
		v1.0
			- First release
*/

private ["_subject"];
_subject = _this select 0;

// Make sure the player is initialized
if !(hasInterface) exitWith {};
waitUntil {player == player};
sleep 5;

// Should be local
if !(local _subject) exitWith {};

// Initialize isConspicuous variable, used for keeping track of
// whether or not the person's cover should be blown
_subject setVariable ["isConspicuous", true];

// Initialize compromised_uniforms variable, used to keep track
// of uniforms the enemy has noticed you wearing
_subject setVariable ["compromised_uniforms", []];

// Start off by making sure the subject is not captive
_subject setCaptive false;

// Spawn loop that checks if the appearance is conspicuous
[_subject] spawn {

	private ["_subject"];
	_subject = _this select 0;

	// Make sure the unit is initialized
	waitUntil {!isNull _subject};

	// Infinite loop
	for "_i" from 0 to 1 step 0 do {

		private ["_isConspicuous", "_uniform_man", "_isConspicuous_var"];
		_subject = _this select 0;

		// High performance switch statement. If any one of these is not met, then the person is conspicuous
		_isConspicuous = call {

			// Check if the the uniform is compromised
			if ( (uniform _subject) in (_subject getVariable ["compromised_uniforms", []]) ) exitWith {true};

			// Each uniform has its own person model which contains the side info
			_uniform_man = getText (configfile >> "CfgWeapons" >> (uniform _subject) >> "ItemInfo" >> "uniformClass");

			// That person model must be civilian
			if !( getNumber (configfile >> "CfgVehicles" >> _uniform_man >> "side") == 3 ) exitWith {true};

			// Must not have vest or backpack
			if !( vest _subject == "" ) exitWith {true};
			//if !( backpack _subject == "" ) exitWith {true};

			// The headgear must not have any armor
			// Old version
			if !( getNumber (configfile >> "CfgWeapons" >> (headGear _subject) >> "ItemInfo" >> "armor") == 0 ) exitWith {true};
			// New version
			if !( getNumber (configfile >> "CfgWeapons" >> (headGear _subject) >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" >> "armor") == 0 ) exitWith {true};

			// Must not have primary, secondary or active weapons
			if !( primaryWeapon _subject == "" ) exitWith {true};
			if !( secondaryWeapon _subject == "" ) exitWith {true};
			if !( currentWeapon _subject == "" ) exitWith {true};

			// Check if using thermals or NVGs (advanced optics)
			if !( currentVisionMode _subject == 0 ) exitWith {true};

			// Check if driving non civ vehicle
			if !(
					if (vehicle _subject != _subject) then {getNumber (configfile >> "CfgVehicles" >> (typeOf (vehicle _subject)) >> "side") == 3} else {true}
				) exitWith {true};

			// Not conspicuous
			false

		};

		// Get global isConspicuous var
		_isConspicuous_var = _subject getVariable ["isConspicuous", true];

		// If is conspicuous but the var is not yet set to reflect that, then set it and hint the player
		// as he\she most probably just became conspicuous
		if (_isConspicuous && !_isConspicuous_var) then {
			systemChat  "You now look conspicuous!";
			_subject setCaptive false;
			_subject setVariable ["isConspicuous", true];
		};

		// Otherwise if it is visa versa, then set to not captive and hint the player
		if (!_isConspicuous && _isConspicuous_var) then {
			systemChat "You don't look conspicuous now.";
			_subject setCaptive true;
			_subject setVariable ["isConspicuous", false];
		};

		// Delay timer
		sleep 2;

	};

};


// Spawn loop that checks ai are close enough, in LOS, knows about and in correct angle
// to discover the subject and remember it's uniform in order to compromise its cover.
[_subject] spawn {

	private ["_subject"];
	_subject = _this select 0;

	// Make sure the unit is initialized
	waitUntil {!isNull _subject};

	// Infinite loop
	for "_i" from 0 to 1 step 0 do {

		private ["_uniform", "_compromised_uniforms"];
		_subject = _this select 0;
		_uniform = uniform _subject;

		{

			// If the uniform is already known by the enemy then that person can't be undercover
			// anymore anyway and there is nothing to do in this current loop count.
			_compromised_uniforms = _subject getVariable ["compromised_uniforms", []];
			if (_uniform in _compromised_uniforms) exitWith {};

			// If the uniform is not compromised, then carry on looking for compromising enemies
			call {

				private ["_distance", "_fov_max", "_dirTo"];

				// If unit not on an enemy side
				if !( (playerSide getFriend side _x) < 0.6 ) exitWith {};

				// If enemy doesn't know enough about him
				if !(_x knowsAbout _subject == 4) exitWith {};

				// If enemy not close enough
				_distance = _subject distance _x;
				if !( (_distance) <= 100 ) exitWith {};

				// The maximum FOV that the subject can be detected at (from 60 deg at 0m to 10 deg at 200m)
				_fov_max = (-0.25 * (_distance) + 60) max 0;

				// Direction to the subject from the enemy
				_dirTo = abs ( getDir _x - ([_x, _subject] call BIS_fnc_dirTo) );

				// Exit if out of FOV
				if (_dirTo > _fov_max) exitWith {};

				// Exit if no LOS
				if (lineIntersects [eyePos _subject, eyePos _x, _subject, _x] || {terrainIntersectASL [eyePos _subject,  eyePos _x]}) exitWith {};

				// If the subject is conspicuous, then the current enemy must blow the cover by rememebring the uniform
				if (_subject getVariable ["isConspicuous", false]) exitWith {
					_compromised_uniforms set [count _compromised_uniforms, _uniform];
					_subject setVariable ["compromised_uniforms", _compromised_uniforms];
				};

				// If the subject is not conspicuous, but close enough, then the cover will still be blown
				if (_distance <= 5) exitWith {
					_compromised_uniforms set [count _compromised_uniforms, _uniform];
					_subject setVariable ["compromised_uniforms", _compromised_uniforms];
				};

			};

		} count allUnits;

		// Delay timer
		sleep 2;

	};

};