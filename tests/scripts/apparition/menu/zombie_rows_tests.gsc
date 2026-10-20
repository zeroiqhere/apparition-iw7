// Zombie menu contracts retain the source Spaceland order and honest mode availability

run()
{
    invisibility_is_a_typed_global_toggle_without_captured_enemies();
    invisibility_rejects_denied_and_malformed_snapshots();
    invisibility_callback_rejects_personal_or_captured_target_scope();
    source_rows_keep_the_spaceland_order_and_only_bind_supported_actions();
    kill_modes_separate_death_from_unported_native_effects();
    host_and_native_snapshot_reasons_precede_action_admission();
    no_captured_actor_list_or_active_effect_is_published_on_the_row();
    movement_retains_four_source_choices_and_blocks_the_unmapped_super_sprint();
    movement_rechecks_host_snapshot_and_empty_target_reasons();
    movement_preview_has_no_captured_targets_or_global_active_mode();
}

source_rows_keep_the_spaceland_order_and_only_bind_supported_actions()
{
    view = ready_view();
    rows = scripts\apparition\menu\zombie_rows::build(view);
    expected = ["Spawner", "Prioritize", "Death Effect", "Damage Effect", "Animations", "Model", "Gib",
        "Kill", "Health", "Movement", "Knockdown", "Teleport", "Animation Speed", "Teleport To Crosshairs",
        "Disable Player Collision", "Disable Spawning", "Disable Push", "Invisibility", "Freeze", "Death Sounds",
        "Projectile Vomit", "Disappearing Zombies", "Exploding Zombies", "Ragdoll After Death", "Stack Zombies",
        "Remove Eyes", "Bodies Float", "Make Crawlers", "Detach Heads", "Clear All Corpses"];
    tests\support\checks::expect(rows.size == expected.size, "Spaceland keeps the thirty original zombie controls without the Shadows-only Push row");
    if (rows.size != expected.size)
        return;
    for (index = 0; index < rows.size; index++)
    {
        tests\support\checks::expect(rows[index].label == expected[index], "Zombie controls retain their source order");
        if (index == 7)
            tests\support\checks::expect(rows[index].kind == "slider" && rows[index].enabled
                && rows[index].callback == scripts\apparition\menu\actions::kill_zombies
                && rows[index].lobby && !isDefined(rows[index].target), "Kill binds a fresh host-wide request without a selected player target");
        else if (index == 8)
            tests\support\checks::expect(rows[index].kind == "slider" && rows[index].enabled
                && rows[index].callback == scripts\apparition\menu\actions::set_zombie_health
                && rows[index].lobby && !isDefined(rows[index].target),
                "Health binds the owner numberpad at its source position without a cached value or actor");
        else if (index == 9)
            tests\support\checks::expect(rows[index].kind == "slider" && rows[index].enabled
                && rows[index].callback == scripts\apparition\menu\actions::set_zombie_movement
                && rows[index].lobby && !isDefined(rows[index].target),
                "Movement binds one fresh host-wide request at its source position");
        else if (index == 17)
            tests\support\checks::expect(rows[index].kind == "toggle" && rows[index].enabled
                && rows[index].callback == scripts\apparition\menu\actions::toggle_zombie_visibility
                && rows[index].lobby && !isDefined(rows[index].target),
                "Invisibility keeps its source slot and global scope");
        else
            tests\support\checks::expect(!rows[index].enabled && !isDefined(rows[index].callback),
                "Unmapped zombie controls do not advertise executable callbacks");
    }
    tests\support\checks::expect(rows[18].description == "A reversible IW7 AI freeze binding is unresolved",
        "The source Freeze position retains its actual unresolved-binding reason");
    model = scripts\apparition\menu\model::build("Zombie Options", view);
    tests\support\checks::expect(model.size == 30 && model[7].label == "Kill",
        "The menu route reaches the full source page rather than the old single Freeze placeholder");
}

kill_modes_separate_death_from_unported_native_effects()
{
    view = ready_view();
    row = scripts\apparition\menu\zombie_rows::build(view)[7];
    expected = ["Death", "Head Gib", "Flame", "Delete"];
    tests\support\checks::expect(row.values.size == expected.size && row.initial_index == 0,
        "Kill starts with source Death and retains all four source choices");
    if (row.values.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(row.values[index] == expected[index], "Kill choice order matches the original source");
        tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, expected[index]) == (index == 0),
            "Only the mapped Death choice passes the same input availability gate");
    }
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Death") == view.zombie_kill.hint,
        "Death previews the current native request hint");
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Delete") == "Delete is not available in this build",
        "An unported deletion preview cannot imply a native death or counter update");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, true, "Death"),
        "A running callback prevents overlapping kill requests");
}

