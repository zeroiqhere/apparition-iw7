// Arcade history keeps observed game IDs separate from native quest state

catalog()
{
    games = [];
    games[games.size] = entry("zombie_zoom", "Zombie Zoom");
    games[games.size] = entry("bowling_for_planets", "Bowling for Planets");
    games[games.size] = entry("rings_of_saturn", "Rings of Saturn");
    games[games.size] = entry("cryptid_attack", "Cryptid Attack");
    games[games.size] = entry("black_hole", "Black Hole");
    return games;
}

entry(id, label)
{
    result = spawnstruct();
    result.id = id;
    result.label = label;
    return result;
}

create()
{
    watch = spawnstruct();
    watch.state = "Arming";
    watch.waiting = false;
    watch.seen = [];
    return watch;
}

registered_entry(state)
{
    if (!isDefined(state)
        || !isDefined(state._id_13F4D) || !isarray(state._id_13F4D)
        || !isDefined(state._id_13F4D["ghost"]) || !isarray(state._id_13F4D["ghost"])
        || state._id_13F4D["ghost"].size <= 3)
        return undefined;
    return state._id_13F4D["ghost"][3];
}

native_entry(entry)
{
    if (!isDefined(entry) || !isstruct(entry))
        return false;
    expected = scripts\apparition\maps\spaceland\ghosts::catalog()[3];
    return isDefined(entry.init_func)
        && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank
        && isDefined(entry._id_DB5D)
        && entry._id_DB5D == expected.body
        && isDefined(entry._id_446D)
        && entry._id_446D == expected.complete;
}

begin(state, watch)
{
    // The ready flag comes from the real level event waiter
    if (!isDefined(state)
        || !isDefined(watch) || !isstruct(watch)
        || !isDefined(state.apparition_arcade_history) || state.apparition_arcade_history != watch
        || !isDefined(watch.state) || watch.state != "Arming"
        || !isDefined(watch.waiting) || !watch.waiting || isDefined(watch.entry)
        || !isDefined(watch.seen) || !isarray(watch.seen) || watch.seen.size != 0)
        return false;

    step = scripts\apparition\maps\spaceland\ghosts::current_step(state);
    if (step < 0 || step >= 3)
        return false;

    entry = registered_entry(state);
    if (!native_entry(entry))
        return false;

    // Retain the exact initialized native entry before the stage can change
    watch.entry = entry;
    watch.state = "Listening";
    // The startup handshake ends while the child keeps listening
    watch.waiting = false;
    return true;
}

owned(state, watch)
{
    if (!isDefined(state)
        || !isDefined(watch) || !isstruct(watch)
        || !isDefined(state.apparition_arcade_history) || state.apparition_arcade_history != watch
        || !isDefined(watch.state) || watch.state != "Listening"
        || !isDefined(watch.entry) || !isDefined(watch.seen) || !isarray(watch.seen))
        return false;

    // Keep event ownership only through the arcade step, while retaining callback identity
    step = scripts\apparition\maps\spaceland\ghosts::current_step(state);
    if (step < 0 || step > 3)
        return false;

    entry = registered_entry(state);
    return isDefined(entry) && entry == watch.entry && native_entry(entry);
}

observe(state, watch, id)
{
    if (!isDefined(id) || !isString(id) || !known_id(id)
        || !owned(state, watch)
        || scripts\apparition\maps\spaceland\ghosts::current_step(state) != 3)
        return false;

    // Duplicate native receipts keep one canonical record per game
    watch.seen[id] = true;
    return true;
}

known_id(id)
{
    foreach (item in catalog())
    {
        if (item.id == id)
            return true;
    }
    return false;
}

inspect(state)
{
    result = spawnstruct();
    result.reason = "";
    result.count = -1;
    result.games = [];
    games = catalog();
    step = scripts\apparition\maps\spaceland\ghosts::current_step(state);
    watch = undefined;

    if (step < 0)
    {
        result.reason = "Ghosts N Skulls progress is not initialized or has changed";
    }
    else if (step < 3)
    {
        // Native progression proves the arcade stage has not started
        result.count = 0;
    }
    else if (step > 3)
    {
        // The native step can advance only after its five game IDs are removed
        result.count = games.size;
    }
    else
    {
        watch = state.apparition_arcade_history;
        if (!owned(state, watch))
            result.reason = "Arcade history was not listening before this stage";
        else
            result.count = 0;
    }

    foreach (item in games)
    {
        row = spawnstruct();
        row.id = item.id;
        row.label = item.label;
        if (step < 0 || (step == 3 && result.reason != ""))
            row.status = "Unknown";
        else if (step < 3)
            row.status = "Not Started";
        else if (step > 3)
            row.status = "Completed";
        else
        {
            row.status = "Pending";
            if (isDefined(watch.seen[item.id]))
            {
                row.status = "Observed";
                result.count++;
            }
        }
        result.games[result.games.size] = row;
    }
    return result;
}

start()
{
    level endon("game_ended");
    if (!scripts\apparition\runtime\context::supported()
        || isDefined(level.apparition_arcade_history))
        return;

    watch = create();
    level.apparition_arcade_history = watch;
    level childthread listen(watch);

    // The child must reach its native event wait before coverage can begin
    deadline = getTime() + 1000;
    while (!watch.waiting && getTime() < deadline
        && scripts\apparition\runtime\context::supported()
        && level.apparition_arcade_history == watch)
        wait 0.05;

    if (!watch.waiting || !scripts\apparition\runtime\context::supported()
        || level.apparition_arcade_history != watch)
    {
        retire(watch);
        return;
    }

    // Map initialization fills the native quest registry after lifecycle startup
    for (;;)
    {
        if (!scripts\apparition\runtime\context::supported()
            || level.apparition_arcade_history != watch)
        {
            retire(watch);
            return;
        }

        step = scripts\apparition\maps\spaceland\ghosts::current_step(level);
        entry = registered_entry(level);
        if (step >= 0 && isDefined(entry))
            break;
        wait 0.05;
    }

    // Loading after step three cannot establish complete game history
    if (step >= 3 || !native_entry(entry) || !begin(level, watch))
    {
        retire(watch);
        return;
    }

    // Keep the owner alive while this exact native callback registration remains
    while (scripts\apparition\runtime\context::supported() && owned(level, watch))
        wait 0.25;

    // Retire only this captured record even if a newer owner replaced it
    retire(watch);
}

listen(watch)
{
    // A child scheduled after retirement must not publish readiness
    if (!isDefined(watch) || !isstruct(watch) || !isDefined(watch.state) || watch.state != "Arming"
        || !isDefined(self.apparition_arcade_history) || self.apparition_arcade_history != watch)
        return;

    self endon("game_ended");
    watch endon("apparition_arcade_history_stop");
    // No yielding operation separates readiness from the first native event wait
    watch.waiting = true;
    for (;;)
    {
        // Capture and return to the event wait without an intervening timer
        self waittill("beat_arcade_game", id);
        observe(self, watch, id);
    }
}

retire(watch)
{
    if (!isDefined(watch) || !isstruct(watch))
        return;
    watch.state = "Unavailable";
    watch.waiting = false;
    watch notify("apparition_arcade_history_stop");
}
