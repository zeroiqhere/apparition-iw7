// Spawn-balloon assistance faces current native locations without changing quest state

stage_reason(state)
{
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) == 0)
        return "";
    return "Face Spawn Balloon requires the native spawn-balloon stage";
}

probe(owner)
{
    result = spawnstruct();
    result.reason = "";
    result.entries = [];

    actor_reason = scripts\apparition\runtime\context::actor_reason([owner]);
    if (actor_reason != "")
    {
        result.reason = actor_reason;
        return result;
    }
    if (!scripts\apparition\runtime\context::living_host(owner))
    {
        result.reason = "Only the current living host can face a spawn balloon";
        return result;
    }
    result.reason = stage_reason(level);
    if (result.reason != "")
        return result;

    // Retain object identity while keeping coordinates out of the menu snapshot
    scriptables = getscriptablearray("beginning_area_balloons", "targetname");
    if (!isDefined(scriptables) || !isarray(scriptables) || !scriptables.size)
    {
        result.reason = "No native spawn-balloon locations are available";
        return result;
    }

    points = [];
    for (index = 0; index < scriptables.size; index++)
    {
        // Reject a sparse or malformed query instead of publishing a partial list
        if (!reference_shape(scriptables[index]))
        {
            result.reason = "The native spawn-balloon list is incomplete";
            return result;
        }
        scriptable = scriptables[index];
        origin = scriptable.origin;
        if (!isDefined(origin) || !isvector(origin))
        {
            result.reason = "A native spawn-balloon location is unavailable";
            return result;
        }

        record = spawnstruct();
        // Retain exact object identity so equal coordinates cannot retarget a stale selection
        record.point = scriptable;
        points[points.size] = record;
    }

    // Publish only after every native entry passed validation
    result.entries = points;
    return result;
}

select(entries, point)
{
    if (!isDefined(entries) || !isarray(entries) || !entries.size
        || !reference_shape(point))
        return undefined;

    selected = undefined;
    for (index = 0; index < entries.size; index++)
    {
        // Every row must remain a complete plain point record
        if (!isDefined(entries[index]) || !isstruct(entries[index])
            || !reference_shape(entries[index].point))
            return undefined;
        if (entries[index].point == point)
            selected = entries[index].point;
    }
    return selected;
}

reference_shape(point)
{
    // The native query proves membership; this check only excludes value data
    // Scriptable references need no unverified isent or isstruct classification
    return isDefined(point) && !isvector(point) && !isnumber(point)
        && !isstring(point) && !isarray(point);
}

aim_reason(eye, origin)
{
    if (!isDefined(eye) || !isvector(eye) || !isDefined(origin) || !isvector(origin))
        return "Wait for a valid host view and native balloon point";
    if (distanceSquared(eye, origin) == 0)
        return "Move away from the balloon before requesting an aim";
    return "";
}

face(owner, point)
{
    // Never trust an earlier menu snapshot for a native angle change
    live = probe(owner);
    if (live.reason != "")
        return false;
    scriptable = select(live.entries, point);
    if (!isDefined(scriptable))
        return false;

    // Read the live position only after current-list identity validation
    origin = scriptable.origin;
    eye = owner getEye();
    if (aim_reason(eye, origin) != "")
        return false;

    owner setPlayerAngles(vectorToAngles(origin - eye));
    return true;
}
