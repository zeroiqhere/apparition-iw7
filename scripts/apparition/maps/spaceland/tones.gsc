// Native tone identities determine the input plan for each fresh listening window

tone_key(tone)
{
    if (!isDefined(tone) || !isString(tone))
        return undefined;
    parts = strTok(tone, "_");
    if (parts.size != 4)
        return undefined;
    return parts[3];
}

plan(state)
{
    if (!isDefined(state.ufo) || !isDefined(state.ufo.tone_array) || state.ufo.tone_array.size != 4
        || !isDefined(state.alldjcenterstructs) || state.alldjcenterstructs.size != 4)
        return undefined;
    locations = [];
    // Each placed speaker contributes one unique native tone identity
    for (index = 0; index < 4; index++)
    {
        if (!isDefined(state.alldjcenterstructs[index]))
            return undefined;
        location = state.alldjcenterstructs[index];
        if (!isDefined(location.placed) || !location.placed || !isDefined(location.model) || !isDefined(location.origin))
            return undefined;
        key = tone_key(location.tone);
        if (!isDefined(key) || isDefined(locations[key]))
            return undefined;
        locations[key] = location;
    }
    ordered = [];
    seen = [];
    // The UFO changes sequence order between successful rounds
    for (index = 0; index < 4; index++)
    {
        key = state.ufo.tone_array[index];
        if (!isDefined(key) || !isString(key) || !isDefined(locations[key]) || isDefined(seen[key]))
            return undefined;
        ordered[index] = locations[key];
        seen[key] = true;
    }
    return ordered;
}

finished(state)
{
    return isDefined(state.flag) && isDefined(state.flag["tones_played_successfully"])
        && state.flag["tones_played_successfully"];
}

listening(state)
{
    return isDefined(state.flag) && isDefined(state.flag["ufo_listening"]) && state.flag["ufo_listening"];
}

available(state)
{
    return scripts\apparition\maps\spaceland\quest::current_step(state) == 8
        && isDefined(state.flag) && isDefined(state.flag["tones_played_successfully"]) && !finished(state)
        && isDefined(state.flag["ufo_intro_reach_center_portal"]) && state.flag["ufo_intro_reach_center_portal"]
        && isDefined(state.flag["ufo_listening"])
        && isDefined(state.flag["all_structs_placed"]) && state.flag["all_structs_placed"]
        && isDefined(plan(state));
}

running(job)
{
    if (!isDefined(job) || !isDefined(job.state))
        return false;
    // Cancellation keeps the slot reserved until the worker removes its listeners
    return job.state == "Waiting for fresh round" || job.state == "Playing tones" || job.state == "Cancelling";
}

checkpoint(job, state, authorized)
{
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    // Native progress can complete while cancellation is arriving
    if (step > 8 || (step == 8 && finished(state)))
        return "Complete";
    if (job.state == "Cancelling")
        return "Cancelled";
    if (!authorized || step != 8 || !isDefined(state.ufo)
        || !isDefined(state.flag) || !isDefined(state.flag["ufo_listening"]))
        return "Unavailable";
    return "";
}

start(player)
{
    if (!available(level) || running(level.apparition_tone_job)
        || !scripts\apparition\runtime\context::can_dispatch(player, undefined, true) || !isAlive(player))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.state = "Waiting for fresh round";
    job.interference = false;
    job.received_expected = false;
    level.apparition_tone_job = job;
    // One level-owned job survives menu closing and keeps a visible terminal result
    level thread scripts\apparition\maps\spaceland\tone_worker::run(job);
    return true;
}

cancel()
{
    if (!running(level.apparition_tone_job))
        return false;
    // The worker owns observer cleanup before its state becomes terminal
    level.apparition_tone_job.state = "Cancelling";
    return true;
}

status(state)
{
    if (!isDefined(state.apparition_tone_job))
        return "Idle";
    // The displayed status is the worker's own state rather than a separate UI flag
    return state.apparition_tone_job.state;
}
