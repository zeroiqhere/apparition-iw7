// Teleport rows show only source-backed movement and saved-location actions

run()
{
    position_shortcuts_show_personal_intent_and_exact_controls();
    position_shortcuts_require_actor_admission_before_record_reads();
    source_rows_keep_their_order_and_only_arrival_effect_stays_unavailable();
    owner_view_keeps_eight_rows_and_default_crosshairs();
    known_empty_official_catalog_omits_one_conditional_row();
    conditional_spawn_rows_preserve_the_selected_teleport_control();
    missing_official_catalog_keeps_disabled_placeholder();
    entity_navigation_keeps_the_selected_player_while_movement_is_paused();
    teleport_gun_shows_saved_intent_and_remains_personal();
    teleport_gun_requires_actor_admission_before_reading_target();
    remote_view_adds_both_directions_with_the_selected_target();
    aim_and_peer_reasons_do_not_hide_other_teleport_choices();
    readiness_reasons_gate_only_their_actions();
    missing_or_malformed_snapshots_fail_closed();
}

source_rows_keep_their_order_and_only_arrival_effect_stays_unavailable()
{
    view = view();
    view.target = view.owner;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    expected = ["Disable Teleport Effect", "Official Spawn Points", "Entity Teleports",
        "Teleport", "Teleport Gun", "Save & Load Position", "Save Current Location",
        "Load Saved Location"];
    tests\support\checks::expect(rows.size == 8, "The owner teleport page keeps its eight source rows");
    if (rows.size != 8)
        return;
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(rows[index].label == expected[index],
            "The owner rows retain their original order");

    tests\support\checks::expect(rows[0].kind == "unavailable" && !rows[0].enabled
        && !isDefined(rows[0].callback) && isSubStr(rows[0].description, "arrival"),
        "Unported arrival effects remain visible without a gameplay callback");
    tests\support\checks::expect(rows[5].kind == "toggle" && rows[5].enabled
        && rows[5].callback == scripts\apparition\menu\actions::toggle_position_shortcuts,
        "The source Save and Load shortcut row now exposes its supported toggle");
    tests\support\checks::expect(rows[1].kind == "slider"
        && rows[1].callback == scripts\apparition\menu\actions::official_spawn
        && rows[1].target == view.target && !rows[1].lobby && rows[1].enabled,
        "Official Spawn Points uses the current native catalog in its source position");
    tests\support\checks::expect(rows[2].kind == "submenu" && rows[2].enabled
        && rows[2].callback == scripts\apparition\menu\actions::open_page
        && rows[2].destination == "Entity Teleports" && rows[2].target == view.target
        && !rows[2].lobby,
        "Entity Teleports opens the native entity page for the selected player");
}

entity_navigation_keeps_the_selected_player_while_movement_is_paused()
{
    view = view();
    view.teleport.reason = "The player is on a native ride";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    row = rows[2];
    tests\support\checks::expect(row.enabled && row.kind == "submenu",
        "Movement pause still allows inspection of entity destinations");
    state = scripts\apparition\menu\state::create(view.owner);
    scripts\apparition\menu\state::push(state, "Teleport Menu", view.target);
    scripts\apparition\menu\state::push(state, row.destination, row.target);
    tests\support\checks::expect(state.page == "Entity Teleports" && state.target == view.target,
        "The entity page keeps the selected remote player");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Teleport Menu" && state.target == view.target,
        "Back returns to the selected player's Teleport Menu");

    view.teleport.actor_reason = "Selected actor permission was lost";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[2].enabled
        && rows[2].description == view.teleport.actor_reason,
        "Lost actor authority disables entity navigation with its reason");
}

