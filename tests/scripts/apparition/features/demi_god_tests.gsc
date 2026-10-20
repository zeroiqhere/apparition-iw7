// Demi-God flag contracts cover saved state and admission without native actors

run()
{
    missing_and_malformed_players_are_not_enabled();
    a_saved_demi_god_flag_is_read_without_mutation();
    enabling_requires_hook_and_typed_ready_feedback();
    failed_feedback_readiness_does_not_partially_clear_god_mode();
    hook_or_fx_loss_still_allows_disabling_demi_god();
    enabling_clears_only_the_selected_players_god_mode_flag();
    disabling_demi_god_leaves_other_flags_and_health_unchanged();
    missing_players_cannot_change_demi_god_state();
    missing_player_feedback_readiness_stops_before_native_reads();
    invalid_directions_are_rejected_before_feedback_readiness();
    a_valid_direction_still_requires_an_admitted_player();
}

missing_and_malformed_players_are_not_enabled()
{
    tests\support\checks::expect(!scripts\apparition\features\demi_god::enabled(undefined),
        "A missing player has no enabled Demi-God flag");

    fixture = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\demi_god::enabled(fixture),
        "A valid player-shaped fixture without a saved flag is disabled");

    foreach (player in ["not a player", 7, false, []])
    {
        tests\support\checks::expect(!scripts\apparition\features\demi_god::enabled(player),
            "A scalar or array is not an enabled actor");
        tests\support\checks::expect(scripts\apparition\features\demi_god::reason(player, true, "") != "",
            "A malformed player is rejected before flag access");
        tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(player, true, ""),
            "A malformed player cannot change protection flags");
    }
}

a_saved_demi_god_flag_is_read_without_mutation()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.playerGodmode = true;
    player.health = 87;

    tests\support\checks::expect(scripts\apparition\features\demi_god::enabled(player),
        "A truthy saved Demi-God flag is enabled");
    tests\support\checks::expect(player.PlayerDemiGod && player.playerGodmode && player.health == 87,
        "Reading Demi-God does not change flags or health");

    player.PlayerDemiGod = 0;
    tests\support\checks::expect(!scripts\apparition\features\demi_god::enabled(player),
        "A zero-valued saved Demi-God flag is disabled");
}

enabling_requires_hook_and_typed_ready_feedback()
{
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(player, true, "") == "",
        "An active hook and typed empty readiness admit enabling");
    tests\support\checks::expect(scripts\apparition\features\demi_god::toggle(player, true, ""),
        "Ready Demi-God can be enabled");
    tests\support\checks::expect(scripts\apparition\features\demi_god::enabled(player),
        "The Demi-God flag is saved after admission");

    blocked = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(blocked, true, undefined) != "",
        "An undefined feedback reason is not an enable-ready result");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(blocked, true, undefined),
        "An undefined feedback reason cannot enable Demi-God");

    foreach (not_ready in [1, spawnstruct(), "Directional effects are unavailable"])
    {
        candidate = spawnstruct();
        tests\support\checks::expect(scripts\apparition\features\demi_god::reason(candidate, true, not_ready) != "",
            "Missing, malformed, or blocked feedback readiness rejects enabling");
        tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(candidate, true, not_ready),
            "Rejected feedback readiness cannot save Demi-God");
        tests\support\checks::expect(!isDefined(candidate.PlayerDemiGod),
            "Rejected feedback readiness leaves the saved flag unset");
    }

    candidate = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(candidate, false, "") != "",
        "Enabling requires the active damage hook");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(candidate, false, ""),
        "Hook loss rejects enabling");
}

