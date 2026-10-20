// Native damage requests leave spawning, death counters and wave events native

run(job)
{
    level endon("game_ended");
    ticket = scripts\apparition\runtime\events::arm(level, ["regular_wave_starting"]);
    result = perform(job, ticket);
    // Keep the native boundary after listener cleanup, including a canceled job
    if (ticket.state == "Received")
        job.regular_event = ticket.event;
    scripts\apparition\runtime\events::cancel(ticket);
    owner = job.owner;
    job.owner = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Completed")
        owner iPrintLn("The native UFO quest has advanced past its wave wait");
    else if (result == "Cancelled")
        owner iPrintLn("Wave clearing canceled; native deaths and spawning continue");
    else
        owner iPrintLn("Wave advance not confirmed; native counters remain visible");
}

perform(job, ticket)
{
    deadline = getTime() + 300000;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        // A receipt ends damage immediately while the quest thread catches up
        if (ticket.state == "Received")
            job.state = "Observing native advance";
        else if (ticket.state != "Armed")
            return "Pending";
        if (scripts\apparition\maps\spaceland\wave::can_submit(level, job, ticket))
        {
            // The native list includes later spawns and is refreshed for each batch
            foreach (enemy in level.spawned_enemies)
            {
                result = poll(job, deadline);
                if (result != "")
                    return result;
                // A callback from the previous actor can fill the quota or end the wave
                if (!scripts\apparition\maps\spaceland\wave::can_submit(level, job, ticket))
                    break;
                if (isDefined(enemy) && isAgent(enemy) && isAlive(enemy)
                    && scripts\apparition\maps\spaceland\zombie_targets::eligible(level, enemy))
                {
                    // A living player attacker keeps clowns on their native non-blast death path
                    enemy doDamage(enemy.maxhealth, enemy.origin, job.owner, job.owner, "MOD_UNKNOWN");
                }
            }
        }
        // A batch finishes before its cooldown begins, including native callback work
        wait 0.25;
    }
}

poll(job, deadline)
{
    return scripts\apparition\maps\spaceland\wave::outcome(level, job,
        scripts\apparition\runtime\context::living_host(job.owner), getTime() >= deadline);
}
