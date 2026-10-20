// One level record owns the activation cohort and configured timer phase

values()
{
    result = [];
    for (minutes = 1; minutes <= 30; minutes++)
        result[result.size] = minutes;
    return result;
}

valid_minutes(value)
{
    // Bound the conversion before checking whole source minute choices
    return isDefined(value) && isnumber(value) && value >= 1 && value <= 30
        && int(value) == value;
}

configured_minutes(state)
{
    if (!isDefined(state))
        return undefined;
    if (!isDefined(state.apparition_lobby_minutes))
        return 10;
    value = state.apparition_lobby_minutes;
    return valid_minutes(value) ? int(value) : undefined;
}

deadline(now, minutes)
{
    if (!valid_minutes(minutes) || !isDefined(now) || !isnumber(now))
        return undefined;
    duration = int(minutes) * 60000;
    limit = 2147483647 - duration;
    // Leave enough room before conversion; float comparison can round the limit
    if (!(now >= 0 && now <= limit))
        return undefined;
    clock = int(now);
    // The integer comparison prevents a rounded float boundary from overflowing addition
    if (clock != now || clock > limit)
        return undefined;
    return clock + duration;
}

owns(state, record)
{
    return isDefined(state) && isDefined(record) && isDefined(state.apparition_lobby_timer)
        && state.apparition_lobby_timer == record;
}

probe(owner)
{
    result = spawnstruct();
    result.configured = false;
    result.native_reason = "";
    result.time_reason = "";
    result.phase = "Off";
    result.error = "";
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;

    // Configuration and native terminal data follow current Co-Host admission
    result.configured = isDefined(level.apparition_lobby_timer);
    result.minutes = configured_minutes(level);
    result.clock = getTime();
    if (!isDefined(result.minutes))
        result.time_reason = "Choose a valid duration from 1 to 30 minutes";
    else if (!isDefined(deadline(result.clock, result.minutes)))
        result.time_reason = "The game clock cannot represent this countdown";
    result.native_reason = scripts\apparition\features\server\end_game::metadata_reason(level, game["state"]);
    if (result.configured)
    {
        record = level.apparition_lobby_timer;
        result.phase = "Unknown";
        if (isstruct(record))
        {
            if (isDefined(record.phase) && isstring(record.phase))
                result.phase = record.phase;
            if (isDefined(record.error) && isstring(record.error))
                result.error = record.error;
        }
    }
    return result;
}

toggle(owner)
{
    current = probe(owner);
    if (current.reason != "")
        return false;
    // Existing configuration remains removable after clock or native callback loss
    if (current.configured)
    {
        stop(level.apparition_lobby_timer);
        return true;
    }
    if (current.time_reason != "" || current.native_reason != "")
        return false;
    return start_countdown(current.minutes);
}

configure(owner, minutes)
{
    if (!valid_minutes(minutes))
        return false;
    current = probe(owner);
    if (current.reason != "")
        return false;
    if (current.configured)
    {
        if (current.native_reason != "")
            return false;
        // Same-value application also restarts the full source countdown
        return start_countdown(int(minutes));
    }
    level.apparition_lobby_minutes = int(minutes);
    return true;
}

start_countdown(minutes)
{
    // Both callers admit current Co-Host access; construction admits every recipient
    if (!isDefined(deadline(getTime(), minutes)))
        return false;
    minutes = int(minutes);
    seconds = minutes * 60;
    record = scripts\apparition\menu\lobby_timer_hud::create(level.players, seconds);
    if (!isDefined(record))
        return false;
    record.phase = "Counting";
    record.error = "";

    // Keep the previous timer unchanged until the complete replacement display exists
    stop(level.apparition_lobby_timer);
    level.apparition_lobby_minutes = minutes;
    level.apparition_lobby_timer = record;
    level thread run(record, seconds);
    return true;
}

stop(record)
{
    if (!isDefined(record))
        return;
    if (owns(level, record))
        level.apparition_lobby_timer = undefined;
    scripts\apparition\menu\lobby_timer_hud::destroy_record(record);
    // Notify after consuming handles, including a worker stopping its own record
    if (isstruct(record))
        record notify("apparition_stop_lobby_timer");
}

run(record, seconds)
{
    level endon("game_ended");
    record endon("apparition_stop_lobby_timer");
    // The source begins its full-duration wait after setting up the recipient HUDs
    wait seconds;
    if (!owns(level, record) || !scripts\apparition\runtime\context::supported())
    {
        stop(record);
        return;
    }

    // The source keeps the setting on after its display and worker have expired
    scripts\apparition\menu\lobby_timer_hud::destroy_record(record);
    record.phase = "Expired";
    record.error = "A unique current native host was not available at expiry";
    host = scripts\apparition\runtime\context::current_host(level);
    if (!isDefined(host))
        return;
    // Resolve authority at expiry instead of retaining the enabling player or grant
    if (scripts\apparition\features\server\end_game::request(host))
    {
        record.phase = "End Requested";
        record.error = "";
        return;
    }
    record.error = scripts\apparition\features\server\end_game::reason(host);
    if (record.error == "")
        record.error = "The native end-game request was not admitted";
    // A rejected terminal request is recorded once; no retry can end a later context
}
