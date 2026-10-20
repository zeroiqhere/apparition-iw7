// One level record owns the Newsbar setting, captured messages and global HUD pair

messages(host_name)
{
    host_name = scripts\apparition\player_name::clean(host_name);
    if (host_name == "")
        return [];

    // The control hint stays truthful when players save different opening chords
    return ["Welcome To ^1Apparition ^7Developed By ^2CF4_99",
        "Your Host Today Is ^6" + host_name,
        "Once verified, use saved opening controls for ^1Apparition",
        "YouTube.Com/^3CF4_99", "Discord.gg/^6apparitionbo3", "^5Enjoy Your Stay!"];
}

owns(state, record)
{
    return isDefined(state) && isDefined(record) && isDefined(state.apparition_newsbar)
        && state.apparition_newsbar == record;
}

probe(owner)
{
    result = spawnstruct();
    result.configured = false;
    result.messages = [];
    // Current private Co-Host admission precedes the setting and host name
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;

    result.configured = isDefined(level.apparition_newsbar);
    // Turning off an existing display does not need a readable current name
    if (result.configured)
        return result;
    // The message names the actual host even when a Co-Host enables the display
    host = scripts\apparition\runtime\context::current_host(level);
    if (!isDefined(host))
    {
        result.reason = "Wait for one current native host";
        return result;
    }
    result.messages = messages(host.name);
    if (!result.messages.size)
        result.reason = "Wait for a readable current host name";
    return result;
}

toggle(owner)
{
    current = probe(owner);
    if (current.reason != "")
        return false;
    if (current.configured)
    {
        stop(level.apparition_newsbar);
        return true;
    }

    record = scripts\apparition\menu\newsbar_hud::create();
    if (!isDefined(record))
        return false;
    // Publish only after both handles exist; messages are captured once as in the source
    record.messages = current.messages;
    level.apparition_newsbar = record;
    level thread run(record);
    return true;
}

stop(record)
{
    if (!isDefined(record))
        return;
    // A stale worker can release its own pair without clearing a replacement setting
    if (owns(level, record))
        level.apparition_newsbar = undefined;
    scripts\apparition\menu\newsbar_hud::destroy_record(record);
    // Consume handles first because this call may be stopping its own worker
    if (isstruct(record))
        record notify("apparition_stop_newsbar");
}

run(record)
{
    level endon("game_ended");
    record endon("apparition_stop_newsbar");
    while (owns(level, record))
    {
        foreach (message in record.messages)
        {
            // The global display continues through menu close, host death and disconnect
            if (!owns(level, record) || !scripts\apparition\runtime\context::supported()
                || (isDefined(level.gameended) && level.gameended))
            {
                stop(record);
                return;
            }
            if (!scripts\apparition\menu\newsbar_hud::cycle(record, message))
            {
                stop(record);
                return;
            }
        }
    }
    stop(record);
}
