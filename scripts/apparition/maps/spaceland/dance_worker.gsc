// Submit one ordinary damage packet at a time while the native kill order is active

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    // Keep a replaced reservation independent from the worker that just ended
    if (level.apparition_dance_job == job)
    {
        job.owner = undefined;
        job.state = result;
    }
    if (!isDefined(owner))
        return;
    if (result == "Completed")
        owner iPrintLn("The native dance-floor kill order has advanced");
    else if (result == "Cancelled")
        owner iPrintLn("Dance-floor assist canceled; native quest progress continues");
    else if (result == "Pending")
        owner iPrintLn("Dance-floor assist stopped without confirming native quest progress");
    else
        owner iPrintLn("Dance-floor assist stopped because its native context changed");
}

perform(job)
{
    deadline = getTime() + 300000;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;

        // An empty sequence is only evidence to observe native completion
        if (isDefined(level.kill_order_on_dance_floor) && level.kill_order_on_dance_floor.size > 0
            && scripts\apparition\runtime\context::living_host(job.owner))
        {
            actual_floor = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::get_dance_floor_tile_color(job.owner.origin);
            if (scripts\apparition\maps\spaceland\dance::can_submit(level, job, actual_floor,
                scripts\apparition\runtime\context::living_host(job.owner)))
            {
                foreach (enemy in level.spawned_enemies)
                {
                    result = poll(job, deadline);
                    if (result != "")
                        return result;
                    if (!isDefined(enemy) || !isAgent(enemy) || !isAlive(enemy)
                        || !scripts\apparition\maps\spaceland\zombie_targets::eligible(level, enemy))
                        continue;

                    // Recheck stage, authority and floor immediately before native damage
                    result = poll(job, deadline);
                    if (result != "")
                        return result;
                    authorized = scripts\apparition\runtime\context::living_host(job.owner);
                    if (!authorized)
                        break;
                    actual_floor = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::get_dance_floor_tile_color(job.owner.origin);
                    if (!scripts\apparition\maps\spaceland\dance::can_submit(level, job, actual_floor, authorized))
                        break;

                    // Submit no second packet before yielding and rereading native progress
                    enemy doDamage(enemy.maxhealth, enemy.origin, job.owner, job.owner, "MOD_UNKNOWN");
                    break;
                }
            }
        }
        // Re-read native order and actors after each bounded callback turn
        wait 0.25;
    }
}

poll(job, deadline)
{
    return scripts\apparition\maps\spaceland\dance::outcome(level, job,
        scripts\apparition\runtime\context::living_host(job.owner), getTime() >= deadline);
}