owner_view_keeps_eight_rows_and_default_crosshairs()
{
    view = view();
    view.target = view.owner;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    slider = rows[3];
    tests\support\checks::expect(rows.size == 8, "An owner view has no redundant self-teleport rows");
    tests\support\checks::expect(slider.kind == "slider" && slider.callback == scripts\apparition\menu\actions::teleport
        && slider.target == view.target && !slider.lobby,
        "Teleport applies to the selected target through a player-scoped action");
    modes = scripts\apparition\features\teleport::modes();
    tests\support\checks::expect(slider.values.size == modes.size && modes.size == 3
        && slider.values[0] == "Crosshairs" && slider.values[1] == "Sky"
        && slider.values[2] == "Random Player" && slider.initial_index == 0
        && !isDefined(slider.active_value),
        "The Teleport slider uses the canonical modes and a Crosshairs preview without saved active state");
    tests\support\checks::expect(isSubStr(slider.description, "Crosshairs uses the menu owner's aim")
        && isSubStr(slider.description, "Sky adds 35000 Z")
        && isSubStr(slider.description, "Random Player requires an eligible peer"),
        "The slider describes each destination without claiming unverified map points");

    spawn_slider = rows[1];
    tests\support\checks::expect(spawn_slider.values.size == 2
        && spawn_slider.values[0] == 0 && spawn_slider.values[1] == 1
        && spawn_slider.initial_index == 0 && !isDefined(spawn_slider.active_value)
        && spawn_slider.spawn_points[0] == view.official_spawns.points[0]
        && spawn_slider.spawn_points[1] == view.official_spawns.points[1],
        "The official spawn row uses numeric choices and keeps native references without coordinates");

    tests\support\checks::expect(rows[4].kind == "toggle" && rows[4].callback == scripts\apparition\menu\actions::toggle_teleport_gun
        && rows[4].target == view.target && !rows[4].lobby && rows[4].enabled && !rows[4].checked,
        "Teleport Gun is a personal enabled toggle for the selected player");
    tests\support\checks::expect(rows[4].description == "Saved off; Use enables; shots use the selected player's own aim",
        "Teleport Gun explains that the saved setting controls future shots");

    tests\support\checks::expect(rows[6].kind == "action" && rows[6].callback == scripts\apparition\menu\actions::save_location
        && rows[6].target == view.target && !rows[6].lobby
        && isSubStr(rows[6].description, "location") && isSubStr(rows[6].description, "view angle"),
        "Save Current Location targets the selected player");
    tests\support\checks::expect(rows[7].kind == "action" && rows[7].callback == scripts\apparition\menu\actions::load_location
        && rows[7].target == view.target && !rows[7].lobby
        && isSubStr(rows[7].description, "location") && isSubStr(rows[7].description, "view angle"),
        "Load Saved Location targets the selected player");
}

known_empty_official_catalog_omits_one_conditional_row()
{
    view = view();
    view.target = view.owner;
    view.official_spawns.points = [];
    owner_rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(owner_rows.size == 7
        && owner_rows[1].label == "Entity Teleports"
        && owner_rows[2].label == "Teleport"
        && owner_rows[3].label == "Teleport Gun"
        && owner_rows[4].label == "Save & Load Position"
        && owner_rows[5].label == "Save Current Location"
        && owner_rows[6].label == "Load Saved Location",
        "A known empty native catalog omits only its conditional row and preserves the rest");

    remote_view = view();
    remote_view.official_spawns.points = [];
    remote_rows = scripts\apparition\menu\teleport_rows::build(remote_view);
    tests\support\checks::expect(remote_rows.size == 9
        && remote_rows[7].label == "Teleport To Self"
        && remote_rows[8].label == "Teleport To Player",
        "Remote movement rows retain their order after the known empty catalog is omitted");
}

conditional_spawn_rows_preserve_the_selected_teleport_control()
{
    view = view();
    view.target = view.owner;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Teleport Menu";
    state.cursors[state.page] = 3;
    selected = rows[3];
    view.official_spawns.points = [];
    smaller = scripts\apparition\menu\teleport_rows::build(view);
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state, smaller, selected.label, selected.target);
    tests\support\checks::expect(resolved == 2 && smaller[resolved].label == "Teleport"
        && smaller[resolved].callback == scripts\apparition\menu\actions::teleport,
        "Removing the conditional row keeps selection on Teleport rather than Teleport Gun");
    state.cursors[state.page] = resolved;
    selected = smaller[resolved];
    fixture = tests\fixtures\spawn_points::ready_state();
    view.official_spawns.points = fixture.struct_class_names["targetname"]["player_respawn_loc"];
    larger = scripts\apparition\menu\teleport_rows::build(view);
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state, larger, selected.label, selected.target);
    tests\support\checks::expect(resolved == 3 && larger[resolved].label == "Teleport",
        "Restoring the conditional row keeps the same control selected");
}

missing_official_catalog_keeps_disabled_placeholder()
{
    view = view();
    view.target = view.owner;
    view.official_spawns = undefined;
    owner_rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(owner_rows.size == 8 && owner_rows[1].label == "Official Spawn Points"
        && owner_rows[1].kind == "unavailable" && !owner_rows[1].enabled,
        "A missing catalog keeps the disabled placeholder in the owner row set");

    remote_view = view();
    remote_view.official_spawns = undefined;
    remote_rows = scripts\apparition\menu\teleport_rows::build(remote_view);
    tests\support\checks::expect(remote_rows.size == 10 && remote_rows[1].label == "Official Spawn Points"
        && remote_rows[1].kind == "unavailable" && !remote_rows[1].enabled,
        "A missing catalog keeps the disabled placeholder in the remote row set");
}

