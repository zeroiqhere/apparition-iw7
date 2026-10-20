// Flag contracts derived from Apparition's personal toggle and all-player sweep
// These structs exercise flags rather than damage protection or player callbacks
// Compilation is checked separately from executing assertions in the game VM

run()
{
    personal_toggle_enables_an_undefined_god_mode_flag();
    personal_toggle_clears_an_enabled_god_mode_flag();
    enabling_god_mode_clears_an_enabled_demi_god_flag();
    conflicting_enabled_flags_clear_without_recursive_toggles();
    mixed_player_flags_become_all_enabled();
    all_enabled_player_flags_become_all_disabled();
    a_single_listed_player_is_toggled();
    a_sweep_changes_only_its_supplied_player_flags();
    an_empty_or_missing_roster_is_unchecked_and_cannot_toggle();
    non_array_rosters_are_unchecked_and_cannot_toggle();
    hook_loss_allows_disabling_an_enabled_roster();
    hook_loss_rejects_enabling_without_changing_any_player();
    mixed_hook_loss_does_not_partially_change_flags();
    println("Apparition god-mode flag contract reached its final assertion");
}

personal_toggle_enables_an_undefined_god_mode_flag()
{
    player = spawnstruct();
    scripts\apparition\features\god_mode::toggle_player(player);

    tests\support\checks::expect(isDefined(player.playerGodmode) && player.playerGodmode, "Personal toggle enables an initially undefined god-mode flag");
}

personal_toggle_clears_an_enabled_god_mode_flag()
{
    player = spawnstruct();
    player.playerGodmode = true;
    scripts\apparition\features\god_mode::toggle_player(player);

    // Apparition uses undefined for the disabled result of BoolVar
    tests\support\checks::expect(!isDefined(player.playerGodmode), "Personal toggle clears the enabled flag");
}

enabling_god_mode_clears_an_enabled_demi_god_flag()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    scripts\apparition\features\god_mode::toggle_player(player);

    // This starts from a reachable state with only demi-god enabled
    tests\support\checks::expect(!isDefined(player.PlayerDemiGod), "Enabling god mode first clears demi-god");
    tests\support\checks::expect(isDefined(player.playerGodmode) && player.playerGodmode, "God mode is enabled after demi-god is cleared");
}

conflicting_enabled_flags_clear_without_recursive_toggles()
{
    player = spawnstruct();
    player.playerGodmode = true;
    player.PlayerDemiGod = true;

    // This is a robustness fix for an inconsistent state in the original source
    scripts\apparition\features\god_mode::toggle_player(player);
    tests\support\checks::expect(!isDefined(player.playerGodmode), "Toggling an active god-mode flag clears it");
    tests\support\checks::expect(!isDefined(player.PlayerDemiGod), "The conflicting demi-god flag is also cleared");
}

mixed_player_flags_become_all_enabled()
{
    first = spawnstruct();
    second = spawnstruct();
    third = spawnstruct();
    second.playerGodmode = true;
    third.PlayerDemiGod = true;
    players = [];
    players[0] = first;
    players[1] = second;
    players[2] = third;

    tests\support\checks::expect(!scripts\apparition\features\god_mode::all_enabled(players), "Mixed flags are not reported as all enabled");
    scripts\apparition\features\god_mode::toggle(players, true);

    // The existing enabled flag must not be toggled back off during this sweep
    tests\support\checks::expect(isDefined(first.playerGodmode) && first.playerGodmode, "The first disabled flag is enabled");
    tests\support\checks::expect(isDefined(second.playerGodmode) && second.playerGodmode, "The existing enabled flag stays enabled");
    tests\support\checks::expect(isDefined(third.playerGodmode) && third.playerGodmode, "The demi-god player receives god mode");
    tests\support\checks::expect(!isDefined(third.PlayerDemiGod), "The sweep clears demi-god before enabling god mode");
    tests\support\checks::expect(scripts\apparition\features\god_mode::all_enabled(players), "The resulting flags are reported as all enabled");
}

all_enabled_player_flags_become_all_disabled()
{
    first = spawnstruct();
    second = spawnstruct();
    first.playerGodmode = true;
    second.playerGodmode = true;
    players = [];
    players[0] = first;
    players[1] = second;
    scripts\apparition\features\god_mode::toggle(players, true);

    tests\support\checks::expect(!isDefined(first.playerGodmode), "An all-enabled sweep clears the first flag");
    tests\support\checks::expect(!isDefined(second.playerGodmode), "An all-enabled sweep clears the second flag");
    tests\support\checks::expect(!scripts\apparition\features\god_mode::all_enabled(players), "The disabled roster is not reported as all enabled");
}