host_and_native_snapshot_reasons_precede_action_admission()
{
    view = ready_view();
    view.host = false;
    view.zombie_kill = undefined;
    row = scripts\apparition\menu\zombie_rows::build(view)[7];
    tests\support\checks::expect(!row.enabled && row.description == "Only the current host can request zombie deaths",
        "Guest denial precedes missing native snapshot details");
    view = ready_view();
    view.zombie_kill.reason = "The native agent death handlers changed";
    row = scripts\apparition\menu\zombie_rows::build(view)[7];
    tests\support\checks::expect(!row.enabled && row.description == view.zombie_kill.reason,
        "Native admission loss disables Death before input");
    foreach (snapshot in [7, [], spawnstruct()])
    {
        view = ready_view();
        view.zombie_kill = snapshot;
        row = scripts\apparition\menu\zombie_rows::build(view)[7];
        tests\support\checks::expect(!row.enabled && row.description == "Wait for a current zombie snapshot",
            "Malformed or incomplete snapshot data cannot enable Death");
    }
    view = ready_view();
    view.zombie_kill.targets = [];
    row = scripts\apparition\menu\zombie_rows::build(view)[7];
    tests\support\checks::expect(!row.enabled && row.description == "No eligible current zombies can receive Death",
        "An empty eligible list cannot advertise a useful native request");
    row = scripts\apparition\menu\zombie_rows::build(undefined)[7];
    tests\support\checks::expect(!row.enabled, "A missing view produces only inert zombie controls");
}

no_captured_actor_list_or_active_effect_is_published_on_the_row()
{
    view = ready_view();
    row = scripts\apparition\menu\zombie_rows::build(view)[7];
    tests\support\checks::expect(!isDefined(row.targets) && !isDefined(row.zombies)
        && !isDefined(row.active_value) && !isDefined(row.checked),
        "A one-pass death request has no cached victims or persistent active-mode claim");
    tests\support\checks::expect(view.zombie_kill.targets.size == 1 && view.zombie_kill.reason == "",
        "Rendering changes neither the native snapshot nor its readiness");
}

movement_retains_four_source_choices_and_blocks_the_unmapped_super_sprint()
{
    view = ready_view();
    row = scripts\apparition\menu\zombie_rows::build(view)[9];
    expected = ["Walk", "Run", "Sprint", "Super Sprint"];
    tests\support\checks::expect(row.label == "Movement" && row.values.size == 4 && row.initial_index == 0,
        "Movement keeps all four source choices and defaults its preview to Walk");
    if (row.values.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(row.values[index] == expected[index],
            "Movement preserves the original choice order");
        tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, expected[index]) == (index < 3),
            "Only the three mapped native movement choices pass the input gate");
    }
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Sprint") == view.zombie_movement.hint,
        "Supported previews describe the current native movement request");
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Super Sprint") == "Super Sprint has no verified IW7 movement mapping",
        "The unmapped preview explains its actual native binding gap");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, true, "Walk"),
        "A busy callback cannot submit an overlapping movement request");
}

movement_rechecks_host_snapshot_and_empty_target_reasons()
{
    view = ready_view();
    view.host = false;
    view.zombie_movement = undefined;
    row = scripts\apparition\menu\zombie_rows::build(view)[9];
    tests\support\checks::expect(!row.enabled && row.description == "Only the current host can request zombie movement",
        "Host denial precedes an absent movement snapshot");
    view = ready_view();
    view.zombie_movement.reason = "Wait for native movement state";
    row = scripts\apparition\menu\zombie_rows::build(view)[9];
    tests\support\checks::expect(!row.enabled && row.description == view.zombie_movement.reason,
        "A rejected native movement snapshot blocks all movement choices");
    foreach (snapshot in [17, [], spawnstruct()])
    {
        view = ready_view();
        view.zombie_movement = snapshot;
        row = scripts\apparition\menu\zombie_rows::build(view)[9];
        tests\support\checks::expect(!row.enabled && row.description == "Wait for a current zombie snapshot",
            "Malformed movement snapshots cannot enable requests");
    }
    view = ready_view();
    view.zombie_movement.targets = [];
    row = scripts\apparition\menu\zombie_rows::build(view)[9];
    tests\support\checks::expect(!row.enabled && row.description == "No eligible current zombies can receive Movement",
        "An empty native movement selection remains unavailable");
    row = scripts\apparition\menu\zombie_rows::build(undefined)[9];
    tests\support\checks::expect(!row.enabled, "A missing view cannot expose movement input");
}

movement_preview_has_no_captured_targets_or_global_active_mode()
{
    view = ready_view();
    row = scripts\apparition\menu\zombie_rows::build(view)[9];
    tests\support\checks::expect(!isDefined(row.targets) && !isDefined(row.zombies)
        && !isDefined(row.active_value) && !isDefined(row.checked),
        "The Movement slider cannot reuse displayed agents or claim a persistent global policy");
    tests\support\checks::expect(view.zombie_movement.reason == "" && view.zombie_movement.targets.size == 1,
        "Building the movement row does not change its native snapshot");
}

