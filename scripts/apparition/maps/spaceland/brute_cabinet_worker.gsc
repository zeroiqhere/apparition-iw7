// One direct cabinet hit uses a real Brute as its native attacker

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    if (level.apparition_brute_cabinet_job == job)
    {
        // Preserve submitted history after actor and target references are released
        job.owner = undefined;
        job.target = undefined;
        job.state = result;
    }
    if (!isDefined(owner))
        return;
    if (result == "Completed")
        owner iPrintLn("The native Brute-at-cabinet quest stage has advanced");
    else
        owner iPrintLn("Cabinet advancement unconfirmed; normal Brute laser hits remain available");
}

perform(job)
{
    result = poll(job, false);
    if (result != "")
        return result;
    live = scripts\apparition\maps\spaceland\brute_cabinet::probe(job.owner);
    if (live.reason != "" || !isDefined(job.target) || live.target != job.target)
        return "Unavailable";
    // Recheck the reservation and host before the last real-actor checks
    result = poll(job, false);
    if (result != "")
        return result;
    attacker = live.attacker;
    if (!isDefined(attacker) || !isAgent(attacker) || !isAlive(attacker)
        || !scripts\apparition\maps\spaceland\brute_cabinet::eligible(attacker))
        return "Unavailable";
    job.submitted = true;
    // The cabinet's native listener requires this attacker type and damage type
    job.target doDamage(1, job.target.origin, attacker, attacker, "MOD_RIFLE_BULLET");
    return scripts\apparition\maps\spaceland\ghost_hit_observer::wait_for_result(job, ::poll, getTime() + 5000);
}

poll(job, expired)
{
    return scripts\apparition\maps\spaceland\brute_cabinet::outcome(level, job,
        scripts\apparition\runtime\context::living_host(job.owner), expired);
}