a_single_listed_player_is_toggled()
{
    player = spawnstruct();
    players = [];
    players[0] = player;
    scripts\apparition\features\god_mode::toggle(players, true);

    // This covers a one-entry roster; host membership needs a game integration test
    tests\support\checks::expect(isDefined(player.playerGodmode) && player.playerGodmode, "A sweep enables its single listed player");
    scripts\apparition\features\god_mode::toggle(players, true);
    tests\support\checks::expect(!isDefined(player.playerGodmode), "A second sweep disables its single listed player");
}

a_sweep_changes_only_its_supplied_player_flags()
{
    listed = spawnstruct();
    unlisted = spawnstruct();
    players = [];
    players[0] = listed;
    scripts\apparition\features\god_mode::toggle(players, true);

    tests\support\checks::expect(isDefined(listed.playerGodmode) && listed.playerGodmode, "The listed player flag is changed");
    tests\support\checks::expect(!isDefined(unlisted.playerGodmode), "An unlisted player flag is unchanged");
}

an_empty_or_missing_roster_is_unchecked_and_cannot_toggle()
{
    players = [];
    tests\support\checks::expect(!scripts\apparition\features\god_mode::all_enabled(players), "An empty roster cannot advertise configured protection");
    tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle(players, true), "An empty sweep cannot report a successful setting change");
    tests\support\checks::expect(players.size == 0, "An empty sweep adds no players or flags");
    tests\support\checks::expect(!scripts\apparition\features\god_mode::all_enabled(undefined), "An unavailable roster is unchecked");
    tests\support\checks::expect(scripts\apparition\features\god_mode::reason(undefined, true) == "No current players are available", "An unavailable roster has a visible admission reason");
    tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle(undefined, true), "An unavailable roster cannot be mutated");
}

non_array_rosters_are_unchecked_and_cannot_toggle()
{
    // Scalars cannot stand in for the current actor selection
    foreach (players in ["invalid roster", 7, false, spawnstruct()])
    {
        tests\support\checks::expect(!scripts\apparition\features\god_mode::all_enabled(players), "A non-array roster is never checked");
        tests\support\checks::expect(scripts\apparition\features\god_mode::reason(players, true) == "Wait for a valid player roster", "A non-array roster names the invalid selection");
        tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle(players, true), "A non-array roster cannot report a successful flag change");
        tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle(players, false), "Hook loss cannot admit an invalid selection");
    }
}

hook_loss_allows_disabling_an_enabled_roster()
{
    first = spawnstruct();
    second = spawnstruct();
    first.playerGodmode = true;
    second.playerGodmode = true;
    players = [first, second];
    tests\support\checks::expect(scripts\apparition\features\god_mode::reason(players, false) == "", "An enabled roster may clear its saved setting without the damage hook");
    tests\support\checks::expect(scripts\apparition\features\god_mode::toggle(players, false), "An authorized off transition does not need a working damage hook");
    tests\support\checks::expect(!isDefined(first.playerGodmode) && !isDefined(second.playerGodmode), "Hook-loss cleanup clears every supplied enabled setting");
}

hook_loss_rejects_enabling_without_changing_any_player()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    tests\support\checks::expect(scripts\apparition\features\god_mode::reason([player], false) == "Enable requires the active Apparition damage callback", "Enabling names the missing native damage hook");
    tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle([player], false), "A lost hook rejects a new saved God Mode setting");
    tests\support\checks::expect(!isDefined(player.playerGodmode) && player.PlayerDemiGod, "Rejected admission cannot clear another setting or enable God Mode");
}

mixed_hook_loss_does_not_partially_change_flags()
{
    off = spawnstruct();
    on = spawnstruct();
    on.playerGodmode = true;
    players = [off, on];
    tests\support\checks::expect(!scripts\apparition\features\god_mode::toggle(players, false), "A mixed roster still requests enable-all and needs the active hook");
    tests\support\checks::expect(!isDefined(off.playerGodmode) && on.playerGodmode, "A rejected mixed sweep leaves both flags unchanged");
    tests\support\checks::expect(scripts\apparition\features\god_mode::toggle([on], false) && !isDefined(on.playerGodmode), "The configured member can be cleared through its personal scope");
}
