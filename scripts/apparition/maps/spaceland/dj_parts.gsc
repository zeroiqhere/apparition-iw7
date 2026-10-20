// Native Spaceland fetch quest records stay owned by the game callback

catalog()
{
    parts = [];
    parts[parts.size] = part(1, "dj_quest_part_1", "zmb_frequency_device_radio");
    parts[parts.size] = part(2, "dj_quest_part_2", "zmb_frequency_device_calculator");
    parts[parts.size] = part(3, "dj_quest_part_3", "zmb_frequency_device_umbrella_ground");
    return parts;
}

part(slot, id, model)
{
    result = spawnstruct();
    result.slot = slot;
    result.id = id;
    result.model = model;
    return result;
}

inspect(state)
{
    result = snapshot("Wait for the native DJ part state");
    if (!isDefined(state))
        return result;

    parts = catalog();
    found = [];
    collected = 0;
    for (index = 0; index < parts.size; index++)
    {
        value = part_flag(state, parts[index].slot);
        // Absent flags and zero both represent an uncollected native part
        if (isDefined(value) && !isnumber(value))
            return result;
        found[index] = isDefined(value) && value != 0;
        if (found[index])
            collected++;
    }

    result.collected = collected;
    // Picked-up models are deleted, so the completed state needs no registry lookup
    if (collected == parts.size)
    {
        result.reason = "All native DJ parts are collected";
        return result;
    }

    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    if (step < 0)
    {
        result.reason = "Wait for the native DJ quest state";
        return result;
    }
    if (step != 0)
    {
        result.reason = "DJ parts are not the current quest step";
        return result;
    }

    if (!isDefined(state.selected_dj_parts) || !isarray(state.selected_dj_parts))
        return reject(result, "Wait for the native DJ part models");

    seen_points = [];
    seen_models = [];
    for (index = 0; index < parts.size; index++)
    {
        if (found[index])
            continue;

        expected = parts[index];
        point = state.selected_dj_parts[expected.slot];
        if (!isDefined(point) || !isstruct(point))
            return reject(result, "Wait for the native DJ part models");
        if (scripts\engine\utility::array_contains(seen_points, point))
            return reject(result, "Native DJ part records are ambiguous");
        seen_points[seen_points.size] = point;

        if (!isDefined(point.script_noteworthy) || !isstring(point.script_noteworthy)
            || point.script_noteworthy != expected.id
            || !isDefined(point.groupname) || !isstring(point.groupname) || point.groupname == ""
            || !isDefined(point.part_model))
            return reject(result, "Wait for the native DJ part models");

        model = point.part_model;
        if (scripts\engine\utility::array_contains(seen_models, model))
            return reject(result, "Native DJ part models are ambiguous");
        seen_models[seen_models.size] = model;
        result.targets[result.targets.size] = point;
    }

    result.reason = "";
    return result;
}

part_flag(state, slot)
{
    if (slot == 1)
        return state.dj_part_1_found;
    if (slot == 2)
        return state.dj_part_2_found;
    return state.dj_part_3_found;
}

reject(result, reason)
{
    result.reason = reason;
    result.targets = [];
    return result;
}

probe(owner)
{
    result = snapshot("Only the current living host can collect DJ parts");
    reason = scripts\apparition\runtime\context::actor_reason([owner]);
    if (reason != "")
    {
        result.reason = reason;
        return result;
    }
    if (!scripts\apparition\runtime\context::supported())
    {
        result.reason = "DJ parts require private normal Spaceland";
        return result;
    }

    // Native slot zero is used by the stock callback, so admit the full roster first
    reason = scripts\apparition\runtime\context::actor_reason(level.players);
    if (reason != "")
    {
        result.reason = reason;
        return result;
    }
    if (!scripts\apparition\runtime\context::in_roster(level.players, owner)
        || !scripts\apparition\runtime\access::can_open(owner)
        || !scripts\apparition\runtime\context::living_host(owner))
        return result;

    result = inspect(level);
    if (result.reason != "" || !result.targets.size)
        return result;

    // The native pickup callback uses this active list, effect and completion flag
    if (!isDefined(level.current_interaction_structs) || !isarray(level.current_interaction_structs))
        return reject(result, "Wait for native DJ part interactions");
    if (!isDefined(level._effect) || !isarray(level._effect)
        || !isDefined(level._effect["souvenir_pickup"]))
        return reject(result, "Wait for the native DJ pickup effect");
    if (!isDefined(level.flag) || !isarray(level.flag)
        || !isDefined(level.flag["dj_fetch_quest_completed"])
        || !isnumber(level.flag["dj_fetch_quest_completed"])
        || level.flag["dj_fetch_quest_completed"] != 0)
        return reject(result, "Wait for the native DJ quest flag");

    // Keep each live model paired with its native slot from the canonical catalog
    parts = catalog();
    foreach (expected in parts)
    {
        point = level.selected_dj_parts[expected.slot];
        if (!scripts\engine\utility::array_contains(result.targets, point))
            continue;
        if (!scripts\engine\utility::array_contains(level.current_interaction_structs, point))
            return reject(result, "A native DJ part is no longer active");
        reason = live_model_reason(point, expected.model);
        if (reason != "")
            return reject(result, reason);
    }
    return result;
}

live_model_reason(point, model_name)
{
    model = point.part_model;
    if (!isDefined(model) || !isent(model)
        || !isDefined(model.model) || !isstring(model.model) || model.model != model_name
        || !isDefined(model.origin) || !isvector(model.origin))
        return "The native DJ part model is not initialized";
    return "";
}

collect(owner)
{
    result = probe(owner);
    if (result.reason != "" || !result.targets.size)
        return false;

    // The stock callback owns sound, analytics, model deletion, interaction cleanup and quest flags
    level scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_fetch_quest();
    return inspect(level).collected == 3;
}

snapshot(reason)
{
    result = spawnstruct();
    result.reason = reason;
    result.collected = -1;
    result.total = 3;
    result.targets = [];
    return result;
}
