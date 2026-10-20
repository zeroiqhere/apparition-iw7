// Power controls use the map's current native generator registry

inspect(state)
{
    result = snapshot("Wait for the native generator list");
    if (!isDefined(state) || !isDefined(state.generators) || !isarray(state.generators)
        || !state.generators.size)
        return result;

    seen = [];
    targets = [];
    powered = 0;
    // Inspect every numeric slot so a missing or repeated point cannot be skipped
    for (index = 0; index < state.generators.size; index++)
    {
        point = state.generators[index];
        if (!isDefined(point) || !isstruct(point)
            || !isDefined(point.script_noteworthy) || !isstring(point.script_noteworthy)
            || point.script_noteworthy != "generator"
            || (isDefined(point.powered_on) && !isnumber(point.powered_on))
            || scripts\engine\utility::array_contains(seen, point))
            return result;

        seen[seen.size] = point;
        if (isDefined(point.powered_on) && point.powered_on != 0)
        {
            powered++;
            continue;
        }

        if (!isDefined(point.target) || !isstring(point.target) || point.target == ""
            || !isDefined(point.script_parameters) || !isstring(point.script_parameters)
            || point.script_parameters == "" || !isDefined(point.handle))
            return result;
        targets[targets.size] = point;
    }

    // Publish counts only after the complete registry has passed admission
    result.reason = targets.size ? "" : "All native generators are powered";
    result.powered = powered;
    result.total = state.generators.size;
    result.targets = targets;
    return result;
}

registration_reason(state)
{
    if (!isDefined(state.interactions) || !isarray(state.interactions)
        || !isDefined(state.interactions["generator"]))
        return "The native generator interaction is not registered";
    // The wrapper below depends on this exact zero-cost native registration
    entry = state.interactions["generator"];
    if (!isstruct(entry) || !isDefined(entry.name) || entry.name != "generator"
        || !isDefined(entry.spend_type) || entry.spend_type != "generator"
        || !isDefined(entry.enabled) || entry.enabled != 1
        || !isDefined(entry.cost) || entry.cost != 0
        || !isDefined(entry.requires_power) || entry.requires_power != 0
        || !isDefined(entry.activation_func)
        || entry.activation_func != scripts\cp\zombies\zombie_power::generic_generator
        || isDefined(entry.can_use_override_func))
        return "The native zero-cost generator interaction has changed";
    return "";
}

point_reason(state, point)
{
    if (!isDefined(point) || !isstruct(point))
        return "The native generator point is unavailable";
    if (!isDefined(state.current_interaction_structs)
        || !isarray(state.current_interaction_structs)
        || !dense(state.current_interaction_structs))
        return "Wait for the native interaction list";
    if (!scripts\engine\utility::array_contains(state.current_interaction_structs, point))
        return "The generator is not in the active native interaction list";

    // Native checks reject any trigger marker, including a defined zero value
    if (isDefined(point.triggered) || (isDefined(point.in_use) && point.in_use != 0))
        return "The native generator is already in use";
    if ((isDefined(point.out_of_order) && point.out_of_order != 0) || isDefined(point.cooling_down))
        return "The native generator is cooling down";
    if (isDefined(point.disabled) && point.disabled != 0)
        return "The native generator is disabled";
    if (isDefined(point.requires_power) && !isnumber(point.requires_power))
        return "The native generator power state is unavailable";
    if (isDefined(point.requires_power) && point.requires_power != 0
        && (!isDefined(point.powered_on) || point.powered_on == 0))
        return "The native generator has an unmet power requirement";
    return "";
}

