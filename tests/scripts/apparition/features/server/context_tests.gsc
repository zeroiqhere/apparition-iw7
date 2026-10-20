// Server settings reject missing and nonplayer owners before authority checks

run()
{
    missing_and_nonplayer_owners_cannot_change_server_settings();
}

missing_and_nonplayer_owners_cannot_change_server_settings()
{
    tests\support\checks::expect(scripts\apparition\features\server\context::reason(undefined) != "",
        "An absent owner cannot change server settings");
    tests\support\checks::expect(scripts\apparition\features\server\context::reason(spawnstruct()) != "",
        "A plain struct cannot stand in for a current native player");
}
