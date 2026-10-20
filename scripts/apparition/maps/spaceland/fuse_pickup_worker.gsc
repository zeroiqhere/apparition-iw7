// One native use event collects the dropped pair without direct inventory writes

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.pickup = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Collected")
        owner iPrintLn("Native alien-fuse collection confirmed; the final UFO stage remains in progress");
    else
        owner iPrintLn("Fuse collection not confirmed yet; current native progress remains visible");
}

perform(job)
{
    allowed = scripts\apparition\runtime\context::living_host(job.owner);
    // A teammate may finish collection before this admitted thread begins
    result = scripts\apparition\maps\spaceland\fuses::outcome(level, job.pickup, allowed, false);
    if (result != "")
        return result;
    native = scripts\apparition\maps\spaceland\fuses::progress(level);
    // Context and authorization were checked above without a yielding operation
    if (native.held != 0 || native.inserted || !isDefined(job.pickup)
        || scripts\apparition\maps\spaceland\fuses::native_pickup() != job.pickup)
        return "Unavailable";
    // Preserve submission history after timeout or owner loss so another job cannot retry
    job.submitted = true;
    job.pickup notify("trigger", job.owner);
    deadline = getTime() + 5000;
    for (;;)
    {
        allowed = scripts\apparition\runtime\context::living_host(job.owner);
        result = scripts\apparition\maps\spaceland\fuses::outcome(level, job.pickup, allowed, getTime() >= deadline);
        if (result != "")
            return result;
        // No automatic retry can submit another native pickup event
        wait 0.05;
    }
}
