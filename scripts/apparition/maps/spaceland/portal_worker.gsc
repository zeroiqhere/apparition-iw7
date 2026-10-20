// One level-owned observer submits at most one native side-portal trigger

run(job)
{
    level endon("game_ended");
    outcome = perform(job);
    owner = job.owner;
    finish(job, outcome);
    if (isDefined(owner))
    {
        if (outcome == "Pending")
            owner iPrintLn("Portal visit not confirmed yet; native travel may still finish");
        else if (outcome == "Interrupted")
            owner iPrintLn("Other portal input detected; no further menu trigger was sent");
        else if (outcome == "Unavailable")
            owner iPrintLn("Portal visit stopped; current native state remains visible");
    }
}

perform(job)
{
    if (scripts\apparition\maps\spaceland\portals::side_reason(level, job.area) != ""
        || scripts\apparition\maps\spaceland\portal_travel::actor_reason(job.owner) != ""
        || !scripts\apparition\maps\spaceland\portal_travel::path_ready(false))
        return "Unavailable";
    spot = level.fast_travel_spots[job.area];
    // Observe competing input before opening a portal or waiting through an existing opening
    job.trigger = scripts\apparition\runtime\events::arm(spot._id_D680, ["trigger"]);
    outcome = opening(job, false);
    if (outcome != "" && outcome != "Open")
        return outcome;
    if (scripts\apparition\maps\spaceland\portals::side_reason(level, job.area) != "")
        return "Unavailable";
    if (outcome != "Open")
    {
        spot = level.fast_travel_spots[job.area];
        scripts\cp\zombies\zombie_fast_travel::run_fast_travel_logic(spot, job.owner);
    }
    deadline = getTime() + 5000;
    for (;;)
    {
        outcome = opening(job, getTime() >= deadline);
        if (outcome == "Open")
            break;
        if (outcome != "")
            return outcome;
        wait 0.05;
    }
    job.complete = scripts\apparition\runtime\events::arm(job.owner, ["fast_travel_complete"]);
    // Arming may yield; all trigger admission gates are read again afterward
    outcome = opening(job, false);
    if (outcome != "Open")
        return outcome == "" ? "Unavailable" : outcome;
    if (job.complete.state != "Armed" || !scripts\apparition\maps\spaceland\portal_travel::path_ready(false))
        return "Unavailable";
    spot = level.fast_travel_spots[job.area];
    job.state = "Travelling";
    spot._id_D680 notify("trigger", job.owner);
    deadline = getTime() + 5000;
    for (;;)
    {
        allowed = scripts\apparition\runtime\context::can_dispatch(job.owner, undefined, true) && isAlive(job.owner);
        outcome = scripts\apparition\maps\spaceland\portals::travel_outcome(level, job.area, job.complete, allowed, getTime() >= deadline);
        if (outcome != "")
            return outcome;
        wait 0.05;
    }
}

opening(job, expired)
{
    allowed = scripts\apparition\maps\spaceland\portal_travel::actor_reason(job.owner) == "";
    return scripts\apparition\maps\spaceland\portals::opening_outcome(level, job.area, job.trigger, allowed, expired);
}

finish(job, outcome)
{
    if (isDefined(job.trigger))
        scripts\apparition\runtime\events::cancel(job.trigger);
    if (isDefined(job.complete))
        scripts\apparition\runtime\events::cancel(job.complete);
    job.trigger = undefined;
    job.complete = undefined;
    job.owner = undefined;
    // Native portal workers retain ownership of their models, timers and actor cleanup
    job.state = outcome;
}
