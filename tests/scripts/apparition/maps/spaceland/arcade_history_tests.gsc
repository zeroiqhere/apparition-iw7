// Arcade history reports observed native game events without inferring their source

run()
{
    catalog_matches_the_native_arcade_game_order();
    registered_entry_requires_the_native_quest_table();
    native_entry_matches_only_the_canonical_arcade_callback();
    malformed_native_entry_and_watch_types_are_rejected();
    begin_requires_current_ready_early_coverage();
    changed_registry_identity_invalidates_history_ownership();
    valid_stage_three_events_are_deduplicated();
    invalid_or_out_of_stage_events_are_ignored();
    native_progression_ends_arcade_listener_ownership();
    inspect_reports_unknown_pending_observed_and_completed();
    inspect_handles_missing_and_malformed_quest_shapes();
    inspect_does_not_change_the_watch_or_native_quest();
    listener_ready_before_event_and_retirement_cancels_it();
    stopping_the_parent_removes_its_ready_capture_child();
    unavailable_watch_cannot_start_a_late_listener();
}

native_progression_ends_arcade_listener_ownership()
{
    state = active_watch(2);
    watch = state.apparition_arcade_history;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "A covered watch remains live before the arcade stage");

    state._id_13F1B["ghost"] = 3;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "The observer remains live while native arcade events are expected");

    state._id_13F1B["ghost"] = 4;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "Native progression past step three ends listener ownership");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::inspect(state).count == 5, "Native completion remains visible after its event listener retires");
}

catalog_matches_the_native_arcade_game_order()
{
    games = scripts\apparition\maps\spaceland\arcade_history::catalog();
    expected_ids = ["zombie_zoom", "bowling_for_planets", "rings_of_saturn", "cryptid_attack", "black_hole"];
    expected_labels = ["Zombie Zoom", "Bowling for Planets", "Rings of Saturn", "Cryptid Attack", "Black Hole"];

    tests\support\checks::expect(games.size == expected_ids.size, "The arcade catalog contains all five native games");
    for (index = 0; index < expected_ids.size; index++)
    {
        tests\support\checks::expect(games[index].id == expected_ids[index], "Arcade ids keep the native callback order");
        tests\support\checks::expect(games[index].label == expected_labels[index], "Arcade labels match the native game names");
    }
}

registered_entry_requires_the_native_quest_table()
{
    state = tests\fixtures\ghosts::quest(2);
    expected = state._id_13F4D["ghost"][3];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::registered_entry(state) == expected, "The arcade observer reads the registered native step-three entry");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\arcade_history::registered_entry(spawnstruct())), "A missing native quest table is not treated as an arcade entry");

    state._id_13F4D["ghost"] = [];
    state._id_13F4D["ghost"][0] = expected;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\arcade_history::registered_entry(state)), "A short native quest table cannot supply step three");

    state = tests\fixtures\ghosts::quest(2);
    state._id_13F4D["ghost"][3] = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\arcade_history::registered_entry(state)), "An undefined arcade slot is not accepted");
}

native_entry_matches_only_the_canonical_arcade_callback()
{
    expected = scripts\apparition\maps\spaceland\ghosts::catalog()[3];
    entry = spawnstruct();
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    entry._id_DB5D = expected.body;
    entry._id_446D = expected.complete;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::native_entry(entry), "The exact native arcade body and completion callback are recognized");

    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::native_entry(entry), "A foreign arcade body is rejected");
    entry._id_DB5D = expected.body;
    entry.init_func = expected.body;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::native_entry(entry), "A foreign quest initializer is rejected");
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::native_entry(entry), "A foreign arcade completion callback is rejected");
}

malformed_native_entry_and_watch_types_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::native_entry(7), "A scalar cannot be treated as a native callback struct");

    state = tests\fixtures\ghosts::quest(2);
    state.apparition_arcade_history = 7;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::begin(state, 7), "A scalar current watch is rejected before field access");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, 7), "A scalar watch cannot own a native registry entry");
}

begin_requires_current_ready_early_coverage()
{
    state = tests\fixtures\ghosts::quest(2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::begin(state, watch), "An observer cannot begin before its event listener is ready");
    watch.waiting = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::begin(state, watch), "A ready observer can establish coverage before the arcade stage");
    tests\support\checks::expect(watch.state == "Listening" && !watch.waiting && watch.entry == state._id_13F4D["ghost"][3], "Beginning retains the exact entry and clears the handshake marker");

    state = tests\fixtures\ghosts::quest(3);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    watch.waiting = true;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::begin(state, watch), "Starting at the arcade stage is too late to claim complete history");

    state = tests\fixtures\ghosts::quest(2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    watch.waiting = true;
    state.apparition_arcade_history = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::begin(state, watch), "A replaced current watch cannot be started");
}

