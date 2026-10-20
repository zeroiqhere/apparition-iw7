// Lobby travel keeps its source preview and reads only current readiness reasons

build(view)
{
    row = scripts\apparition\menu\model::action("Teleport",
        scripts\apparition\menu\actions::teleport_lobby, undefined, true);
    row.kind = "slider";
    row.values = scripts\apparition\features\lobby_teleport::modes();
    row.initial_index = 0;
    row.enabled = false;
    row.description = "Co-Host access is required to teleport other players";
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;

    row.description = "Wait for current lobby travel data";
    snapshot = view.lobby_teleport;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.owner_reason) || !isstring(snapshot.owner_reason)
        || !isDefined(snapshot.targets) || !isarray(snapshot.targets))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!snapshot.targets.size)
    {
        row.description = "No other current players are available";
        return row;
    }

    // Sky does not need the requester's position or view while targets are ready
    row.choice_reasons = [];
    row.choice_reasons["Self"] = snapshot.owner_reason;
    row.choice_reasons["Crosshairs"] = snapshot.owner_reason;
    row.choice_reasons["Sky"] = "";
    row.enabled = true;
    row.description = "Request Teleport for " + snapshot.targets.size
        + " other players; the current host stays in place";
    return row;
}