probe(owner, own_job)
{
    denied = snapshot("Only the current living host can turn on power");
    // Actor and authority checks precede native point or player method calls
    reason = scripts\apparition\runtime\context::actor_reason([owner]);
    if (reason != "")
    {
        denied.reason = reason;
        return denied;
    }
    if (!scripts\apparition\runtime\context::supported())
    {
        denied.reason = "Power controls require private normal Spaceland";
        return denied;
    }
    reason = scripts\apparition\runtime\context::actor_reason(level.players);
    if (reason != "")
    {
        denied.reason = reason;
        return denied;
    }
    if (!scripts\apparition\runtime\context::in_roster(level.players, owner)
        || !scripts\apparition\runtime\access::can_open(owner)
        || !scripts\apparition\runtime\context::living_host(owner))
        return denied;

    result = inspect(level);
    if (result.reason != "" && result.reason != "All native generators are powered")
        return result;
    if (!result.targets.size)
        return result;

    reason = job_reason(own_job);
    if (reason != "")
    {
        result.reason = reason;
        result.targets = [];
        return result;
    }
    reason = registration_reason(level);
    if (reason != "")
    {
        result.reason = reason;
        result.targets = [];
        return result;
    }
    // The stock validity helper indexes the actor's per-point rejection list
    if (!isDefined(owner.disabled_interactions) || !isarray(owner.disabled_interactions))
    {
        result.reason = "Wait for the host interaction state to initialize";
        result.targets = [];
        return result;
    }

    // Validate every pending point and actor gate before publishing any request
    foreach (point in result.targets)
    {
        reason = live_point_reason(owner, point);
        if (reason != "")
        {
            result.reason = reason;
            result.targets = [];
            return result;
        }
    }
    return result;
}

live_point_reason(owner, point)
{
    reason = point_reason(level, point);
    if (reason != "")
        return reason;

    // Native setup locates this exact switch model and uses its direction tag
    if (!isDefined(point.handle) || !isent(point.handle)
        || !isDefined(point.handle.targetname) || !isstring(point.handle.targetname)
        || point.handle.targetname != point.target
        || !isDefined(point.handle.model) || point.handle.model != "icbm_electricpanel_switch_02"
        || !isDefined(point.handle.script_noteworthy) || !isstring(point.handle.script_noteworthy)
        || !scripts\engine\utility::array_contains(["roll", "-roll", "pitch", "-pitch"], point.handle.script_noteworthy))
        return "The native generator switch is not initialized";
    if (isDefined(point._id_2F12)
        && (!isent(point._id_2F12)
            || !isDefined(point._id_2F12.targetname) || !isstring(point._id_2F12.targetname)
            || point._id_2F12.targetname != point.target))
        return "The native generator switch panel is not initialized";
    if (!owner scripts\cp\cp_interaction::can_use_interaction(point))
        return "Wait until the game allows the host to use a generator";
    if (!scripts\cp\cp_interaction::interaction_is_valid(point, owner))
        return "The native generator interaction is no longer valid";
    if (!owner scripts\cp\cp_interaction::can_purchase_interaction(point, 0, "generator"))
        return "The native generator interaction cannot be purchased";
    return "";
}

job_reason(own_job)
{
    // The published request identity is the sole record of active menu work
    current = level.apparition_power_job;
    if (!isDefined(own_job))
    {
        if (isDefined(current))
            return "Power activation is already running";
        return "";
    }
    if (!isDefined(current) || current != own_job || !isstruct(own_job))
        return "The power worker no longer owns this request";
    return "";
}

start(owner)
{
    result = probe(owner);
    if (result.reason != "" || !result.targets.size)
        return false;

    job = spawnstruct();
    job.owner = owner;
    job.targets = result.targets;
    // Publish the one level-owned request before the worker can yield
    level.apparition_power_job = job;
    level thread scripts\apparition\maps\spaceland\power_worker::run(job);
    return true;
}

dense(values)
{
    for (index = 0; index < values.size; index++)
    {
        if (!isDefined(values[index]))
            return false;
    }
    return true;
}

snapshot(reason)
{
    result = spawnstruct();
    result.reason = reason;
    result.powered = 0;
    result.total = 0;
    result.targets = [];
    return result;
}
