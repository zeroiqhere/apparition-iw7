// The Fun page preserves its source order while exposing only the supported action

run()
{
    audited_unavailable_controls_explain_their_specific_native_gaps();
    the_fun_page_keeps_all_thirty_seven_source_labels_in_order();
    insta_kill_replaces_its_source_row_with_the_personal_mode_slider();
    earthquake_is_a_personal_action_with_global_submission_copy();
    sounds_and_jingles_is_a_selected_target_link();
    rejected_fun_target_disables_the_sounds_link_before_snapshot_reads();
    frog_jump_replaces_its_source_row_as_a_selected_player_toggle();
    a_configured_frog_jump_remains_visible_while_readiness_is_blocked();
    frog_jump_rejects_missing_and_malformed_readiness();
    frog_jump_actor_denial_precedes_target_and_snapshot_reads();
    health_bar_replaces_its_source_row_as_a_selected_player_toggle();
    a_configured_health_bar_remains_visible_while_native_readiness_is_blocked();
    health_bar_snapshot_requires_a_typed_reason_and_exact_numeric_flag();
    health_bar_actor_denial_precedes_target_and_snapshot_reads();
    an_absent_or_nonstruct_view_cannot_supply_a_ready_target();
    rejected_actor_reason_precedes_earthquake_snapshot_reads();
    missing_and_malformed_earthquake_snapshots_fail_closed();
    rendering_does_not_change_target_or_store_earthquake_parameters();
}

audited_unavailable_controls_explain_their_specific_native_gaps()
{
    rows = scripts\apparition\menu\fun_rows::build(ready_view());
    expected = [
        [15, "Per-player gravity has no verified IW7 binding"],
        [16, "Per-player slick movement has no verified IW7 binding"],
        [32, "Damage and death effects need matching native hooks and a blood effect"],
        [33, "The original headshot perk has no verified IW7 behavior"],
        [34, "Live pickup tracking and safe movement ownership remain unverified"]
    ];
    foreach (entry in expected)
        tests\support\checks::expect(!rows[entry[0]].enabled
            && rows[entry[0]].description == entry[1],
            "Each audited control explains its concrete unresolved binding instead of offering an approximate effect");
}

