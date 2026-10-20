// Native stage and death counters own bomber progress and completion

progress(state)
{
    progress = spawnstruct();
    progress.kills = isDefined(state.num_ufo_zombies_killed) ? state.num_ufo_zombies_killed : -1;
    // The stock sequence spawns 51 actors and waits for 50 tracked deaths
    progress.goal = 50;
    return progress;
}

reason(state)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 9)
        return "The UFO quest is not on its suicide-bomber stage";
    return sequence_reason(state);
}

sequence_reason(state)
{
    if (!isDefined(state.flag) || !isDefined(state.flag["pause_wave_progression"]) || !state.flag["pause_wave_progression"]
        || !isDefined(state.flag["tones_played_successfully"]) || !state.flag["tones_played_successfully"])
        return "Wait for the native UFO sequence to hold the wave";
    if (progress(state).kills < 0)
        return "Wait for the native bomber counter to initialize";
    return "";
}

eligible(enemy)
{
    // The caller separately checks native agent identity and life state
    return isDefined(enemy) && isDefined(enemy.agent_type) && enemy.agent_type == "generic_zombie"
        && isDefined(enemy.team) && enemy.team == "axis"
        && isDefined(enemy.is_suicide_bomber) && enemy.is_suicide_bomber
        && isDefined(enemy.is_reserved) && enemy.is_reserved
        && isDefined(enemy.health) && enemy.health > 0 && isDefined(enemy.origin);
}

running(job)
{
    return isDefined(job) && isDefined(job.state) && (job.state == "Active" || job.state == "Cancelling");
}

outcome(state, job, authorized, expired)
{
    if (job.state == "Cancelling")
        return "Cancelled";
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    // A full death counter still leaves the native spawn loop and final wait to finish
    if (step > 9)
        return "Completed";
    if (!authorized || step != 9 || sequence_reason(state) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

status(state)
{
    if (!isDefined(state.apparition_bomber_job))
        return "Idle";
    job = state.apparition_bomber_job;
    native = progress(state);
    if (job.state == "Active" && native.kills >= native.goal)
        return "Waiting for native advance";
    return job.state;
}


start(player)
{
    if (running(level.apparition_bomber_job) || reason(level) != "" || !scripts\apparition\runtime\context::living_host(player))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.state = "Active";
    // Reserve before starting a worker so another menu cannot admit the same job
    level.apparition_bomber_job = job;
    level thread scripts\apparition\maps\spaceland\bomber_worker::run(job);
    return true;
}

cancel()
{
    job = level.apparition_bomber_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    // Keep the reservation until the worker has stopped submitting damage
    job.state = "Cancelling";
    return true;
}