changed_registry_identity_invalidates_history_ownership()
{
    state = active_watch(2);
    watch = state.apparition_arcade_history;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "The captured native entry remains owned while it is unchanged");

    replacement_state = tests\fixtures\ghosts::quest(2);
    state._id_13F4D["ghost"][3] = replacement_state._id_13F4D["ghost"][3];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "A same-shaped replacement entry cannot inherit history ownership");

    state = active_watch(2);
    watch = state.apparition_arcade_history;
    state._id_13F4D["ghost"][3]._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "A changed native callback invalidates the captured entry");

    state = active_watch(2);
    watch = state.apparition_arcade_history;
    state.apparition_arcade_history = scripts\apparition\maps\spaceland\arcade_history::create();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "A stale observer cannot own a replaced map watch");
}

valid_stage_three_events_are_deduplicated()
{
    state = active_watch(3);
    watch = state.apparition_arcade_history;
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "zombie_zoom");
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "zombie_zoom");
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "black_hole");

    tests\support\checks::expect(isDefined(watch.seen["zombie_zoom"]) && isDefined(watch.seen["black_hole"]), "Known native arcade ids are retained as observations");
    tests\support\checks::expect(watch.seen.size == 2, "Repeated event ids do not inflate observed game count");
    tests\support\checks::expect(state._id_13F1B["ghost"] == 3, "Arcade observation does not write native quest progress");
}

invalid_or_out_of_stage_events_are_ignored()
{
    state = active_watch(3);
    watch = state.apparition_arcade_history;
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "made_up_game");
    tests\support\checks::expect(watch.seen.size == 0, "Unknown ids are not stored");

    state._id_13F1B["ghost"] = 2;
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "zombie_zoom");
    state._id_13F1B["ghost"] = 4;
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "bowling_for_planets");
    tests\support\checks::expect(watch.seen.size == 0, "Events outside native step three do not become game results");

    watch.state = "Unavailable";
    state._id_13F1B["ghost"] = 3;
    scripts\apparition\maps\spaceland\arcade_history::observe(state, watch, "rings_of_saturn");
    tests\support\checks::expect(watch.seen.size == 0, "A retired observer cannot collect later arcade events");
}

inspect_reports_unknown_pending_observed_and_completed()
{
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(spawnstruct());
    tests\support\checks::expect(snapshot.reason != "" && snapshot.count == -1, "An invalid quest table reports unknown history");
    expect_all_statuses(snapshot, "Unknown");

    state = tests\fixtures\ghosts::quest(2);
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.reason == "" && snapshot.count == 0, "A valid pre-arcade quest stage reports no games started");
    expect_all_statuses(snapshot, "Not Started");

    state = active_watch(3);
    watch = state.apparition_arcade_history;
    watch.seen["zombie_zoom"] = true;
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.reason == "" && snapshot.count == 1, "Covered native step three reports the derived observed count");
    tests\support\checks::expect(game_status(snapshot, "zombie_zoom") == "Observed", "A captured arcade id is marked observed");
    tests\support\checks::expect(game_status(snapshot, "black_hole") == "Pending", "An uncaptured game is pending only with early coverage");

    state = tests\fixtures\ghosts::quest(4);
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.reason == "" && snapshot.count == 5, "Native progression beyond step three proves all five game requirements completed");
    expect_all_statuses(snapshot, "Completed");

    state = tests\fixtures\ghosts::quest(3);
    state.apparition_arcade_history = scripts\apparition\maps\spaceland\arcade_history::create();
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.reason != "" && snapshot.count == -1, "Step three without a prior active listener remains unknown");
    expect_all_statuses(snapshot, "Unknown");
}

inspect_does_not_change_the_watch_or_native_quest()
{
    state = active_watch(3);
    watch = state.apparition_arcade_history;
    watch.seen["rings_of_saturn"] = true;
    state.gns_active = true;
    old_entry = state._id_13F4D["ghost"][3];
    old_step = state._id_13F1B["ghost"];

    scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(watch.seen.size == 1 && isDefined(watch.seen["rings_of_saturn"]), "Inspection derives output without changing canonical history");
    tests\support\checks::expect(state._id_13F1B["ghost"] == old_step && state._id_13F4D["ghost"][3] == old_entry, "Inspection leaves native quest fields and callback identity untouched");
    tests\support\checks::expect(state.gns_active, "Inspection does not infer or write unrelated Ghosts N Skulls state");
}

inspect_handles_missing_and_malformed_quest_shapes()
{
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(undefined);
    tests\support\checks::expect(snapshot.count == -1 && snapshot.reason != "", "An absent map state reports unknown history without field access");

    state = spawnstruct();
    state._id_13F4D = 7;
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.count == -1 && snapshot.reason != "", "A malformed registry container reports unknown history");

    state = tests\fixtures\ghosts::quest(2);
    state._id_13F1B["ghost"] = "two";
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.count == -1 && snapshot.reason != "", "A nonnumeric native quest step reports unknown history");

    state = tests\fixtures\ghosts::quest(2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    watch.waiting = true;
    scripts\apparition\maps\spaceland\arcade_history::begin(state, watch);
    watch.seen = spawnstruct();
    state._id_13F1B["ghost"] = 3;
    snapshot = scripts\apparition\maps\spaceland\arcade_history::inspect(state);
    tests\support\checks::expect(snapshot.count == -1 && snapshot.reason != "", "A malformed observer history cannot be read as an array");
}

