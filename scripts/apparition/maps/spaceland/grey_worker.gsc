// One bounded worker submits native Grey body and fresh fuse inputs

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.watch = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Pending")
        owner iPrintLn("Grey assist stopped without confirmation; native fight progress remains visible");
    else if (result == "Cancelled")
        owner iPrintLn("Grey assist canceled; no further menu hits will be sent");
    else if (result == "Unavailable")
        owner iPrintLn("Grey assist stopped; current quest progress remains visible");
    else
        owner iPrintLn("The native UFO quest has advanced past the Grey fight");
}

perform(job)
{
    // This policy bound limits observation of a fight that may otherwise stall
    deadline = getTime() + 300000;
    records = [];
    next_body_batch = getTime();
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        current = [];
        body_batch = getTime() >= next_body_batch;
        foreach (enemy in level.spawned_grey)
        {
            result = poll(job, deadline);
            if (result != "")
                return result;
            if (!candidate(enemy))
                continue;
            if (scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy))
            {
                record = find_record(records, enemy);
                current[current.size] = record;
                result = strike(job, record, deadline);
                if (result != "")
                    return result;
            }
            // Fuse confirmation can yield, so body input rechecks live ownership
            result = poll(job, deadline);
            if (result != "")
                return result;
            if (body_batch && scripts\apparition\maps\spaceland\greys::can_submit(level, job, true)
                && candidate(enemy) && scripts\apparition\maps\spaceland\greys::body_eligible(enemy))
                enemy doDamage(enemy.health, enemy.origin, job.owner, job.owner, "MOD_UNKNOWN");
        }
        // Start the cooldown after the batch so yielded fuse work cannot shorten it
        if (body_batch)
            next_body_batch = getTime() + 250;
        // Keep fuse records only for current eligible actors
        records = current;
        wait 0.05;
    }
}

find_record(records, enemy)
{
    foreach (record in records)
    {
        if (isDefined(record.enemy) && record.enemy == enemy)
            return record;
    }
    return scripts\apparition\maps\spaceland\grey_fuses::record(enemy);
}

candidate(enemy)
{
    return isDefined(enemy) && isAgent(enemy) && isAlive(enemy)
        && scripts\apparition\maps\spaceland\greys::identity(enemy)
        && isDefined(level.spawned_grey) && scripts\engine\utility::array_contains(level.spawned_grey, enemy);
}

strike(job, record, deadline)
{
    fuse = scripts\apparition\maps\spaceland\grey_fuses::observe(record);
    if (!isDefined(fuse))
        return "";
    enemy = record.enemy;
    // Capture a teammate's stop event before submitting any menu input
    ticket = scripts\apparition\runtime\events::arm(enemy, ["stop_regen_health"]);
    result = poll(job, deadline);
    if (result == "")
    {
        if (ticket.state == "Received")
        {
            // The event has no sender payload, so conservatively spend this window
            record.ready = false;
        }
        else if (ticket.state != "Armed")
            result = "Pending";
        else if (scripts\apparition\maps\spaceland\greys::can_submit(level, job, false)
            && candidate(enemy) && scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse))
        {
            // Spend the window before native callbacks can process the hit
            record.ready = false;
            enemy doDamage(1, fuse.origin, job.owner, job.owner, "MOD_MELEE");
            result = wait_for_removal(job, enemy, fuse, deadline);
        }
        else
            record.ready = false;
    }
    // Every exit after arming releases the listener, including Cancel and host loss
    scripts\apparition\runtime\events::cancel(ticket);
    return result;
}

wait_for_removal(job, enemy, fuse, deadline)
{
    confirmation_deadline = getTime() + 1500;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        if (scripts\apparition\maps\spaceland\grey_fuses::removed(enemy, fuse))
            return "";
        if (getTime() >= confirmation_deadline)
            return "Pending";
        wait 0.05;
    }
}

poll(job, deadline)
{
    allowed = scripts\apparition\runtime\context::living_host(job.owner);
    return scripts\apparition\maps\spaceland\greys::outcome(level, job, allowed, getTime() >= deadline);
}
