// HUD visibility contracts inspect saved intent without native omnvar writes

run()
{
    missing_and_disabled_flags_are_not_configured();
    enabled_flag_is_reported_from_saved_state();
    configured_reads_do_not_change_player_state();
    a_missing_actor_cannot_toggle_hud_visibility();
}

missing_and_disabled_flags_are_not_configured()
{
    tests\support\checks::expect(!scripts\apparition\features\hud_visibility::configured(undefined),
        "A missing player has no configured HUD visibility flag");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\hud_visibility::configured(player),
        "An undefined player flag is not configured");

    // The original flag treats an explicit zero the same as an unset field
    player.DisablePlayerHUD = 0;
    tests\support\checks::expect(!scripts\apparition\features\hud_visibility::configured(player),
        "A zero-valued player flag is disabled");
}

enabled_flag_is_reported_from_saved_state()
{
    player = spawnstruct();
    player.DisablePlayerHUD = 1;
    tests\support\checks::expect(scripts\apparition\features\hud_visibility::configured(player),
        "A truthy saved player flag is configured");
}

configured_reads_do_not_change_player_state()
{
    player = spawnstruct();
    player.DisablePlayerHUD = 1;
    player.unrelated_value = "preserved";

    // Reading saved intent must not send a command or change other settings
    configured = scripts\apparition\features\hud_visibility::configured(player);
    tests\support\checks::expect(configured, "Reading a configured flag returns its truth state");
    tests\support\checks::expect(player.DisablePlayerHUD == 1,
        "Reading the HUD visibility flag does not alter it");
    tests\support\checks::expect(player.unrelated_value == "preserved",
        "Reading the HUD visibility flag leaves unrelated player fields unchanged");
}

a_missing_actor_cannot_toggle_hud_visibility()
{
    // This failure path stops before the client omnvar call
    tests\support\checks::expect(!scripts\apparition\features\hud_visibility::toggle(undefined),
        "A missing player is rejected before a HUD visibility toggle");
}