teleport_gun_shows_saved_intent_and_remains_personal()
{
    view = view();
    view.target.apparition_teleport_gun = spawnstruct();
    view.target.apparition_teleport_gun.owner = view.owner;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[4].kind == "toggle" && rows[4].checked
        && rows[4].enabled && rows[4].target == view.target && !rows[4].lobby,
        "A saved on setting is checked without changing its target or scope");
    tests\support\checks::expect(rows[4].description == "Saved on; Use disables; shots use the selected player's own aim"
        && isDefined(view.target.apparition_teleport_gun)
        && view.target.apparition_teleport_gun.owner == view.owner,
        "Reading the saved setting leaves it unchanged and describes its own-aim behavior");

    view = view();
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[4].checked && rows[4].enabled
        && !isDefined(view.target.apparition_teleport_gun),
        "An absent saved setting remains unchecked and unchanged");

    view = view();
    view.teleport.reason = "The selected player is not ready to travel";
    view.target.apparition_teleport_gun = spawnstruct();
    view.target.apparition_teleport_gun.owner = view.owner;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[4].enabled && rows[4].checked,
        "Movement readiness does not block changing the personal saved setting");
    tests\support\checks::expect(rows[4].description == "Saved on; Use disables; shots use the selected player's own aim; paused: The selected player is not ready to travel",
        "A blocked movement reason is shown as paused copy while preserving saved state");
}

teleport_gun_requires_actor_admission_before_reading_target()
{
    view = view();
    view.target = 7;
    view.teleport.actor_reason = "The selected actor is no longer authorized";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[4].kind == "toggle" && !rows[4].enabled
        && !rows[4].checked && rows[4].target == 7
        && rows[4].description == "The selected actor is no longer authorized",
        "Blocked actor admission disables the toggle without reading the selected target");

    view = view();
    view.target = 7;
    view.teleport.actor_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[4].enabled && !rows[4].checked,
        "A malformed snapshot also prevents target reads and fails closed");
}

remote_view_adds_both_directions_with_the_selected_target()
{
    view = view();
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows.size == 10 && rows[8].label == "Teleport To Self"
        && rows[9].label == "Teleport To Player", "A remote view appends both source directions in order");
    if (rows.size != 10)
        return;

    tests\support\checks::expect(rows[8].kind == "action"
        && rows[8].callback == scripts\apparition\menu\actions::teleport_to_self
        && rows[8].target == view.target && !rows[8].lobby && rows[8].enabled
        && isSubStr(rows[8].description, "selected player to the menu owner's position"),
        "Teleport To Self moves the selected player to the menu owner");
    tests\support\checks::expect(rows[9].kind == "action"
        && rows[9].callback == scripts\apparition\menu\actions::teleport_to_player
        && rows[9].target == view.target && !rows[9].lobby && rows[9].enabled
        && isSubStr(rows[9].description, "menu owner to the selected player's position"),
        "Teleport To Player moves the menu owner to the selected player");
}

aim_and_peer_reasons_do_not_hide_other_teleport_choices()
{
    view = view();
    view.teleport.aim_reason = "The menu owner must be alive to aim";
    view.teleport.random_reason = "No eligible peer is available";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[3].enabled,
        "A blocked aim or peer destination leaves the other Teleport choices usable");
    tests\support\checks::expect(rows[3].choice_reasons["Crosshairs"] == view.teleport.aim_reason
        && rows[3].choice_reasons["Random Player"] == view.teleport.random_reason
        && rows[3].choice_reasons["Sky"] == "",
        "Each preview has its own readiness reason without blocking unrelated choices");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(rows[3], false, "Crosshairs")
        && !scripts\apparition\menu\dispatch::can_start(rows[3], false, "Random Player")
        && scripts\apparition\menu\dispatch::can_start(rows[3], false, "Sky"),
        "Use rejects blocked aim and peer previews while allowing the ready Sky preview");
    tests\support\checks::expect(scripts\apparition\menu\availability::description(rows[3], "Crosshairs") == view.teleport.aim_reason
        && scripts\apparition\menu\availability::description(rows[3], "Random Player") == view.teleport.random_reason
        && scripts\apparition\menu\availability::description(rows[3], "Sky") == rows[3].description,
        "The selected preview drives the same reason for the footer and input rejection");
    tests\support\checks::expect(!rows[8].enabled && !rows[9].enabled,
        "Both remote directions require the owner travel readiness reason to be clear");

    view = view();
    view.teleport.random_reason = "No eligible peer is available";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[3].enabled && rows[8].enabled && rows[9].enabled,
        "Peer-selection readiness does not block aim or direct-player destinations");
}