the_fun_page_keeps_all_thirty_seven_source_labels_in_order()
{
    view = ready_view();
    rows = scripts\apparition\menu\fun_rows::build(view);
    labels = ["Earthquake", "Adventure Time", "Force Field Options", "Effects Man Options",
        "Sounds & Jingles", "Hit Markers", "Insta-Kill", "Death Skull", "Mount Camera",
        "Shoot Power-Ups", "Drop Camera", "Dead Ops View", "Zombie Counter", "Light Protector",
        "Special Movements", "Moon Gravity", "Ice Skating", "Forge Mode", "Spec-Nade",
        "Nuke Nades", "Cod Jumper", "Frog Jump", "Jetpack", "Health Bar", "Cluster Grenades",
        "Electric Fire Cherry", "Human Centipede", "Rocket Riding", "Grappling Gun", "Gravity Gun",
        "Delete Gun", "Rapid Fire", "Extra Gore", "Head Drama", "Power-Up Magnet",
        "Disable Earning Points", "Points Multiplier"];

    tests\support\checks::expect(rows.size == 37 && labels.size == 37,
        "Fun Scripts preserves all 37 root options");
    if (rows.size != labels.size)
        return;
    for (index = 0; index < labels.size; index++)
        tests\support\checks::expect(rows[index].label == labels[index],
            "Fun Scripts keeps each original root label and position");

    for (index = 1; index < rows.size; index++)
    {
        if (index == 4 || index == 6 || index == 21 || index == 23)
            continue;
        tests\support\checks::expect(!rows[index].enabled && rows[index].kind == "unavailable"
            && !isDefined(rows[index].callback) && !isDefined(rows[index].checked),
            "Every other original Fun option remains unavailable without a fake callback or checkbox");
    }
    tests\support\checks::expect(rows[12].description == "Native all-phase zombie count semantics are unresolved",
        "Zombie Counter stays blocked until its full native count semantics are established");
    tests\support\checks::expect(rows[23].label == "Health Bar"
        && rows[23].callback == scripts\apparition\menu\actions::toggle_health_bar,
        "Health Bar keeps its source row position and dedicated callback");
    tests\support\checks::expect(rows[4].label == "Sounds & Jingles"
        && rows[4].kind == "submenu" && rows[4].callback == scripts\apparition\menu\actions::open_page
        && rows[4].destination == "Sounds & Jingles" && rows[4].target == view.target && !rows[4].lobby,
        "Sounds & Jingles keeps its source row position as a selected-player submenu");
    tests\support\checks::expect(rows[6].label == "Insta-Kill"
        && rows[6].kind == "slider" && rows[6].callback == scripts\apparition\menu\actions::set_insta_kill
        && rows[6].target == view.target && !rows[6].lobby,
        "Insta-Kill keeps its source row position and personal action scope");
    tests\support\checks::expect(rows[21].label == "Frog Jump"
        && rows[21].callback == scripts\apparition\menu\actions::toggle_frog_jump,
        "Frog Jump keeps its source row position and dedicated callback");
    tests\support\checks::expect(rows[31].label == "Rapid Fire" && !rows[31].enabled
        && rows[31].kind == "unavailable"
        && rows[31].description == "Native player muzzle, weapon and shot-event behavior remain unverified"
        && !isDefined(rows[31].callback) && !isDefined(rows[31].checked),
        "Rapid Fire stays unavailable without a callback or toggle state until native shot behavior is verified");
    tests\support\checks::expect(rows[35].description == "Native currency scaling also affects refunds and cannot isolate damage awards"
        && rows[36].description == "Native currency scaling also affects refunds and cannot isolate damage awards",
        "Unsupported currency options explain their shared source-side effect");
}

insta_kill_replaces_its_source_row_with_the_personal_mode_slider()
{
    view = ready_view();
    view.insta_kill = spawnstruct();
    view.insta_kill.reason = "";
    view.insta_kill.mode = "Melee";
    view.insta_kill.hook_reason = "";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[6];
    tests\support\checks::expect(row.enabled && row.values.size == 3
        && row.values[0] == "Disable" && row.values[1] == "All" && row.values[2] == "Melee"
        && row.active_value == "Melee" && row.initial_index == 0,
        "Fun Scripts routes its source Insta-Kill row to the ready mode slider");
}

earthquake_is_a_personal_action_with_global_submission_copy()
{
    view = ready_view();
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(row.kind == "action" && row.enabled && row.target == view.target && !row.lobby
        && row.callback == scripts\apparition\menu\actions::send_earthquake,
        "A fresh ready snapshot exposes the selected-player action only in personal scope");
    tests\support\checks::expect(row.description == "One global 15s quake at this player's current position, radius 750. Nearby players may feel it; request only.",
        "The row explains global camera effect, native parameters and submission limits");
}

sounds_and_jingles_is_a_selected_target_link()
{
    view = ready_view();
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[4];
    tests\support\checks::expect(row.enabled && row.kind == "submenu"
        && row.label == "Sounds & Jingles" && row.destination == "Sounds & Jingles"
        && row.callback == scripts\apparition\menu\actions::open_page
        && row.target == view.target && !row.lobby,
        "The Fun Scripts link opens Sounds & Jingles for the selected player");
}

rejected_fun_target_disables_the_sounds_link_before_snapshot_reads()
{
    view = ready_view();
    view.target_actor_reason = "The player is no longer in the current roster";
    view.perk_sounds = "malformed snapshot";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[4];
    tests\support\checks::expect(!row.enabled && row.target == view.target
        && row.description == view.target_actor_reason,
        "Rejected Fun target admission disables the sound link before snapshot use");
}

