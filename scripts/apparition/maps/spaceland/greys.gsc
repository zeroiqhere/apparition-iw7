// One fight reservation supports either fuse-only or complete native damage input

reason(state, full_fight)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 10)
        return "The UFO quest is not on its Grey boss stage";
    hint = sequence_reason(state);
    if (hint != "" || !full_fight)
        return hint;
    watch = state.apparition_grey_sequence;
    if (scripts\apparition\maps\spaceland\grey_sequence::tracked(state, watch) && watch.state == "Ended")
        return "Wait for native Grey fight cleanup to advance the quest";
    if (!scripts\apparition\maps\spaceland\grey_sequence::owned(state, watch))
        return "Full fight assist needs the unchanged native callback observed before this stage";
    if (watch.state != "Ready")
        return "Wait for the entire native initial Grey spawn sequence to return";
    if (isDefined(state.explosive_touch) && state.explosive_touch)
        return "The native damage gate currently blocks ordinary Grey hits";
    return "";
}

sequence_reason(state)
{
    if (!isDefined(state.flag) || !isDefined(state.flag["pause_wave_progression"]) || !state.flag["pause_wave_progression"]
        || !isDefined(state.flag["tones_played_successfully"]) || !state.flag["tones_played_successfully"])
        return "Wait for the native UFO sequence to hold the wave";
    if (!isDefined(state.grey_on_killed_func) || state.grey_on_killed_func != scripts\cp\maps\cp_zmb\cp_zmb_ufo::grey_on_killed_func
        || !isDefined(state.greygetmeleedamagedfunc) || state.greygetmeleedamagedfunc != scripts\cp\maps\cp_zmb\cp_zmb_ufo::remove_alien_fuse
        || !isDefined(state.greysetupfunc) || state.greysetupfunc != scripts\cp\maps\cp_zmb\cp_zmb_ufo::attach_alien_fuse)
        return "The native Spaceland Grey callbacks are not registered";
    if (!isDefined(state.spawned_grey))
        return "Wait for the first native Grey registration";
    return "";
}

identity(enemy)
{
    return isDefined(enemy) && isDefined(enemy.agent_type) && enemy.agent_type == "zombie_grey"
        && isDefined(enemy.team) && enemy.team == "axis"
        && isDefined(enemy.is_reserved) && enemy.is_reserved
        && isDefined(enemy.health) && enemy.health > 0;
}

body_eligible(enemy)
{
    // Clones share the native fight roster but never receive fuse handling
    return identity(enemy) && isDefined(enemy.origin) && isDefined(enemy.maxhealth) && enemy.maxhealth > 0
        && (!isDefined(enemy.is_regening_health) || !enemy.is_regening_health);
}

full_fight(job)
{
    return isDefined(job.full_fight) && job.full_fight;
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
    // Only native quest advancement completes the menu's stage checkbox
    if (step > 10)
        return "Completed";
    if (!authorized || step != 10 || sequence_reason(state) != "")
        return "Unavailable";
    if (full_fight(job) && (!scripts\apparition\maps\spaceland\grey_sequence::tracked(state, job.watch)
        || (job.watch.state != "Ready" && job.watch.state != "Ended")))
        return "Unavailable";
    return expired ? "Pending" : "";
}

can_submit(state, job, ordinary)
{
    if (ordinary && !full_fight(job))
        return false;
    if (full_fight(job) && (!scripts\apparition\maps\spaceland\grey_sequence::owned(state, job.watch) || job.watch.state != "Ready"))
        return false;
    // The native damage callback rejects MOD_UNKNOWN Greys while this field is true
    return !ordinary || !isDefined(state.explosive_touch) || !state.explosive_touch;
}


start(player, full_fight)
{
    if (running(level.apparition_grey_job) || reason(level, full_fight) != "" || !scripts\apparition\runtime\context::living_host(player))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.full_fight = full_fight;
    if (full_fight)
        job.watch = level.apparition_grey_sequence;
    job.state = "Active";
    // Both modes reserve the same worker before its first scheduled frame
    level.apparition_grey_job = job;
    level thread scripts\apparition\maps\spaceland\grey_worker::run(job);
    return true;
}

cancel()
{
    job = level.apparition_grey_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    job.state = "Cancelling";
    return true;
}

status(state)
{
    job = state.apparition_grey_job;
    if (!isDefined(job))
        return "Idle";
    if (job.state != "Active")
        return job.state;
    if (!full_fight(job))
        return "Active: exposed fuses only";
    if (job.watch.state == "Ended")
        return "Observing native quest cleanup";
    return isDefined(state.explosive_touch) && state.explosive_touch ? "Active: native gate pauses body hits" : "Active: full fight";
}
