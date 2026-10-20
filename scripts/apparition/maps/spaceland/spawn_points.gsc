// Official choices follow the complete native registry rather than its active subset

inspect(state)
{
    result = spawnstruct();
    result.reason = "Wait for native spawn structures";
    result.points = [];
    if (!isDefined(state) || !isDefined(state.struct_class_names)
        || !isarray(state.struct_class_names))
        return result;
    names = state.struct_class_names["targetname"];
    if (!isDefined(names) || !isarray(names))
        return result;

    // The native getstructarray helper returns an empty list for an absent tag
    registry = names["player_respawn_loc"];
    if (!isDefined(registry))
    {
        result.reason = "";
        return result;
    }
    if (!isarray(registry))
        return result;

    points = [];
    for (index = 0; index < registry.size; index++)
    {
        point = registry[index];
        if (!isDefined(point) || !isstruct(point)
            || !isDefined(point.origin) || !isvector(point.origin)
            || !isDefined(point.angles) || !isvector(point.angles))
        {
            result.reason = "Wait for complete native spawn positions and view angles";
            return result;
        }
        // Copy identities so a later registry edit cannot retarget a displayed index
        points[points.size] = point;
    }

    // Publish only a complete dense list, preserving its native index order
    result.points = points;
    result.reason = "";
    return result;
}

select(points, index)
{
    if (!isDefined(points) || !isarray(points)
        || !isDefined(index) || !isnumber(index))
        return undefined;
    // Bounds precede integer conversion, including values beyond the integer range
    if (!(index >= 0 && index < points.size) || int(index) != index)
        return undefined;
    return points[index];
}
