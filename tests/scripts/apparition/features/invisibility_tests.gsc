// Invisibility contracts inspect saved flags without invoking native player methods

run()
{
    missing_and_disabled_flags_are_not_configured();
    enabled_flag_is_reported_without_guessing_engine_visibility();
    configured_reads_do_not_change_player_state();
    a_missing_actor_cannot_toggle_invisibility();
}

missing_and_disabled_flags_are_not_configured()
{
    tests\support\checks::expect(!scripts\apparition\features\invisibility::configured(undefined),
        "A missing player has no configured invisibility flag");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\invisibility::configured(player),
        "An undefined player flag is not configured");

    player.Invisibility = 0;
    tests\support\checks::expect(!scripts\apparition\features\invisibility::configured(player),
        "A zero-valued player flag is disabled");
}

enabled_flag_is_reported_without_guessing_engine_visibility()
{
    player = spawnstruct();
    player.Invisibility = 1;
    tests\support\checks::expect(scripts\apparition\features\invisibility::configured(player),
        "A truthy saved player flag is configured");
}

configured_reads_do_not_change_player_state()
{
    player = spawnstruct();
    player.Invisibility = 1;
    player.unrelated_value = "preserved";

    configured = scripts\apparition\features\invisibility::configured(player);
    tests\support\checks::expect(configured, "Reading a configured flag returns its truth state");
    tests\support\checks::expect(player.Invisibility == 1,
        "Reading the invisibility flag does not alter it");
    tests\support\checks::expect(player.unrelated_value == "preserved",
        "Reading the invisibility flag leaves unrelated player fields unchanged");
}

a_missing_actor_cannot_toggle_invisibility()
{
    tests\support\checks::expect(!scripts\apparition\features\invisibility::toggle(undefined),
        "A missing player is rejected before an invisibility toggle");
}
