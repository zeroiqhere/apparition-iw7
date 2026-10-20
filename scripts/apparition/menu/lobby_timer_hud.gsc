// Each activation recipient owns one native timer HUD in an explicit IW7 layout

create(players, seconds)
{
    if (!isDefined(seconds) || !isnumber(seconds) || !(seconds > 0 && seconds <= 1800)
        || scripts\apparition\runtime\context::actor_reason(players) != "")
        return undefined;

    record = spawnstruct();
    record.timers = [];
    foreach (player in players)
    {
        element = newClientHudElem(player);
        if (!isDefined(element))
        {
            // A later allocation failure releases the entire unpublished cohort
            destroy_record(record);
            return undefined;
        }
        record.timers[record.timers.size] = element;
        // Match the stock client timer constructor before native countdown setup
        element.elemType = "timer";
        element.horzAlign = "left";
        element.vertAlign = "bottom";
        element.alignX = "left";
        element.alignY = "bottom";
        element.x = 25;
        element.y = -20;
        element.font = "default";
        element.fontScale = 1.2;
        element.color = (1, 1, 1);
        element.alpha = 1;
        element.sort = 3;
        element.hideWhenInMenu = true;
        element.foreground = true;
        element.archived = true;
        // Installed CP bytecode passes seconds to this one-argument native timer
        element setTimer(seconds);
    }
    return record;
}

destroy_record(record)
{
    if (!isDefined(record) || !isstruct(record))
        return;
    timers = record.timers;
    record.timers = [];
    if (!isDefined(timers) || !isarray(timers))
        return;
    // Consuming the whole list first makes cleanup repeatable and stale-record safe
    foreach (element in timers)
    {
        if (isDefined(element))
            element destroy();
    }
}
