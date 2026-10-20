// One native use event owns the reward's real lobby award and pickup cleanup

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.pickup = undefined;
    job.recipients = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Collected")
        owner iPrintLn("Native Soul Key pickup cleanup and recipient ownership confirmed");
    else
        owner iPrintLn("Soul Key pickup unconfirmed; native ownership remains visible");
}

perform(job)
{
    allowed = scripts\apparition\runtime\context::living_host(job.owner);
    receipt = scripts\apparition\maps\spaceland\soul_key::snapshot(job.recipients);
    result = scripts\apparition\maps\spaceland\soul_key::outcome(level, job.pickup, receipt, allowed, false);
    if (result != "")
        return result;
    // Refresh intended recipients before input; the native callback still chooses its own live roster
    job.recipients = scripts\apparition\maps\spaceland\soul_key::current_recipients();
    receipt = scripts\apparition\maps\spaceland\soul_key::snapshot(job.recipients);
    if (scripts\apparition\maps\spaceland\soul_key::reason(level) != ""
        || !scripts\apparition\maps\spaceland\soul_key::ownership_known(receipt)
        || !isDefined(job.pickup) || scripts\apparition\maps\spaceland\soul_key::native_pickup() != job.pickup)
        return "Unavailable";
    // Preserve ambiguous submissions through timeout and owner loss instead of retrying
    job.submitted = true;
    job.pickup notify("trigger", job.owner);
    deadline = getTime() + 5000;
    for (;;)
    {
        allowed = scripts\apparition\runtime\context::living_host(job.owner);
        receipt = scripts\apparition\maps\spaceland\soul_key::snapshot(job.recipients);
        result = scripts\apparition\maps\spaceland\soul_key::outcome(level, job.pickup, receipt, allowed, getTime() >= deadline);
        if (result != "")
            return result;
        wait 0.05;
    }
}
