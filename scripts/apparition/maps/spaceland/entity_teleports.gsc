// Native interaction references identify destinations without caching coordinates

probe()
{
    return inspect(level, getEntArray("magic_wheel", "script_noteworthy"));
}

inspect(state, wheels)
{
    result = spawnstruct();
    result.reason = "Wait for native entity destinations";
    result.entries = [];
    if (!isDefined(state) || !isDefined(wheels) || !isarray(wheels)
        || !isDefined(state.struct_class_names) || !isarray(state.struct_class_names))
        return result;
    names = state.struct_class_names["script_noteworthy"];
    if (!isDefined(names) || !isarray(names))
        return result;

    entries = [];
    wheel = state.current_active_wheel;
    if (isDefined(wheel))
    {
        // Area changes precede the new pointer while native activation is finishing
        // The encoded A8E2 token is the native selected-area field
        if (!scripts\engine\utility::array_contains(wheels, wheel)
            || !point_ready(wheel) || !isDefined(wheel.script_noteworthy)
            || wheel.script_noteworthy != "magic_wheel"
            || !isDefined(wheel.area_name) || !isstring(wheel.area_name)
            || !isDefined(state._id_A8E2) || !isstring(state._id_A8E2)
            || wheel.area_name != state._id_A8E2)
            return result;
        entries[entries.size] = entry("wheel", "magic_wheel", "Mystery Box", wheel);
    }
    else if (wheels.size)
        return result;

    // The shared perk catalog owns IDs and names; each native array owns its order
    foreach (perk in scripts\apparition\maps\spaceland\perks::catalog())
    {
        registry = names[perk.id];
        if (!isDefined(registry))
            continue;
        if (!isarray(registry))
            return result;
        for (index = 0; index < registry.size; index++)
        {
            point = registry[index];
            if (!point_ready(point) || !isstruct(point)
                || !isDefined(point.script_noteworthy) || point.script_noteworthy != perk.id)
                return result;
            entries[entries.size] = entry("perk", perk.id, perk.label, point);
        }
    }

    // Only the full validated snapshot becomes visible to the menu
    result.entries = entries;
    result.reason = "";
    return result;
}

point_ready(point)
{
    // Wheels are entities and perk interactions are authored script structures
    return isDefined(point) && (isstruct(point) || isent(point))
        && isDefined(point.origin) && isvector(point.origin)
        && isDefined(point.angles) && isvector(point.angles);
}

entry(kind, id, label, point)
{
    item = spawnstruct();
    item.kind = kind;
    item.id = id;
    item.label = label;
    item.point = point;
    return item;
}

resolve(state, wheels, captured)
{
    if (!isDefined(captured) || !isstruct(captured)
        || !isDefined(captured.kind) || !isstring(captured.kind)
        || !isDefined(captured.id) || !isstring(captured.id)
        || !isDefined(captured.point))
        return undefined;
    current = inspect(state, wheels);
    if (current.reason != "")
        return undefined;
    foreach (item in current.entries)
    {
        // Equal coordinates, display names or array indexes do not replace identity
        if (item.kind == captured.kind && item.id == captured.id && item.point == captured.point)
            return item;
    }
    return undefined;
}
