if !(isServer) exitWith {};
waitUntil {time > 5};

_options = [
    "autoReport",
    "cameraShake",
    "commands",
    "deathMessages",
    "detectedMines",
    "enemyTags",
    "friendlyTags",
    "groupIndicators",
    "mapContent",
    "mapContentEnemy",
    "mapContentFriendly",
    "mapContentMines",
    "mapContentPing",
    "multipleSaves",
    "reducedDamage",
    "scoreTable",
    "squadRadar",
    "staminaBar",
    "stanceIndicator",
    "tacticalPing",
    "thirdPersonView",
    "visionAid",
    "vonID",
    "waypoints",
    "weaponCrosshair",
    "weaponInfo"
];

_settings = [];
{
    _settings set [count _settings, format ["%1: %2", _x, difficultyOption _x]];
} forEach _options;

_test_enemy = (createGroup east) createUnit ["O_Soldier_F", [0, 0, 0], [], 0, "NONE"];
_test_enemy setSkill 0.24757722;

_skillNames = [
    "aimingAccuracy",
    "aimingShake",
    "aimingSpeed",
    "endurance",
    "spotDistance",
    "spotTime",
    "courage",
    "reloadSpeed",
    "commanding",
    "general"
];

_skills = [];
{
    _skills set [count _skills, format ["%1: %2", _x, _test_enemy skillFinal _x]];
} forEach _skillNames;

_all_settings = [
    format ["Difficulty Preset: %1", difficulty],
    _settings,
    _skills
];

diag_log "**** Difficulty Settings ****";
diag_log _all_settings;

_enemy_group = group _test_enemy;
deleteVehicle _test_enemy;
deleteGroup _enemy_group;