ready_view()
{
    view = spawnstruct();
    view.host = true;
    view.zombie_health = spawnstruct();
    view.zombie_health.reason = "";
    view.zombie_health.configured = false;
    view.zombie_kill = spawnstruct();
    view.zombie_kill.reason = "";
    view.zombie_kill.hint = "Request Death for the current eligible native zombies; spawning and quest progress remain native";
    view.zombie_kill.targets = [spawnstruct()];
    view.zombie_visibility = spawnstruct();
    view.zombie_visibility.reason = "";
    view.zombie_visibility.configured = false;
    view.zombie_movement = spawnstruct();
    view.zombie_movement.reason = "";
    view.zombie_movement.hint = "Request movement for current ordinary zombies; native callbacks and temporary effects may replace it";
    view.zombie_movement.targets = [spawnstruct()];
    return view;
}

// Configuration hints describe requests rather than measured renderer state

invisibility_is_a_typed_global_toggle_without_captured_enemies()
{
    view = ready_view();
    row = scripts\apparition\menu\zombie_rows::build(view)[17];
    tests\support\checks::expect(row.enabled && !row.checked && row.kind == "toggle"
        && row.callback == scripts\apparition\menu\actions::toggle_zombie_visibility
        && row.lobby && !isDefined(row.target) && !isDefined(row.targets),
        "The source Invisibility row dispatches a fresh global request without retaining enemies");
    tests\support\checks::expect(row.description == "Hide living Axis agents every 0.5s, including special and quest enemies; snapshots do not measure visibility",
        "The off hint discloses the full source enemy scope and measurement limit");
    view.zombie_visibility.configured = true;
    row = scripts\apparition\menu\zombie_rows::build(view)[17];
    tests\support\checks::expect(row.enabled && row.checked
        && row.description == "Configured on; Use stops hiding and requests Show for current living Axis agents; prior visibility is not restored",
        "The on hint describes stopping enforcement and showing the current living set");
    tests\support\checks::expect(view.zombie_visibility.configured && view.zombie_visibility.reason == "",
        "Rendering leaves the visibility snapshot unchanged");
}

invisibility_rejects_denied_and_malformed_snapshots()
{
    view = ready_view();
    view.host = false;
    row = scripts\apparition\menu\zombie_rows::build(view)[17];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Only the current host can change zombie visibility",
        "A guest cannot expose saved state or execute the world control");
    view = ready_view();
    view.zombie_visibility.configured = true;
    view.zombie_visibility.reason = "Wait for private Spaceland";
    row = scripts\apparition\menu\zombie_rows::build(view)[17];
    tests\support\checks::expect(!row.enabled && row.checked && row.description == view.zombie_visibility.reason,
        "A typed denial preserves configured intent without claiming an active effect");
    foreach (value in [undefined, 1, "on", [], spawnstruct()])
    {
        view.zombie_visibility = value;
        tests\support\checks::expect(!scripts\apparition\menu\zombie_rows::build(view)[17].enabled,
            "Absent or malformed visibility snapshots cannot enable the callback");
    }
    view = ready_view();
    foreach (value in [undefined, "1", 2, -1, [], spawnstruct()])
    {
        view.zombie_visibility.configured = value;
        tests\support\checks::expect(!scripts\apparition\menu\zombie_rows::build(view)[17].enabled,
            "Configured snapshots require an exact numeric Boolean");
    }
    view = ready_view();
    view.zombie_visibility = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\zombie_rows::build(view)[17].enabled,
        "A host without a captured visibility snapshot cannot execute the row");
    view.zombie_visibility = spawnstruct();
    view.zombie_visibility.reason = "";
    tests\support\checks::expect(!scripts\apparition\menu\zombie_rows::build(view)[17].enabled,
        "A readable reason cannot replace a missing configured value");
    row = scripts\apparition\menu\zombie_rows::invisibility_row(undefined);
    tests\support\checks::expect(!row.enabled && !row.checked,
        "A missing view cannot enable a native enemy request");
}


invisibility_callback_rejects_personal_or_captured_target_scope()
{
    owner = spawnstruct();
    row = spawnstruct();
    row.lobby = false;
    tests\support\checks::expect(!(owner scripts\apparition\menu\actions::toggle_zombie_visibility(row, undefined)),
        "A personal row cannot reach the global visibility provider");
    row.lobby = true;
    row.target = spawnstruct();
    tests\support\checks::expect(!(owner scripts\apparition\menu\actions::toggle_zombie_visibility(row, undefined)),
        "A captured target cannot replace the fresh native team query");
}
