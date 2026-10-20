// The native speaker activation owns placement geometry, models and wave setup

spot(state)
{
    if (!isDefined(state.current_interaction_structs))
        return undefined;
    selected = undefined;
    foreach (location in state.current_interaction_structs)
    {
        if (!isDefined(location) || !isDefined(location.script_noteworthy) || location.script_noteworthy != "dj_quest_speaker")
            continue;
        // Native setup exposes one selected spot; ambiguity disables the action
        if (isDefined(selected) || !isDefined(location.origin))
            return undefined;
        selected = location;
    }
    return selected;
}

blocked(location)
{
    return isDefined(location.apparition_speaker_placement) || isDefined(location.triggered)
        || isDefined(location.cooling_down) || isDefined(location.post_activate_update)
        || (isDefined(location.in_use) && location.in_use)
        || (isDefined(location.disabled) && location.disabled)
        || (isDefined(location.out_of_order) && location.out_of_order);
}

reason(state, own_job)
{
    hint = scripts\apparition\maps\spaceland\speakers::context_reason(state);
    if (hint != "")
        return hint;
    if (!state.flag["dj_request_defense_done"] || !state.flag["defend_sequence"])
        return "Request or retry this speaker defense from the DJ first";
    if (isDefined(state.current_speaker)
        || (isDefined(state.flag["defense_sequence_active"]) && state.flag["defense_sequence_active"]))
        return "A native speaker defense is already active";
    if ((isDefined(state.spawn_event_running) && state.spawn_event_running)
        || (isDefined(state.flag["pause_wave_progression"]) && state.flag["pause_wave_progression"]))
        return "Wait for the native wave or previous defense cleanup";
    if (isDefined(state.apparition_speaker_placement) && state.apparition_speaker_placement.state == "Placing"
        && (!isDefined(own_job) || state.apparition_speaker_placement != own_job))
        return "Native speaker placement is already being observed";
    if (!isDefined(state.interactions) || !isDefined(state.interactions["dj_quest_speaker"]))
        return "The native speaker interaction is not registered";
    entry = state.interactions["dj_quest_speaker"];
    if (!isDefined(entry.enabled) || !entry.enabled || !isDefined(entry.name) || entry.name != "dj_quest_speaker"
        || !isDefined(entry.cost) || entry.cost != 0 || !isDefined(entry.spend_type) || entry.spend_type != "quest"
        || !isDefined(entry.activation_func) || entry.activation_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::start_defense_sequence
        || !isDefined(entry.init_func) || entry.init_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::init_dj_speaker)
        return "The native zero-cost speaker interaction has changed";
    selected = spot(state);
    if (!isDefined(selected) || blocked(selected))
        return "Wait for one available native speaker location";
    return "";
}

actor_reason(player, selected)
{
    if (!scripts\apparition\runtime\context::living_host(player))
        return "The host must be alive, out of last stand and in a supported private session";
    if (!isDefined(selected) || !isDefined(player.disabled_interactions)
        || scripts\engine\utility::array_contains(player.disabled_interactions, selected)
        || !player scripts\cp\cp_interaction::can_use_interaction(selected))
        return "Wait until the game allows the host to place the speaker";
    if (!isDefined(player scripts\cp\maps\cp_zmb\cp_zmb_dj::can_place_speaker(selected)))
        return "Stand on level ground near the selected height with clear placement space";
    return "";
}

reserve(selected)
{
    if (blocked(selected))
        return undefined;
    lease = spawnstruct();
    lease.spot = selected;
    lease.prior_in_use = selected.in_use;
    selected.apparition_speaker_placement = lease;
    selected.in_use = 1;
    return lease;
}

release(lease)
{
    selected = lease.spot;
    if (isDefined(selected.apparition_speaker_placement) && selected.apparition_speaker_placement == lease)
    {
        // A later writer keeps any admission value that differs from this lease
        if (isDefined(selected.in_use) && selected.in_use == 1)
            selected.in_use = lease.prior_in_use;
        selected.apparition_speaker_placement = undefined;
    }
    lease.spot = undefined;
}

start(player)
{
    if (reason(level) != "")
        return false;
    selected = spot(level);
    if (actor_reason(player, selected) != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    job.spot = selected;
    job.state = "Placing";
    level.apparition_speaker_placement = job;
    level thread run(job);
    return true;
}

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.spot = undefined;
    job.state = result;
    if (isDefined(owner) && result != "Placed")
        owner iPrintLn("Speaker placement not confirmed; current native state remains visible");
}

perform(job)
{
    // The worker keeps its published reservation during final native admission
    if (level.apparition_speaker_placement != job || job.state != "Placing" || reason(level, job) != ""
        || spot(level) != job.spot || actor_reason(job.owner, job.spot) != ""
        || !scripts\cp\cp_interaction::interaction_is_valid(job.spot, job.owner))
        return "Unavailable";
    lease = reserve(job.spot);
    if (!isDefined(lease))
        return "Unavailable";
    // Stock zero-cost wrapper effects precede the native activation
    job.owner thread scripts\cp\cp_interaction::interaction_post_activate_delay(job.spot);
    level notify("interaction", "purchase", level.interactions["dj_quest_speaker"], job.owner);
    job.owner thread scripts\cp\cp_interaction::take_player_money(0, "quest");
    // Level ownership preserves lease release if the initiating actor disconnects
    level scripts\cp\maps\cp_zmb\cp_zmb_dj::start_defense_sequence(job.spot, job.owner);
    release(lease);
    return isDefined(level.flag["defense_sequence_active"]) && level.flag["defense_sequence_active"]
        && scripts\apparition\maps\spaceland\speakers::model_valid(level.current_speaker) ? "Placed" : "Pending";
}
