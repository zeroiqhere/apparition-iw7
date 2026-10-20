// Native timer and pickup cleanup own speaker success and quest progression

context_reason(state)
{
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    if (step < 2 || step > 4)
        return "The UFO quest is not on a speaker-defense stage";
    initializers = [scripts\cp\maps\cp_zmb\cp_zmb_dj::init_first_speaker_defense, scripts\cp\maps\cp_zmb\cp_zmb_dj::init_second_speaker_defense, scripts\cp\maps\cp_zmb\cp_zmb_dj::init_third_speaker_defense];
    bodies = [scripts\cp\maps\cp_zmb\cp_zmb_dj::do_first_speaker_defend, scripts\cp\maps\cp_zmb\cp_zmb_dj::do_second_speaker_defend, scripts\cp\maps\cp_zmb\cp_zmb_dj::do_third_speaker_defend];
    entry = state._id_13F4D["ufo"][step];
    completion = step == 4 ? scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_all_speaker_defense : scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    if (!isDefined(entry.init_func) || entry.init_func != initializers[step - 2]
        || !isDefined(entry._id_DB5D) || entry._id_DB5D != bodies[step - 2]
        || !isDefined(entry._id_446D) || entry._id_446D != completion)
        return "The native speaker quest callbacks have changed";
    if (!isDefined(state.flag) || !isDefined(state.flag["defend_sequence"])
        || !isDefined(state.flag["dj_request_defense_done"]))
        return "Wait for native speaker quest initialization";
    if (!isDefined(state.frequency_device_clip) || !isDefined(state.frequency_device_clip.origin)
        || !isDefined(state.frequency_device_clip.originalloc))
        return "The native speaker defense clip is not initialized";
    return "";
}

model_valid(model)
{
    return isDefined(model) && isDefined(model.model) && model.model == "zmb_frequency_device"
        && isDefined(model.origin) && isDefined(model.hit_point_left) && model.hit_point_left > 0;
}

reason(state)
{
    hint = context_reason(state);
    if (hint != "")
        return hint;
    if (!state.flag["defend_sequence"] || !state.flag["dj_request_defense_done"]
        || !isDefined(state.flag["defense_sequence_active"]) || !state.flag["defense_sequence_active"]
        || !isDefined(state.flag["pause_wave_progression"]) || !state.flag["pause_wave_progression"])
        return "Place the requested speaker and wait for its native defense to start";
    if (!isDefined(state.use_dj_door_func)
        || state.use_dj_door_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_during_speaker_defense
        || !model_valid(state.current_speaker))
        return "The current native speaker is not available for defense assistance";
    return "";
}

can_attack(state, job)
{
    return job.state == "Defending" && assist_reason(state) == ""
        && state.current_speaker == job.defense.speaker && state.frequency_device_clip == job.defense.clip;
}

assist_reason(state)
{
    hint = reason(state);
    if (hint != "")
        return hint;
    capture = state.apparition_speaker_capture;
    // Combat and pickup share the actual captured model and its existing listener
    if (!scripts\apparition\maps\spaceland\speaker_history::listening(capture)
        || capture.speaker != state.current_speaker || capture.clip != state.frequency_device_clip
        || capture.step != scripts\apparition\maps\spaceland\quest::current_step(state))
        return "Wait for the native speaker capture listener to become ready";
    return "";
}

eligible(enemy, clip)
{
    // Native assignment links the attacker to this exact defense target
    return isDefined(enemy) && isDefined(clip)
        && (!isDefined(enemy.agent_type) || enemy.agent_type != "zombie_brute")
        && isDefined(enemy.species) && enemy.species == "zombie"
        && isDefined(enemy.team) && enemy.team == "axis"
        && isDefined(enemy.health) && enemy.health > 0 && isDefined(enemy.origin)
        && isDefined(enemy.active_speaker_attacker) && enemy.active_speaker_attacker
        && isDefined(enemy.favoriteenemy) && enemy.favoriteenemy == clip;
}

pickup_reason(state, capture)
{
    hint = context_reason(state);
    if (hint != "")
        return hint;
    // The native success callback no longer exposes current_speaker for discovery
    if (!isDefined(capture) || !isDefined(state.apparition_speaker_capture)
        || state.apparition_speaker_capture != capture || !model_valid(capture.speaker)
        || scripts\apparition\maps\spaceland\quest::current_step(state) != capture.step
        || state.frequency_device_clip != capture.clip)
        return "No live speaker was recorded during this defense; use the normal pickup";
    // A receipt blocks input immediately, before the history owner next samples it
    if (!isDefined(capture.submitted) || capture.submitted
        || (isDefined(capture.ticket) && capture.ticket.state == "Received"))
        return "Speaker pickup already requested; use the normal pickup if it remains";
    if (!isDefined(capture.ticket) || capture.ticket.state != "Armed")
        return "Speaker pickup listener unavailable; use the normal pickup";
    // Native success clears current_speaker before exit enables its pickup wait
    if (isDefined(state.current_speaker) || !isDefined(state.flag["defense_sequence_active"])
        || state.flag["defense_sequence_active"] || !isDefined(state.use_dj_door_func)
        || state.use_dj_door_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer)
        return "Finish the native speaker defense before collecting its model";
    return "";
}

pickup_ready(state, job)
{
    return (job.state == "Defending" || job.state == "Awaiting pickup")
        && pickup_reason(state, job.defense) == "";
}

claim_pickup(state, job)
{
    if (!pickup_ready(state, job))
        return false;
    // The capture survives job cleanup and prevents a retry of ambiguous input
    job.defense.submitted = true;
    job.state = "Collecting";
    return true;
}

running(job)
{
    return isDefined(job) && isDefined(job.state) && (job.state == "Defending" || job.state == "Awaiting pickup" || job.state == "Collecting"
        || job.state == "Observing native advance" || job.state == "Cancelling");
}

outcome(state, job, authorized, expired)
{
    if (job.state == "Cancelling")
        return "Cancelled";
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    // Timer success and pickup deletion still leave a native wave wait
    if (step > job.defense.step)
        return "Completed";
    if (!authorized || step != job.defense.step || context_reason(state) != "" || state.frequency_device_clip != job.defense.clip)
        return "Unavailable";
    if (isDefined(state.flag["defense_sequence_active"]) && !state.flag["defense_sequence_active"]
        && isDefined(state.use_dj_door_func)
        && state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense)
        return "Failed";
    if (isDefined(state.current_speaker) && state.current_speaker != job.defense.speaker)
        return "Unavailable";
    return expired ? "Pending" : "";
}

start(player, pickup_only)
{
    if (running(level.apparition_speaker_job)
        || !scripts\apparition\runtime\context::living_host(player))
        return false;
    capture = level.apparition_speaker_capture;
    hint = pickup_only ? pickup_reason(level, capture) : assist_reason(level);
    if (hint != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    // Jobs borrow the identity record rather than copying model, clip and stage
    job.defense = capture;
    job.state = pickup_only ? "Awaiting pickup" : "Defending";
    // Reserve the captured defense before starting its level-owned worker
    level.apparition_speaker_job = job;
    level thread scripts\apparition\maps\spaceland\speaker_worker::run(job);
    return true;
}

cancel()
{
    job = level.apparition_speaker_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    job.state = "Cancelling";
    return true;
}
