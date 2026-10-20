// Power-up descriptors preserve source navigation and separate settings from drops

run()
{
    the_main_powerup_link_keeps_its_source_position_and_owner();
    page_rows_keep_source_controls_and_host_drop_scope();
    location_preview_does_not_change_the_configured_owner_setting();
    each_drop_uses_its_native_snapshot_reason_without_blocking_other_items();
    guests_can_configure_location_but_cannot_spawn_world_pickups();
    missing_and_malformed_snapshots_fail_closed();
}

the_main_powerup_link_keeps_its_source_position_and_owner()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Main", view);
    tests\support\checks::expect(rows[4].label == "Power-Up Menu" && rows[4].destination == "Power-Up Menu"
        && rows[4].kind == "submenu", "Power-Up Menu keeps its original main-menu position and opens its page");
    tests\support\checks::expect(rows[4].target == view.owner && !rows[4].lobby,
        "Power-up navigation belongs to the menu owner after visiting another player");
}

page_rows_keep_source_controls_and_host_drop_scope()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(rows.size == 12 && rows[0].label == "Spawn Location"
        && rows[1].label == "Reign Drops" && rows[2].label == "", "The page keeps source controls before nine native pickups");
    tests\support\checks::expect(rows[0].kind == "slider" && rows[0].enabled
        && rows[0].callback == scripts\apparition\menu\actions::set_powerup_location
        && rows[0].target == view.owner && !rows[0].lobby, "Spawn Location configures only the owner");
    tests\support\checks::expect(rows[0].values.size == 2 && rows[0].values[0] == "Crosshairs"
        && rows[0].values[1] == "Self", "Spawn Location retains both original choices in order");
    tests\support\checks::expect(!rows[1].enabled && !isDefined(rows[1].callback)
        && !rows[2].enabled && !isDefined(rows[2].callback), "Reign Drops and the blank separator have no unverified gameplay callback");
    tests\support\checks::expect(rows[3].label == "Double Cash" && rows[11].label == "Weapon Upgrade",
        "Native drop rows follow the verified Spaceland group order");
    entries = scripts\apparition\maps\spaceland\powerups::catalog();
    for (index = 0; index < entries.size; index++)
    {
        row = rows[index + 3];
        tests\support\checks::expect(row.enabled && row.kind == "action" && row.lobby
            && !isDefined(row.target) && row.callback == scripts\apparition\menu\actions::drop_powerup
            && row.powerup_id == entries[index].id, "Each ready world pickup binds its own native ID through fresh host dispatch");
    }
}

location_preview_does_not_change_the_configured_owner_setting()
{
    view = view();
    view.owner.PowerUpSpawnLocation = "Self";
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Power-Up Menu";
    tests\support\checks::expect(rows[0].active_value == "Self"
        && scripts\apparition\menu\state::slider_value(state, rows[0]) == "Crosshairs", "Location preview is separate from the configured spawn location");
    tests\support\checks::expect(rows[0].description == "Configured: Self; Use applies the preview location",
        "The location footer distinguishes preview from the applied setting");
    scripts\apparition\menu\state::adjust_slider(state, rows[0], 1);
    tests\support\checks::expect(view.owner.PowerUpSpawnLocation == "Self"
        && !isDefined(view.target.PowerUpSpawnLocation), "Rendering and preview leave owner and selected guest settings unchanged");
    tests\support\checks::expect(isSubStr(rows[3].description, "near the host"),
        "A drop description uses the applied Self setting rather than the slider preview");
}

each_drop_uses_its_native_snapshot_reason_without_blocking_other_items()
{
    view = view();
    view.powerups.reasons["board_windows"] = "Wait for the native Carpenter callback";
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(!rows[7].enabled && rows[7].description == "Wait for the native Carpenter callback",
        "The unavailable item keeps its specific native callback explanation");
    tests\support\checks::expect(rows[3].enabled && rows[6].enabled && rows[11].enabled,
        "An unrelated callback does not disable ready native items");
    view.powerups.reason = "Aim at a permitted floor point";
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(rows[0].enabled && !rows[3].enabled && rows[3].description == view.powerups.reason,
        "Spatial failure blocks drops while leaving location configuration available");
}

guests_can_configure_location_but_cannot_spawn_world_pickups()
{
    view = view();
    view.host = false;
    view.powerups.reason = "Wait for native loot initialization";
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(rows[0].enabled && rows[0].target == view.owner,
        "A valid guest may configure a personal spawn location");
    for (index = 3; index < rows.size; index++)
        tests\support\checks::expect(!rows[index].enabled && rows[index].description == "Only the current host can spawn power-ups",
            "Guest permission copy takes precedence over native readiness");
}

missing_and_malformed_snapshots_fail_closed()
{
    view = view();
    view.powerups = undefined;
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[3].enabled,
        "Missing owner and drop admission cannot enable controls");
    foreach (invalid in [7, "ready", [], spawnstruct()])
    {
        view.powerups = invalid;
        rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
        tests\support\checks::expect(!rows[0].enabled && !rows[3].enabled,
            "Malformed native snapshots cannot claim owner or spawn readiness");
    }
    view = view();
    view.powerups.actor_reason = "The menu owner is unavailable";
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[3].enabled
        && rows[3].description == view.powerups.actor_reason, "Rejected owner admission disables both setting and world action");
    view = view();
    view.powerups.origin = undefined;
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(rows[0].enabled && !rows[3].enabled,
        "An empty reason cannot enable a drop without a valid captured point");
    view = view();
    view.powerups.reasons["cash_2"] = 0;
    rows = scripts\apparition\menu\model::build("Power-Up Menu", view);
    tests\support\checks::expect(!rows[3].enabled && rows[4].enabled,
        "A malformed item reason fails closed without disabling another ready item");
}

view()
{
    view = spawnstruct();
    view.access = "VIP";
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.host = true;
    view.powerups = scripts\apparition\maps\spaceland\powerups::inspect(tests\fixtures\powerups::state());
    // These fields represent the actor and spatial portion of a live probe
    view.powerups.actor_reason = "";
    view.powerups.origin = (100, 200, 0);
    return view;
}