failed_feedback_readiness_does_not_partially_clear_god_mode()
{
    player = spawnstruct();
    player.playerGodmode = true;
    player.PlayerDemiGod = false;
    player.NoExplosiveDamage = true;
    player.health = 61;
    reason = "Wait for native directional feedback effects";

    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(player, true, reason) == reason,
        "Native effect loss is reported before enabling");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(player, true, reason),
        "Missing native effects reject enabling");
    tests\support\checks::expect(player.playerGodmode && !player.PlayerDemiGod,
        "Rejected enabling preserves both God Mode flags");
    tests\support\checks::expect(player.NoExplosiveDamage && player.health == 61,
        "Rejected enabling leaves explosive protection and health unchanged");
}

hook_or_fx_loss_still_allows_disabling_demi_god()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.playerGodmode = true;
    player.health = 73;
    blocked = "Directional feedback is unavailable";

    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(player, false, blocked) == "",
        "A saved setting can be cleared after hook and FX loss");
    tests\support\checks::expect(scripts\apparition\features\demi_god::toggle(player, false, blocked),
        "Hook or FX loss does not block the off transition");
    tests\support\checks::expect(!isDefined(player.PlayerDemiGod),
        "The off transition clears only the saved Demi-God flag");
    tests\support\checks::expect(player.playerGodmode && player.health == 73,
        "Disabling leaves God Mode and health unchanged");
}

enabling_clears_only_the_selected_players_god_mode_flag()
{
    player = spawnstruct();
    other = spawnstruct();
    player.playerGodmode = true;
    player.PlayerDemiGod = false;
    player.NoExplosiveDamage = true;
    player.health = 91;
    other.PlayerDemiGod = true;
    other.playerGodmode = true;

    tests\support\checks::expect(scripts\apparition\features\demi_god::toggle(player, true, ""),
        "An admitted enable changes the selected player");
    tests\support\checks::expect(!isDefined(player.playerGodmode) && player.PlayerDemiGod,
        "Enabling clears God Mode and saves Demi-God on the selected player");
    tests\support\checks::expect(player.NoExplosiveDamage && player.health == 91,
        "Enabling leaves explosive protection and health unchanged");
    tests\support\checks::expect(other.PlayerDemiGod && other.playerGodmode,
        "Enabling does not change another player's protection");
}

disabling_demi_god_leaves_other_flags_and_health_unchanged()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.playerGodmode = true;
    player.NoExplosiveDamage = true;
    player.health = 44;

    tests\support\checks::expect(scripts\apparition\features\demi_god::toggle(player, false, undefined),
        "An enabled Demi-God setting can be cleared with unavailable readiness");
    tests\support\checks::expect(!isDefined(player.PlayerDemiGod),
        "Disabling removes the original Demi-God flag");
    tests\support\checks::expect(player.playerGodmode && player.NoExplosiveDamage && player.health == 44,
        "Disabling does not alter other protections or health");
}

missing_players_cannot_change_demi_god_state()
{
    tests\support\checks::expect(scripts\apparition\features\demi_god::reason(undefined, true, "") != "",
        "A missing player has an admission reason");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(undefined, true, ""),
        "A missing player cannot enable Demi-God");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::toggle(undefined, false, undefined),
        "A missing player cannot disable Demi-God");
}

missing_player_feedback_readiness_stops_before_native_reads()
{
    readiness = scripts\apparition\features\demi_god::feedback_reason(undefined);
    tests\support\checks::expect(isDefined(readiness) && isstring(readiness) && readiness != "",
        "A missing target is rejected before native model, tag, or effect reads");
}

invalid_directions_are_rejected_before_feedback_readiness()
{
    fixture = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\demi_god::feedback(fixture, undefined),
        "An undefined direction is rejected before player admission");
    tests\support\checks::expect(!scripts\apparition\features\demi_god::feedback(fixture, "not a vector"),
        "A non-vector direction is rejected before player admission");
}

a_valid_direction_still_requires_an_admitted_player()
{
    direction = (1, 2, 3);
    tests\support\checks::expect(!scripts\apparition\features\demi_god::feedback(undefined, direction),
        "A typed direction cannot produce feedback for a missing player");
}