frog_jump_replaces_its_source_row_as_a_selected_player_toggle()
{
    view = ready_view();
    view.owner = spawnstruct();
    view.frog_jump = spawnstruct();
    view.frog_jump.reason = "";
    view.frog_jump.configured = 0;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[21];
    tests\support\checks::expect(row.label == "Frog Jump" && row.kind == "toggle"
        && row.callback == scripts\apparition\menu\actions::toggle_frog_jump
        && row.target == view.target && row.target != view.owner && !row.lobby,
        "Frog Jump toggles the currently selected player in personal scope");
    tests\support\checks::expect(row.enabled && !row.checked
        && row.description == "Hold Jump while airborne and standing for one forward boost until landing; native rides and links pause it.",
        "A ready configured-off row explains its source input and boost behavior");

    view.frog_jump.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[21];
    tests\support\checks::expect(row.enabled && row.checked
        && row.description == "Configured on; one boost until landing. Use turns it off; native rides and links can pause boosting.",
        "A ready configured-on row preserves intent and explains pause conditions");
}

a_configured_frog_jump_remains_visible_while_readiness_is_blocked()
{
    view = ready_view();
    view.frog_jump = spawnstruct();
    view.frog_jump.reason = "Wait for the shared Jump observer";
    view.frog_jump.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[21];
    tests\support\checks::expect(!row.enabled && row.checked
        && row.description == view.frog_jump.reason,
        "A blocked native path preserves the configured-on checkbox and current reason");

    view.frog_jump.configured = 0;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
        && rows[21].description == view.frog_jump.reason,
        "A blocked configured-off row stays unchecked and unavailable");
}

frog_jump_rejects_missing_and_malformed_readiness()
{
    view = ready_view();
    view.frog_jump = undefined;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
        && rows[21].description == "Wait for a current frog jump snapshot",
        "A missing Frog Jump snapshot fails closed");

    foreach (invalid in [17, "ready", (1, 2, 3), []])
    {
        view.frog_jump = invalid;
        rows = scripts\apparition\menu\fun_rows::build(view);
        tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
            && rows[21].description == "Wait for a current frog jump snapshot",
            "A scalar, string, vector or array snapshot fails closed");
    }

    view.frog_jump = spawnstruct();
    view.frog_jump.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
        && rows[21].description == "Wait for a current frog jump snapshot",
        "A missing typed reason cannot trust configured state");

    view.frog_jump.reason = "";
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
        && rows[21].description == "Wait for a current frog jump snapshot",
        "A missing configured flag cannot imply an off setting");

    foreach (invalid in ["1", 0.5, -1, 2])
    {
        view.frog_jump.configured = invalid;
        rows = scripts\apparition\menu\fun_rows::build(view);
        tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
            && rows[21].description == "Wait for a current frog jump snapshot",
            "A non-numeric or non-Boolean configured flag fails closed");
    }

    view.frog_jump.configured = 0;
    view.frog_jump.reason = 17;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[21].enabled && !rows[21].checked
        && rows[21].description == "Wait for a current frog jump snapshot",
        "A malformed readiness reason fails closed");
}

frog_jump_actor_denial_precedes_target_and_snapshot_reads()
{
    view = ready_view();
    view.target = 17;
    view.target_actor_reason = "The player is no longer in the current roster";
    view.frog_jump = "malformed snapshot";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[21];
    tests\support\checks::expect(!row.enabled && !row.checked && row.target == view.target
        && row.description == view.target_actor_reason,
        "Rejected target admission wins before target flags or native snapshot members are read");
}

