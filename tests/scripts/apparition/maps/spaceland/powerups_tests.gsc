// Power-up menu contracts follow the live Spaceland loot metadata

run()
{
    catalog_matches_the_supported_spaceland_entries_and_native_indices();
    lookup_accepts_only_known_string_ids();
    fully_ready_native_shaped_state_exposes_every_supported_row();
    malformed_common_tables_block_readiness_without_mutation();
    a_missing_id_disables_only_its_row();
    incomplete_assets_or_mismatched_indices_disable_only_the_affected_row();
    special_effect_rows_require_their_native_callbacks();
    inspection_does_not_repair_or_change_native_state();
}

catalog_matches_the_supported_spaceland_entries_and_native_indices()
{
    ids = ["cash_2", "kill_50", "instakill_30", "ammo_max", "board_windows",
        "infinite_20", "fire_30", "grenade_30", "upgrade_weapons"];
    labels = ["Double Cash", "Nuke", "Insta-Kill", "Max Ammo", "Carpenter",
        "Infinite Ammo", "Fire Sale", "Infinite Grenades", "Weapon Upgrade"];
    native_indices = [2, 1, 3, 4, 5, 7, 9, 8, 6];
    catalog = scripts\apparition\maps\spaceland\powerups::catalog();
    tests\support\checks::expect(isDefined(catalog) && isarray(catalog)
        && catalog.size == ids.size, "The catalog contains the nine normal Spaceland drops");
    if (!isDefined(catalog) || !isarray(catalog) || catalog.size != ids.size)
        return;

    for (index = 0; index < ids.size; index++)
    {
        tests\support\checks::expect(catalog[index].id == ids[index]
            && catalog[index].label == labels[index]
            && catalog[index].native_index == native_indices[index],
            "Each menu entry keeps the source-backed ID, label, and loot index");
    }
}

lookup_accepts_only_known_string_ids()
{
    entry = scripts\apparition\maps\spaceland\powerups::find("kill_50");
    tests\support\checks::expect(isDefined(entry) && entry.label == "Nuke"
        && entry.native_index == 1, "A supported string ID resolves to its catalog entry");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\powerups::find("power_off")),
        "A non-zombie-player loot entry is not in the menu catalog");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\powerups::find("")),
        "An empty string is not a power-up ID");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\powerups::find(2)),
        "A numeric index cannot be used as a loot ID");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\powerups::find(undefined)),
        "An undefined ID cannot resolve to a menu entry");
}

fully_ready_native_shaped_state_exposes_every_supported_row()
{
    state = tests\fixtures\powerups::state();
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(isDefined(result) && result.reason == "",
        "A complete native-shaped loot state has no common readiness issue");
    if (!isDefined(result) || !isDefined(result.reasons) || !isarray(result.reasons))
        return;

    foreach (entry in scripts\apparition\maps\spaceland\powerups::catalog())
        tests\support\checks::expect(result.reasons[entry.id] == "",
            "Every supported row is ready when its live metadata and effects are present");
}

malformed_common_tables_block_readiness_without_mutation()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(undefined).reason != "",
        "A missing map state cannot authorize power-up rows");

    state = tests\fixtures\powerups::state();
    state.power_up_table = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reason != "", "An unknown active loot table blocks all rows");

    state = tests\fixtures\powerups::state();
    state.power_up_table = "";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "An empty active loot table name blocks readiness");

    state = tests\fixtures\powerups::state();
    state.loot_fx = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "A malformed common native lookup table blocks readiness");

    state = tests\fixtures\powerups::state();
    state.loot_info["kill_generic_zombie"]["contents"] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "Native contents must remain an array");

    state = tests\fixtures\powerups::state();
    state.loot_info["kill_generic_zombie"]["contents"][0] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "Each native contents item must remain an associative array record");

    state = tests\fixtures\powerups::state();
    state.loot_info["kill_generic_zombie"]["contents"][0]["value"] = "";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "An empty native content value makes common readiness incomplete");

    state = tests\fixtures\powerups::state();
    contents = [];
    contents[0] = state.loot_info["kill_generic_zombie"]["contents"][0];
    contents[2] = state.loot_info["kill_generic_zombie"]["contents"][2];
    state.loot_info["kill_generic_zombie"]["contents"] = contents;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "Sparse native contents cannot be scanned as a complete loot list");

    state = tests\fixtures\powerups::state();
    state._effect["pickup_fnfmod"] = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reason != "", "Missing common pickup effects block readiness");
    tests\support\checks::expect(result.reasons.size == 0,
        "A common setup failure uses one shared reason without fabricated item results");

    state = tests\fixtures\powerups::state();
    state.active_spawn_volumes = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "A defined malformed active-volume table blocks native spatial use");

    state = tests\fixtures\powerups::state();
    state.invalid_spawn_volume_array = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\powerups::inspect(state).reason != "",
        "A defined malformed invalid-volume table blocks native spatial use");
}

