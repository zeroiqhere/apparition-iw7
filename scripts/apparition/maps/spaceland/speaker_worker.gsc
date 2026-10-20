// Assist assigned attackers, then let the native success path collect the model

run(job)
{
    level endon("game_ended");
    // History owns the listener across cancellation and jobs that start after success
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    // History keeps the original model and spent-input evidence after this job ends
    job.defense = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Completed")
        owner iPrintLn("The native UFO quest has advanced past this speaker defense");
    else if (result == "Failed")
        owner iPrintLn("The native speaker defense failed; request a retry from the DJ");
    else if (result == "Cancelled")
        owner iPrintLn("Speaker assist canceled; the native timer and accepted pickup continue");
    else
        owner iPrintLn("Speaker assist stopped without confirming native quest advancement");
}

perform(job)
{
    deadline = getTime() + 300000;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        if (scripts\apparition\maps\spaceland\speakers::pickup_ready(level, job))
        {
            // Allow native exit work a scheduler turn, then recheck every input gate
            wait 0.05;
            result = poll(job, deadline);
            if (result != "")
                return result;
            if (scripts\apparition\maps\spaceland\speakers::claim_pickup(level, job))
            {
                job.defense.speaker notify("trigger", job.owner);
                result = wait_for_pickup(job, deadline);
                if (result != "")
                    return result;
                job.state = "Observing native advance";
            }
        }
        else if (!isDefined(job.defense.speaker))
        {
            // A missed physical pickup remains an observation, never forced success
            job.state = "Observing native advance";
        }
        if (scripts\apparition\maps\spaceland\speakers::can_attack(level, job))
        {
            foreach (enemy in scripts\cp\cp_agent_utils::getaliveagentsofteam("axis"))
            {
                result = poll(job, deadline);
                if (result != "")
                    return result;
                if (!scripts\apparition\maps\spaceland\speakers::can_attack(level, job))
                    break;
                if (isDefined(enemy) && isAgent(enemy) && isAlive(enemy)
                    && scripts\apparition\maps\spaceland\speakers::eligible(enemy, job.defense.clip))
                {
                    // Native death callbacks release and replace assigned attackers
                    enemy doDamage(enemy.health, enemy.origin, job.owner, job.owner, "MOD_UNKNOWN");
                }
            }
        }
        // Native defense and wave timing remain unchanged by this polling bound
        wait 0.25;
    }
}

wait_for_pickup(job, deadline)
{
    confirmation_deadline = getTime() + 5000;
    for (;;)
    {
        result = poll(job, deadline);
        if (result != "")
            return result;
        if (!isDefined(job.defense.speaker))
            return "";
        if (getTime() >= confirmation_deadline)
            return "Pending";
        wait 0.05;
    }
}

poll(job, deadline)
{
    return scripts\apparition\maps\spaceland\speakers::outcome(level, job,
        scripts\apparition\runtime\context::living_host(job.owner), getTime() >= deadline);
}
