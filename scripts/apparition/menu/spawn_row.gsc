// Official spawn rows keep map-owned points as opaque selection data

build(view, actor_reason, movement_reason)
{
    target = undefined;
    snapshot = undefined;
    if (isDefined(view) && isstruct(view))
    {
        target = view.target;
        snapshot = view.official_spawns;
    }

    snapshot_reason = "Wait for official spawn data";
    points = undefined;
    snapshot_valid = false;
    if (isDefined(snapshot) && isstruct(snapshot)
        && isDefined(snapshot.reason) && isstring(snapshot.reason)
        && isDefined(snapshot.points) && isarray(snapshot.points))
    {
        points = snapshot.points;
        snapshot_valid = true;
        for (index = 0; index < points.size; index++)
        {
            if (!isDefined(points[index]))
            {
                snapshot_valid = false;
                break;
            }
        }
        snapshot_reason = snapshot_valid ? snapshot.reason : "Official spawn data is malformed";
    }

    if (!snapshot_valid)
    {
        description = actor_reason != "" ? actor_reason
            : movement_reason != "" ? movement_reason : snapshot_reason;
        return scripts\apparition\menu\model::unavailable("Official Spawn Points", description);
    }

    // An empty ready registry has no source row, unlike a pending registry
    if (snapshot.reason == "" && points.size == 0)
        return undefined;

    // A catalog reason keeps the placeholder and never exposes stale point refs
    if (snapshot.reason != "")
    {
        description = actor_reason != "" ? actor_reason
            : movement_reason != "" ? movement_reason : snapshot.reason;
        return scripts\apparition\menu\model::unavailable("Official Spawn Points", description);
    }

    row = scripts\apparition\menu\model::action("Official Spawn Points",
        scripts\apparition\menu\actions::official_spawn, target, false);
    row.kind = "slider";
    row.values = [];
    for (index = 0; index < points.size; index++)
        row.values[row.values.size] = index;
    row.initial_index = 0;
    row.enabled = false;

    // Actor admission takes precedence over movement readiness
    if (actor_reason != "")
        row.description = actor_reason;
    else if (movement_reason != "")
        row.description = movement_reason;
    else
    {
        // The map adapter already returns a fresh dense list of native references
        row.spawn_points = points;
        row.enabled = true;
        row.description = "Use moves to the selected native spawn; availability is checked again";
    }
    return row;
}
