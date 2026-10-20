// The callback router is checked without replacing a live game callback

run()
{
    capture_precedes_the_original_callback_and_preserves_receiver_and_actor();
    an_unsupported_session_forwards_without_replacing_saved_perks();
    a_disabled_target_forwards_without_creating_retention();
    arcade_inventory_preserves_saved_perks_and_forwards_once();
    non_arcade_protection_markers_do_not_skip_a_new_normal_down();
    an_arcade_down_without_a_prior_snapshot_keeps_it_empty();
}

capture_precedes_the_original_callback_and_preserves_receiver_and_actor()
{
    owner = spawnstruct();
    player = tests\fixtures\perks::retaining_player(["perk_machine_tough"]);
    player.original_calls = 0;
    owner scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
    tests\support\checks::expect(player.original_calls == 1 && player.original_actor == player, "The saved callback receives the exact actor once");
    tests\support\checks::expect(player.original_receiver == owner, "The callback router preserves its inherited receiver");
    tests\support\checks::expect(player.apparition_perk_retention.saved.size == 1 && player.apparition_perk_retention.saved[0] == "perk_machine_tough", "Capture precedes removal by the original callback");
    tests\support\checks::expect(!isDefined(player.zombies_perks["perk_machine_tough"]), "The original callback still performs its normal work");
}

an_unsupported_session_forwards_without_replacing_saved_perks()
{
    player = tests\fixtures\perks::retaining_player(["perk_machine_tough"]);
    player.apparition_perk_retention.saved = ["perk_machine_revive"];
    player.original_calls = 0;
    scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, false);
    tests\support\checks::expect(player.original_calls == 1, "An unsupported session still delegates exactly once");
    tests\support\checks::expect(player.apparition_perk_retention.saved.size == 1 && player.apparition_perk_retention.saved[0] == "perk_machine_revive", "An unsupported session cannot overwrite saved perks");
}

a_disabled_target_forwards_without_creating_retention()
{
    player = tests\fixtures\perks::owned_player(["perk_machine_tough"]);
    player.original_calls = 0;
    scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
    tests\support\checks::expect(player.original_calls == 1 && !isDefined(player.apparition_perk_retention), "A disabled target keeps native behavior without a new record");
}

arcade_inventory_preserves_saved_perks_and_forwards_once()
{
    owner = spawnstruct();
    player = tests\fixtures\perks::retaining_player(["perk_machine_more"]);
    record = player.apparition_perk_retention;
    record.saved = ["perk_machine_revive", "perk_machine_tough"];
    player.playing_ghosts_n_skulls = 1;
    player.dontremoveperks = 1;
    player.original_calls = 0;
    owner scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
    tests\support\checks::expect(player.original_calls == 1
        && player.original_receiver == owner && player.original_actor == player,
        "Arcade capture still forwards the exact stock actor and receiver once");
    tests\support\checks::expect(player.apparition_perk_retention == record
        && record.saved.size == 2 && record.saved[0] == "perk_machine_revive"
        && record.saved[1] == "perk_machine_tough",
        "The GNS inventory cannot replace the last saved normal perks");
    tests\support\checks::expect(player.zombies_perks["perk_machine_more"] == 1
        && player.playing_ghosts_n_skulls == 1 && player.dontremoveperks == 1,
        "Skipped capture leaves current inventory and native markers unchanged");

    // Native restoration clears its own markers before normal capture resumes
    player.playing_ghosts_n_skulls = undefined;
    player.dontremoveperks = undefined;
    player.zombies_perks["perk_machine_more"] = undefined;
    player.zombies_perks["perk_machine_tough"] = 1;
    owner scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
    tests\support\checks::expect(player.original_calls == 2,
        "The next normal down still delegates exactly once");
    tests\support\checks::expect(record.saved.size == 1 && record.saved[0] == "perk_machine_tough",
        "The next normal down replaces the previous snapshot before the original callback");
    tests\support\checks::expect(!isDefined(player.zombies_perks["perk_machine_tough"]),
        "The original callback remains active after the arcade marker clears");
}

non_arcade_protection_markers_do_not_skip_a_new_normal_down()
{
    foreach (flags in [[1, 0], [0, 1], [1, 1]])
    {
        owner = spawnstruct();
        player = tests\fixtures\perks::retaining_player(["perk_machine_tough", "perk_machine_smack"]);
        player.dontremoveperks = flags[0];
        player.keep_perks = flags[1];
        player.playing_ghosts_n_skulls = 0;
        player.apparition_perk_retention.saved = ["perk_machine_revive"];
        player.original_calls = 0;
        owner scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
        saved = player.apparition_perk_retention.saved;
        tests\support\checks::expect(saved.size == 2 && saved[0] == "perk_machine_tough"
            && saved[1] == "perk_machine_smack",
            "Normal protected or pending-reapply inventory still refreshes newly owned perks");
        tests\support\checks::expect(player.original_calls == 1 && player.original_receiver == owner
            && player.original_actor == player && !isDefined(player.zombies_perks["perk_machine_tough"]),
            "Normal capture precedes the exact delegated fixture callback");
        tests\support\checks::expect(player.dontremoveperks == flags[0] && player.keep_perks == flags[1],
            "Read-only capture preserves native protection and pending-reapply markers");
    }
}

an_arcade_down_without_a_prior_snapshot_keeps_it_empty()
{
    player = tests\fixtures\perks::retaining_player(["perk_machine_more"]);
    player.playing_ghosts_n_skulls = 1;
    player.original_calls = 0;
    scripts\apparition\runtime\perk_retention::route(player, ::remove_inventory, true);
    tests\support\checks::expect(player.apparition_perk_retention.saved.size == 0 && player.original_calls == 1,
        "An arcade down cannot create a temporary saved selection before the first normal capture");
}

remove_inventory(player)
{
    player.original_calls++;
    player.original_actor = player;
    player.original_receiver = self;
    // Isolated fixture work makes capture ordering observable in a later VM run
    player.zombies_perks["perk_machine_tough"] = undefined;
}
