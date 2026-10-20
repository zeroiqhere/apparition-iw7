// Native laststand owns revival; this module submits one request per native body

probe(players)
{
    result = spawnstruct();
    result.targets = [];
    result.hint = "";
    result.reason = scripts\apparition\runtime\context::actor_reason(players);
    if (result.reason != "")
        return result;
    if (!scripts\apparition\runtime\context::supported())
    {
        result.reason = "Private normal Spaceland is required for native revives";
        return result;
    }
    if (!isDefined(level.players) || !isarray(level.players))
    {
        result.reason = "Wait for a valid current roster";
        return result;
    }
    // A live entity outside the current roster is not an authorized target
    foreach (player in players)
    {
        if (!scripts\apparition\runtime\context::in_roster(level.players, player))
        {
            result.reason = "A selected player is no longer in the current roster";
            return result;
        }
    }
    result.reason = scripts\apparition\maps\spaceland\revive::context_reason(level,
        scripts\cp\utility::isplayingsolo());
    if (result.reason != "")
        return result;

    entities = getEntArray("revive_trigger", "targetname");
    first_reason = "No supported downed players are ready for a native revive";
    foreach (player in players)
    {
        candidate = spawnstruct();
        candidate.reason = "The selected player must be alive in native laststand";
        if (isAlive(player))
            candidate = scripts\apparition\maps\spaceland\revive::probe(player, entities);
        if (candidate.reason != "")
        {
            if (!result.targets.size)
                first_reason = candidate.reason;
            continue;
        }
        target = spawnstruct();
        target.player = player;
        target.entity = candidate.entity;
        result.targets[result.targets.size] = target;
    }
    result.reason = result.targets.size ? "" : first_reason;
    if (result.targets.size)
        result.hint = "Request native revival for " + result.targets.size + "/" + players.size
            + " selected players; submission does not confirm native exit";
    return result;
}

request(players)
{
    selection = probe(players);
    if (selection.reason != "")
        return false;
    complete = true;
    foreach (target in selection.targets)
    {
        // Native state can change between selection and an individual input
        current = probe([target.player]);
        if (current.reason != "" || current.targets.size != 1
            || current.targets[0].entity != target.entity)
        {
            complete = false;
            continue;
        }
        // The native model lifetime bounds this record to the current down
        target.entity.apparition_revive_submitted = true;
        scripts\cp\cp_laststand::instant_revive(target.player);
    }
    // This reports handled input, not a request-correlated native completion
    return complete;
}

request_lobby(owner)
{
    // Lobby controls include a Co-Host requester and omit only the native host
    selection = scripts\apparition\runtime\player_control::without_host(owner);
    if (selection.reason != "" || !selection.targets.size)
        return false;

    // Preflight the complete current recipient set before reserving any revive
    admitted = probe(selection.targets);
    if (admitted.reason != "")
        return false;

    // Native state may change after a previous target's revive callback
    foreach (target in admitted.targets)
    {
        if (scripts\apparition\runtime\player_control::lobby_reason(owner) != ""
            || scripts\apparition\runtime\player_control::reason(owner, target.player) != ""
            || target.player isHost())
            return false;
        if (!request([target.player]))
            return false;
    }
    return true;
}
