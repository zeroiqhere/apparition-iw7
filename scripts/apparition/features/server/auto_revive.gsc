// One level token owns the current automatic native revive worker

enabled(state)
{
    return isDefined(state) && isDefined(state.apparition_auto_revive);
}

owns(state, record)
{
    return isDefined(state) && isDefined(record)
        && isDefined(state.apparition_auto_revive)
        && state.apparition_auto_revive == record;
}

probe(owner)
{
    result = spawnstruct();
    result.reason = "";
    result.enabled = false;
    result.native_reason = "";
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;

    // Read world configuration only after current Co-Host access is admitted
    result.enabled = enabled(level);
    result.native_reason = scripts\apparition\maps\spaceland\revive::context_reason(level,
        scripts\cp\utility::isplayingsolo());

    // An unavailable native path blocks enabling but never traps an enabled setting
    if (!result.enabled)
        result.reason = result.native_reason;
    return result;
}

toggle(owner)
{
    result = probe(owner);
    if (result.reason != "")
        return false;

    if (result.enabled)
        return stop(level.apparition_auto_revive);

    // The empty struct is both the setting and the worker's ownership token
    record = spawnstruct();
    level.apparition_auto_revive = record;
    level thread run(record);
    return true;
}

stop(record)
{
    if (!owns(level, record))
        return false;

    // Clear first so a stale worker cannot mistake a replacement for its own token
    level.apparition_auto_revive = undefined;
    level notify("apparition_stop_auto_revive");
    return true;
}

run(record)
{
    level endon("game_ended");
    level endon("apparition_stop_auto_revive");

    while (owns(level, record))
    {
        // End an unsupported session without touching a newer worker token
        if ((isDefined(level.gameended) && level.gameended)
            || !scripts\apparition\runtime\context::supported())
        {
            stop(record);
            return;
        }

        // The canonical request validates this fresh native roster before effects
        scripts\apparition\features\revive::request(level.players);
        wait 0.1;
    }
}
