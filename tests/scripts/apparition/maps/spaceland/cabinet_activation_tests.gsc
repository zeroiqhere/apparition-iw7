// Cabinet snapshots inspect native requirements without issuing game input

run()
{
    initial_scope_requires_the_final_stage_and_normal_live_marker();
    completed_or_changed_initial_routes_do_not_show_a_hold_snapshot();
    retry_scope_requires_the_current_observed_attempt_and_marker();
    native_member_checks_keep_their_order_and_inclusive_radius();
    missing_position_or_input_never_reports_a_passing_member();
}

initial_scope_requires_the_final_stage_and_normal_live_marker()
{
    state = tests\fixtures\ghosts::activation(false);
    result = scripts\apparition\maps\spaceland\cabinet_activation::scope(state);
    tests\support\checks::expect(result.reason == "" && result.route == "Initial Unlock",
        "The known final step and normal marker expose an initial requirements snapshot");
    tests\support\checks::expect(state._id_13F1B["ghost"] == 6
        && state.gns_game_console_vfx.origin == (2859, -553, 286),
        "Inspecting the initial route changes no quest or effect fields");

    foreach (origin in [(5459, -4767, 29), (2859, -553, 287), "invalid"])
    {
        state.gns_game_console_vfx.origin = origin;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
            "A card marker, moved marker or malformed marker cannot identify the normal hold");
    }
    state.gns_game_console_vfx = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "A missing or normally deleted marker hides stale final-step readiness");
}

completed_or_changed_initial_routes_do_not_show_a_hold_snapshot()
{
    state = tests\fixtures\ghosts::activation(false);
    state._id_13F1B["ghost"] = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "The Brute stage cannot expose final cabinet hold data");
    state = tests\fixtures\ghosts::activation(false);
    state.gns_active = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "An active native arena does not look like a pending cabinet hold");
    state = tests\fixtures\ghosts::activation(false);
    watch = spawnstruct();
    watch.observed = false;
    state.apparition_ghost_history = watch;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_history::install(state, watch),
        "The initial completion receipt fixture owns the exact native callback");
    watch.observed = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "An observed initial activation cannot be reopened by a leftover marker");
    state = tests\fixtures\ghosts::activation(false);
    state._id_13F4D["ghost"][6]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "Changed native registration blocks cabinet requirements data");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(spawnstruct()).reason != "",
        "An uninitialized quest cannot expose a cabinet hold snapshot");
}

retry_scope_requires_the_current_observed_attempt_and_marker()
{
    state = tests\fixtures\ghosts::activation(true);
    result = scripts\apparition\maps\spaceland\cabinet_activation::scope(state);
    tests\support\checks::expect(result.reason == "" && result.route == "Reactivation",
        "A current observed retry at its final step has a distinct route");
    state._id_13F1B["reactivateghost"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "A retry waiting for a Brute hit cannot borrow the initial final-step index");
    state = tests\fixtures\ghosts::activation(true);
    state.apparition_reactivation_history.attempt.ready = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "An unsettled retry cannot expose a hold snapshot");
    state = tests\fixtures\ghosts::activation(true);
    state.apparition_reactivation_history.attempt.activation = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "A replaced activation entry invalidates the observed retry identity");
    state = tests\fixtures\ghosts::activation(true);
    state.ghost_n_skull_reactivate_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "Lost callback ownership cannot fall back to the old initial route");
    state = tests\fixtures\ghosts::activation(true);
    state.gns_game_console_vfx = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::scope(state).reason != "",
        "A retry index that persists after normal completion needs its live marker");
}

native_member_checks_keep_their_order_and_inclusive_radius()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        (2874, -542, 242), undefined, undefined, 1) == "",
        "Unset native last-stand and carrying flags have the stock false meaning");
    foreach (origin in [(2924, -542, 242), (2874, -492, 242), (2874, -542, 292)])
        tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
            origin, false, false, 1) == "", "The exact 50-unit native boundary passes on every axis");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        (2924.1, -542, 242), false, false, 1) == "Move within 50 units of the cabinet corner",
        "A point just beyond the native radius fails");
    // Earlier native blockers retain priority when several conditions fail
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        undefined, true, true, 0) == "Leave last stand", "Last stand is the first native blocker");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        undefined, false, true, 0) == "Finish carrying the current item", "Carrying precedes position and Use checks");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        (3000, -542, 242), false, false, 0) == "Move within 50 units of the cabinet corner",
        "Distance precedes the released Use button");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        (2874, -542, 242), false, false, 0) == "Hold [{+activate}]",
        "A nearby unburdened player still needs the native Use input");
}

missing_position_or_input_never_reports_a_passing_member()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        undefined, false, false, 1) == "Wait for native player position", "An absent position stays unknown");
    foreach (origin in ["position", 0])
        tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
            origin, false, false, 1) == "Wait for native player position", "Missing or malformed positions stay unknown");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\cabinet_activation::member_reason(
        (2874, -542, 242), false, false, undefined) == "Wait for native Use input",
        "Missing input data is distinct from an observed released button");
}
