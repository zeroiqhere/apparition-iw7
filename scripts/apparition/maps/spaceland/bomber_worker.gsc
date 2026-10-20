// A bounded level worker sends ordinary damage only to native quest bombers

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Pending")
        owner iPrintLn("Bomber objective not confirmed yet; current progress remains visible");
    else if (result == "Cancelled")
        owner iPrintLn("Bomber worker canceled; no further menu damage will be sent");
    else if (result == "Unavailable")
        owner iPrintLn("Bomber attacks stopped; current quest progress remains visible");
    else
        owner iPrintLn("The native UFO quest has advanced past the bomber stage");
}

perform(job)
{
    // The stock spawn cadence is at most one second per actor after its intro
    deadline = getTime() + 120000;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        native = scripts\apparition\maps\spaceland\bombers::progress(level);
        if (native.kills < native.goal)
        {
            // Refresh the native roster so later quest spawns are included
            foreach (enemy in scripts\cp\cp_agent_utils::getaliveagentsofteam("axis"))
            {
                result = poll(job, deadline);
                if (result != "")
                    return result;
                native = scripts\apparition\maps\spaceland\bombers::progress(level);
                if (native.kills >= native.goal)
                    break;
                if (isDefined(enemy) && isAgent(enemy) && isAlive(enemy) && scripts\apparition\maps\spaceland\bombers::eligible(enemy))
                {
                    // Native damage owns death callbacks, tracked kills and spawn bookkeeping
                    enemy doDamage(enemy.health + 100, enemy.origin, job.owner, job.owner, "MOD_UNKNOWN");
                }
            }
        }
        // Ignored damage remains bounded instead of creating a per-frame retry loop
        wait 0.25;
    }
}

poll(job, deadline)
{
    allowed = scripts\apparition\runtime\context::living_host(job.owner);
    return scripts\apparition\maps\spaceland\bombers::outcome(level, job, allowed, getTime() >= deadline);
}
