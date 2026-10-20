// Native death bookkeeping and the next regular-wave event own quest progress

progress(state)
{
    progress = spawnstruct();
    progress.wave = isDefined(state.wave_num) ? state.wave_num : -1;
    progress.kills = isDefined(state.current_enemy_deaths) ? state.current_enemy_deaths : -1;
    progress.goal = isDefined(state.desired_enemy_deaths_this_wave) ? state.desired_enemy_deaths_this_wave : -1;
    return progress;
}

context_reason(state)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 5)
        return "The UFO quest is not on its native wave-wait stage";
    entry = state._id_13F4D["ufo"][5];
    if (!isDefined(entry.init_func) || entry.init_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::blank
        || !isDefined(entry._id_DB5D) || entry._id_DB5D != scripts\cp\maps\cp_zmb\cp_zmb_dj::wait_one_wave
        || !isDefined(entry._id_446D) || entry._id_446D != scripts\cp\maps\cp_zmb\cp_zmb_dj::blank)
        return "The native wave-wait callbacks have changed";
    if (!isDefined(state.spawnloopupdatefunc)
        || state.spawnloopupdatefunc != scripts\cp\zombies\zombies_spawning::_id_12E29
        || !scripts\apparition\maps\spaceland\zombie_targets::death_path(state, "generic_zombie"))
        return "The native countable-death callbacks are not active";
    native = progress(state);
    if (native.wave < 0 || native.kills < 0 || native.goal < 0 || !isDefined(state.spawned_enemies)
        || !isDefined(state.spawn_event_running) || !isDefined(state.flag) || !isDefined(state.flag["pause_wave_progression"]))
        return "Wait for the native wave roster and counters to initialize";
    return "";
}

paused(state)
{
    return state.flag["pause_wave_progression"]
        || (isDefined(state.zombies_paused) && state.zombies_paused)
        || (isDefined(state.nuke_zombies_paused) && state.nuke_zombies_paused);
}

event_supported(state)
{
    // The default selector chooses goon; a foreign selector has no known target policy
    return !isDefined(state.available_event_func) && !isDefined(state.special_zombie_spawn_func)
        && !isDefined(state.event_funcs_init) && !isDefined(state.event_funcs_start) && !isDefined(state.event_funcs_end)
        && (!isDefined(state.goon_spawner_patch_func)
            || state.goon_spawner_patch_func == scripts\cp\maps\cp_zmb\cp_zmb::cp_zmb_goon_spawner_patch_func)
        && isDefined(state.event_funcs)
        && isDefined(state.event_funcs["goon"])
        && state.event_funcs["goon"] == scripts\cp\zombies\zombies_spawning::goon_spawn_event_func
        && scripts\apparition\maps\spaceland\zombie_targets::death_path(state, "zombie_clown");
}

reason(state)
{
    hint = context_reason(state);
    if (hint != "")
        return hint;
    previous = state.apparition_wave_job;
    // Receipt history outlives the listener and cannot be reset by cancellation
    if (isDefined(previous) && isDefined(previous.regular_event))
        return "A regular wave was observed; wait for native quest advancement";
    // A retry cannot adopt the next regular round while its listener is catching up
    if (isDefined(previous) && state.wave_num != previous.wave && !state.spawn_event_running)
        return "The native wave changed; wait for quest advancement";
    if (paused(state))
        return "Wait for native wave progression and spawning to resume";
    if (state.spawn_event_running && !event_supported(state))
        return "This event-wave callback is unknown; clear it normally";
    return "";
}

can_submit(state, job, ticket)
{
    if (job.state != "Active" || ticket.state != "Armed" || paused(state)
        || state.current_enemy_deaths >= state.desired_enemy_deaths_this_wave)
        return false;
    // The wave number protects a new regular round even if its listener runs later
    if (state.wave_num != job.wave && !state.spawn_event_running)
        return false;
    return !state.spawn_event_running || event_supported(state);
}

running(job)
{
    return isDefined(job) && isDefined(job.state)
        && (job.state == "Active" || job.state == "Observing native advance" || job.state == "Cancelling");
}

outcome(state, job, authorized, expired)
{
    if (job.state == "Cancelling")
        return "Cancelled";
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    // Neither a full quota nor an observed regular-wave event can replace this evidence
    if (step > 5)
        return "Completed";
    if (!authorized || context_reason(state) != "" || state.wave_num < job.wave)
        return "Unavailable";
    return expired ? "Pending" : "";
}

status(state)
{
    job = state.apparition_wave_job;
    if (!isDefined(job))
        return "Idle";
    if (job.state != "Active")
        return job.state;
    if (context_reason(state) != "")
        return "Native wave context changed";
    if (paused(state))
        return "Waiting for native spawning and progression";
    // The same quota gate stops packets before the event loop returns
    if (state.current_enemy_deaths >= state.desired_enemy_deaths_this_wave)
        return "Waiting for the next regular-wave event";
    if (state.spawn_event_running)
        return event_supported(state) ? "Clearing native event round" : "Waiting for an unsupported event round";
    if (state.wave_num != job.wave)
        return "Waiting for the next regular-wave event";
    return "Clearing eligible wave enemies";
}

start(player)
{
    if (running(level.apparition_wave_job) || reason(level) != ""
        || !scripts\apparition\runtime\context::living_host(player))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.wave = level.wave_num;
    job.state = "Active";
    // One level reservation survives HUD closure and precedes listener registration
    level.apparition_wave_job = job;
    level thread scripts\apparition\maps\spaceland\wave_worker::run(job);
    return true;
}

cancel()
{
    job = level.apparition_wave_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    // The worker retains the reservation until its listener and owner are released
    job.state = "Cancelling";
    return true;
}
