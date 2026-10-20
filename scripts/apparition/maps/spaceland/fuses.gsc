// Dropped-fuse collection leaves inventory, interaction lists and model cleanup to the game

progress(state)
{
    progress = spawnstruct();
    progress.held = isDefined(state.num_fuse_in_possession) ? state.num_fuse_in_possession : -1;
    progress.inserted = isDefined(state.flag) && isDefined(state.flag["fuses_inserted"]) && state.flag["fuses_inserted"];
    return progress;
}

spot(state, name)
{
    if (!isDefined(state.struct_class_names) || !isDefined(state.struct_class_names["script_noteworthy"]))
        return undefined;
    spots = state.struct_class_names["script_noteworthy"][name];
    // Native getStruct accepts only one registered match
    if (!isDefined(spots) || spots.size != 1 || !isDefined(spots[0])
        || !isDefined(spots[0].script_noteworthy) || spots[0].script_noteworthy != name)
        return undefined;
    return spots[0];
}

context_reason(state)
{
    native = scripts\apparition\maps\spaceland\quest::progress(state);
    if (native.step != 11 || native.finished)
        return "Alien fuse controls require the final UFO stage";
    if (!isDefined(state.flag) || !isDefined(state.flag["fuses_inserted"]) || progress(state).held < 0)
        return "Wait for the native fuse inventory to initialize";
    if (!isDefined(state.interactions) || !isDefined(state.interactions["pap_upgrade"]))
        return "The native fuse insertion interaction is not registered";
    entry = state.interactions["pap_upgrade"];
    if (!isDefined(entry.activation_func) || entry.activation_func != scripts\cp\maps\cp_zmb\cp_zmb_ufo::upgrade_pap
        || !isDefined(entry.can_use_override_func) || entry.can_use_override_func != scripts\cp\maps\cp_zmb\cp_zmb_ufo::can_use_pap_upgrade
        || !isDefined(entry.enabled) || !entry.enabled)
        return "The native fuse insertion interaction is not ready";
    if (!isDefined(state.current_interaction_structs) || !isDefined(spot(state, "pap_upgrade"))
        || !isDefined(spot(state, "weapon_upgrade")))
        return "The native Pack-a-Punch interactions are not ready";
    return "";
}

reason(state)
{
    reason = context_reason(state);
    if (reason != "")
        return reason;
    native = progress(state);
    if (native.inserted)
        return "The alien fuses are already inserted";
    if (native.held > 0)
        return "The dropped alien fuses are already collected";
    if (isDefined(state.apparition_fuse_pickup_job) && isDefined(state.apparition_fuse_pickup_job.submitted)
        && state.apparition_fuse_pickup_job.submitted)
        return "Pickup already requested; use the normal pickup if the pair remains";
    return "";
}

native_pickup()
{
    // Only the first dropped model owns the native pickup listener
    return scripts\apparition\maps\spaceland\pickup_models::select(getEntArray("script_model", "classname"), "park_alien_gray_fuse", [(657, 765, 105)]);
}

outcome(state, pickup, authorized, expired)
{
    native = progress(state);
    if (!isDefined(pickup))
    {
        // A teammate may insert the pair before this observer reads possession
        if (native.inserted)
            return "Collected";
        if (native.held > 0 && isDefined(state.current_interaction_structs)
            && isDefined(spot(state, "pap_upgrade")) && isDefined(spot(state, "weapon_upgrade"))
            && scripts\engine\utility::array_contains(state.current_interaction_structs, spot(state, "pap_upgrade"))
            && !scripts\engine\utility::array_contains(state.current_interaction_structs, spot(state, "weapon_upgrade")))
            return "Collected";
    }
    if (!authorized || context_reason(state) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

running(job)
{
    return isDefined(job) && isDefined(job.state) && job.state == "Collecting";
}


start(player)
{
    if (running(level.apparition_fuse_pickup_job) || reason(level) != "" || !scripts\apparition\runtime\context::living_host(player))
        return false;
    pickup = native_pickup();
    if (!isDefined(pickup))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.pickup = pickup;
    job.state = "Collecting";
    // Reserve before starting the level thread; closing the HUD cannot cancel cleanup
    level.apparition_fuse_pickup_job = job;
    level thread scripts\apparition\maps\spaceland\fuse_pickup_worker::run(job);
    return true;
}
