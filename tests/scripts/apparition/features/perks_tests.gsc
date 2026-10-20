// Ownership and life admission are checked without running native perk effects

run()
{
    missing_native_inventory_is_not_reported_as_owned();
    inventory_reason_accepts_missing_and_array_inventory_only();
    malformed_inventory_is_rejected_before_ownership_indexing();
    all_owned_rejects_non_array_rosters_and_selections();
    owns_rejects_malformed_ids_before_inventory_indexing();
    every_selected_perk_owned_by_every_player_is_all_owned();
    matching_array_size_with_a_missing_perk_is_not_all_owned();
    a_zero_native_perk_value_is_not_owned();
    a_mixed_roster_is_not_all_owned();
    an_empty_roster_or_selection_is_not_all_owned();
    complete_selected_callbacks_are_ready();
    missing_set_or_unset_in_any_selected_callback_blocks_the_batch();
    callback_readiness_checks_only_the_selected_ids();
    missing_callback_data_or_selection_is_not_ready();
    callback_container_and_entry_shapes_are_rejected_before_field_reads();
    malformed_selected_ids_are_rejected_before_native_table_indexing();
    an_empty_roster_is_rejected_before_native_player_checks();
    normal_life_allows_native_perk_changes();
    dead_or_spectating_players_cannot_change_native_perks();
    last_stand_blocks_native_perk_changes_even_when_alive();
    every_native_temporary_perk_marker_blocks_changes_independently();
    per_player_temporary_perk_markers_survive_global_teardown();
    native_preservation_blocks_changes_without_other_temporary_markers();
    undefined_and_zero_temporary_perk_markers_allow_normal_changes();
}

normal_life_allows_native_perk_changes()
{
    tests\support\checks::expect(scripts\apparition\features\perks::life_reason(true, false) == "",
        "A living non-spectator player outside last stand can change native perks");
    tests\support\checks::expect(scripts\apparition\features\perks::life_reason(true, undefined) == "",
        "A missing last-stand flag does not block an otherwise living player");
}

dead_or_spectating_players_cannot_change_native_perks()
{
    tests\support\checks::expect(scripts\apparition\features\perks::life_reason(false, false)
        == "Players must be alive and out of spectator mode for native perk changes",
        "Native death or a spectator session blocks immediate perk changes");
    tests\support\checks::expect(scripts\apparition\features\perks::life_reason(false, true)
        == "Players must be alive and out of spectator mode for native perk changes",
        "Native life admission precedes a stale last-stand flag");
}

last_stand_blocks_native_perk_changes_even_when_alive()
{
    tests\support\checks::expect(scripts\apparition\features\perks::life_reason(true, 1)
        == "Wait until players are out of last stand for native perk changes",
        "A positive native life result cannot bypass a current last stand");
}

every_native_temporary_perk_marker_blocks_changes_independently()
{
    reason = "Wait until native temporary perk handling is finished";
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(1, 0, 0, 0) == reason,
        "The native Ghosts N Skulls phase blocks immediate perk changes");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(0, 1, 0, 0) == reason,
        "A player's active Ghosts N Skulls marker blocks immediate perk changes");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(0, 0, 1, 0) == reason,
        "A player's native perk-retention marker blocks immediate perk changes");
}

per_player_temporary_perk_markers_survive_global_teardown()
{
    reason = "Wait until native temporary perk handling is finished";
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(0, 1, undefined, 0) == reason,
        "A per-player arcade marker still blocks changes after the global marker clears");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(undefined, undefined, 1, undefined) == reason,
        "A per-player perk-retention marker blocks changes after global teardown");
}

undefined_and_zero_temporary_perk_markers_allow_normal_changes()
{
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(undefined, undefined, undefined, undefined) == "",
        "Native startup without temporary markers allows normal perk changes");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(0, 0, 0, 0) == "",
        "Cleared native temporary markers allow normal perk changes");
}

native_preservation_blocks_changes_without_other_temporary_markers()
{
    reason = "Native perk preservation is pending; another spawn may be needed";
    // The native marker can remain set after a revive, before a later loadout
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(0, 0, 0, 1) == reason,
        "Native preservation blocks immediate perk changes with a specific pending-loadout reason");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(undefined, undefined, undefined, 1) == reason,
        "Native preservation does not depend on defined arcade markers");
    tests\support\checks::expect(scripts\apparition\features\perks::temporary_reason(1, 0, 0, 1)
        == "Wait until native temporary perk handling is finished",
        "The existing active arcade reason takes precedence over pending native preservation");
}

