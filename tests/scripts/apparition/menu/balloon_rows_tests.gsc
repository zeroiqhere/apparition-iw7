// Balloon rows offer angle requests without asserting pop state or completion

run()
{
    only_the_current_balloon_stage_opens_the_owner_bound_page();
    ready_rows_face_current_host_targets_by_identity();
    a_reordered_list_keeps_the_selected_object_instead_of_its_number();
    guests_keep_host_denial_ahead_of_snapshot_details();
    missing_or_malformed_snapshots_publish_no_action_prefix();
    empty_or_blocked_queries_remain_unavailable();
    rendering_retains_references_without_copying_coordinates();
}

only_the_current_balloon_stage_opens_the_owner_bound_page()
{
    view = ready_view();
    view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(tests\fixtures\ghosts::quest(0));
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    row = rows[1];
    tests\support\checks::expect(row.label == "Pop Spawn Balloons" && row.kind == "submenu"
        && row.enabled && !row.checked && row.destination == "Spawn Balloons"
        && row.target == view.owner && !row.lobby,
        "The current first stage opens its owner-bound aiming page without checking completion");
    view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(tests\fixtures\ghosts::quest(1));
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[1].checked && !rows[1].enabled && !isDefined(rows[1].callback),
        "Later native progression supplies the completed checkbox and closes stage-zero input");
    view.ghost_progress.step = -1;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[1].checked && !rows[1].enabled,
        "Unknown native progress does not expose an aiming route");
}

ready_rows_face_current_host_targets_by_identity()
{
    view = ready_view();
    rows = scripts\apparition\menu\model::build("Spawn Balloons", view);
    tests\support\checks::expect(rows.size == 2 && rows[0].label == "Face Spawn Balloon 1"
        && rows[1].label == "Face Spawn Balloon 2", "Authored objects retain their query order in the visible list");
    foreach (row in rows)
        tests\support\checks::expect(row.kind == "action" && row.enabled && row.lobby
            && !isDefined(row.target) && !isDefined(row.checked)
            && row.callback == scripts\apparition\menu\actions::face_spawn_balloon,
            "Each request requires the current host and has no hit or pop checkbox");
    tests\support\checks::expect(rows[0].balloon_point == view.balloons.entries[0].point
        && rows[0].selection_key == view.balloons.entries[0].point
        && isSubStr(rows[0].description, "does not pop"),
        "A captured object identity and an aiming-only footer describe the actual command");
}

a_reordered_list_keeps_the_selected_object_instead_of_its_number()
{
    view = ready_view();
    before = scripts\apparition\menu\balloon_rows::build(view);
    held = before[0];
    first = view.balloons.entries[0];
    view.balloons.entries[0] = view.balloons.entries[1];
    view.balloons.entries[1] = first;
    after = scripts\apparition\menu\balloon_rows::build(view);
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Spawn Balloons";
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state, after,
        held.label, held.target, held.selection_key) == 1
        && after[1].balloon_point == held.balloon_point,
        "A renamed ordinal follows its same native object after a query reorder");
}

guests_keep_host_denial_ahead_of_snapshot_details()
{
    view = ready_view();
    view.host = false;
    view.balloons = 7;
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback)
        && rows[0].description == "Only the current host can face spawn balloons",
        "Guest denial is displayed without inspecting a rejected snapshot");
}

missing_or_malformed_snapshots_publish_no_action_prefix()
{
    view = ready_view();
    foreach (bad in [7, "ready", [], spawnstruct()])
    {
        view.balloons = bad;
        rows = scripts\apparition\menu\balloon_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback),
            "Malformed query data cannot enable a native view change");
    }
    view.balloons = undefined;
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A missing query remains an explained unavailable page");
    view = ready_view();
    view.balloons.entries[1] = 7;
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].balloon_point),
        "An invalid later record cannot publish a valid action prefix");
    view = ready_view();
    view.balloons.entries[1].point = undefined;
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A missing native object reference blocks the complete captured list");
    view = ready_view();
    view.balloons.entries[0].point = (1, 2, 3);
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "Cached coordinates cannot replace a selected native object identity");
    view = ready_view();
    view.balloons.entries = [];
    view.balloons.entries["named"] = spawnstruct();
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A sparse list cannot stand in for native query order");
}

empty_or_blocked_queries_remain_unavailable()
{
    view = ready_view();
    view.balloons.entries = [];
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback),
        "An empty query cannot imply that balloons were popped");
    view.balloons.reason = "The native quest has advanced";
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(rows[0].description == "The native quest has advanced",
        "Live phase or actor rejection remains ahead of an empty target list");
}

rendering_retains_references_without_copying_coordinates()
{
    view = ready_view();
    point = view.balloons.entries[0].point;
    rows = scripts\apparition\menu\balloon_rows::build(view);
    tests\support\checks::expect(!isDefined(rows[0].origin) && !isDefined(rows[0].angles)
        && view.balloons.entries[0].point == point && view.balloons.reason == "",
        "A render keeps references only and leaves the captured query untouched");
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.host = true;
    view.balloons = spawnstruct();
    view.balloons.reason = "";
    view.balloons.entries = [];
    for (index = 0; index < 2; index++)
    {
        entry = spawnstruct();
        // Native object identity is all the row builder is permitted to consume
        entry.point = spawnstruct();
        view.balloons.entries[index] = entry;
    }
    return view;
}
