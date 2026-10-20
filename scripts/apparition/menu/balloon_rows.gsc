// Authored balloon locations are selectable without inferring which have popped

build(view)
{
    host = isDefined(view) && isstruct(view)
        && scripts\apparition\menu\model::truth(view.host);
    if (!host)
        return blocked("Only the current host can face spawn balloons");

    snapshot = view.balloons;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return blocked("Wait for native spawn-balloon locations");
    // Admission may reject before any native object list is read
    if (snapshot.reason != "")
        return blocked(snapshot.reason);
    if (!isDefined(snapshot.entries) || !isarray(snapshot.entries))
        return blocked("Wait for a complete native spawn-balloon list");
    if (!snapshot.entries.size)
        return blocked("No native spawn-balloon locations are available; pop state is unconfirmed");

    // Validate the complete plain-record list before publishing its first action
    for (index = 0; index < snapshot.entries.size; index++)
    {
        entry = snapshot.entries[index];
        if (!isDefined(entry) || !isstruct(entry)
            || !scripts\apparition\maps\spaceland\balloons::reference_shape(entry.point))
            return blocked("Wait for a complete native spawn-balloon list");
    }

    rows = [];
    for (index = 0; index < snapshot.entries.size; index++)
    {
        entry = snapshot.entries[index];
        row = scripts\apparition\menu\model::action("Face Spawn Balloon " + (index + 1),
            scripts\apparition\menu\actions::face_spawn_balloon, undefined, true);
        // Reordering cannot redirect a captured request to the same numbered row
        row.balloon_point = entry.point;
        row.selection_key = entry.point;
        row.description = "Face this authored location; does not pop a balloon or confirm it remains unpopped; shoot normally and let the native quest advance";
        rows[rows.size] = row;
    }
    return rows;
}

blocked(reason)
{
    return [scripts\apparition\menu\model::unavailable("Spawn Balloons", reason)];
}
