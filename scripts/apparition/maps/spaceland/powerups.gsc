// The menu catalog is limited to the ordinary Spaceland zombie drops

catalog()
{
    entries = [];
    entries[entries.size] = entry("cash_2", "Double Cash", 2);
    entries[entries.size] = entry("kill_50", "Nuke", 1);
    entries[entries.size] = entry("instakill_30", "Insta-Kill", 3);
    entries[entries.size] = entry("ammo_max", "Max Ammo", 4);
    entries[entries.size] = entry("board_windows", "Carpenter", 5);
    entries[entries.size] = entry("infinite_20", "Infinite Ammo", 7);
    entries[entries.size] = entry("fire_30", "Fire Sale", 9);
    entries[entries.size] = entry("grenade_30", "Infinite Grenades", 8);
    entries[entries.size] = entry("upgrade_weapons", "Weapon Upgrade", 6);
    return entries;
}

entry(id, label, native_index)
{
    powerup = spawnstruct();
    powerup.id = id;
    powerup.label = label;
    powerup.native_index = native_index;
    return powerup;
}

find(id)
{
    // IDs are finite source entries, not arbitrary table keys
    if (!isDefined(id) || !isstring(id) || id == "")
        return undefined;

    foreach (powerup in catalog())
    {
        if (powerup.id == id)
            return powerup;
    }
    return undefined;
}

inspect(state)
{
    result = spawnstruct();
    result.reason = common_reason(state);
    result.reasons = [];
    if (result.reason != "")
        return result;

    // Shared loader state is checked once before evaluating individual rows
    foreach (powerup in catalog())
        result.reasons[powerup.id] = entry_reason(state, powerup);
    return result;
}

common_reason(state)
{
    if (!isDefined(state) || !isDefined(state.power_up_table)
        || !isstring(state.power_up_table) || state.power_up_table == "")
        return "Wait for the active native loot table";

    // The native loader stores these maps as associative arrays
    if (!isDefined(state.loot_info) || !isarray(state.loot_info)
        || !isDefined(state.loot_fx) || !isarray(state.loot_fx)
        || !isDefined(state.loot_id) || !isarray(state.loot_id)
        || !isDefined(state.loot_icon) || !isarray(state.loot_icon)
        || !isDefined(state._effect) || !isarray(state._effect))
        return "Wait for native loot metadata";

    group = state.loot_info["kill_generic_zombie"];
    if (!isDefined(group) || !isarray(group)
        || !isDefined(group["contents"]) || !isarray(group["contents"])
        || group["contents"].size == 0)
        return "Wait for native power-up contents";

    // Native contents are a dense list of associative records
    contents = group["contents"];
    for (index = 0; index < contents.size; index++)
    {
        record = contents[index];
        if (!isDefined(record) || !isarray(record)
            || !isDefined(record["value"]) || !isstring(record["value"])
            || record["value"] == "")
            return "Wait for complete native power-up contents";
    }

    // Required pickup effects are loaded by native power-up setup
    foreach (effect_name in ["pickup", "pickup_fnfmod", "powerup_additive_fx"])
    {
        if (!isDefined(state._effect[effect_name]))
            return "Wait for native pickup effects";
    }

    // These optional tables may be absent, but native consumers expect arrays when present
    if ((isDefined(state.active_spawn_volumes) && !isarray(state.active_spawn_volumes))
        || (isDefined(state.invalid_spawn_volume_array) && !isarray(state.invalid_spawn_volume_array)))
        return "Wait for valid native spawn-volume arrays";

    return "";
}

entry_reason(state, powerup)
{
    matches = 0;
    foreach (record in state.loot_info["kill_generic_zombie"]["contents"])
    {
        if (record["value"] == powerup.id)
            matches++;
    }
    if (matches != 1)
        return "Wait for one matching entry in the active loot table";

    fx = state.loot_fx[powerup.id];
    icon = state.loot_icon[powerup.id];
    if (!isDefined(fx) || !isstring(fx) || fx == ""
        || !isDefined(icon) || !isstring(icon) || icon == "")
        return "Wait for native effect and icon metadata";

    if (!index_matches(state.loot_id[powerup.id], powerup.native_index))
        return "Wait for the matching native power-up index";

    if (!isDefined(state._effect[fx]))
        return "Wait for the loaded native power-up effect";

    // Nuke content directly consumes this separately loaded effect
    if (powerup.id == "kill_50" && !isDefined(state._effect["big_explo"]))
        return "Wait for the native Nuke effect";

    // These content handlers are conditional in the stock loot script
    if (powerup.id == "fire_30" && !isDefined(state.fire_sale_func))
        return "Wait for the native Fire Sale callback";
    if (powerup.id == "board_windows" && !isDefined(state.rebuild_all_windows_func))
        return "Wait for the native Carpenter callback";
    if (powerup.id == "upgrade_weapons" && !isDefined(state.upgrade_weapons_func))
        return "Wait for the native Weapon Upgrade callback";

    return "";
}

index_matches(value, expected)
{
    // Native table lookups return text, and parsed numeric indices also remain valid
    if (!isDefined(value))
        return false;
    if (isnumber(value))
        return value == expected;
    if (!isstring(value))
        return false;

    expected_text = "" + expected;
    return value == expected_text;
}
