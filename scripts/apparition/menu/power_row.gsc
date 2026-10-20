// Native progress drives the checkbox; one host action requests remaining generators

build(view)
{
    row = scripts\apparition\menu\model::action("Turn On Power",
        scripts\apparition\menu\actions::turn_on_power, undefined, true);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;

    // Host authority is clear before the native snapshot is inspected
    if (!scripts\apparition\menu\model::truth(view.host))
    {
        row.description = "Only the current host can activate native generators";
        return row;
    }

    snapshot = view.power;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.powered) || !isnumber(snapshot.powered)
        || !isDefined(snapshot.total) || !isnumber(snapshot.total)
        || snapshot.powered < 0 || snapshot.total < 0 || snapshot.powered > snapshot.total)
    {
        row.description = "Wait for native power state";
        return row;
    }

    // Only the native count can mark the shared objective complete
    row.checked = snapshot.total > 0 && snapshot.powered == snapshot.total;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (snapshot.total == 0)
    {
        row.description = "No native generators are ready";
        return row;
    }
    if (row.checked)
    {
        row.description = "All native generators are powered; powered "
            + snapshot.powered + "/" + snapshot.total;
        return row;
    }

    row.enabled = true;
    row.description = "Activate remaining native generators in sequence; powered "
        + snapshot.powered + "/" + snapshot.total;
    return row;
}