missing_native_inventory_is_not_reported_as_owned()
{
    player = spawnstruct();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([player], ids), "Missing native inventory is not all perks");
    tests\support\checks::expect(!scripts\apparition\features\perks::owns(undefined, ids[0]), "A departed player has no readable perk inventory");
}

every_selected_perk_owned_by_every_player_is_all_owned()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    first = tests\fixtures\perks::owned_player(ids);
    second = tests\fixtures\perks::owned_player(ids);
    tests\support\checks::expect(scripts\apparition\features\perks::all_owned([first, second], ids), "Every selected native perk is owned by the whole roster");
    tests\support\checks::expect(scripts\apparition\features\perks::all_owned([first], [ids[0]]), "The same ownership rule handles one player and one perk");
}

matching_array_size_with_a_missing_perk_is_not_all_owned()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    selected = [];
    for (index = 1; index < ids.size; index++)
        selected[selected.size] = ids[index];
    player = tests\fixtures\perks::owned_player(selected);

    // Equal counts cannot prove that the supported perk identities match
    player.zombies_perks["unrelated_perk"] = 1;
    tests\support\checks::expect(player.zombies_perks.size == ids.size, "The regression fixture keeps the same inventory size");
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([player], ids), "A missing supported perk is detected despite equal counts");
}

a_zero_native_perk_value_is_not_owned()
{
    player = tests\fixtures\perks::owned_player([]);
    player.zombies_perks["perk_machine_tough"] = 0;
    tests\support\checks::expect(!scripts\apparition\features\perks::owns(player, "perk_machine_tough"), "A zero inventory value is not an owned perk");
}

a_mixed_roster_is_not_all_owned()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    first = tests\fixtures\perks::owned_player(ids);
    second = tests\fixtures\perks::owned_player([]);
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([first, second], [ids[0]]), "A mixed roster does not display an owned lobby perk");
    second.zombies_perks[ids[0]] = 1;
    tests\support\checks::expect(scripts\apparition\features\perks::all_owned([first, second], [ids[0]]), "Uniform ownership displays the lobby perk as owned");
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([first], ["unrelated_perk"]), "Unrelated IDs are not inferred from other inventory entries");
}

an_empty_roster_or_selection_is_not_all_owned()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    player = tests\fixtures\perks::owned_player(ids);
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([], ids), "An empty roster never displays a checked perk row");
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned(undefined, ids), "An unavailable roster is not all owned");
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([player], []), "An empty selection has no ownership claim");
    tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([player], undefined), "An unavailable selection has no ownership claim");
}

complete_selected_callbacks_are_ready()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    registry = tests\fixtures\perks::callbacks(ids);
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ids) == "", "All selected native set and unset callbacks are ready");
}

missing_set_or_unset_in_any_selected_callback_blocks_the_batch()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    foreach (perk_id in ids)
    {
        // Every position is checked so a late missing callback cannot follow changes
        registry = tests\fixtures\perks::callbacks(ids);
        registry[perk_id].set = undefined;
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ids) == "Wait for native perk callbacks", "A missing selected set callback blocks the entire selection");
        registry = tests\fixtures\perks::callbacks(ids);
        registry[perk_id].unset = undefined;
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ids) == "Wait for native perk callbacks", "A missing selected unset callback blocks the entire selection");
    }
}

callback_readiness_checks_only_the_selected_ids()
{
    registry = tests\fixtures\perks::callbacks(["perk_machine_tough"]);
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ["perk_machine_tough"]) == "", "A single ready perk does not require unrelated callbacks");
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ["unknown_perk"]) == "Wait for native perk callbacks", "An unknown perk cannot pass callback admission");
}

missing_callback_data_or_selection_is_not_ready()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(undefined, ids) == "Wait for native perk callbacks", "An unavailable native registry blocks the batch");
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason([], ids) == "Wait for native perk callbacks", "An empty native registry blocks the batch");
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(undefined, []) == "No perks selected", "An empty selection reports its own admission reason");
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(undefined, undefined) == "No perks selected", "An unavailable selection cannot be applied");
}