health_bar_replaces_its_source_row_as_a_selected_player_toggle()
{
    view = ready_view();
    view.owner = spawnstruct();
    view.health_bar = spawnstruct();
    view.health_bar.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && rows[23].description == "Wait for a current health bar snapshot",
        "A missing typed readiness reason fails closed before saved configuration is trusted");

    view.health_bar = spawnstruct();
    view.health_bar.reason = "";
    view.health_bar.configured = 0;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[23];
    tests\support\checks::expect(row.label == "Health Bar" && row.kind == "toggle"
        && row.callback == scripts\apparition\menu\actions::toggle_health_bar
        && row.target == view.target && row.target != view.owner && !row.lobby,
        "Health Bar toggles the currently selected player in personal scope");
    tests\support\checks::expect(row.enabled && !row.checked
        && row.description == "Show this player's live health bar until death or Use turns it off; native placement is adapted.",
        "A ready configured-off row explains its adapted live display");

    view.health_bar.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[23];
    tests\support\checks::expect(row.enabled && row.checked
        && row.description == "Configured on; Use removes this player's health bar. It stays outside the menu and turns off on death.",
        "A ready configured-on row retains its check and describes cleanup");
}

a_configured_health_bar_remains_visible_while_native_readiness_is_blocked()
{
    view = ready_view();
    view.health_bar = spawnstruct();
    view.health_bar.reason = "Wait for the native health bar callback";
    view.health_bar.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[23];
    tests\support\checks::expect(!row.enabled && row.checked
        && row.description == view.health_bar.reason,
        "A blocked native path preserves the configured-on checkbox and current reason");

    view.health_bar.configured = 0;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && rows[23].description == view.health_bar.reason,
        "A blocked configured-off row remains unchecked and unavailable");
}

health_bar_snapshot_requires_a_typed_reason_and_exact_numeric_flag()
{
    view = ready_view();
    view.health_bar = undefined;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && rows[23].description == "Wait for a current health bar snapshot",
        "A missing health bar snapshot fails closed");

    foreach (invalid in [17, "ready", (1, 2, 3), []])
    {
        view.health_bar = invalid;
        rows = scripts\apparition\menu\fun_rows::build(view);
        tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
            && rows[23].description == "Wait for a current health bar snapshot",
            "A scalar, string, vector or array snapshot fails closed");
    }

    view.health_bar = spawnstruct();
    view.health_bar.reason = "";
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && rows[23].description == "Wait for a current health bar snapshot",
        "A missing configured flag cannot imply an off setting");

    foreach (invalid in ["1", 0.5, -1, 2])
    {
        view.health_bar.configured = invalid;
        rows = scripts\apparition\menu\fun_rows::build(view);
        tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
            && rows[23].description == "Wait for a current health bar snapshot",
            "A non-numeric or non-Boolean configured flag fails closed");
    }

    view.health_bar.configured = 0;
    view.health_bar.reason = 17;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && rows[23].description == "Wait for a current health bar snapshot",
        "A malformed health bar reason fails closed");
}

health_bar_actor_denial_precedes_target_and_snapshot_reads()
{
    view = ready_view();
    view.target = 17;
    view.target_actor_reason = "The player is no longer in the current roster";
    view.health_bar = "malformed snapshot";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[23];
    tests\support\checks::expect(!row.enabled && !row.checked && row.target == view.target
        && row.description == view.target_actor_reason,
        "Rejected target admission wins before reading target flags or native snapshot members");
}

rejected_actor_reason_precedes_earthquake_snapshot_reads()
{
    view = ready_view();
    view.target = 17;
    view.target_actor_reason = "The player is no longer in the current roster";
    view.earthquake = undefined;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(!row.enabled && row.description == view.target_actor_reason
        && row.target == view.target,
        "Rejected target admission is returned before reading the missing native snapshot");
}

