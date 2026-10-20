// Official spawn rows retain native references and defer movement until dispatch

run()
{
    available_catalog_uses_numeric_choice_indexes_and_preserves_references();
    actor_and_movement_blocks_do_not_publish_spawn_payload();
    catalog_reasons_and_malformed_snapshots_stay_unavailable();
    known_empty_catalog_omits_the_conditional_row();
}

available_catalog_uses_numeric_choice_indexes_and_preserves_references()
{
    view = view();
    actor = "";
    movement = "";
    row = scripts\apparition\menu\spawn_row::build(view, actor, movement);
    tests\support\checks::expect(row.label == "Official Spawn Points" && row.kind == "slider"
        && row.callback == scripts\apparition\menu\actions::official_spawn
        && row.target == view.target && !row.lobby && row.enabled,
        "Available official spawns form a player-scoped slider action");
    tests\support\checks::expect(row.values.size == 2 && isnumber(row.values[0])
        && isnumber(row.values[1]) && row.values[0] == 0 && row.values[1] == 1
        && row.initial_index == 0 && !isDefined(row.active_value),
        "The slider uses numeric zero-based choices with a default preview only");
    tests\support\checks::expect(row.description == "Use moves to the selected native spawn; availability is checked again",
        "The description states the selected movement and dispatch-time readiness check");
    tests\support\checks::expect(row.spawn_points.size == 2
        && row.spawn_points[0] == view.official_spawns.points[0]
        && row.spawn_points[1] == view.official_spawns.points[1],
        "The action carries the catalog point references without rebuilding coordinates");
}

actor_and_movement_blocks_do_not_publish_spawn_payload()
{
    view = view();
    row = scripts\apparition\menu\spawn_row::build(view,
        "The selected actor is no longer authorized", "Movement is paused");
    tests\support\checks::expect(row.kind == "slider" && !row.enabled
        && row.description == "The selected actor is no longer authorized"
        && !isDefined(row.spawn_points),
        "Actor admission takes precedence and withholds point references");

    row = scripts\apparition\menu\spawn_row::build(view, "", "Movement is paused");
    tests\support\checks::expect(row.kind == "slider" && !row.enabled
        && row.description == "Movement is paused"
        && !isDefined(row.spawn_points),
        "Movement readiness blocks the action without publishing point references");
}

catalog_reasons_and_malformed_snapshots_stay_unavailable()
{
    view = view();
    view.official_spawns.reason = "Native spawn catalog is not ready";
    row = scripts\apparition\menu\spawn_row::build(view, "", "");
    tests\support\checks::expect(row.kind == "unavailable" && !row.enabled
        && row.label == "Official Spawn Points" && row.description == view.official_spawns.reason
        && !isDefined(row.spawn_points),
        "A catalog readiness reason keeps the row unavailable without exposing points");

    row = scripts\apparition\menu\spawn_row::build(view, "Actor blocked", "Movement paused");
    tests\support\checks::expect(row.description == "Actor blocked" && !isDefined(row.spawn_points),
        "Actor reason takes precedence over movement and catalog messages");
    row = scripts\apparition\menu\spawn_row::build(view, "", "Movement paused");
    tests\support\checks::expect(row.description == "Movement paused" && !isDefined(row.spawn_points),
        "Movement reason takes precedence over the catalog message");

    view = view();
    view.official_spawns.reason = 7;
    row = scripts\apparition\menu\spawn_row::build(view, "", "");
    tests\support\checks::expect(row.kind == "unavailable" && !row.enabled
        && !isDefined(row.spawn_points), "A malformed reason disables the spawn row");

    view = view();
    view.official_spawns.points = 7;
    row = scripts\apparition\menu\spawn_row::build(view, "", "");
    tests\support\checks::expect(row.kind == "unavailable" && !row.enabled
        && !isDefined(row.spawn_points), "A malformed point list disables the spawn row");

    view = view();
    view.official_spawns.points = [];
    view.official_spawns.points[1] = spawnstruct();
    row = scripts\apparition\menu\spawn_row::build(view, "", "");
    tests\support\checks::expect(row.kind == "unavailable" && !row.enabled
        && !isDefined(row.spawn_points), "A sparse point list is rejected as malformed");

    view = spawnstruct();
    row = scripts\apparition\menu\spawn_row::build(view, "Actor blocked", "Movement paused");
    tests\support\checks::expect(row.kind == "unavailable" && !row.enabled
        && row.description == "Actor blocked" && !isDefined(row.spawn_points),
        "A missing catalog stays unavailable and keeps actor admission precedence");
}

known_empty_catalog_omits_the_conditional_row()
{
    view = view();
    view.official_spawns.points = [];
    row = scripts\apparition\menu\spawn_row::build(view, "Actor blocked", "Movement paused");
    tests\support\checks::expect(!isDefined(row),
        "A validated empty catalog omits the conditional row even when actors are blocked");
}

view()
{
    result = spawnstruct();
    result.target = spawnstruct();
    result.official_spawns = spawnstruct();
    result.official_spawns.reason = "";
    state = tests\fixtures\spawn_points::ready_state();
    result.official_spawns.points = state.struct_class_names["targetname"]["player_respawn_loc"];
    return result;
}