a_missing_id_disables_only_its_row()
{
    state = tests\fixtures\powerups::state();
    contents = [];
    foreach (record in state.loot_info["kill_generic_zombie"]["contents"])
    {
        if (record["value"] != "cash_2")
            contents[contents.size] = record;
    }
    state.loot_info["kill_generic_zombie"]["contents"] = contents;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.reasons["cash_2"] != "",
        "An ID absent from the active table disables that row");
    tests\support\checks::expect(result.reasons["kill_50"] == ""
        && result.reasons["instakill_30"] == "", "An absent ID leaves unrelated rows ready");

    state = tests\fixtures\powerups::state();
    state.loot_info["kill_generic_zombie"]["contents"][1]["value"] = "cash_2";
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["cash_2"] != "",
        "Duplicate live membership is ambiguous and disables that row");
    tests\support\checks::expect(result.reasons["kill_50"] != "",
        "Duplicate membership also removes the duplicated ID from a different row");
    tests\support\checks::expect(result.reasons["instakill_30"] == "",
        "Duplicate membership does not block unrelated entries");
}

incomplete_assets_or_mismatched_indices_disable_only_the_affected_row()
{
    state = tests\fixtures\powerups::state();
    state.loot_fx["kill_50"] = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["kill_50"] != ""
        && result.reasons["cash_2"] == "", "A missing row FX path does not block other rows");

    state = tests\fixtures\powerups::state();
    state.loot_icon["ammo_max"] = "";
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["ammo_max"] != ""
        && result.reasons["board_windows"] == "", "A missing row icon disables only its own row");

    state = tests\fixtures\powerups::state();
    state._effect[state.loot_fx["grenade_30"]] = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["grenade_30"] != ""
        && result.reasons["infinite_20"] == "", "An unloaded row FX disables only its own row");

    state = tests\fixtures\powerups::state();
    state.loot_id["fire_30"] = "08";
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["fire_30"] != ""
        && result.reasons["grenade_30"] == "", "A non-exact metadata index disables only its row");

    state = tests\fixtures\powerups::state();
    state.loot_id["upgrade_weapons"] = 6;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["upgrade_weapons"] == "",
        "A numeric native index is accepted when it matches the catalog");

    state = tests\fixtures\powerups::state();
    state._effect["big_explo"] = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["kill_50"] != ""
        && result.reasons["cash_2"] == "", "Nuke readiness requires the native explosion effect");
}

special_effect_rows_require_their_native_callbacks()
{
    state = tests\fixtures\powerups::state();
    state.fire_sale_func = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["fire_30"] != ""
        && result.reasons["cash_2"] == "", "Fire Sale requires its native callback");

    state = tests\fixtures\powerups::state();
    state.rebuild_all_windows_func = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["board_windows"] != ""
        && result.reasons["ammo_max"] == "", "Carpenter requires its native callback");

    state = tests\fixtures\powerups::state();
    state.upgrade_weapons_func = undefined;
    result = scripts\apparition\maps\spaceland\powerups::inspect(state);
    tests\support\checks::expect(result.reasons["upgrade_weapons"] != ""
        && result.reasons["grenade_30"] == "", "Weapon Upgrade requires its native callback");
}

inspection_does_not_repair_or_change_native_state()
{
    state = tests\fixtures\powerups::state();
    contents = state.loot_info["kill_generic_zombie"]["contents"];
    first_record = contents[0];
    original_value = first_record["value"];
    original_time = first_record["last_time"];
    original_fx = state.loot_fx["cash_2"];
    original_index = state.loot_id["cash_2"];
    original_icon = state.loot_icon["cash_2"];
    scripts\apparition\maps\spaceland\powerups::inspect(state);

    tests\support\checks::expect(first_record["value"] == original_value
        && first_record["last_time"] == original_time, "Inspection preserves native content records");
    tests\support\checks::expect(state.loot_fx["cash_2"] == original_fx
        && state.loot_id["cash_2"] == original_index
        && state.loot_icon["cash_2"] == original_icon,
        "Inspection does not rewrite native per-power metadata");
    tests\support\checks::expect(state.power_up_table == "runtime_selected_loot_table.csv",
        "Inspection does not choose or replace the active loot table");
}
