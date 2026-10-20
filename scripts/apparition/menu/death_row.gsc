// Death and lobby Down rows share one readiness snapshot

build(view, lobby)
{
    if (lobby)
        return lobby_row(view);
    return personal_row(view);
}

personal_row(view)
{
    target = undefined;
    if (isDefined(view) && isstruct(view) && isDefined(view.target))
        target = view.target;

    row = scripts\apparition\menu\model::action("Death",
        scripts\apparition\menu\actions::player_death, target, false);
    row.kind = "slider";
    row.values = scripts\apparition\features\down::modes();
    row.initial_index = 0;
    // The selected source mode is a preview, not a reported native state
    row.choice_reasons = [];
    row.choice_reasons["Down"] = "";
    row.choice_reasons["Kill"] = "Kill is not available in this build";

    snapshot = readiness(view);
    row.enabled = snapshot.ready;
    row.description = snapshot.description;
    return row;
}

lobby_row(view)
{
    row = scripts\apparition\menu\model::action("Down",
        scripts\apparition\menu\actions::down_players, undefined, true);

    // Role denial comes before any readiness snapshot is inspected
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\runtime\player_control::can_manage(view.access))
    {
        row.enabled = false;
        row.description = "Co-Host access is required to down current players";
        return row;
    }

    snapshot = readiness(view);
    row.enabled = snapshot.ready;
    row.description = snapshot.description;
    return row;
}

readiness(view)
{
    result = spawnstruct();
    result.ready = false;
    result.description = "Wait for down readiness";

    if (!isDefined(view) || !isstruct(view) || !isDefined(view.down)
        || !isstruct(view.down))
        return result;

    snapshot = view.down;
    if (!isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.hint) || !isstring(snapshot.hint)
        || !isDefined(snapshot.targets) || !isarray(snapshot.targets))
        return result;

    // A ready roster must be dense; otherwise an omitted actor could look ready
    for (index = 0; index < snapshot.targets.size; index++)
    {
        if (!isDefined(snapshot.targets[index]))
            return result;
    }

    if (snapshot.reason != "")
    {
        result.description = snapshot.reason;
        return result;
    }

    if (snapshot.targets.size == 0)
        return result;

    result.ready = true;
    result.description = snapshot.hint;
    return result;
}
