// One native snapshot drives both Spaceland collection entries

build(view)
{
    row = scripts\apparition\menu\model::action("Collect DJ Parts",
        scripts\apparition\menu\actions::collect_dj_parts, undefined, true);
    row.enabled = false;

    // Host denial is resolved before the progress snapshot is read
    if (!scripts\apparition\menu\model::truth(view.host))
    {
        row.description = "Only the current host can collect native DJ parts";
        return row;
    }

    snapshot = view.dj_parts;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.collected) || !isnumber(snapshot.collected)
        || !isDefined(snapshot.total) || !isnumber(snapshot.total)
        || snapshot.total != 3
        || !(snapshot.collected == -1 || snapshot.collected == 0
            || snapshot.collected == 1 || snapshot.collected == 2 || snapshot.collected == 3))
    {
        row.description = "Wait for native DJ parts snapshot";
        return row;
    }

    // The provider uses -1 only when progress cannot be sampled
    if (snapshot.reason == "" && snapshot.collected == -1)
    {
        row.description = "Wait for native DJ parts snapshot";
        return row;
    }

    if (snapshot.reason == "All native DJ parts are collected")
    {
        if (snapshot.collected != 3)
        {
            row.description = "Wait for native DJ parts snapshot";
            return row;
        }
        row.description = snapshot.reason;
        return row;
    }

    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }

    // A clear reason with all parts collected is an inconsistent snapshot
    if (snapshot.collected == 3)
    {
        row.description = "Wait for native DJ parts snapshot";
        return row;
    }

    row.enabled = true;
    row.description = "Collect missing native DJ parts; sampled collected "
        + snapshot.collected + "/" + snapshot.total;
    return row;
}