missing_and_malformed_earthquake_snapshots_fail_closed()
{
    view = ready_view();
    // Undefined array entries can be skipped by foreach, so test absence directly
    view.earthquake = undefined;
    rows = scripts\apparition\menu\fun_rows::build(view);
    tests\support\checks::expect(!rows[0].enabled
        && rows[0].description == "Wait for a current earthquake readiness snapshot",
        "An absent snapshot cannot enable the native quake action");
    foreach (invalid in [17, "ready", (1, 2, 3), []])
    {
        view.earthquake = invalid;
        rows = scripts\apparition\menu\fun_rows::build(view);
        row = rows[0];
        tests\support\checks::expect(!row.enabled && row.description == "Wait for a current earthquake readiness snapshot",
            "Missing and non-struct earthquake snapshots leave the action unavailable");
    }

    view = ready_view();
    view.earthquake = spawnstruct();
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for a current earthquake readiness snapshot",
        "A snapshot without a typed reason cannot enable Earthquake");
    view.earthquake.reason = 17;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for a current earthquake readiness snapshot",
        "A malformed readiness reason cannot enable Earthquake");
    view.earthquake.reason = "Wait for the native camera callback";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(!row.enabled && row.description == view.earthquake.reason,
        "A valid pending reason is shown without enabling the action");
}

an_absent_or_nonstruct_view_cannot_supply_a_ready_target()
{
    rows = scripts\apparition\menu\fun_rows::build(undefined);
    tests\support\checks::expect(rows.size == 37 && !rows[0].enabled && !isDefined(rows[0].target)
        && rows[0].description == "Wait for a valid player roster",
        "An absent view keeps the complete source page but supplies no action target");
    tests\support\checks::expect(!rows[23].enabled && !rows[23].checked
        && !isDefined(rows[23].target) && rows[23].description == "Wait for a valid player roster",
        "The missing-view health bar remains unchecked before any snapshot read");
    foreach (invalid in [0, "view", []])
    {
        rows = scripts\apparition\menu\fun_rows::build(invalid);
        tests\support\checks::expect(rows.size == 37 && !rows[0].enabled && !isDefined(rows[0].target)
            && !rows[23].enabled && !rows[23].checked && !isDefined(rows[23].target),
            "A scalar or array view cannot enter target or readiness member reads");
    }
}

rendering_does_not_change_target_or_store_earthquake_parameters()
{
    view = ready_view();
    view.target.QuakeSentinel = "unchanged";
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[0];
    tests\support\checks::expect(view.target.QuakeSentinel == "unchanged",
        "Rendering leaves target state unchanged");
    tests\support\checks::expect(!isDefined(row.checked)
        && !isDefined(row.origin) && !isDefined(row.strength) && !isDefined(row.duration)
        && !isDefined(row.radius) && !isDefined(row.parameters),
        "The row carries no toggle state or cached quake command parameters");

    view.target.HealthBarSentinel = "unchanged";
    view.health_bar = spawnstruct();
    view.health_bar.reason = "";
    view.health_bar.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[23];
    tests\support\checks::expect(row.checked && view.target.HealthBarSentinel == "unchanged"
        && view.health_bar.configured == 1,
        "The health bar row reads saved configuration without mutating the target or snapshot");
    tests\support\checks::expect(!isDefined(row.health) && !isDefined(row.current_health)
        && !isDefined(row.max_health) && !isDefined(row.health_fraction)
        && !isDefined(row.origin) && !isDefined(row.position) && !isDefined(row.angles)
        && !isDefined(row.handle) && !isDefined(row.hud) && !isDefined(row.element),
        "The health bar row caches no native health, handle or geometry data");

    view.target.FrogJumpSentinel = "unchanged";
    view.frog_jump = spawnstruct();
    view.frog_jump.reason = "";
    view.frog_jump.configured = 1;
    rows = scripts\apparition\menu\fun_rows::build(view);
    row = rows[21];
    tests\support\checks::expect(row.checked && view.target.FrogJumpSentinel == "unchanged"
        && view.frog_jump.configured == 1,
        "The Frog Jump row reads saved configuration without mutating target or snapshot");
    tests\support\checks::expect(!isDefined(row.velocity) && !isDefined(row.angles)
        && !isDefined(row.phase) && !isDefined(row.handle) && !isDefined(row.position)
        && !isDefined(row.origin) && !isDefined(row.native_state),
        "The Frog Jump row caches no raw velocity, phase, handle or geometry data");
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.target_actor_reason = "";
    view.earthquake = spawnstruct();
    view.earthquake.reason = "";
    return view;
}