listener_ready_before_event_and_retirement_cancels_it()
{
    state = tests\fixtures\ghosts::quest(2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    state childthread scripts\apparition\maps\spaceland\arcade_history::listen(watch);
    deadline = getTime() + 1000;
    while (!watch.waiting && getTime() < deadline)
        wait 0.05;

    tests\support\checks::expect(watch.waiting, "The event child signals readiness only after it reaches its wait");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::begin(state, watch), "The parent can establish coverage after the listener handshake");
    state._id_13F1B["ghost"] = 3;
    state notify("beat_arcade_game", "zombie_zoom");
    wait 0.05;
    tests\support\checks::expect(isDefined(watch.seen["zombie_zoom"]), "An immediate native event after the handshake is captured");

    state._id_13F1B["ghost"] = 4;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\arcade_history::owned(state, watch), "Native advancement ends ownership of the step-three event listener");
    scripts\apparition\maps\spaceland\arcade_history::retire(watch);
    tests\support\checks::expect(watch.state == "Unavailable", "Retirement marks the captured record unavailable");
    // Restore only fixture admission so a leaked waiter would have an observable effect
    state._id_13F1B["ghost"] = 3;
    watch.state = "Listening";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::owned(state, watch),
        "The post-stop probe admits a result if a waiter incorrectly survived");
    state notify("beat_arcade_game", "bowling_for_planets");
    wait 0.05;
    tests\support\checks::expect(!isDefined(watch.seen["bowling_for_planets"]),
        "Retirement ends the actual waiter independently of the observation admission guard");
    scripts\apparition\maps\spaceland\arcade_history::retire(watch);
}

stopping_the_parent_removes_its_ready_capture_child()
{
    state = tests\fixtures\ghosts::quest(2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    state thread parent_with_arcade_capture(watch);
    deadline = getTime() + 1000;
    while (!watch.waiting && getTime() < deadline)
        wait 0.05;
    tests\support\checks::expect(watch.waiting,
        "The real production capture reaches its wait before the parent is cancelled");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::begin(state, watch),
        "A ready child can establish the normal observation record");
    state._id_13F1B["ghost"] = 3;
    state notify("beat_arcade_game", "zombie_zoom");
    wait 0.05;
    tests\support\checks::expect(isDefined(watch.seen["zombie_zoom"]),
        "The capture records a baseline result while its parent is still alive");
    state notify("test_stop_arcade_parent");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\arcade_history::owned(state, watch),
        "Cancelling the test parent leaves result admission open to expose a leaked child");
    state notify("beat_arcade_game", "black_hole");
    wait 0.05;
    tests\support\checks::expect(!isDefined(watch.seen["black_hole"]),
        "A cancelled parent removes the production capture before a later result can reach it");
    // This also cleans up when a broken child relationship makes the contract fail
    scripts\apparition\maps\spaceland\arcade_history::retire(watch);
    state notify("test_stop_arcade_parent");
}

parent_with_arcade_capture(watch)
{
    self endon("test_stop_arcade_parent");
    self childthread scripts\apparition\maps\spaceland\arcade_history::listen(watch);
    self waittill("test_arcade_parent_lifetime");
}

unavailable_watch_cannot_start_a_late_listener()
{
    state = tests\fixtures\ghosts::quest(3);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    scripts\apparition\maps\spaceland\arcade_history::retire(watch);
    state thread scripts\apparition\maps\spaceland\arcade_history::listen(watch);
    wait 0.05;
    tests\support\checks::expect(watch.state == "Unavailable" && !watch.waiting, "A child scheduled after retirement cannot reopen a listener");
}

active_watch(step)
{
    state = tests\fixtures\ghosts::quest(step < 3 ? step : 2);
    watch = scripts\apparition\maps\spaceland\arcade_history::create();
    state.apparition_arcade_history = watch;
    watch.waiting = true;
    scripts\apparition\maps\spaceland\arcade_history::begin(state, watch);
    state._id_13F1B["ghost"] = step;
    return state;
}

game_status(snapshot, id)
{
    foreach (item in snapshot.games)
    {
        if (item.id == id)
            return item.status;
    }
    return "Missing";
}

expect_all_statuses(snapshot, status)
{
    tests\support\checks::expect(snapshot.games.size == 5, "A snapshot always has one row per arcade game");
    foreach (item in snapshot.games)
        tests\support\checks::expect(item.status == status, "All arcade rows share the expected snapshot status");
}
