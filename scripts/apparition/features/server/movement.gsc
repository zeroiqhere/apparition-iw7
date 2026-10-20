// Global movement controls use the two startup values captured before player setup

catalog()
{
    gravity = spawnstruct();
    gravity.id = "low_gravity";
    gravity.target = 200.0;
    gravity.dvar = "bg_gravity";
    gravity.kind = "float";

    speed = spawnstruct();
    speed.id = "super_speed";
    speed.target = 500;
    speed.dvar = "g_speed";
    speed.kind = "int";

    return [gravity, speed];
}

control_for(id)
{
    if (!isDefined(id) || !isstring(id))
        return undefined;

    foreach (control in catalog())
    {
        if (control.id == id)
            return control;
    }

    return undefined;
}

valid_native_value(id, value)
{
    control = control_for(id);
    if (!isDefined(control) || !isDefined(value) || !isnumber(value))
        return false;

    // The float dvar has explicit native bounds; speed values come from getDvarInt
    if (control.kind == "float")
        return value >= 1.0 && value <= 1000.0;

    // Speed values are read and captured only through the native int32 getter
    return control.kind == "int";
}

next_value(id, current, baseline)
{
    control = control_for(id);
    if (!isDefined(control) || !valid_native_value(id, current)
        || !valid_native_value(id, baseline))
        return undefined;

    // Preserve the original comparison: every non-baseline live value selects baseline
    return current == baseline ? control.target : baseline;
}

read_native(control)
{
    if (control.kind == "float")
        return getDvarFloat(control.dvar);

    if (control.kind == "int")
        return getDvarInt(control.dvar);

    return undefined;
}

initialize()
{
    // A defined store is the startup snapshot, even when partial or malformed
    if (isDefined(level.apparition_server_movement_baselines))
        return;

    baselines = [];

    foreach (control in catalog())
    {
        if (getDvar(control.dvar) == "")
            continue;

        baseline = read_native(control);
        if (valid_native_value(control.id, baseline))
            baselines[control.id] = baseline;
    }

    // Publish once so missing startup reads can never be filled later
    level.apparition_server_movement_baselines = baselines;
}

probe(owner, id)
{
    state = spawnstruct();
    state.id = id;
    state.reason = "";
    state.current = undefined;
    state.target = undefined;
    state.checked = undefined;
    state.enabled = 0;
    state.next_value = undefined;

    control = control_for(id);
    if (!isDefined(control))
    {
        state.reason = "Unsupported server movement control";
        return state;
    }
    state.target = control.target;

    // Admit current Co-Host access before reading native dvars or the startup baseline
    state.reason = scripts\apparition\features\server\context::reason(owner);
    if (state.reason != "")
        return state;

    if (getDvar(control.dvar) == "")
    {
        state.reason = "The native movement setting is unavailable";
        return state;
    }

    current = read_native(control);
    if (isDefined(current) && isnumber(current))
    {
        state.current = current;
        state.checked = current == control.target;
    }
    if (!valid_native_value(id, current))
    {
        state.reason = "The native movement setting is invalid";
        return state;
    }

    baseline = undefined;
    if (isDefined(level.apparition_server_movement_baselines)
        && isarray(level.apparition_server_movement_baselines))
        baseline = level.apparition_server_movement_baselines[id];
    if (!isDefined(baseline))
    {
        state.reason = "The movement startup value was unavailable when controls initialized";
        return state;
    }
    if (!valid_native_value(id, baseline))
    {
        state.reason = "The captured movement startup value is invalid";
        return state;
    }
    // Equal endpoints offer no change and must not invent another starting value
    if (baseline == control.target)
    {
        state.reason = "The startup value already matches the preset; no alternate value was captured";
        return state;
    }

    // Both possible results were admitted above, so no second value check is needed
    state.next_value = next_value(id, current, baseline);
    state.enabled = 1;
    return state;
}

toggle(owner, id)
{
    state = probe(owner, id);
    if (state.reason != "" || state.enabled != 1)
        return false;

    control = control_for(id);

    // Use the exact source-selected value without changing the startup baseline
    setDvar(control.dvar, state.next_value);
    updated = read_native(control);
    if (!valid_native_value(id, updated) || updated != state.next_value)
        return false;

    return true;
}