callback_container_and_entry_shapes_are_rejected_before_field_reads()
{
    ids = ["perk_machine_tough", "perk_machine_run"];
    foreach (invalid in [0, "registry", (1, 2, 3), spawnstruct(), tests\fixtures\perks::callback])
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(invalid, ids)
            == "Wait for native perk callbacks", "Only the native array registry may be indexed for selected callbacks");
    foreach (invalid in [0, "entry", (1, 2, 3), [], tests\fixtures\perks::callback])
    {
        registry = tests\fixtures\perks::callbacks(ids);
        // A valid prefix must not hide a malformed later callback record
        registry[ids[1]] = invalid;
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ids)
            == "Wait for native perk callbacks", "A malformed selected entry blocks the whole batch before member access");
    }
    registry = tests\fixtures\perks::callbacks(ids);
    registry["unrelated"] = "untouched";
    tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ids) == ""
        && registry["unrelated"] == "untouched", "Unselected entries remain untouched and do not block a ready selected pair");
}

malformed_selected_ids_are_rejected_before_native_table_indexing()
{
    registry = tests\fixtures\perks::callbacks(["perk_machine_tough"]);
    foreach (invalid in [0, "perk_machine_tough", (1, 2, 3), spawnstruct(), tests\fixtures\perks::callback])
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, invalid)
            == "No perks selected", "A scalar or object cannot replace the selected-ID array");
    foreach (invalid in [0, "", (1, 2, 3), [], spawnstruct(), tests\fixtures\perks::callback])
        tests\support\checks::expect(scripts\apparition\features\perks::callback_reason(registry, ["perk_machine_tough", invalid])
            == "Wait for native perk callbacks", "A malformed later ID blocks indexing even when the first selected callback is ready");
}

an_empty_roster_is_rejected_before_native_player_checks()
{
    // Empty inputs exercise admission without passing fake actors to game natives
    tests\support\checks::expect(scripts\apparition\features\perks::roster_reason([]) == "No current players are available", "An empty roster has a visible admission reason");
    tests\support\checks::expect(scripts\apparition\features\perks::roster_reason(undefined) == "No current players are available", "An unavailable roster has the same admission reason");
}

inventory_reason_accepts_missing_and_array_inventory_only()
{
    tests\support\checks::expect(scripts\apparition\features\perks::inventory_reason(undefined) == "",
        "Missing native inventory remains valid before the native grant initializes it");
    tests\support\checks::expect(scripts\apparition\features\perks::inventory_reason([]) == "",
        "The stock array inventory is admitted");
    foreach (invalid in [0, "inventory", (1, 2, 3), spawnstruct()])
        tests\support\checks::expect(scripts\apparition\features\perks::inventory_reason(invalid)
            == "Wait for native perk inventory", "A defined non-array inventory blocks native perk changes");
}

malformed_inventory_is_rejected_before_ownership_indexing()
{
    perk_id = "perk_machine_tough";
    foreach (invalid in [0, "inventory", (1, 2, 3), spawnstruct()])
    {
        player = tests\fixtures\perks::owned_player([perk_id]);
        player.zombies_perks = invalid;
        tests\support\checks::expect(!scripts\apparition\features\perks::owns(player, perk_id),
            "A malformed inventory cannot be indexed as a native perk array");
    }
}

all_owned_rejects_non_array_rosters_and_selections()
{
    player = tests\fixtures\perks::owned_player(["perk_machine_tough"]);
    foreach (invalid in [0, "players", (1, 2, 3), spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\perks::all_owned(invalid, ["perk_machine_tough"]),
            "Only an array roster can claim shared perk ownership");
    foreach (invalid in [0, "perk_machine_tough", (1, 2, 3), spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\perks::all_owned([player], invalid),
            "Only an array selection can claim shared perk ownership");
}

owns_rejects_malformed_ids_before_inventory_indexing()
{
    player = tests\fixtures\perks::owned_player(["perk_machine_tough"]);
    foreach (invalid in [0, "", (1, 2, 3), [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\perks::owns(player, invalid),
            "Only a nonempty string perk ID can index native inventory");
}