readiness_reasons_gate_only_their_actions()
{
    view = view();
    view.teleport.reason = "The selected player is not ready to travel";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "Target travel readiness blocks teleport and saved-location actions");
    tests\support\checks::expect(isSubStr(rows[3].description, view.teleport.reason)
        && rows[6].description == view.teleport.reason && rows[7].description == view.teleport.reason,
        "Blocked actions show the target readiness reason");

    view = view();
    view.teleport.load_reason = "No valid saved location is available";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[3].enabled && rows[6].enabled && !rows[7].enabled
        && rows[7].description == view.teleport.load_reason,
        "A missing saved location disables load while keeping unrelated actions available");
}

missing_or_malformed_snapshots_fail_closed()
{
    view = view();
    view.teleport = undefined;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled,
        "A missing teleport snapshot disables every state-changing action");

    view = view();
    view.teleport.actor_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "A malformed actor admission field disables teleport actions");

    view = view();
    view.teleport.reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "A malformed target readiness field disables teleport actions");

    view = view();
    view.teleport.aim_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "A malformed owner readiness field disables teleport actions");

    view = view();
    view.teleport.random_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "A malformed peer readiness field disables teleport actions");

    view = view();
    view.teleport.load_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "A malformed saved-position readiness field disables teleport actions");

    view = view();
    view.teleport.actor_reason = "The selected actors are no longer authorized";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled
        && !rows[8].enabled && !rows[9].enabled,
        "Actor admission failure blocks all state-changing rows");
}

view()
{
    result = spawnstruct();
    result.owner = spawnstruct();
    result.target = spawnstruct();
    result.teleport = spawnstruct();
    result.teleport.actor_reason = "";
    result.teleport.reason = "";
    result.teleport.aim_reason = "";
    result.teleport.random_reason = "";
    result.teleport.load_reason = "";
    result.official_spawns = spawnstruct();
    result.official_spawns.reason = "";
    state = tests\fixtures\spawn_points::ready_state();
    result.official_spawns.points = state.struct_class_names["targetname"]["player_respawn_loc"];
    return result;
}

position_shortcuts_show_personal_intent_and_exact_controls()
{
    view = view();
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[5].kind == "toggle" && !rows[5].checked && rows[5].enabled
        && rows[5].target == view.target && !rows[5].lobby
        && rows[5].callback == scripts\apparition\menu\actions::toggle_position_shortcuts,
        "Save and Load starts off for the selected player without creating a shortcut record");
    tests\support\checks::expect(rows[5].description
        == "Saved off; Use enables; Action Slot 3 saves and Action Slot 2 loads outside this player's menu"
        && !isDefined(view.target.apparition_position_shortcuts),
        "The row states the exact source controls without changing saved intent");
    record = spawnstruct();
    record.owner = view.owner;
    view.target.apparition_position_shortcuts = record;
    view.teleport.reason = "Finish the native portal trip first";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(rows[5].checked && rows[5].enabled
        && rows[5].description == "Saved on; Use disables; Action Slot 3 saves and Action Slot 2 loads outside this player's menu; paused: Finish the native portal trip first"
        && view.target.apparition_position_shortcuts == record,
        "Movement pauses remain visible while the configured shortcut can still be disabled");
    view.target.apparition_position_shortcuts = undefined;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[5].checked && rows[5].enabled,
        "Reading an absent shortcut does not start a worker even while movement is paused");
}

position_shortcuts_require_actor_admission_before_record_reads()
{
    view = view();
    view.target = 7;
    view.teleport.actor_reason = "The selected actor is no longer authorized";
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[5].enabled && !rows[5].checked && rows[5].target == 7
        && rows[5].description == view.teleport.actor_reason,
        "Blocked actor admission prevents reading the selected shortcut record");
    view.teleport.actor_reason = 7;
    rows = scripts\apparition\menu\teleport_rows::build(view);
    tests\support\checks::expect(!rows[5].enabled && !rows[5].checked,
        "A malformed actor snapshot also keeps shortcut configuration unavailable");
}
