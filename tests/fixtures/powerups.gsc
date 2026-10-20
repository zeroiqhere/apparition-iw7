// Native-shaped loot tables keep readiness contracts away from live map state

state()
{
    state = spawnstruct();
    state.power_up_table = "runtime_selected_loot_table.csv";
    state.loot_info = [];
    state.loot_fx = [];
    state.loot_id = [];
    state.loot_icon = [];
    state._effect = [];

    contents = [];
    catalog = scripts\apparition\maps\spaceland\powerups::catalog();
    foreach (entry in catalog)
    {
        record = [];
        record["value"] = entry.id;
        record["last_time"] = 0;
        contents[contents.size] = record;

        state.loot_fx[entry.id] = "vfx/native/" + entry.id + ".vfx";
        state.loot_id[entry.id] = "" + entry.native_index;
        state.loot_icon[entry.id] = "zm_powerup_" + entry.id;
        state._effect[state.loot_fx[entry.id]] = "loaded_effect";
    }

    group = [];
    group["contents"] = contents;
    state.loot_info["kill_generic_zombie"] = group;

    state._effect["pickup"] = "loaded_pickup";
    state._effect["pickup_fnfmod"] = "loaded_pickup_fnfmod";
    state._effect["powerup_additive_fx"] = "loaded_additive";
    state._effect["big_explo"] = "loaded_big_explosion";
    state.fire_sale_func = ::callback;
    state.rebuild_all_windows_func = ::callback;
    state.upgrade_weapons_func = ::callback;
    return state;
}

callback()
{
}
