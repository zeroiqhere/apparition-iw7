// Submit one direct damage request, then observe the native quest independently

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    if (level.apparition_floating_skull_job == job)
    {
        // Keep the submitted marker after transient actor references are released
        job.owner = undefined;
        job.target = undefined;
        job.state = result;
    }
    if (!isDefined(owner))
        return;
    if (result == "Completed")
        owner iPrintLn("The native floating-skull quest stage has advanced");
    else
        owner iPrintLn("Floating-skull advancement unconfirmed; normal sign-laser shots remain available");
}

perform(job)
{
    result = poll(job, false);
    if (result != "")
        return result;
    live = scripts\apparition\maps\spaceland\floating_skull::probe(job.owner);
    if (live.reason != "" || !isDefined(job.target) || live.target != job.target)
        return "Unavailable";
    // Refresh reservation, native stage and host authority after target discovery
    result = poll(job, false);
    if (result != "")
        return result;
    job.submitted = true;
    // The native listener checks this weapon ID and the real glasses condition
    job.target doDamage(1, job.target.origin, job.owner, job.owner, "MOD_UNKNOWN", "iw7_spaceland_wmd");

    return scripts\apparition\maps\spaceland\ghost_hit_observer::wait_for_result(job, ::poll, getTime() + 5000);
}

poll(job, expired)
{
    return scripts\apparition\maps\spaceland\floating_skull::outcome(level, job,
        scripts\apparition\runtime\context::living_host(job.owner), expired);
}
